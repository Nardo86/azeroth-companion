# Getting a free AI key — step by step

This guide assumes you know **nothing** about APIs. Follow it click by click and
you'll have Azeroth Companion talking to a **free** AI in about 3 minutes. No
credit card needed.

You only need to fill three things in `config.json`:

```json
{
  "endpoint": "...",
  "api_key": "...",
  "model": "..."
}
```

Think of it like a key to a door:
- **endpoint** = which door (which AI service)
- **api_key** = your personal key to open it
- **model** = which AI brain to use behind that door

Pick **one** of the options below. **Groq is the recommended starting point** —
it's very fast and its free tier holds up better than OpenRouter's `:free`
models, which often get rate-limited upstream. (Even better, you can list
**several at once** and let the companion fall back automatically — see
[Use more than one](#use-more-than-one-automatic-fallback) below.)

---

## Option A — Groq (recommended, free, no card, very fast)

### 1. Make an account
1. Go to **https://console.groq.com** and **Sign in** with Google or GitHub
   (easiest). No payment, no card.

### 2. Create your key
1. Open **API Keys** (left sidebar) → **Create API Key**.
2. Give it any name, e.g. `WoW`, and create it.
3. **Copy the key now** — it starts with `gsk_...`. You won't be able to see it
   again later (you can always make a new one if you lose it).

### 3. Put it in config.json
Open `companion/config.json` (copy it from `config.example.json` if you haven't)
in any text editor and set:

```json
{
  "endpoint": "https://api.groq.com/openai/v1",
  "api_key": "gsk_PASTE-YOUR-KEY-HERE",
  "model": "llama-3.3-70b-versatile"
}
```

Save the file. **Done!** Jump to [Verify it works](#verify-it-works).

> Free limits: ~30 requests/minute and 1000/day. Open-source models only.

---

## Option B — OpenRouter (free, no card)

### 1. Make an account
1. Go to **https://openrouter.ai**
2. Click **Sign in** (top right) and log in with Google or GitHub (easiest).
   That's it — no payment, no card.

### 2. Create your key
1. Go to **https://openrouter.ai/keys** (or click your avatar → **Keys**).
2. Click **Create Key**.
3. Give it any name, e.g. `WoW`, and click **Create**.
4. **Copy the key now** — it looks like `sk-or-v1-xxxxxxxx...`. You won't be able
   to see it again later (you can always make a new one if you lose it).

### 3. Pick a free model
1. Go to **https://openrouter.ai/models?max_price=0** (this filters to free models).
2. Click any model, then copy its **ID** — it ends with **`:free`**, for example
   `meta-llama/llama-3.3-70b-instruct:free`.

### 4. Put it in config.json
```json
{
  "endpoint": "https://openrouter.ai/api/v1",
  "api_key": "sk-or-v1-PASTE-YOUR-KEY-HERE",
  "model": "meta-llama/llama-3.3-70b-instruct:free"
}
```

Save the file. **Done!** Jump to [Verify it works](#verify-it-works).

> Free limits: about 20 requests/minute and 50/day. (A one-time $10 raises it to
> 1000/day forever, if you ever want more — totally optional.)

---

## Option C — Ollama (100% offline & private, no key, no internet)

Best if you have a decent PC and don't want anything leaving your machine.

1. Download and install Ollama from **https://ollama.com** (Windows/Mac/Linux).
2. Open a terminal and run once:
   ```
   ollama pull llama3.2
   ```
   (Leave Ollama running — it sits in the background.)
3. In `config.json`:
   ```json
   {
     "endpoint": "http://localhost:11434/v1",
     "api_key": "ollama",
     "model": "llama3.2"
   }
   ```
4. Save. No key, no limits, nothing leaves your PC. (Answers are as smart as the
   model your PC can run; `llama3.2` is a good light default.)

---

## Use more than one (automatic fallback)

Free tiers throttle and go down a lot. Instead of a single endpoint you can list
**several** and the companion will try them in order, automatically falling over
to the next one the moment one fails (rate limit, firewall block, timeout…).
Replace the three lines above with an `endpoints` list:

```json
{
  "endpoints": [
    { "endpoint": "https://api.groq.com/openai/v1", "api_key": "gsk_...",   "model": "llama-3.3-70b-versatile" },
    { "endpoint": "https://openrouter.ai/api/v1",   "api_key": "sk-or-...", "model": "meta-llama/llama-3.3-70b-instruct:free" },
    { "endpoint": "http://localhost:11434/v1",      "api_key": "ollama",    "model": "llama3.2" }
  ]
}
```

Put your steadiest provider first (Groq), a second free one next, and — if you
have it — a local Ollama as an always-available last resort. Full details in
[CONFIG.md](CONFIG.md#multiple-endpoints-automatic-fallback).

---

## Don't forget: point it at your WoW folder

Also in `config.json`, set the folder that contains **both** `WTF` and
`Interface` (see [INSTALL.md](INSTALL.md) for the exact path on your OS):

```json
"wow_installs": [
  { "path": "C:\\Games\\Warmane WoTLK" }
]
```
On Windows use double backslashes `\\` (or forward slashes `/`).

---

## Verify it works

1. **Check the config offline** (no game needed):
   ```
   python3 azeroth_companion.py --selftest
   ```
   It should list your endpoint(s) and print `== self-test passed ==`.

2. **Start the companion** and leave it running:
   ```
   python3 azeroth_companion.py
   ```
   (or just double-click the prebuilt executable). It lists the WoW install(s)
   it found and waits.

3. **In game:** type `/ac`, ask something like *"what should I do next?"*, and
   wait a moment. With auto-reload on (default) the screen flashes once to send
   and again to show the answer. If nothing appears, click **Refresh** (or type
   `/ac get`).

4. **Watch the companion's console.** You should see lines like:
   ```
   [ask] 17183...-1: what should I do next?
   [ok]  17183...-1: 312 chars via meta-llama/llama-3.3-70b-instruct:free
   ```

If you see `[ok]`, everything works. 🎉

---

## Troubleshooting

| You see… | Meaning | Fix |
|---|---|---|
| `Auth error (HTTP 401)` | wrong/expired key | re-copy the key into `api_key` |
| `Forbidden (HTTP 403)` | key lacks access to that model, or blocked upstream | try another model; check the key's permissions |
| `Blocked … (HTTP 403 / Cloudflare 1010)` | the provider's firewall blocked the request (not your key) | usually transient — retry, or list a fallback endpoint |
| `Rate limit reached` (429) | free limit hit | wait a minute, switch model/provider, or add a fallback endpoint |
| `Network error … Is the endpoint reachable / is Ollama running?` | can't reach the service | check internet; for Ollama make sure it's running |
| `No WoW install found` | wrong path | fix `wow_installs[].path` (the folder with `WTF` + `Interface`) |
| answer never appears in game | companion not running, or no reload | start the companion; click **Refresh** / `/ac get` |

Still stuck? Open an issue: https://github.com/Nardo86/azeroth-companion/issues
