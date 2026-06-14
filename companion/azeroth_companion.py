#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Azeroth Companion - companion app.

The bridge between the in-game addon and an OpenAI-compatible LLM endpoint.
WoW addons are sandboxed and cannot make HTTP calls, so this small program does
it for them:

    addon  --(SavedVariables: outbox_b64)-->  companion  --(LLM API)-->  model
    model  --(answer)-->  companion  --(writes _Inbox.lua)-->  addon (on /reload)

It is pure standard-library Python 3 (no pip installs) so it packages cleanly
into a single executable for Windows / macOS / Linux.

See docs/CONFIG.md for configuration and docs/PROTOCOL.md for the wire format.
"""

import argparse
import base64
import glob
import json
import os
import re
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

VERSION = "0.1.0"
PROTOCOL = 1
ADDON_FOLDER = "AzerothCompanion"

# Matches  ["outbox_b64"] = "BASE64..."  in the SavedVariables Lua file.
OUTBOX_RE = re.compile(r'\[?"?outbox_b64"?\]?\s*=\s*"([A-Za-z0-9+/=]*)"')

# ----------------------------------------------------------------------------
# Endpoint presets (verified June 2026 - rosters/limits rotate, model is editable)
# ----------------------------------------------------------------------------

PRESETS = {
    "openrouter": {
        "endpoint": "https://openrouter.ai/api/v1",
        "model": "meta-llama/llama-3.3-70b-instruct:free",
        "note": "Free models use the ':free' suffix. No card to sign up. ~20 RPM, 50/day (1000/day after one-time $10).",
    },
    "groq": {
        "endpoint": "https://api.groq.com/openai/v1",
        "model": "llama-3.3-70b-versatile",
        "note": "No card. ~30 RPM / 1000 RPD. Open-source models only.",
    },
    "gemini": {
        "endpoint": "https://generativelanguage.googleapis.com/v1beta/openai/",
        "model": "gemini-2.5-flash",
        "note": "Key from Google AI Studio, no card. Free tier may train on your prompts.",
    },
    "ollama": {
        "endpoint": "http://localhost:11434/v1",
        "model": "llama3.2",
        "note": "Fully local/offline, no key needed (any dummy works). Run 'ollama pull <model>' first.",
    },
}

LANG_NAMES = {
    "it": "Italian", "en": "English", "es": "Spanish", "de": "German",
    "fr": "French", "pt": "Portuguese", "ru": "Russian", "ko": "Korean",
    "zh": "Chinese", "pl": "Polish", "nl": "Dutch", "sv": "Swedish",
}

DEFAULT_CONFIG = {
    "endpoint": "https://openrouter.ai/api/v1",
    "api_key": "",
    "model": "meta-llama/llama-3.3-70b-instruct:free",
    "language": "auto",
    "temperature": 0.4,
    "max_tokens": 700,
    "request_timeout": 60,
    "poll_interval": 1.0,
    "system_prompt_extra": "",
    "http_referer": "https://github.com/Nardo86/azeroth-companion",
    "x_title": "Azeroth Companion",
    "wow_installs": [],
}


# ----------------------------------------------------------------------------
# config
# ----------------------------------------------------------------------------

def strip_line_comments(text):
    """Allow full-line // comments in the config file (URLs keep their //)."""
    out = []
    for line in text.splitlines():
        if line.lstrip().startswith("//"):
            continue
        out.append(line)
    return "\n".join(out)


