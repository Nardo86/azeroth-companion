--
-- Bridge.lua -- the addon <-> companion transport.
--
-- Channels (see docs/PROTOCOL.md):
--   OUT  addon -> companion : AzerothCompanionDB.outbox_b64  (Base64(JSON))
--        written to the SavedVariables file, which WoW flushes to disk on
--        every /reload. The companion only READS this.
--   IN   companion -> addon : AzerothCompanion_Inbox_b64     (Base64(JSON))
--        the companion overwrites _Inbox.lua in the addon folder; WoW re-reads
--        it on /reload and never overwrites it. The addon only READS this.
--
-- Because every /reload restarts the addon, ALL transient state (the question
-- we are waiting on, the retry count) lives in SavedVariables so it survives
-- the reload round-trip.
--

local ADDON, ns = ...

local Bridge = {}
ns.Bridge = Bridge

local PROTOCOL = 1
local MAX_OUTBOX = 10

----------------------------------------------------------------------
-- (de)serialization helpers
----------------------------------------------------------------------

local function now()
  return (time and time()) or 0
end

local function newId()
  local db = ns.Config.db
  db._seq = (db._seq or 0) + 1
  return string.format("%d-%d", now(), db._seq)
end

local function readInbox()
  local b64 = _G.AzerothCompanion_Inbox_b64
  if type(b64) ~= "string" or b64 == "" then return nil end
  local raw = ns.base64.decode(b64)
  if not raw or raw == "" then return nil end
  local ok, data = pcall(ns.json.decode, raw)
  if ok and type(data) == "table" then return data end
  return nil
end

local function getOutbox()
  local db = ns.Config.db
  local b64 = db.outbox_b64
  if type(b64) == "string" and b64 ~= "" then
    local raw = ns.base64.decode(b64)
    local ok, data = pcall(ns.json.decode, raw)
    if ok and type(data) == "table" and type(data.requests) == "table" then
      return data.requests
    end
  end
  return {}
end

local function saveOutbox(requests)
  local db = ns.Config.db
  local raw = ns.json.encode({ protocol = PROTOCOL, requests = requests })
  db.outbox_b64 = ns.base64.encode(raw)
end

local function dropFromOutbox(id)
  if not id then return end
  local requests = getOutbox()
  local remaining = {}
  for _, r in ipairs(requests) do
    if r.id ~= id then remaining[#remaining + 1] = r end
  end
  saveOutbox(remaining)
end

----------------------------------------------------------------------
-- delivery
----------------------------------------------------------------------

local function deliver(req, ans)
  if ans.error and ans.error ~= "" then
    if ns.UI and ns.UI.ShowError then
      ns.UI.ShowError(ans.error, req)
    else
      ns.Print("|cffff5555Companion error:|r " .. tostring(ans.error))
    end
  else
    if ns.UI and ns.UI.ShowAnswer then
      ns.UI.ShowAnswer(ans.answer or "", req, ans)
    else
      ns.Print(ans.answer or "")
    end
  end
end

----------------------------------------------------------------------
-- public API
----------------------------------------------------------------------

-- Ask a question. Builds the live context, queues it, and (if autoReload)
-- flushes via a reload so the companion can pick it up.
function Bridge.Ask(question)
  if type(question) ~= "string" then return end
  question = question:gsub("^%s+", ""):gsub("%s+$", "")
  if question == "" then return end

  local db = ns.Config.db
  local id = newId()
  local req = {
    id       = id,
    ts       = now(),
    question = question,
    context  = ns.Context.Build(),
  }

  local requests = getOutbox()
  requests[#requests + 1] = req
  db.pendingId = id   -- set before trimming so the active question is never dropped
  while #requests > MAX_OUTBOX do
    if requests[1].id == db.pendingId then break end
    table.remove(requests, 1)
  end
  saveOutbox(requests)

  db.awaitingSince = req.ts
  db.refreshCount  = 0

  if ns.UI and ns.UI.ShowSelf then ns.UI.ShowSelf(question) end

  if ns.Config.Get("autoReload") then
    local reloaded = ns.Compat.SafeReload()
    if not reloaded and ns.UI and ns.UI.ShowStatus then
      ns.UI.ShowStatus("combat")   -- queued until combat ends
    end
  elseif ns.UI and ns.UI.ShowStatus then
    ns.UI.ShowStatus("manual")     -- user must /reload then /ac get
  end
end

-- Force a fetch attempt now (used by the Refresh button / `/ac get`).
function Bridge.Refresh()
  -- A deliberate user fetch restarts the auto-poll budget, so we don't stay
  -- wedged at "timeout" after the automatic retries were exhausted.
  if ns.Config.db then ns.Config.db.refreshCount = 0 end
  ns.Compat.SafeReload()
end

-- Called once per addon load (after Config.Initialize) to deliver any answers
-- the companion produced and to keep polling for a still-pending question.
function Bridge.OnLoad()
  local db = ns.Config.db
  local inbox = readInbox()
  local answers = (inbox and inbox.answers) or nil

  local requests = getOutbox()
  local remaining = {}
  local deliveredPending = false

  for _, req in ipairs(requests) do
    local ans = answers and answers[req.id]
    if ans then
      deliver(req, ans)
      if req.id == db.pendingId then deliveredPending = true end
    else
      remaining[#remaining + 1] = req
    end
  end
  saveOutbox(remaining)

  local stillPending = false
  if db.pendingId then
    for _, req in ipairs(remaining) do
      if req.id == db.pendingId then stillPending = true break end
    end
  end

  if deliveredPending or not db.pendingId then
    db.pendingId    = nil
    db.refreshCount = 0
  elseif stillPending then
    local maxTries = ns.Config.Get("maxAutoRefresh") or 3
    if ns.Config.Get("autoReload") and (db.refreshCount or 0) < maxTries then
      if ns.UI and ns.UI.ShowStatus then ns.UI.ShowStatus("waiting") end
      ns.Compat.After(ns.Config.Get("refreshDelay") or 3, function()
        -- Re-check: a manual action may have cleared the pending question.
        if ns.Config.db.pendingId then
          ns.Config.db.refreshCount = (ns.Config.db.refreshCount or 0) + 1
          ns.Compat.SafeReload()
        end
      end)
    else
      if ns.UI and ns.UI.ShowStatus then ns.UI.ShowStatus("timeout") end
    end
  end
end

-- Clipboard fallback: the user pastes a Base64 payload the companion put on the
-- OS clipboard (no-reload mode). Returns true if an answer was displayed.
function Bridge.IngestPasted(text)
  if type(text) ~= "string" or text == "" then return false end
  local raw = ns.base64.decode(text)
  if not raw or raw == "" then return false end
  local ok, data = pcall(ns.json.decode, raw)
  if not ok or type(data) ~= "table" then return false end

  if data.answers and ns.Config.db.pendingId and data.answers[ns.Config.db.pendingId] then
    local id = ns.Config.db.pendingId
    deliver({ id = id, question = "(pasted)" }, data.answers[id])
    dropFromOutbox(id)          -- so the next reload doesn't re-deliver it
    ns.Config.db.pendingId = nil
    ns.Config.db.refreshCount = 0
    return true
  elseif data.answer then
    deliver({ question = "(pasted)" }, data)
    if ns.Config.db.pendingId then
      dropFromOutbox(ns.Config.db.pendingId)
      ns.Config.db.pendingId = nil
      ns.Config.db.refreshCount = 0
    end
    return true
  end
  return false
end

function Bridge.HasPending()
  return ns.Config.db and ns.Config.db.pendingId ~= nil
end

return Bridge
