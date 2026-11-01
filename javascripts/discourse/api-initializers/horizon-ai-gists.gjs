import Component from "@glimmer/component";
import { schedule } from "@ember/runloop";
import { service } from "@ember/service";
import bodyClass from "discourse/helpers/body-class";
import { apiInitializer } from "discourse/lib/api";

// Horizon's high-context card deletes core's TopicCell, taking with it both outlets
// discourse-ai renders gists into (topic-list-topic-cell-link-bottom-line__before on
// desktop, topic-list-main-link-bottom on mobile). `topic-list-after-title` is the only
// core outlet the card keeps, so the gist is rendered there instead.
//
// The attribute only exists when discourse-ai's serializer guard passes:
//   add_to_serializer(:topic_list_item, :ai_topic_gist,
//     include_condition: -> { scope.can_see_gists? })
// can_see_gists? needs ai_summarization_enabled + ai_summary_gists_enabled + an agent
// (ai_summary_gists_agent) whose allowed groups include the viewer's — or `everyone`
// for signed-out visitors. Backfill generates gists without consulting those groups,
// so the admin UI can show gists while every payload omits them. Check with:
//   fetch('/latest.json').then(r=>r.json()).then(d=>
//     console.log(d.topic_list.topics.filter(t=>'ai_topic_gist' in t).length))
//
// Plain text, kept escaped: it is LLM output. aria-hidden because the outlet sits inside
// Horizon's role="heading" title, whose accessible name would otherwise swallow the gist.
// Screen readers get the excerpt instead, which the stylesheet only hides visually.

// Category ids as strings: compared both to path segments and to topic.category_id.
// Client-side only — discourse-ai has no per-category scoping, so the gist is still
// generated and still sent; this suppresses rendering, not cost. Read on each use, not
// at import, so a changed setting (and the tests) take effect without a reload.
function isHiddenCategory(id) {
  return (settings.gist_hidden_categories || "")
    .split("|")
    .includes(String(id));
}

class HorizonAiGist extends Component {
  // Optional-chained: absent when discourse-ai is disabled.
  @service gists;

  // discourse-ai's layout preference: "table" (compact) or "table-ai". Unset counts as
  // show, so the excerpts/gists button is an opt-out.
  get show() {
    if (isHiddenCategory(this.args.topic?.category_id)) {
      return false;
    }
    return this.gists?.currentPreference !== "table";
  }

  <template>
    {{#if this.show}}
      <div
        class="horizon-ai-gist"
        aria-hidden="true"
      >{{@topic.ai_topic_gist}}</div>
    {{/if}}
  </template>
}

// Three modes, when the "Topic Excerpts & AI Gists Button" component is installed:
//   Compact  → gists "table",    prefersExcerpt false → titles only
//   Excerpts → gists "table",    prefersExcerpt true  → Horizon's excerpt, no gist
//   AI       → gists "table-ai", prefersExcerpt false → gist; excerpt only where no gist
// Without the button the preference stays "table-ai" and gists simply show.
class TopicListMode extends Component {
  @service gists;
  @service excerptState;

  get titlesOnly() {
    return (
      this.gists?.currentPreference === "table" &&
      !this.excerptState.prefersExcerpt
    );
  }

  <template>
    {{#if this.titlesOnly}}
      {{bodyClass "horizon-titles-only"}}
    {{/if}}
  </template>
}

// The category id comes from the URL (/c/<slug>/.../<id>) rather than a route model,
// so it also works on lists the discovery route does not own (docs categories).
function currentCategoryId() {
  const segments = window.location.pathname.split("/").filter(Boolean);
  if (segments[0] !== "c") {
    return null;
  }
  return segments.find((segment) => /^\d+$/.test(segment)) ?? null;
}

export default apiInitializer((api) => {
  // The button only labels a state "AI" when the stored preference is literally
  // "table-ai"; unset reads as Compact while gists show. Persist the default so the
  // label matches (this also makes gists the default on non-Horizon lists).
  const gists = api.container.lookup("service:gists");
  if (gists && !gists.currentPreference) {
    gists.setPreference("table-ai");
  }

  api.renderInOutlet("before-topic-list-body", TopicListMode);

  // Bare template on purpose: this form is known to receive @outletArgs; the topic is
  // then passed explicitly into the class component.
  api.renderInOutlet(
    "topic-list-after-title",
    <template>
      {{#if @outletArgs.topic.ai_topic_gist}}
        <HorizonAiGist @topic={{@outletArgs.topic}} />
      {{/if}}
    </template>
  );

  // Hidden categories lose the excerpt too (a title-only index), via a body class the
  // stylesheet keys on.
  api.onPageChange(() => {
    schedule("afterRender", () => {
      const id = currentCategoryId();
      document.body.classList.toggle(
        "horizon-no-gists",
        !!id && isHiddenCategory(id)
      );
    });
  });
});
