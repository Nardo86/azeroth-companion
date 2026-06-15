#!/usr/bin/env python3
"""
Generate Core/KnowledgeData.lua from the companion's JSON knowledge base.

The dungeon/raid boss tips are STATIC data. The companion needs them as JSON
(to ground the LLM prompt); the addon needs the same facts as a Lua table so it
can answer boss/role questions IN-GAME, instantly, with no /reload and no LLM
round-trip. Rather than maintain the data twice, the JSON stays the single
source and this script bakes it into a Lua module at build time.

    python tools/gen_knowledge_lua.py
    # writes addon/AzerothCompanion/Core/KnowledgeData.lua

Run it whenever companion/knowledge/*.json changes (CI can diff to enforce it).
"""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
KB_DIR = ROOT / "companion" / "knowledge"
OUT = ROOT / "addon" / "AzerothCompanion" / "Core" / "KnowledgeData.lua"

# Only the fields the in-game lookup actually uses. Keeping the projection
# explicit means we never bloat the addon with companion-only fields.
INSTANCE_FIELDS = ("name", "aliases", "type", "levelRange", "generalTips", "bosses")
BOSS_FIELDS = ("name", "summary", "positioning", "tank", "healer", "dps")


def lua_string(s):
    s = (s if s is not None else "")
    s = (s.replace("\\", "\\\\")
          .replace('"', '\\"')
          .replace("\n", "\\n")
          .replace("\r", "\\r")
          .replace("\t", "\\t"))
    return '"' + s + '"'


def emit(value, indent):
    pad = "  " * indent
    inner = "  " * (indent + 1)
    if isinstance(value, str):
        return lua_string(value)
    if isinstance(value, (int, float)):
        return repr(value)
    if isinstance(value, list):
        if not value:
            return "{}"
        parts = [inner + emit(v, indent + 1) + "," for v in value]
        return "{\n" + "\n".join(parts) + "\n" + pad + "}"
    if isinstance(value, dict):
        if not value:
            return "{}"
        parts = []
        for k, v in value.items():
            parts.append("%s[%s] = %s," % (inner, lua_string(k), emit(v, indent + 1)))
        return "{\n" + "\n".join(parts) + "\n" + pad + "}"
    raise TypeError("unhandled type: %r" % (value,))


def project(d, fields):
    return {k: d[k] for k in fields if k in d}


def main():
    instances = []
    for fname in ("dungeons_wotlk.json", "raids_wotlk.json"):
        f = KB_DIR / fname
        if not f.exists():
            print("[warn] missing", f)
            continue
        data = json.loads(f.read_text(encoding="utf-8"))
        for inst in data.get("instances", []):
            entry = project(inst, INSTANCE_FIELDS)
            entry["bosses"] = [project(b, BOSS_FIELDS) for b in inst.get("bosses", [])]
            instances.append(entry)

    n_bosses = sum(len(i.get("bosses", [])) for i in instances)
    header = (
        "--\n"
        "-- KnowledgeData.lua -- GENERATED, do not edit by hand.\n"
        "--\n"
        "-- Source: companion/knowledge/{dungeons,raids}_wotlk.json\n"
        "-- Regenerate: python tools/gen_knowledge_lua.py\n"
        "--\n"
        "-- Static WotLK boss tips, baked in so the addon can answer boss/role\n"
        "-- questions in-game with zero /reload and zero LLM round-trip.\n"
        "--\n\n"
        "local ADDON, ns = ...\n\n"
    )
    body = "ns.KnowledgeData = " + emit({"expansion": "wotlk", "instances": instances}, 0) + "\n\n"
    body += "return ns.KnowledgeData\n"
    OUT.write_text(header + body, encoding="utf-8")
    print("wrote %s (%d instances, %d bosses, %d bytes)"
          % (OUT.relative_to(ROOT), len(instances), n_bosses, OUT.stat().st_size))
    return 0


if __name__ == "__main__":
    sys.exit(main())
