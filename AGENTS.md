# Horizon AI Gists — agent guide

Rules for anyone changing this repo, people and AI agents alike. Org-wide conventions
(README, licenses, commits) are in the
[contributing guide](https://github.com/somos-criptonautas/.github/blob/main/CONTRIBUTING.md).

## Scope

A Discourse **theme component** for the Horizon theme. All work stays within:

```
javascripts/   ← api-initializer and the excerptState service (.gjs / .js)
common/        ← common.scss
locales/       ← en.yml, es.yml (always both)
settings.yml   ← theme settings
test/          ← QUnit acceptance tests
spec/          ← core features system spec
```

## What it depends on

- **discourse-ai's `ai_topic_gist`** on topic list items, present only when
  `Guardian#can_see_gists?` passes. No attribute means nothing renders, silently.
- **Horizon internals**: `.hc-topic-card`, `.--high-context`, the simple-card grid and the
  `topic-list-after-title` outlet. Horizon ships with core and changes often; after a core
  update, check `/latest`, a docs category and suggested topics.
- **discourse-ai's `gists` service** (optional-chained) and its layout preference
  (`"table"` / `"table-ai"`), shared with the Topic Excerpts & AI Gists Button.

## Gotchas

- `api.container` is the lookup container, not the owner: it has `lookup`, but no
  `register` or `hasRegistration`. Services go in `services/`.
- Never put mustache syntax inside a `{{! }}` template comment: it ends at the first
  closing braces and the rest spills onto the page. Keep notes in JS comments.
- The gist is LLM output: always `{{}}`, never `{{{}}}` or `htmlSafe`.
- Horizon's excerpt rule is `(0,3,0)`; ours need `.--high-context` to reach `(0,4,0)`
  instead of tying and losing on source order.
- Font sizes inside the card title use rem tokens: em tokens multiply by the title's
  inflated size.
- Theme settings are read on each use, not at import, so tests can change them.

## Checks

```bash
pnpm install && pnpm lint
```

CI runs lint, the QUnit tests in `test/` and the core features spec. Lint and tests run
without Horizon, so also install the component on a Horizon site and look at the page.

Screenshots in `docs/screenshots/` come from `spec/system/screenshots_spec.rb` via
Actions → Screenshots. That spec serializes a sample gist, so it shows the layout, not
real discourse-ai output.
