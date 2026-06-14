# Changelog

All notable changes to this project are documented here.
This project adheres to [Semantic Versioning](https://semver.org/).

## [0.1.0] - 2026-06-14

Initial release.

### Added
- In-game chat window addon (`/ac`) with quest, dungeon and raid help.
- Cross-version compatibility layer (`Core/Compat.lua`) targeting WotLK 3.3.5a
  first, with `.toc` files for Wrath/Cata Classic, retail, TBC and Vanilla.
- Live context snapshot (quest log, position, target, role, instance, group).
- Optional runtime integration with Questie for coordinates.
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
