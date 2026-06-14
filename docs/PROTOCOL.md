# Wire protocol

The addon and the companion exchange data through **files** (the only channel a
sandboxed addon has) over two conflict-free lanes. Payloads are **Base64-encoded
JSON** in both directions.

## Why Base64(JSON)?

- **Escaping:** the value is always flat `[A-Za-z0-9+/=]`, so neither side has
  to deal with Lua string escaping, quotes, newlines or non-ASCII bytes. The
  companion extracts it with one regex; the addon embeds it as a plain string.
- **Safety:** the inbound file the companion writes contains **only data**, not
  executable Lua, so there's no code-injection path into the client.

## Lane 1 — Outbox (addon → companion)

The addon stores requests in its **SavedVariables**, which WoW flushes to disk
on `/reload` (and logout). The companion only **reads** this file.

File: `WTF/Account/<ACCOUNT>/SavedVariables/AzerothCompanion.lua`

```lua
AzerothCompanionDB = {
    ["outbox_b64"] = "<base64 of the JSON below>",
    -- … other settings …
}
```

Decoded JSON:
```json
{
  "protocol": 1,
  "requests": [
    {
      "id": "1718364000-3",
      "ts": 1718364000,
      "question": "where do I turn this in?",
      "context": { "...": "live snapshot, see below" }
    }
  ]
}
```

The companion extracts the string with:
`outbox_b64"?\]?\s*=\s*"([A-Za-z0-9+/=]*)"`.

## Lane 2 — Inbox (companion → addon)

The companion writes the answer into a `.lua` file **inside the addon folder**.
WoW re-reads it on the next `/reload` and never overwrites it (it only writes to
`WTF/`). The write is atomic (temp file + rename) so the addon never sees a
partial file.

File: `Interface/AddOns/AzerothCompanion/_Inbox.lua`

```lua
AzerothCompanion_Inbox_proto = 1
AzerothCompanion_Inbox_b64 = "<base64 of the JSON below>"
```

Decoded JSON:
```json
{
  "protocol": 1,
  "answers": {
    "1718364000-3": {
      "answer": "Talk to Larana Drome at Valiance Keep (≈ 60,63).",
      "model": "meta-llama/llama-3.3-70b-instruct:free",
      "error": null,
      "ts": 1718364000
    }
  }
}
```

## Request `context` snapshot

Built by `Core/Context.lua` from live game state:

```json
{
  "client":   { "interface": 30300, "locale": "enUS" },
  "prefs":    { "language": "it", "verbosity": "normal", "xpMultiplier": 5 },
  "player":   { "name": "...", "level": 74, "class": "Hunter", "classId": "HUNTER",
                "race": "...", "faction": "Alliance", "spec": "Survival", "role": "dps" },
  "location": { "zone": "Howling Fjord", "subZone": "...", "x": 60.3, "y": 62.9 },
  "instance": { "name": "Utgarde Keep", "type": "party", "difficulty": "Heroic",
                "groupType": "party", "groupSize": 5 },
  "group":    { "type": "party", "size": 5 },
  "target":   { "name": "...", "classification": "elite", "level": 74, "isDead": false },
  "quests": [
    { "title": "...", "level": 72, "questID": 11378, "isComplete": false,
      "difficulty": "standard", "rewardXP": 25200,
      "objectives": [ { "text": "Slain Nerubians: 3/8", "have": 3, "need": 8, "finished": false } ],
      "questie":    { "finisher": { "name": "...", "zone": "...", "x": 60, "y": 63 },
                      "objectives": [ { "name": "...", "zone": "...", "x": 45, "y": 21 } ] }
    }
  ]
}
```

`quests[].questie` is present only when the player has Questie installed (it's
read at runtime from Questie's in-memory DB — never bundled).

## State machine (survives reloads)

Because each `/reload` restarts the addon, transient state lives in
SavedVariables: `pendingId` (question awaiting an answer), `awaitingSince`,
`refreshCount`. On every load the addon delivers any matching answer from the
inbox, trims it from the outbox, and — if still pending — schedules a fetch
reload (up to `maxAutoRefresh`).

The companion dedupes by request `id` (an id already in its answer store is
never re-sent to the model), so reloads and restarts don't cause duplicate API
calls.
