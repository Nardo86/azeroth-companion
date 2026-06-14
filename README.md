# Azeroth Companion

**An in-game AI chatbot for World of Warcraft** that helps you with quests,
dungeons and raids — grounded in what you're *actually* doing right now (your
live quest log, location, target, role and instance), and powered by any
OpenAI-compatible model you choose (including **free** ones).

Built to work from **WotLK 3.3.5a** (Warmane & other private servers) up through
WotLK/Cata Classic and modern retail, via a runtime compatibility layer.

> ⚠️ **Read this first — the one thing that shapes everything:** WoW addons run
> in a sandbox with **no internet access** (no sockets, no HTTP, no file I/O).
> An addon *alone* can never call an AI API. Azeroth Companion therefore has two
> parts: the **in-game addon** and a tiny **companion app** that runs on your PC
> and does the network call for it. See [How it works](#how-it-works).

---

## Features

- 💬 **In-game chat window** — ask questions in natural language, get answers in
  a dedicated, movable window. Type `/ac` to open it.
- 🧭 **Quest help, grounded in your real quest log** — it reads your active
  quests, objectives and progress live from the game and tells you *what to
  kill, what to collect, who to talk to, and roughly where*. Never generic.
- 📍 **Coordinates via Questie or pfQuest (optional)** — if you run
  [Questie](https://github.com/Krigsgaldrnet/Questie-3.3.5) or
  [pfQuest](https://github.com/shagu/pfQuest), it borrows exact spawn/turn-in
  coordinates from their in-memory database at runtime (Questie preferred, then
  pfQuest). Reading the version's own helper keeps this version-agnostic. No
  helper? It falls back to directions by zone and landmarks.
- ⚔️ **Role-aware dungeon & raid coaching** — detects your spec/role (or lets
  you override it) and gives **tank / healer / DPS**-specific positioning and
  the mechanics that matter, backed by a bundled, verified WotLK knowledge base
  (every 5-man + all the raids: Naxx, Ulduar, ToC, ICC, RS, …).
- 🚀 **High-XP server quest optimization** — tell it your realm's XP rate
  (e.g. Warmane 5x with `/ac xp 5`) and it helps you decide which quests to
  **skip** (trivial/gray) versus **keep** (chain → reward/attunement/next-zone
  breadcrumb).
- 🔌 **Bring your own model** — OpenRouter, Groq, Google Gemini, or fully-local
  **Ollama** (offline, private, free). One config file: endpoint + key + model.
- 🌍 **Cross-version** — one addon, multiple `.toc`s and a runtime compat layer
  for 3.3.5a / Wrath Classic / Cata Classic / retail.
- 🗣️ **Replies in your language** — the UI is English; the bot answers in the
  language you set (`/ac lang it`, `en`, `es`, …). Defaults to your client locale.

---

## How it works

```
   ┌─────────────────────────┐         ┌──────────────────────────┐        ┌────────────┐
   │   WoW client (addon)     │         │   Companion app (PC)     │        │  LLM API   │
   │                          │         │                          │        │ (your key) │
   │ reads quest log / role / │  file   │ watches SavedVariables,  │  HTTPS │            │
   │ target / instance  ──────┼────────▶│ builds a role/version-   │───────▶│  model     │
   │ writes question+context  │ outbox  │ aware prompt, calls API  │◀───────│  answer    │
   │                          │         │                          │        └────────────┘
   │ shows the answer  ◀──────┼─────────┤ writes _Inbox.lua        │
   └─────────────────────────┘  file    └──────────────────────────┘
                                inbox
```

Because the sandbox blocks networking, the two halves talk through **files** —
the only channel available — using two conflict-free lanes:

- **Outbox (addon → companion):** the addon writes your question + a JSON
  snapshot of your situation into its **SavedVariables**, which WoW flushes to
  disk on `/reload`. The companion only *reads* this.
- **Inbox (companion → addon):** the companion writes the answer into
  `_Inbox.lua` inside the addon's own folder. WoW re-reads that file on the next
  `/reload` and **never overwrites it** (it only ever writes to `WTF/`), so the
  answer can't be clobbered.

Payloads are **Base64(JSON)** in both directions — robust, and the inbound file
contains *only data* (no executable Lua), so the companion can't inject code
into your client.

### The trade-off you should know about

On 3.3.5a this round-trip needs a **UI reload** to flush the question and
another to pick up the answer (the addon can do this for you automatically — a
brief screen flash). It's a *consultation tool*, not a real-time stream: ask,
wait a couple of seconds, read. This is inherent to the sandbox; there is no
way around it on an unmodified client. You can disable auto-reload (`/ac auto
off`) and fetch manually, or use the **clipboard mode** (`/ac paste`) for a
no-reload flow. (On **retail**, silent timer-driven reloads are restricted, so
manual/clipboard mode is recommended there.)

---

## Installation

**You need both parts.** Full per-OS details in [docs/INSTALL.md](docs/INSTALL.md).

### 1. The addon
Copy the folder `addon/AzerothCompanion` into your client's
`Interface/AddOns/` directory, so you end up with
`Interface/AddOns/AzerothCompanion/AzerothCompanion.toc`. Enable it on the
character screen (tick *Load out of date AddOns* on 3.3.5 if needed).

### 2. The companion app
- **Easiest:** download the prebuilt executable for your OS from the
  [Releases](https://github.com/Nardo86/azeroth-companion/releases) page,
  put it next to a `config.json`, and run it.
- **From source (needs Python 3.8+, no extra packages):**
  ```bash
  cd companion
  cp config.example.json config.json   # then edit it
  python3 azeroth_companion.py
  ```

### 3. Configure
Copy `companion/config.example.json` to `config.json` and set your
`endpoint`, `api_key`, `model`, and your `wow_installs` path. See
[docs/CONFIG.md](docs/CONFIG.md). Then launch the companion **while you play** —
keep it running in the background.

---

## Usage

| Command | What it does |
|---|---|
| `/ac` | Toggle the chat window |
| `/ac <question>` | Ask directly from the chat line |
| `/ac get` | Fetch a pending answer now (manual refresh) |
| `/ac role <auto\|tank\|healer\|dps>` | Override the detected role |
| `/ac xp <number>` | Set your realm's XP multiplier (e.g. `5`) |
| `/ac lang <auto\|it\|en\|…>` | Set the reply language |
| `/ac verbosity <short\|normal\|detailed>` | Answer length |
| `/ac auto <on\|off>` | Toggle automatic reload-to-send/fetch |
| `/ac paste` | Paste an answer (clipboard / no-reload mode) |
| `/ac status` | Show current settings |

**Example questions**
- *"What do I still need to kill for my active quests in this zone?"*
- *"I'm tanking Utgarde Keep, what should I watch on the last boss?"*
- *"I'm a resto druid in Naxx — where do I stand on Heigan and what do I heal through?"*
- *"I'm level 74 on a 5x realm, which of my quests are worth keeping?"*

---

## Free model options

| Provider | Endpoint | Example free model | Notes |
|---|---|---|---|
| **OpenRouter** | `https://openrouter.ai/api/v1` | `meta-llama/llama-3.3-70b-instruct:free` | No card; `:free` models; ~20 rpm / 50–1000 per day |
| **Groq** | `https://api.groq.com/openai/v1` | `llama-3.3-70b-versatile` | No card; ~30 rpm / 1000 per day; very fast |
| **Google Gemini** | `https://generativelanguage.googleapis.com/v1beta/openai/` | `gemini-2.5-flash` | Key from AI Studio; may train on free-tier data |
| **Ollama (local)** | `http://localhost:11434/v1` | `llama3.2` | 100% offline & private; no key |

Run `python3 azeroth_companion.py --list-presets` to print these.
Free rosters and limits change often — the `model` field is yours to edit.

---

## Compatibility

| Client | `.toc` | Status |
|---|---|---|
| WotLK **3.3.5a** (Warmane, etc.) | `AzerothCompanion.toc` (Interface 30300) | **Primary target** |
| WotLK Classic | `AzerothCompanion_Wrath.toc` | Supported (compat layer) |
| Cata Classic | `AzerothCompanion_Cata.toc` | Supported (compat layer) |
| Retail | `AzerothCompanion_Mainline.toc` | Supported; manual/clipboard mode recommended |
| TBC / Vanilla Classic | `_TBC.toc` / `_Vanilla.toc` | Best-effort |

The addon never calls a version-specific API directly — everything goes through
`Core/Compat.lua`, which feature-detects the right function at runtime
(e.g. old `GetQuestLogTitle` vs `C_QuestLog.GetInfo`).

---

## Privacy & safety

- Your **API key never leaves your PC** — it lives in the companion's
  `config.json`, never in the addon or its SavedVariables.
- The questions you ask and the context snapshot (your quests/zone/role) are
  sent to **the model provider you chose**. For maximum privacy use **Ollama**
  (fully offline). Note Gemini's free tier may use prompts to improve Google.
- The companion writes **only data** into the addon folder (Base64/JSON), never
  executable Lua — no code-injection path into your client.

---

## Limitations & roadmap

- Turn-based, not real-time (the reload trade-off above).
- Quest reward **XP** is readable on 3.3.5a but not on Classic clients (Blizzard
  removed the API); skip-advice there relies on quest level vs. yours.
- Localized clients may not match the English knowledge-base instance names; the
  model still answers from general knowledge.
- Roadmap ideas: a watcher that auto-presses reload on a hotkey, a bundled
  lightweight bundled coordinate DB (no quest helper needed), per-class tips,
  packaged installers.

Contributions welcome — see [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

---

## Credits & license

Azeroth Companion is released under the [MIT License](LICENSE).
Bundled third-party code and data sources are listed in
[docs/CREDITS.md](docs/CREDITS.md) (notably `json.lua` by rxi, MIT). Questie is
**not** bundled — it's used at runtime only if you have it installed.

This is a fan project and is not affiliated with or endorsed by Blizzard
Entertainment. World of Warcraft is a trademark of Blizzard Entertainment, Inc.
