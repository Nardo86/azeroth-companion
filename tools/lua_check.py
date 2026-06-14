#!/usr/bin/env python3
"""
Lua sanity check for the addon, using the optional 'lupa' package (LuaJIT/Lua).

It does two things, without a running WoW client:
  1. compiles every addon .lua file (catches syntax errors), and
  2. loads the bundled json.lua + base64.lua and round-trips the wire format
     against Python, so the addon<->companion contract is verified both ways.

Skips with exit 0 if 'lupa' is not installed (so it never blocks a dev who
hasn't set it up). CI installs lupa, so there it actually runs.

    pip install --user lupa
    python tools/lua_check.py
"""
import base64
import glob
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
ADDON = ROOT / "addon" / "AzerothCompanion"


def main():
    try:
        from lupa import LuaRuntime
    except Exception:
        print("[skip] lupa not installed; `pip install --user lupa` to run Lua checks.")
        return 0

    lua = LuaRuntime(unpack_returned_tuples=True, encoding="utf-8")
    failures = 0

    # 1) compile every .lua
    for f in sorted(glob.glob(str(ADDON / "**" / "*.lua"), recursive=True)):
        try:
            lua.compile(Path(f).read_text(encoding="utf-8"))
            print("  OK   compile", Path(f).relative_to(ROOT))
        except Exception as e:
            print("  FAIL compile", Path(f).relative_to(ROOT), "->", e)
            failures += 1

    # 2) load libs and round-trip the wire format
    ns = lua.eval("{}")

    def load(path):
        return lua.compile(Path(path).read_text(encoding="utf-8"))("AzerothCompanion", ns)

    try:
        jsonlib = load(ADDON / "Libs" / "json.lua")
        b64lib = load(ADDON / "Libs" / "base64.lua")

        sample = "Vai al Pozzo dell'Eternità (à è ì ò ù €)"
        assert b64lib.encode(sample) == base64.b64encode(sample.encode()).decode()
        assert b64lib.decode(base64.b64encode(sample.encode()).decode()) == sample

        # Python inbox -> Lua decodes
        payload = {"protocol": 1, "answers": {"7-3": {"answer": "Parla con Larana (à!)."}}}
        inbox_b64 = base64.b64encode(json.dumps(payload, ensure_ascii=False).encode()).decode()
        decoded = jsonlib.decode(b64lib.decode(inbox_b64))
        assert "à" in decoded["answers"]["7-3"]["answer"]

        # Lua outbox -> Python decodes
        tbl = lua.eval('{ protocol = 1, requests = { { id = "7-3", question = "dove?" } } }')
        back = json.loads(base64.b64decode(b64lib.encode(jsonlib.encode(tbl))).decode())
        assert back["requests"][0]["id"] == "7-3"
        print("  OK   wire-format round-trip (base64 + json, both directions)")
    except Exception as e:
        print("  FAIL wire-format round-trip ->", e)
        failures += 1

    if failures:
        print(f"\n{failures} failure(s).")
        return 1
    print("\nAll Lua checks passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