def load_config(path):
    cfg = dict(DEFAULT_CONFIG)
    p = Path(path)
    if p.exists():
        raw = strip_line_comments(p.read_text(encoding="utf-8"))
        user = json.loads(raw)
        cfg.update(user)
    else:
        print(f"[warn] config not found at {p}; using defaults + environment.")

    # Apply a named preset (fills endpoint/model if the user only set 'preset').
    preset = cfg.get("preset")
    if preset and preset in PRESETS:
        cfg.setdefault("endpoint", PRESETS[preset]["endpoint"])
        if not cfg.get("endpoint"):
            cfg["endpoint"] = PRESETS[preset]["endpoint"]
        if not cfg.get("model"):
            cfg["model"] = PRESETS[preset]["model"]

    # Environment overrides (handy for secrets / CI / quick tests).
    env = os.environ
    if env.get("AC_ENDPOINT"):
        cfg["endpoint"] = env["AC_ENDPOINT"]
    if env.get("AC_API_KEY"):
        cfg["api_key"] = env["AC_API_KEY"]
    if env.get("OPENAI_API_KEY") and not cfg.get("api_key"):
        cfg["api_key"] = env["OPENAI_API_KEY"]
    if env.get("AC_MODEL"):
        cfg["model"] = env["AC_MODEL"]
    return cfg


# ----------------------------------------------------------------------------
# install discovery
# ----------------------------------------------------------------------------

def candidate_roots():
    """Best-effort guesses for a WoW root across OSes (user should set the path)."""
    roots = []
    home = Path.home()
    guesses = [
        "C:/Program Files/World of Warcraft",
        "C:/Program Files (x86)/World of Warcraft",
        "C:/Games/World of Warcraft",
        "C:/Warmane",
        str(home / "Games/world-of-warcraft/drive_c/Program Files/World of Warcraft"),
        str(home / ".wine/drive_c/Program Files/World of Warcraft"),
        str(home / ".wine/drive_c/Games/World of Warcraft"),
        "/Applications/World of Warcraft",
    ]
    for g in guesses:
        roots.append(Path(g))
    return roots


def discover_installs(cfg):
    """Return a list of install descriptors: {root, wtf, addons, inbox, state_key}."""
    installs = []
    configured = cfg.get("wow_installs") or []

    def add_install(root, wtf=None, addons=None):
        root = Path(root)
        wtf = Path(wtf) if wtf else root / "WTF"
        addons = Path(addons) if addons else root / "Interface" / "AddOns"
        inbox = addons / ADDON_FOLDER / "_Inbox.lua"
        state_key = re.sub(r"[^A-Za-z0-9]+", "_", str(root))[-60:]
        installs.append({
            "root": root, "wtf": wtf, "addons": addons,
            "inbox": inbox, "state_key": state_key,
        })

    if configured:
        for item in configured:
            if isinstance(item, str):
                add_install(item)
            else:
                add_install(item.get("path"), item.get("wtf_path"), item.get("addons_path"))
    else:
        for root in candidate_roots():
            if (root / "WTF").is_dir() or (root / "Interface" / "AddOns").is_dir():
                add_install(root)

    return installs


def find_outbox_files(install):
    """All AzerothCompanion SavedVariables files across accounts in this install."""
    pattern = str(install["wtf"] / "Account" / "*" / "SavedVariables" / "AzerothCompanion.lua")
    return glob.glob(pattern)


# ----------------------------------------------------------------------------
# wire format
# ----------------------------------------------------------------------------

def parse_outbox(sv_text):
    """Extract the request list from a SavedVariables file's outbox_b64 string."""
    m = OUTBOX_RE.search(sv_text)
    if not m:
        return []
    b64 = m.group(1)
    if not b64:
        return []
    try:
        raw = base64.b64decode(b64)
        data = json.loads(raw.decode("utf-8"))
    except Exception:
        return []
    if isinstance(data, dict) and isinstance(data.get("requests"), list):
        return data["requests"]
    return []


def write_inbox(install, answers):
    """Atomically write _Inbox.lua with the Base64(JSON) answer payload."""
    payload = {"protocol": PROTOCOL, "answers": answers}
    raw = json.dumps(payload, ensure_ascii=False).encode("utf-8")
    b64 = base64.b64encode(raw).decode("ascii")
    body = (
        "-- AUTO-GENERATED by the Azeroth Companion app. DO NOT EDIT.\n"
        "AzerothCompanion_Inbox_proto = 1\n"
        'AzerothCompanion_Inbox_b64 = "%s"\n' % b64
    )
    inbox = Path(install["inbox"])
    inbox.parent.mkdir(parents=True, exist_ok=True)
    tmp = inbox.with_suffix(".lua.tmp")
    tmp.write_text(body, encoding="utf-8")
    os.replace(str(tmp), str(inbox))  # atomic so the addon never reads a partial file


