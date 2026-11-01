# Horizon AI Gists

**ENGLISH** | [ESPAÑOL](README.es.md)

Maintained by Criptonautas. Not affiliated with or endorsed by Discourse (Civilized Discourse Construction Kit, Inc.).

Shows [discourse-ai](https://meta.discourse.org/t/summarize-gists/340269) topic gists
(short AI summaries) on the [Horizon](https://meta.discourse.org/t/horizon-theme/360486)
theme's topic cards.

| Desktop | Mobile |
|---|---|
| ![Gists on Horizon cards, desktop](docs/screenshots/gists-desktop.png) | ![Gists on Horizon cards, mobile](docs/screenshots/gists-mobile.png) |

## Why

discourse-ai renders gists into two core outlets inside the topic cell. Horizon's
high-context card replaces that cell, so on Horizon gists never appear — which Discourse
treats as expected behaviour. This component renders the gist into
`topic-list-after-title`, the one core outlet the card keeps.

## What it does

- **High-context cards:** the gist sits under the title and replaces the excerpt.
  Topics without a gist keep their excerpt.
- **Simple cards** (suggested / related lists): discourse-ai's own gist is placed in the
  card's grid instead of breaking it into a column.
- **discourse-docs lists:** one blurb per row — the gist when there is one, otherwise the
  excerpt.
- **`gist_hidden_categories`:** categories that show neither gist nor excerpt, as a
  title-only index.

### Optional: three display modes

With [Topic Excerpts & AI Gists Button](https://meta.discourse.org/t/topic-excerpts-ai-gists-button/394885)
installed, members can switch between **Compact** (titles only), **Excerpts** and
**AI summaries**. That button expects an `excerptState` service it does not ship; this
component provides one — so don't install it alongside another component that defines
`excerptState`. Without the button, gists simply show.

## Requirements

- Discourse 2026.5.0 or later.

Gists only reach the browser when discourse-ai lets the viewer see them:

- `ai_summarization_enabled` and `ai_summary_gists_enabled` on.
- `ai_summary_gists_agent` set to an agent whose **allowed groups** include the viewer's
  group — add `everyone` to include signed-out visitors. An agent with no groups hides
  gists from everyone, even while the admin shows them as generated.
- Gists generated: `ai_summary_backfill_maximum_topics_per_hour` above 0.

Check from the browser console on `/latest` (non-zero means gists are arriving):

```js
fetch("/latest.json").then((r) => r.json()).then((d) =>
  console.log(d.topic_list.topics.filter((t) => t.ai_topic_gist).length)
);
```

## Limits

- **Built on Horizon internals** (`.hc-topic-card`, `.--high-context`, the simple-card
  grid). Discourse does not support customising Horizon's cards, so a Horizon update
  can break this.
- **Hiding is cosmetic.** discourse-ai has no per-category scoping: hidden gists are
  still generated and still sent in the topic list payload.
- **Not indexed.** Gists render client-side; search engines get Discourse's crawler view,
  which has excerpts but no gists.
- **Screen readers get the excerpt, not the gist.** The gist sits inside Horizon's title
  heading, so it is hidden from them to keep the heading short.
- **A stored preference stays.** The component sets each browser's discourse-ai layout
  preference to `table-ai` so gists show by default. Removing the component doesn't reset it.

## Install

**Admin → Appearance → Themes & components → Install**, from this repository's URL, then
add it to Horizon.

## Development

`pnpm install && pnpm lint`. CI also runs the QUnit tests in `test/` and the core
features spec. Contributor notes are in [AGENTS.md](AGENTS.md).

## License

MIT. See [LICENSE](LICENSE).

Text of this README under [CC BY-NC-SA 4.0](CC-BY-NC-SA-4.0.txt).
