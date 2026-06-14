#!/usr/bin/env python3
"""
Tests for the Azeroth Companion bridge (pure stdlib, no pip deps).

Run:  python -m unittest discover -s companion/tests
 or:  python companion/tests/test_bridge.py
"""
import base64
import importlib.util
import json
import re
import sys
import tempfile
import threading
import unittest
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path

HERE = Path(__file__).resolve().parent
COMPANION = HERE.parent / "azeroth_companion.py"


def load_module():
    spec = importlib.util.spec_from_file_location("ac", str(COMPANION))
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


ac = load_module()


def make_sv(requests):
    payload = {"protocol": 1, "requests": requests}
    b64 = base64.b64encode(json.dumps(payload).encode()).decode()
    return 'AzerothCompanionDB = {\n\t["outbox_b64"] = "%s",\n}\n' % b64


class WireFormatTests(unittest.TestCase):
    def test_outbox_roundtrip(self):
        reqs = [{"id": "1-1", "ts": 1, "question": "ciao", "context": {"player": {"role": "dps"}}}]
        parsed = ac.parse_outbox(make_sv(reqs))
        self.assertEqual(len(parsed), 1)
        self.assertEqual(parsed[0]["id"], "1-1")
        self.assertEqual(parsed[0]["context"]["player"]["role"], "dps")

    def test_empty_and_missing_outbox(self):
        self.assertEqual(ac.parse_outbox('AzerothCompanionDB = {\n\t["outbox_b64"] = "",\n}\n'), [])
        self.assertEqual(ac.parse_outbox("nonsense"), [])

    def test_url_builder(self):
        self.assertEqual(ac.chat_completion_url("https://x/v1"), "https://x/v1/chat/completions")
        self.assertEqual(ac.chat_completion_url("https://x/v1/"), "https://x/v1/chat/completions")
        self.assertEqual(ac.chat_completion_url("https://x/v1/chat/completions"),
                         "https://x/v1/chat/completions")

    def test_prune_protects_unfetched_answers(self):
        # 60 answers; the oldest belongs to a still-pending (unfetched) request
        # and must survive pruning even though keep=50 by ts.
        answers = {f"a{i}": {"answer": "x", "ts": i} for i in range(60)}
        answers["pending"] = {"answer": "keep me", "ts": -1}  # oldest by ts
        pruned = ac.prune_answers(answers, keep=50, protect={"pending"})
        self.assertIn("pending", pruned)
        # Without protection it WOULD be evicted (sanity check on the cap).
        self.assertNotIn("pending", ac.prune_answers(answers, keep=50))


class PromptTests(unittest.TestCase):
    def setUp(self):
        self.kb = ac.KnowledgeBase(str(HERE.parent / "knowledge"))

    def test_version_label(self):
        self.assertIn("3.3.5a", ac.version_label(30300))
        self.assertIn("Classic", ac.version_label(30403))
        self.assertIn("retail", ac.version_label(110007))

    def test_kb_lookup(self):
        block = self.kb.format_for("Utgarde Keep", "tips for the last boss", None, "tank")
        self.assertIn("Instance:", block)
        self.assertIn("Utgarde Keep", block)

    def test_system_prompt(self):
        req = {"question": "dove vado?", "context": {
            "client": {"interface": 30300},
            "player": {"role": "tank", "level": 80},
            "prefs": {"language": "it", "verbosity": "short", "xpMultiplier": 5},
        }}
        msgs = ac.build_messages(req, dict(ac.DEFAULT_CONFIG), self.kb)
        sys_p = msgs[0]["content"]
        self.assertIn("3.3.5a", sys_p)
        self.assertIn("Italian", sys_p)
        self.assertIn("5x XP", sys_p)
        self.assertIn("TANK", sys_p)


class EndToEndTests(unittest.TestCase):
    def test_full_pipeline_with_mock_server(self):
        captured = {}

        class Handler(BaseHTTPRequestHandler):
            def log_message(self, *a):
                pass

            def do_POST(self):
                n = int(self.headers.get("Content-Length", 0))
                captured["body"] = json.loads(self.rfile.read(n).decode())
                captured["auth"] = self.headers.get("Authorization")
                resp = {"model": "mock", "choices": [
                    {"message": {"content": "Uccidi 8 Nerubiani a nord; consegna a Larana (à)."}}]}
                b = json.dumps(resp).encode()
                self.send_response(200)
                self.send_header("Content-Type", "application/json")
                self.send_header("Content-Length", str(len(b)))
                self.end_headers()
                self.wfile.write(b)

        srv = HTTPServer(("127.0.0.1", 0), Handler)
        port = srv.server_address[1]
        threading.Thread(target=srv.serve_forever, daemon=True).start()
        try:
            with tempfile.TemporaryDirectory() as d:
                root = Path(d) / "WoW"
                sv_dir = root / "WTF" / "Account" / "TEST" / "SavedVariables"
                sv_dir.mkdir(parents=True)
                addon_dir = root / "Interface" / "AddOns" / "AzerothCompanion"
                addon_dir.mkdir(parents=True)
                (addon_dir / "_Inbox.lua").write_text('AzerothCompanion_Inbox_b64 = ""\n')

                reqs = [{"id": "99-1", "ts": 123, "question": "dove finisco?",
                         "context": {"client": {"interface": 30300},
                                     "player": {"role": "dps", "level": 74},
                                     "prefs": {"language": "it", "xpMultiplier": 5},
                                     "instance": {"name": "Azjol-Nerub"}}}]
                (sv_dir / "AzerothCompanion.lua").write_text(make_sv(reqs))

                cfg = {"endpoint": f"http://127.0.0.1:{port}/v1", "api_key": "secret",
                       "model": "test", "wow_installs": [{"path": str(root)}]}
                cfgp = Path(d) / "config.json"
                cfgp.write_text(json.dumps(cfg))

                rc = ac.main(["--config", str(cfgp),
                              "--knowledge", str(HERE.parent / "knowledge"), "--once"])
                self.assertEqual(rc, 0)

                inbox = (addon_dir / "_Inbox.lua").read_text()
                m = re.search(r'AzerothCompanion_Inbox_b64 = "([A-Za-z0-9+/=]*)"', inbox)
                self.assertIsNotNone(m)
                payload = json.loads(base64.b64decode(m.group(1)).decode())
                ans = payload["answers"]["99-1"]
                self.assertIsNone(ans["error"])
                self.assertIn("Nerubiani", ans["answer"])

                self.assertEqual(captured["auth"], "Bearer secret")
                self.assertIn("Azjol-Nerub", captured["body"]["messages"][1]["content"])
        finally:
            srv.shutdown()


if __name__ == "__main__":
    unittest.main(verbosity=2)