def state_path(cfg_dir, install):
    return Path(cfg_dir) / ("inbox-%s.json" % install["state_key"])


def load_state(cfg_dir, install):
    p = state_path(cfg_dir, install)
    if p.exists():
        try:
            return json.loads(p.read_text(encoding="utf-8"))
        except Exception:
            return {}
    return {}


def save_state(cfg_dir, install, answers):
    p = state_path(cfg_dir, install)
    try:
        p.write_text(json.dumps(answers, ensure_ascii=False), encoding="utf-8")
    except Exception as e:
        print(f"[warn] could not persist state: {e}")


# ----------------------------------------------------------------------------
# knowledge base
# ----------------------------------------------------------------------------

class KnowledgeBase:
    def __init__(self, kb_dir):
        self.instances = []
        self.general = {}
        kb_dir = Path(kb_dir)
        for fname in ("dungeons_wotlk.json", "raids_wotlk.json"):
            f = kb_dir / fname
            if f.exists():
                try:
                    data = json.loads(f.read_text(encoding="utf-8"))
                    self.instances.extend(data.get("instances", []))
                except Exception as e:
                    print(f"[warn] failed to load {f}: {e}")
        gf = kb_dir / "general_tips.json"
        if gf.exists():
            try:
                self.general = json.loads(gf.read_text(encoding="utf-8"))
            except Exception:
                self.general = {}

    def find_instance(self, instance_name, question):
        hay = ((instance_name or "") + " " + (question or "")).lower()
        for inst in self.instances:
            names = [inst.get("name", "")] + list(inst.get("aliases", []))
            for n in names:
                n = (n or "").lower()
                if n and n in hay:
                    return inst
        return None

    @staticmethod
    def _focus_boss(inst, question, target_name):
        q = (question or "").lower()
        for boss in inst.get("bosses", []):
            bn = (boss.get("name") or "").lower()
            if bn and (bn in q):
                return boss
        if target_name:
            tn = target_name.lower()
            for boss in inst.get("bosses", []):
                bn = (boss.get("name") or "").lower()
                # match either direction (boss display name vs unit name)
                if bn and (tn in bn or bn in tn):
                    return boss
        return None

    def format_for(self, instance_name, question, target_name, role):
        inst = self.find_instance(instance_name, question)
        if not inst:
            return ""
        lines = ["KNOWLEDGE (verified WotLK tips - prefer this over guessing):"]
        lines.append("Instance: %s (%s)" % (inst.get("name"), inst.get("levelRange", "")))
        for t in (inst.get("generalTips") or [])[:4]:
            lines.append("  - " + t)

        boss = self._focus_boss(inst, question, target_name)
        if boss:
            lines.append("Boss: %s - %s" % (boss.get("name"), boss.get("summary", "")))
            if boss.get("positioning"):
                lines.append("  Positioning: " + boss["positioning"])
            for r in ("tank", "healer", "dps"):
                bullets = boss.get(r) or []
                if bullets:
                    mark = " (YOU)" if r == role else ""
                    lines.append("  %s%s:" % (r.upper(), mark))
                    for b in bullets:
                        lines.append("    - " + b)
        else:
            names = [b.get("name") for b in inst.get("bosses", []) if b.get("name")]
            if names:
                lines.append("Bosses: " + ", ".join(names))
            lines.append("(Ask about a specific boss for detailed role tips.)")
        return "\n".join(lines)

    def role_tips(self, role):
        roles = (self.general or {}).get("roles", {})
        return roles.get(role, [])


# ----------------------------------------------------------------------------
# prompt building
# ----------------------------------------------------------------------------

