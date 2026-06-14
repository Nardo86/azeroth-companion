# Architecture

```
addon/AzerothCompanion/        the in-game addon (Lua, WoW sandbox)
  *.toc                        one per client flavor (3.3.5 default + suffixed)
  Libs/
    json.lua                   rxi/json.lua (MIT) — JSON encode/decode
    base64.lua                 minimal Base64 for the wire format
  Core/
    Compat.lua                 ★ cross-version API abstraction (feature-detect)
    Config.lua                 SavedVariables, defaults, gameplay prefs
    Context.lua                builds the live situation snapshot
    Questie.lua                optional runtime read of Questie's coordinate DB
    Bridge.lua                 ★ outbox/inbox transport + reload state machine
    Init.lua                   events, slash commands, bootstrap
  UI/ChatFrame.lua             the movable chat window (pure Lua, cross-version)
  _Inbox.lua                   inbox stub, overwritten by the companion

companion/                     the helper app (Python 3, stdlib only)
  azeroth_companion.py         ★ watch SavedVariables → build prompt → call LLM → write inbox
  config.example.json          copy to config.json
  knowledge/                   bundled, verified WotLK tips (JSON)
    dungeons_wotlk.json        16 five-mans, 64 bosses
    raids_wotlk.json           8 raids, 39 bosses
    general_tips.json          role/dungeon/raid/quest-flow guidance
  tests/test_bridge.py         wire-format + prompt + end-to-end (mock server)

docs/                          this folder
```

## Design principles

1. **The sandbox is the boss.** Addons can't do HTTP/sockets/file-IO. Every
   design choice follows from that: a file bridge, a separate companion process,
   a turn-based reload round-trip. See [PROTOCOL.md](PROTOCOL.md).

2. **Ground the model, don't trust it blindly.** Static facts the model could
   hallucinate (boss mechanics, the player's current objectives) come from
   *real sources*: the live quest log via the API, Questie's DB for coordinates,
   and a bundled knowledge base for instances. The model synthesises and
   phrases; it doesn't invent coordinates (the prompt forbids it).

3. **Never call a version-specific API directly.** `Core/Compat.lua` is the
   single place that knows about client differences. It feature-detects
   (`C_QuestLog.GetInfo` vs `GetQuestLogTitle`, `C_Map` vs `GetPlayerMapPosition`,
   `GetSpecialization` vs talent-tab inference, `C_Timer.After` vs an OnUpdate
   timer). The rest of the addon calls `Compat.*` and stays version-agnostic.

4. **Two conflict-free lanes.** Outbox via SavedVariables (WoW writes, companion
   reads); inbox via a `.lua` in the addon folder (companion writes, WoW reads).
   Neither side can clobber the other. Base64(JSON) keeps it escaping-proof and
   prevents code injection.

5. **Robustness over cleverness.** Every Questie/optional-API access is
   `pcall`-guarded; a missing companion answer degrades to a "click Refresh"
   prompt; the companion dedupes by request id so reloads/restarts don't double-bill.

## Extending

- **Add a provider:** it only needs to speak OpenAI `/v1/chat/completions`. Set
  `endpoint`/`api_key`/`model`; add a preset in `PRESETS` if you like.
- **Improve quest coordinates without Questie:** implement a lookup in
  `Context.lua`/a new module and attach it as `quests[].questie`-shaped data.
- **Grow the knowledge base:** edit `companion/knowledge/*.json`
  (`name`, `aliases`, `bosses[].{tank,healer,dps,positioning}`). It's injected by
  `KnowledgeBase.format_for` when the instance name or a boss name is matched.
- **New client API quirk:** add a wrapper in `Core/Compat.lua`, never a raw call
  elsewhere.

## Testing

```bash
# Python (companion): wire format, prompt building, full mock-server round-trip
python -m unittest discover -s companion/tests

# Lua (addon): syntax + interop, needs the optional 'lupa' package
pip install --user lupa
python tools/lua_check.py      # see CI; compiles every .lua and round-trips the wire format
```
