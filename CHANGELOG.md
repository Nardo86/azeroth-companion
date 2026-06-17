# Changelog

All notable changes to this project are documented here.
This project adheres to [Semantic Versioning](https://semver.org/).

## [0.4.0] - 2026-06-17

### Added
- **Richer quest coordinates from Questie/pfQuest**: each objective/turn-in spot
  now carries a `count` (number of known spawn points) as a density hint, so the
  assistant can steer you to the quickest, least-scattered objectives instead of
  ranking purely by XP. The helper now prefers spawns in your current zone and
  flags objectives that are in another zone. Quests detected as part of a chain
  are marked `chain: true` so they are not suggested as skippable for XP.
- Leveling guidance reworked accordingly: dungeon and long fetch/escort quests
  are now flagged as time-costly rather than always recommended.
- **XP-to-level in context** (`player.xp`: `cur`/`max`/`toLevel`/`rested`, absent
  at max level) via `Compat.GetXP`, so advice can be measured against the actual
  XP remaining instead of a vague level estimate.
- **Computed guidance block**: the companion now does the math deterministically
  and injects an authoritative `COMPUTED` block the model just narrates —
  effective quest XP at the realm rate, each quest as a % of the level, how many
  quests cover the level, which gray quests are skippable (chains excluded), and
  in-zone objective **clusters with compass bearings** computed from the player's
  position. Directions are no longer left to the model to guess.

## [0.3.0] - 2026-06-15

### Added
- **In-game local boss tips** (`/ac boss`): role-specific dungeon/raid advice
  served straight from the addon — no `/reload`, no companion, no LLM — so it's
  safe to use mid-pull. Matches the current instance + target (or a typed name)
  against the bundled knowledge base and highlights your role. `/ac boss all`
  shows every role; `/ac boss <name>` looks one up by name.
- `Core/KnowledgeData.lua`, generated from `companion/knowledge/*.json` by
  `tools/gen_knowledge_lua.py` so the boss data stays single-sourced (the
  companion reads the JSON to ground the LLM; the addon reads the baked Lua).
  Lookup logic mirrors the companion's `KnowledgeBase` for consistent answers.
- **First-run setup nudges**: the greeting now points out `/ac lang` and
  `/ac xp` while they're still at defaults (neither is auto-detectable — the
  client locale drives `auto` language, and no API exposes a realm's XP rate).

### Fixed
- Addon `.toc` version was left at 0.1.0 in the 0.2.0 release; all client
  flavors and the companion now report a single, aligned version.

## [0.2.0] - 2026-06-14

### Added
- **Multiple endpoints with automatic fallback** (#2): configure an `endpoints`
  list and the companion tries them in order, failing over to the next on any
  error (rate limit, `403`/Cloudflare, timeout, network). Per-endpoint overrides
  for `model`/`temperature`/`max_tokens`/`request_timeout`/`http_referer`/
  `x_title`. Non-last endpoints fail over fast (≤30s); the last one uses its full
  `request_timeout` and retries `429` honouring `Retry-After` (clamped to 30s).
  Each entry carries its own key — the top-level key is never sent to a
  different host. The single-endpoint config form keeps working unchanged.

### Fixed
- **Groq/Cloudflare 403** (#1): always send a real `User-Agent` header.
  Cloudflare blocks the stdlib default (`Python-urllib/x.y`) with HTTP 403 /
  error 1010, which looked like a bad API key. A 403 is no longer reported as a
  definite auth error — only 401 is; 403s surface the upstream body and flag
  likely firewall blocks.
- Read timeouts now report a clear "Timed out …" message instead of a generic
  "Unexpected error".

### Changed
- **Groq is now the recommended/default provider** (its free tier is steadier
  than OpenRouter's `:free` models): docs, `config.example.json`, the built-in
  default config and `--list-presets` all lead with Groq.

## [0.1.0] - 2026-06-14

Initial release.

### Added
- In-game chat window addon (`/ac`) with quest, dungeon and raid help.
- Cross-version compatibility layer (`Core/Compat.lua`) targeting WotLK 3.3.5a
  first, with `.toc` files for Wrath/Cata Classic, retail, TBC and Vanilla.
- Live context snapshot (quest log, position, target, role, instance, group).
- Optional runtime integration with Questie and pfQuest for coordinates,
  auto-selected per client version (Questie preferred, then pfQuest); never
  bundled, so it stays version-agnostic without shipping any helper's data.
- Role detection (talent-tab inference on 3.3.5, `GetSpecialization` on retail)
  with `/ac role` override.
- High-XP-server quest optimization guidance via `/ac xp <n>`.
- File-bridge transport (Base64/JSON over SavedVariables outbox + `_Inbox.lua`
  inbox) with a reload-surviving state machine and a clipboard fallback mode.
- Companion app (Python, stdlib only): SavedVariables watcher, role/version/
  language-aware prompt builder, OpenAI-compatible client with retry/backoff,
  atomic inbox writes, request de-duplication.
- Endpoint presets for OpenRouter, Groq, Google Gemini and local Ollama.
- Bundled WotLK knowledge base: 16 dungeons (64 bosses) + 8 raids (39 bosses) +
  role/quest-flow general tips.
- Tests: Python unit + end-to-end (mock server) suite; Lua compile + wire-format
  interop check (`tools/lua_check.py`). CI workflows for tests and prebuilt
  companion binaries.