def version_label(interface):
    try:
        n = int(interface)
    except Exception:
        return "World of Warcraft"
    if n >= 100000:
        return "World of Warcraft (modern retail: Dragonflight / War Within era)"
    if 40000 <= n < 50000:
        return "World of Warcraft: Cataclysm"
    if 30400 <= n < 40000:
        return "World of Warcraft: Wrath of the Lich King Classic"
    if 30000 <= n < 30400:
        return "World of Warcraft: Wrath of the Lich King (client 3.3.5a)"
    if 20000 <= n < 30000:
        return "World of Warcraft: The Burning Crusade"
    return "World of Warcraft: Classic (Vanilla)"


ROLE_LENS = {
    "tank": ("As a TANK, prioritise: holding threat on every target, where to face/position the boss and "
             "adds, mitigation/defensive timing, and incoming spawns or frontal abilities to watch for."),
    "healer": ("As a HEALER, prioritise: mana management, who and when to heal, pre-healing before burst "
               "windows, dispels/decurses that matter, and staying in range/line of sight."),
    "dps": ("As DPS, prioritise: standing behind the boss (melee) or spread at range, target priority and "
            "swaps to adds, assigned interrupts, avoiding ground effects, and not pulling aggro off the tank."),
    "unknown": "Give balanced advice and, where role matters, briefly cover tank, healer and DPS.",
}

VERBOSITY = {
    "short": "Answer in 1-3 short sentences or up to 3 bullets. Be direct.",
    "normal": "Answer concisely: a short paragraph or up to ~6 bullets.",
    "detailed": "You may give a fuller answer, but stay skimmable and avoid filler.",
}


def language_instruction(lang_code, cfg):
    code = (lang_code or cfg.get("language") or "en")
    if code == "auto":
        code = "en"
    name = LANG_NAMES.get(code)
    if name:
        return f"Always reply in {name}."
    return f"Always reply in the player's language (code '{code}')."


def build_system_prompt(ctx, cfg, kb):
    prefs = ctx.get("prefs", {})
    player = ctx.get("player", {})
    client = ctx.get("client", {})
    role = player.get("role", "unknown") or "unknown"
    xp = prefs.get("xpMultiplier", 1) or 1
    verbosity = prefs.get("verbosity", "normal") or "normal"

    parts = []
    parts.append(
        'You are "Azeroth Companion", an expert, friendly in-game assistant for '
        + version_label(client.get("interface")) + "."
    )
    parts.append(language_instruction(prefs.get("language"), cfg))
    parts.append(
        "Keep answers skimmable for a small chat window: short sentences or a few bullets. "
        "No markdown tables, no big headers, no code fences."
    )
    parts.append(VERBOSITY.get(verbosity, VERBOSITY["normal"]))
    parts.append(
        "The player's LIVE situation is provided as JSON (CONTEXT) in the user message. "
        "Ground every answer in it - their real quests, location, target, role and instance."
    )
    parts.append(
        "Never invent map coordinates. Give exact coords ONLY when they appear in the data "
        "(a quest's 'coords' block). Otherwise guide by zone, sub-zone, landmarks and known "
        "locations for this version of the game, and say when you are not certain."
    )
    parts.append("Player role: " + role + ". " + ROLE_LENS.get(role, ROLE_LENS["unknown"]))
    parts.append(
        "QUESTS: when asked about quests, tell the player exactly what to do for their active "
        "quests - which mobs to kill, items to gather, or NPCs to talk to, and roughly where. "
        "Use objective progress (have/need) to focus on what's left."
    )
    if xp and float(xp) > 1:
        parts.append(
            f"This realm runs {xp}x XP. Help optimise leveling: flag quests that have turned "
            "trivial/gray (their difficulty is well below the player) as skippable for XP, BUT keep "
            "quests that belong to a chain leading to a reward, a dungeon/attunement, or a "
            "breadcrumb to the next zone. Prefer dense kill quests and dungeon quests."
        )
    parts.append(
        "DUNGEONS/RAIDS: if the player is in an instance or asks about one, give role-specific "
        "positioning and the 1-3 mechanics that matter. If a KNOWLEDGE block is provided, prefer it."
    )
    extra = cfg.get("system_prompt_extra")
    if extra:
        parts.append(str(extra))
    return "\n".join(parts)


