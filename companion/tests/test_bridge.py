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
                captured["ua"] = self.headers.get("User-Agent")
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
                # A real User-Agent must be sent (Cloudflare blocks the urllib
                # default with 403/1010 - see issue #1).
                self.assertTrue((captured.get("ua") or "").startswith("AzerothCompanion/"))
                self.assertIn("Azjol-Nerub", captured["body"]["messages"][1]["content"])
        finally:
            srv.shutdown()


class EndpointResolutionTests(unittest.TestCase):
    def test_legacy_single_endpoint(self):
        cfg = {"endpoint": "https://x/v1", "api_key": "k", "model": "m",
               "temperature": 0.7, "max_tokens": 123}
        eps = ac.resolve_endpoints(cfg)
        self.assertEqual(len(eps), 1)
        self.assertEqual(eps[0]["endpoint"], "https://x/v1")
        self.assertEqual(eps[0]["api_key"], "k")
        self.assertEqual(eps[0]["model"], "m")
        # top-level sampling settings are inherited
        self.assertEqual(eps[0]["temperature"], 0.7)
        self.assertEqual(eps[0]["max_tokens"], 123)

    def test_endpoints_chain_order_and_inheritance(self):
        cfg = {"temperature": 0.4, "max_tokens": 700,
               "endpoints": [
                   {"endpoint": "https://a/v1", "api_key": "ka", "model": "ma", "temperature": 0.1},
                   {"endpoint": "https://b/v1", "api_key": "kb", "model": "mb"},
               ]}
        eps = ac.resolve_endpoints(cfg)
        self.assertEqual([e["endpoint"] for e in eps], ["https://a/v1", "https://b/v1"])
        # per-entry override wins; otherwise inherit the top-level default
        self.assertEqual(eps[0]["temperature"], 0.1)
        self.assertEqual(eps[1]["temperature"], 0.4)
        self.assertEqual(eps[1]["max_tokens"], 700)

    def test_empty_or_invalid_chain_falls_back_to_legacy(self):
        cfg = {"endpoint": "https://x/v1", "api_key": "k", "model": "m", "endpoints": []}
        eps = ac.resolve_endpoints(cfg)
        self.assertEqual(len(eps), 1)
        self.assertEqual(eps[0]["endpoint"], "https://x/v1")

    def test_entry_without_endpoint_inherits_top_level(self):
        # a chain of fallback *models* on the same provider
        cfg = {"endpoint": "https://x/v1", "api_key": "k",
               "endpoints": [{"model": "big"}, {"model": "small"}]}
        eps = ac.resolve_endpoints(cfg)
        self.assertEqual([e["endpoint"] for e in eps], ["https://x/v1", "https://x/v1"])
        self.assertEqual([e["model"] for e in eps], ["big", "small"])

    def test_entry_without_endpoint_dropped_when_no_top_level(self):
        cfg = {"endpoints": [{"model": "noep"}, {"endpoint": "https://y/v1", "model": "my"}]}
        eps = ac.resolve_endpoints(cfg)
        self.assertEqual([e["endpoint"] for e in eps], ["https://y/v1"])

    def test_foreign_entry_does_not_inherit_top_level_key(self):
        # An entry with its OWN (different) endpoint must NOT borrow the
        # top-level key — that would leak one provider's secret to another host.
        cfg = {"endpoint": "https://openrouter/v1", "api_key": "sk-or-SECRET",
               "endpoints": [{"endpoint": "https://groq/v1", "model": "g"}]}
        eps = ac.resolve_endpoints(cfg)
        self.assertEqual(eps[0]["endpoint"], "https://groq/v1")
        self.assertEqual(eps[0]["api_key"], "")

    def test_same_provider_entry_inherits_top_level_key(self):
        # Keyless entries that reuse the top-level endpoint DO inherit its key.
        cfg = {"endpoint": "https://x/v1", "api_key": "sk-SECRET",
               "endpoints": [{"model": "a"}, {"model": "b"}]}
        eps = ac.resolve_endpoints(cfg)
        self.assertTrue(all(e["api_key"] == "sk-SECRET" for e in eps))


