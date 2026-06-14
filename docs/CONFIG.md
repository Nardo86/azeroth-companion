# Configuration

All connection settings live in **`companion/config.json`** (copy it from
`config.example.json`). The in-game `/ac` settings cover gameplay preferences.
The file supports full-line `//` comments.

> 🔐 `config.json` holds your API key. It is git-ignored. Never commit it.

## Fields

| Field | Default | Meaning |
|---|---|---|
| `endpoint` | OpenRouter `/v1` | OpenAI-compatible base URL. `/chat/completions` is appended automatically. |
| `api_key` | `""` | Your provider key. Sent as `Authorization: Bearer …`. Leave empty only for local Ollama. |
| `model` | llama-3.3-70b…:free | Model id (free-text — rosters change). |
| `endpoints` | — | Optional **list** of `{ endpoint, api_key, model, … }` tried in order with automatic fallback. Takes precedence over the single `endpoint`/`api_key`/`model` above. See [Multiple endpoints](#multiple-endpoints-automatic-fallback). |
| `language` | `"auto"` | Default reply language; overridden per-request by the addon's `/ac lang`. |
| `temperature` | `0.4` | Sampling temperature. |
| `max_tokens` | `700` | Max answer length. |
| `system_prompt_extra` | `""` | Extra system instructions (persona, "Warmane Lordaeron 7x", etc.). |
| `request_timeout` | `60` | Seconds before an API call times out. |
| `poll_interval` | `1.0` | Seconds between SavedVariables scans. |
| `http_referer` / `x_title` | repo url / name | Optional headers (OpenRouter shows these). |
| `wow_installs` | `[]` | List of installs. Each is `{ "path": "...", "wtf_path"?, "addons_path"? }`. Empty = auto-detect. |
| `preset` | — | Optional shortcut: `"openrouter" \| "groq" \| "gemini" \| "ollama"` fills `endpoint`/`model` if unset. |

## Multiple endpoints (automatic fallback)

Free tiers throttle and go down a lot, so you can list several endpoints and the
companion will **try them in order, failing over to the next on any failure**
(rate limit, `403`/Cloudflare block, timeout or network error). Add an
`endpoints` list — when present it replaces the single `endpoint`/`api_key`/
`model` form:

```jsonc
{
  "endpoints": [
    { "endpoint": "https://api.groq.com/openai/v1", "api_key": "gsk_...",   "model": "llama-3.3-70b-versatile" },
    { "endpoint": "https://openrouter.ai/api/v1",   "api_key": "sk-or-...", "model": "meta-llama/llama-3.3-70b-instruct:free" },
    { "endpoint": "http://localhost:11434/v1",      "api_key": "ollama",    "model": "llama3.2" }   // local last resort
  ]
}
```

- Endpoints are tried top to bottom; the console logs which one served each
  answer (e.g. `[endpoint] served by #2/2: …`) and each failover
  (`[fallback] endpoint #1/2 … failed: …; trying next`).
- A `429` honours the server's `Retry-After` (capped at 30s) on the **last**
  endpoint; between endpoints it fails over immediately so you don't wait.
- Give each entry its **own** `api_key`. An entry may also override `model`,
  `temperature`, `max_tokens`, `request_timeout`, `http_referer` and `x_title`;
  anything omitted inherits the top-level value. An entry with no `endpoint` of
  its own inherits the top-level one (and its key) — handy for listing several
  **models on the same provider**. The top-level key is **never** sent to an
  entry that targets a different host, so a missing key there is just left empty.
- Between endpoints the companion fails over fast (a non-last endpoint waits at
  most 30s before moving on); the last endpoint uses its full `request_timeout`.
- Tip: put a steadier provider first. Groq tends to be more reliable than
  OpenRouter's `:free` tier (which is prone to upstream `429`s), and a local
  Ollama makes a good always-available last resort.

> Note: the `AC_ENDPOINT`/`AC_API_KEY`/`AC_MODEL` environment overrides apply to
> the single-endpoint form. With an `endpoints` list, edit the list directly
> (the `AC_API_KEY` key only reaches a list entry that reuses the top-level
> endpoint, never a different host).

## Provider setups

### Groq (recommended — steadiest free tier)

```json
{ "endpoint": "https://api.groq.com/openai/v1",
  "api_key": "gsk_...",
  "model": "llama-3.3-70b-versatile" }
```
No card. ~30 req/min, 1000/day. Open-source models only. Very fast and, in
practice, less prone to the upstream rate-limits that hit OpenRouter's free tier.

### OpenRouter
```json
{ "endpoint": "https://openrouter.ai/api/v1",
  "api_key": "sk-or-...",
  "model": "meta-llama/llama-3.3-70b-instruct:free" }
```
No credit card to start. Free models end in `:free`. ~20 req/min, 50/day
(permanently 1000/day after a one-time $10 credit). Browse models at
`openrouter.ai/models` and filter by `:free`.

### Google Gemini
```json
{ "endpoint": "https://generativelanguage.googleapis.com/v1beta/openai/",
  "api_key": "AIza...",
  "model": "gemini-2.5-flash" }
```
Key from Google AI Studio, no card. Note: free-tier prompts may be used to
improve Google's products.

### Ollama (local, offline, private, free)
```json
{ "endpoint": "http://localhost:11434/v1",
  "api_key": "ollama",
  "model": "llama3.2" }
```
Install Ollama, `ollama pull llama3.2`, keep it running. Nothing leaves your PC.

## Environment overrides

Handy for secrets / testing: `AC_ENDPOINT`, `AC_API_KEY` (or `OPENAI_API_KEY`),
`AC_MODEL` override the config file.

## In-game settings (`/ac …`)

These are stored per character/account in SavedVariables and travel with each
question:

- `/ac role auto|tank|healer|dps` — role used for tactical advice.
- `/ac xp <n>` — realm XP multiplier (drives quest-skip advice).
- `/ac lang <code>` — reply language (`it`, `en`, …) or `auto`.
- `/ac verbosity short|normal|detailed`.
- `/ac auto on|off` — automatic reload to send & fetch (default on).
- `/ac status` — print current values.

## Reload behaviour (advanced)

In SavedVariables (`AzerothCompanionDB`) you can also tune:
`refreshDelay` (seconds before the fetch reload, default 3) and
`maxAutoRefresh` (give-up after N tries, default 3). Set `autoReload=false`
(`/ac auto off`) to fetch manually with **Refresh** / `/ac get`, or use
`/ac paste` clipboard mode for a no-reload flow.