def trim_context(ctx):
    """Drop noisy/empty fields to keep the payload small."""
    c = json.loads(json.dumps(ctx))  # deep copy
    quests = c.get("quests") or []
    for q in quests:
        q.pop("index", None)
        objs = q.get("objectives") or []
        for o in objs:
            # keep text/have/need/finished; drop type if absent
            if o.get("type") is None:
                o.pop("type", None)
    return c


def build_messages(req, cfg, kb):
    ctx = req.get("context", {}) or {}
    question = req.get("question", "")
    system = build_system_prompt(ctx, cfg, kb)

    player = ctx.get("player", {})
    instance = ctx.get("instance") or {}
    target = ctx.get("target") or {}
    kb_block = kb.format_for(
        instance.get("name") if instance else None,
        question,
        target.get("name") if target else None,
        player.get("role", "unknown"),
    )

    user_parts = ["QUESTION: " + question, "", "CONTEXT (JSON):",
                  json.dumps(trim_context(ctx), ensure_ascii=False)]
    if kb_block:
        user_parts += ["", kb_block]
    user = "\n".join(user_parts)

    return [
        {"role": "system", "content": system},
        {"role": "user", "content": user},
    ]


# ----------------------------------------------------------------------------
# LLM call
# ----------------------------------------------------------------------------

def chat_completion_url(endpoint):
    e = (endpoint or "").rstrip("/")
    if e.endswith("/chat/completions"):
        return e
    return e + "/chat/completions"


def call_llm(cfg, messages, verbose=False):
    """Returns (content, model_used, error_string)."""
    url = chat_completion_url(cfg.get("endpoint"))
    body = {
        "model": cfg.get("model"),
        "messages": messages,
        "temperature": cfg.get("temperature", 0.4),
        "max_tokens": cfg.get("max_tokens", 700),
        "stream": False,
    }
    data = json.dumps(body).encode("utf-8")
    headers = {"Content-Type": "application/json"}
    key = cfg.get("api_key")
    if key:
        headers["Authorization"] = "Bearer " + key
    if cfg.get("http_referer"):
        headers["HTTP-Referer"] = cfg["http_referer"]
    if cfg.get("x_title"):
        headers["X-Title"] = cfg["x_title"]

    timeout = cfg.get("request_timeout", 60)
    attempts = 0
    while True:
        attempts += 1
        req = urllib.request.Request(url, data=data, headers=headers, method="POST")
        try:
            with urllib.request.urlopen(req, timeout=timeout) as resp:
                payload = json.loads(resp.read().decode("utf-8"))
            choices = payload.get("choices") or []
            if not choices:
                return None, cfg.get("model"), "empty response from endpoint"
            msg = choices[0].get("message", {})
            content = msg.get("content")
            if isinstance(content, list):  # some providers return content parts
                content = "".join(p.get("text", "") for p in content if isinstance(p, dict))
            model_used = payload.get("model") or cfg.get("model")
            return content, model_used, None
        except urllib.error.HTTPError as e:
            detail = ""
            try:
                detail = e.read().decode("utf-8")[:400]
            except Exception:
                pass
            if e.code == 429 and attempts < 3:
                wait = 6 * attempts
                print(f"[rate-limit] HTTP 429; retrying in {wait}s ...")
                time.sleep(wait)
                continue
            if e.code == 429:
                return None, cfg.get("model"), "Rate limit reached (free tier). Try again shortly or switch model/provider."
            if e.code in (401, 403):
                return None, cfg.get("model"), f"Auth error (HTTP {e.code}). Check api_key. {detail}"
            return None, cfg.get("model"), f"HTTP {e.code}: {detail}"
        except urllib.error.URLError as e:
            return None, cfg.get("model"), f"Network error: {e.reason}. Is the endpoint reachable / is Ollama running?"
        except Exception as e:
            return None, cfg.get("model"), f"Unexpected error: {e}"