class HttpErrorClassificationTests(unittest.TestCase):
    def test_401_is_auth_error(self):
        msg = ac.classify_http_error(401, "no")
        self.assertIn("401", msg)
        self.assertIn("api_key", msg)

    def test_403_cloudflare_is_not_auth(self):
        msg = ac.classify_http_error(403, "<html>Cloudflare ... error code: 1010</html>")
        self.assertIn("Cloudflare", msg)
        self.assertIn("NOT your api_key", msg)

    def test_403_generic_is_not_definite_auth(self):
        msg = ac.classify_http_error(403, "model not permitted for this key")
        self.assertIn("403", msg)
        self.assertNotIn("Cloudflare", msg)

    def test_parse_retry_after(self):
        self.assertEqual(ac.parse_retry_after("12"), 12)
        self.assertEqual(ac.parse_retry_after("  5 "), 5)
        self.assertIsNone(ac.parse_retry_after(None))
        self.assertIsNone(ac.parse_retry_after("soon"))

    def test_parse_retry_after_http_date(self):
        # HTTP-date form (a date in the past clamps to 0, never negative).
        self.assertEqual(ac.parse_retry_after("Wed, 21 Oct 2015 07:28:00 GMT"), 0)


class RetryAndTimeoutTests(unittest.TestCase):
    """429 retry/backoff and chain failover timing (time.sleep is mocked)."""

    def _stateful_429_then_200(self, retry_after=None):
        state = {"calls": 0}

        class H(BaseHTTPRequestHandler):
            def log_message(self, *a):
                pass

            def do_POST(self):
                n = int(self.headers.get("Content-Length", 0))
                self.rfile.read(n)
                state["calls"] += 1
                if state["calls"] == 1:
                    b = b'{"error": "rate limited"}'
                    self.send_response(429)
                    if retry_after is not None:
                        self.send_header("Retry-After", retry_after)
                else:
                    b = json.dumps({"model": "m", "choices": [{"message": {"content": "ok"}}]}).encode()
                    self.send_response(200)
                self.send_header("Content-Type", "application/json")
                self.send_header("Content-Length", str(len(b)))
                self.end_headers()
                self.wfile.write(b)
        return H, state

    def test_429_clamps_long_retry_after_to_30(self):
        from unittest import mock
        H, state = self._stateful_429_then_200(retry_after="60")
        srv, port = _spawn_server(H)
        waits = []
        try:
            ep = {"endpoint": f"http://127.0.0.1:{port}/v1", "api_key": "k", "model": "m"}
            with mock.patch.object(ac.time, "sleep", lambda s: waits.append(s)):
                content, model, err = ac.call_endpoint(ep, [{"role": "user", "content": "hi"}], max_attempts=3)
            self.assertIsNone(err)
            self.assertEqual(content, "ok")
            self.assertEqual(state["calls"], 2)   # retried once after the 429
            self.assertEqual(waits, [30])         # Retry-After: 60 clamped to 30
        finally:
            srv.shutdown()

    def test_429_without_retry_after_uses_linear_backoff(self):
        from unittest import mock
        H, state = self._stateful_429_then_200(retry_after=None)
        srv, port = _spawn_server(H)
        waits = []
        try:
            ep = {"endpoint": f"http://127.0.0.1:{port}/v1", "api_key": "k", "model": "m"}
            with mock.patch.object(ac.time, "sleep", lambda s: waits.append(s)):
                content, model, err = ac.call_endpoint(ep, [{"role": "user", "content": "hi"}], max_attempts=3)
            self.assertIsNone(err)
            self.assertEqual(waits, [6])          # 6 * attempt, attempt == 1
        finally:
            srv.shutdown()

    def test_non_last_endpoints_get_capped_timeout(self):
        from unittest import mock
        seen = []

        def fake_call_endpoint(ep, messages, max_attempts=1, timeout_override=None):
            seen.append((ep["endpoint"], max_attempts, timeout_override))
            if ep["endpoint"].endswith("a/v1"):
                return None, ep["model"], "boom"
            return "ok", ep["model"], None

        cfg = {"endpoints": [
            {"endpoint": "https://a/v1", "api_key": "x", "model": "a", "request_timeout": 60},
            {"endpoint": "https://b/v1", "api_key": "y", "model": "b", "request_timeout": 60},
        ]}
        with mock.patch.object(ac, "call_endpoint", fake_call_endpoint):
            content, model, err = ac.call_llm(cfg, [{"role": "user", "content": "hi"}])
        self.assertEqual(content, "ok")
        self.assertEqual(seen[0], ("https://a/v1", 1, 30))    # non-last: fail fast, capped
        self.assertEqual(seen[1], ("https://b/v1", 3, None))  # last: full timeout, retries


