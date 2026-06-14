# Credits & third-party

## Bundled in the addon

- **`Libs/json.lua`** — JSON for Lua by [rxi](https://github.com/rxi/json.lua),
  MIT License. Vendored with its license header intact.
- **`Libs/base64.lua`** — written for this project (MIT, see LICENSE).

> ⭐ If you find rxi/json.lua useful, consider starring the upstream repo — it's
> a small single-maintainer project we depend on.

## Used at runtime only (NOT bundled)

- **[Questie](https://github.com/Krigsgaldrnet/Questie-3.3.5)** — if installed,
  Azeroth Companion reads spawn/turn-in coordinates from Questie's *in-memory*
  database at runtime. We do **not** copy or redistribute Questie's code or
  database files. Questie's repository did not expose a clear top-level license
  at the time of writing; runtime interop is the low-risk path and the only one
  we use. If you maintain Questie and want this interop changed, please open an
  issue.
- **[pfQuest-wotlk](https://github.com/Bennylavaa/pfQuest-wotlk)** (GPLv3) — a
  possible alternative coordinate source; not currently integrated.

## Knowledge base

The dungeon/raid tips in `companion/knowledge/*.json` were compiled for the
Wrath of the Lich King (3.3.5 / WotLK Classic) version of the game, cross-checked
against community sources (Wowhead WotLK, warcraft.wiki.gg). They are concise,
original tactical summaries written for this project.

## Disclaimer

This is a fan-made project, **not affiliated with or endorsed by Blizzard
Entertainment**. World of Warcraft, Wrath of the Lich King and related marks are
trademarks of Blizzard Entertainment, Inc. Use on private servers is subject to
those servers' own rules — check that third-party addons/tools are permitted.