# ----------------------------------------------------------------------------
# processing
# ----------------------------------------------------------------------------

def prune_answers(answers, keep=50, protect=()):
    """Cap the stored answers, but NEVER drop one that hasn't been fetched yet.

    `protect` is the set of request ids still present in some outbox — i.e. the
    addon has not consumed them (it removes a request from its outbox only after
    delivering the answer on /reload). Evicting one of those would lose an answer
    the player is still waiting for, so we always keep them.
    """
    protect = set(protect)
    if len(answers) <= keep:
        return answers
    items = sorted(answers.items(), key=lambda kv: kv[1].get("ts", 0), reverse=True)
    kept = dict(items[:keep])
    for rid in protect:
        if rid in answers:
            kept[rid] = answers[rid]
    return kept


def process_install(install, cfg, kb, cfg_dir, verbose=False):
    files = find_outbox_files(install)
    if not files:
        return 0
    answers = load_state(cfg_dir, install)
    processed = 0
    changed = False

    # Merge requests from every account on this install, dedup by id.
    seen_ids = set()
    requests = []
    for f in files:
        try:
            text = Path(f).read_text(encoding="utf-8", errors="replace")
        except Exception:
            continue
        for r in parse_outbox(text):
            rid = r.get("id")
            if rid and rid not in seen_ids:
                seen_ids.add(rid)
                requests.append(r)

    for req in requests:
        rid = req.get("id")
        if not rid or rid in answers:
            continue  # already answered (dedup across restarts)
        question = (req.get("question") or "").strip()
        if not question:
            continue
        print(f"[ask] {rid}: {question[:80]}")
        messages = build_messages(req, cfg, kb)
        if verbose:
            print("----- system -----\n" + messages[0]["content"])
            print("----- user -----\n" + messages[1]["content"][:1500])
        content, model_used, error = call_llm(cfg, messages, verbose=verbose)
        answers[rid] = {
            "answer": content or "",
            "model": model_used,
            "error": error,
            "ts": int(req.get("ts", time.time())),
        }
        if error:
            print(f"[error] {rid}: {error}")
        else:
            print(f"[ok] {rid}: {len((content or ''))} chars via {model_used}")
        processed += 1
        changed = True

    if changed:
        answers = prune_answers(answers, protect=seen_ids)
        write_inbox(install, answers)
        save_state(cfg_dir, install, answers)
    return processed


def run_loop(cfg, kb, installs, cfg_dir, once=False, verbose=False):
    poll = float(cfg.get("poll_interval", 1.0))
    print(f"Azeroth Companion v{VERSION} watching {len(installs)} install(s). Ctrl-C to stop.")
    for ins in installs:
        print(f"  - {ins['root']}")
        print(f"      WTF:   {ins['wtf']}")
        print(f"      inbox: {ins['inbox']}")
    try:
        while True:
            total = 0
            for ins in installs:
                try:
                    total += process_install(ins, cfg, kb, cfg_dir, verbose=verbose)
                except Exception as e:
                    print(f"[warn] processing {ins['root']}: {e}")
            if once:
                print(f"--once: processed {total} request(s); exiting.")
                return
            time.sleep(poll)
    except KeyboardInterrupt:
        print("\nStopped.")


# ----------------------------------------------------------------------------
# self-test (no network)
# ----------------------------------------------------------------------------