def _spawn_server(handler_cls):
    srv = HTTPServer(("127.0.0.1", 0), handler_cls)
    port = srv.server_address[1]
    threading.Thread(target=srv.serve_forever, daemon=True).start()
    return srv, port


def _make_handler(name, code, hits, seen_ua):
    class H(BaseHTTPRequestHandler):
        def log_message(self, *a):
            pass

        def do_POST(self):
            n = int(self.headers.get("Content-Length", 0))
            self.rfile.read(n)
            hits[name] = hits.get(name, 0) + 1
            seen_ua[name] = self.headers.get("User-Agent")
            if code == 200:
                b = json.dumps({"model": name,
                                "choices": [{"message": {"content": "hi from %s" % name}}]}).encode()
            else:
                b = b'{"error": {"message": "boom"}}'
            self.send_response(code)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(b)))
            self.end_headers()
            self.wfile.write(b)
    return H


class FallbackTests(unittest.TestCase):
    def test_failover_to_next_endpoint(self):
        hits, ua = {}, {}
        bad, bad_port = _spawn_server(_make_handler("bad", 500, hits, ua))
        good, good_port = _spawn_server(_make_handler("good", 200, hits, ua))
        try:
            cfg = {"endpoints": [
                {"endpoint": f"http://127.0.0.1:{bad_port}/v1", "api_key": "x", "model": "bad"},
                {"endpoint": f"http://127.0.0.1:{good_port}/v1", "api_key": "y", "model": "good"},
            ]}
            content, model, err = ac.call_llm(cfg, [{"role": "user", "content": "hi"}])
            self.assertIsNone(err)
            self.assertEqual(content, "hi from good")
            self.assertEqual(model, "good")
            self.assertEqual(hits.get("bad"), 1)   # tried once, then failed over
            self.assertEqual(hits.get("good"), 1)
            self.assertTrue((ua.get("good") or "").startswith("AzerothCompanion/"))
        finally:
            bad.shutdown()
            good.shutdown()

    def test_all_endpoints_fail_reports_each(self):
        hits, ua = {}, {}
        a, a_port = _spawn_server(_make_handler("a", 500, hits, ua))
        b, b_port = _spawn_server(_make_handler("b", 502, hits, ua))
        try:
            cfg = {"endpoints": [
                {"endpoint": f"http://127.0.0.1:{a_port}/v1", "api_key": "x", "model": "a"},
                {"endpoint": f"http://127.0.0.1:{b_port}/v1", "api_key": "y", "model": "b"},
            ]}
            content, model, err = ac.call_llm(cfg, [{"role": "user", "content": "hi"}])
            self.assertIsNone(content)
            self.assertIn("All 2 endpoints failed", err)
            self.assertIn("500", err)
            self.assertIn("502", err)
        finally:
            a.shutdown()
            b.shutdown()

    def test_single_endpoint_error_is_not_aggregated(self):
        hits, ua = {}, {}
        srv, port = _spawn_server(_make_handler("solo", 401, hits, ua))
        try:
            cfg = {"endpoint": f"http://127.0.0.1:{port}/v1", "api_key": "x", "model": "solo"}
            content, model, err = ac.call_llm(cfg, [{"role": "user", "content": "hi"}])
            self.assertIsNone(content)
            self.assertNotIn("endpoints failed", err)  # single-endpoint message preserved
            self.assertIn("401", err)
        finally:
            srv.shutdown()


if __name__ == "__main__":
    unittest.main(verbosity=2)
