-- _Inbox.lua
--
-- This file is the "inbox" channel: the Azeroth Companion helper program
-- (the external process running on your PC) OVERWRITES this file with the
-- latest answer payload, encoded as Base64(JSON). WoW re-reads it on every
-- /reload, so the addon picks the answer up without WoW ever clobbering it
-- (WoW only writes to SavedVariables, never to an addon's own source files).
--
-- The empty stub below ships with the addon so the game does not throw a
-- "file not found" error before the companion has run for the first time.
--
-- DO NOT EDIT BY HAND.

AzerothCompanion_Inbox_proto = 1
AzerothCompanion_Inbox_b64 = ""