def selftest(cfg, kb):
    print("== self-test ==")
    sample = {"protocol": 1, "requests": [{"id": "1-1", "ts": 1, "question": "where do I turn in?",
              "context": {"client": {"interface": 30300},
                          "player": {"role": "dps", "level": 72, "class": "Mage"},
                          "prefs": {"language": "it", "verbosity": "normal", "xpMultiplier": 5},
                          "instance": {"name": "Utgarde Keep"},
                          "quests": [{"title": "Disloyal?", "level": 70,
                                      "objectives": [{"text": "Proof: 0/1"}]}]}}]}
    b64 = base64.b64encode(json.dumps(sample).encode()).decode()
    sv = 'AzerothCompanionDB = {\n\t["outbox_b64"] = "%s",\n}\n' % b64
    reqs = parse_outbox(sv)
    assert len(reqs) == 1 and reqs[0]["id"] == "1-1", "outbox round-trip failed"
    print("  outbox parse: OK (1 request)")

    msgs = build_messages(reqs[0], cfg, kb)
    assert msgs[0]["role"] == "system" and "Wrath of the Lich King" in msgs[0]["content"]
    assert "Italian" in msgs[0]["content"], "language instruction missing"
    assert "5x XP" in msgs[0]["content"] or "5.0x XP" in msgs[0]["content"] or "5x" in msgs[0]["content"]
    print("  system prompt: OK (version + language + xp)")

    kb_block = kb.format_for("Utgarde Keep", "how do I tank Ingvar?", None, "tank")
    print("  KB lookup for 'Utgarde Keep': %s" % ("OK" if "Instance:" in kb_block else "EMPTY"))

    # inbox encode/decode round-trip
    payload = {"protocol": 1, "answers": {"1-1": {"answer": "Ciao!", "model": "x", "error": None, "ts": 1}}}
    raw = base64.b64encode(json.dumps(payload, ensure_ascii=False).encode()).decode()
    back = json.loads(base64.b64decode(raw).decode())
    assert back["answers"]["1-1"]["answer"] == "Ciao!"
    print("  inbox round-trip: OK")
    print(f"  endpoint URL: {chat_completion_url(cfg.get('endpoint'))}")
    print(f"  model: {cfg.get('model')}  key set: {bool(cfg.get('api_key'))}")
    print("== self-test passed ==")


# ----------------------------------------------------------------------------
# main
# ----------------------------------------------------------------------------

def main(argv=None):
    parser = argparse.ArgumentParser(description="Azeroth Companion helper app")
    # Frozen (PyInstaller) vs source: keep config.json next to the executable so
    # users can edit it, but read the bundled knowledge from the extraction dir.
    if getattr(sys, "frozen", False):
        exe_dir = Path(sys.executable).resolve().parent
        res_dir = Path(getattr(sys, "_MEIPASS", exe_dir))
    else:
        exe_dir = Path(__file__).resolve().parent
        res_dir = exe_dir
    parser.add_argument("--config", default=str(exe_dir / "config.json"),
                        help="path to config.json (default: alongside the executable)")
    parser.add_argument("--knowledge", default=str(res_dir / "knowledge"),
                        help="path to the knowledge directory")
    parser.add_argument("--once", action="store_true", help="process pending requests once and exit")
    parser.add_argument("--selftest", action="store_true", help="run offline self-test and exit")
    parser.add_argument("--list-presets", action="store_true", help="print endpoint presets and exit")
    parser.add_argument("--verbose", action="store_true", help="print the prompts sent to the model")
    args = parser.parse_args(argv)

    if args.list_presets:
        for name, p in PRESETS.items():
            print(f"{name:12} {p['endpoint']}\n             model: {p['model']}\n             {p['note']}")
        return 0

    cfg = load_config(args.config)
    cfg_dir = str(Path(args.config).resolve().parent)
    kb = KnowledgeBase(args.knowledge)

    if args.selftest:
        selftest(cfg, kb)
        return 0

    if not cfg.get("api_key") and "localhost" not in (cfg.get("endpoint") or "") and "127.0.0.1" not in (cfg.get("endpoint") or ""):
        print("[warn] no api_key set and endpoint is not local. Set api_key in config.json "
              "(or AC_API_KEY env). See docs/CONFIG.md.")

    installs = discover_installs(cfg)
    if not installs:
        print("[error] No WoW install found. Set 'wow_installs' in config.json to your WoW folder "
              "(the one containing WTF and Interface). See docs/INSTALL.md.")
        return 2

    run_loop(cfg, kb, installs, cfg_dir, once=args.once, verbose=args.verbose)
    return 0


if __name__ == "__main__":
    sys.exit(main())
