# Installation

Azeroth Companion has **two parts** and you need both:

1. the **addon** (goes inside your WoW client), and
2. the **companion app** (runs on your PC and does the AI call).

---

## 1. Install the addon

Copy the folder `addon/AzerothCompanion` into your client's add-ons folder:

```
<WoW>/Interface/AddOns/AzerothCompanion/
```

You should end up with `…/Interface/AddOns/AzerothCompanion/AzerothCompanion.toc`.

On the character-selection screen open **AddOns** and make sure *Azeroth
Companion* is enabled. On 3.3.5a tick **Load out of date AddOns** if it shows as
out of date.

Log in and type `/ac` — the window should open and you'll see a "loaded" message.

---

## 2. Install the companion app

### Option A — prebuilt executable (no Python)
Download the build for your OS from the
[Releases](https://github.com/Nardo86/azeroth-companion/releases) page. Put the
executable in a folder together with a `config.json` (see step 3) and run it.

### Option B — from source (Python 3.8+, no extra packages)
```bash
cd companion
cp config.example.json config.json     # then edit config.json (step 3)
python3 azeroth_companion.py
```

Leave it running in the background while you play.

---

## 3. Configure `config.json`

Copy `companion/config.example.json` → `companion/config.json` and edit at least
`endpoint`, `api_key`, `model` and `wow_installs`. Details in
[CONFIG.md](CONFIG.md). Quick check:

```bash
python3 azeroth_companion.py --selftest      # offline sanity check
python3 azeroth_companion.py --list-presets  # show free provider presets
```

---

## Where is my WoW folder? (the `wow_installs` path)

`wow_installs[].path` must point at the folder that contains **both** `WTF` and
`Interface`.

| OS | Typical path |
|---|---|
| Windows | `C:\Games\Warmane WoTLK` · `C:\Program Files (x86)\World of Warcraft` |
| Linux (Wine/Lutris) | `~/Games/<prefix>/drive_c/Program Files/World of Warcraft` · `~/.wine/drive_c/...` |
| macOS | `/Applications/World of Warcraft` |

From that root the app expects:
- SavedVariables: `WTF/Account/<ACCOUNT>/SavedVariables/AzerothCompanion.lua`
- Inbox target:   `Interface/AddOns/AzerothCompanion/_Inbox.lua`

If your layout is unusual you can override `wtf_path` and `addons_path` per
install in `config.json`.

> **Windows JSON paths:** use double backslashes, e.g.
> `"path": "C:\\Games\\Warmane WoTLK"`, or forward slashes `"C:/Games/..."`.

---

## First run sanity check

1. Companion app running, `config.json` filled in.
2. In game: `/ac` then ask *"what should I do next?"*.
3. With auto-reload on (default) the UI flashes (flush), waits a moment, then
   flashes again to show the answer. If nothing appears, click **Refresh** or
   type `/ac get`, and check the companion's console for `[ask]` / `[ok]` /
   `[error]` lines.

See [CONFIG.md](CONFIG.md) for tuning the reload behaviour.
