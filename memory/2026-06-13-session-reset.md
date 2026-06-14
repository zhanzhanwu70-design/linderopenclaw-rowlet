# 2026-06-13 Session reset note

Linder requested clearing/reopening current rowlet Discord channel session so it stops using `gpt-5.5` and picks default `MiniMax-M2.7`.

Evidence before reset from `openclaw status`:
- Current session: `agent:rowlet:discord:channel:1482363974119854234`
- Model before reset: `gpt-5.5`
- Overall sessions default: `MiniMax-M2.7`

Important recent work preserved:
- HCS judgment map raw: `raw/references/minerva-hcs-judgment-map-2026-06-13/`
- HCS public name list raw: `raw/references/minerva-hcs-full-list-search-2026-06-13/`
- Wiki pages:
  - `wiki/synthesis/hcs-judgment-map.md`
  - `wiki/concepts/hcs-minimal-judgment-checklist.md`
  - `wiki/sources/minerva-hcs-public-name-list.md`
- HCS Graphify subgraph: `.graphify-hcs/.graphify/`

User preference/order: rowlet should use MiniMax only; avoid OpenAI model/API, do not read OpenAI key, no OpenAI Whisper/API.
