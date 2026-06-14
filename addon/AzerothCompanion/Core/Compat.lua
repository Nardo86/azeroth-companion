--
-- Compat.lua -- cross-client-version abstraction layer.
--
-- The whole point of this file: the rest of the addon NEVER calls a raw
-- Blizzard API that might or might not exist on a given client. It calls
-- ns.Compat.* helpers that feature-detect the right API at runtime, so the
-- same addon works on 3.3.5a (Warmane & co.), WotLK/Cata Classic and retail.
--
-- Design rule: feature-detect by checking the function exists, not by parsing
-- the interface number. pcall around anything that could throw on a client
-- where the signature differs. Always return normalized tables/strings.
--

local ADDON, ns = ...

local Compat = {}
ns.Compat = Compat

local _G = _G
local pcall = pcall
local select = select
local tonumber = tonumber

----------------------------------------------------------------------
-- Client identification
----------------------------------------------------------------------

local interfaceNumber
do
  local ok, _v, _b, _d, toc = pcall(GetBuildInfo)
  interfaceNumber = (ok and tonumber(toc)) or 30300
end

Compat.interfaceNumber = interfaceNumber

-- Coarse buckets. Used only for cosmetic/logging decisions; behaviour is
-- always driven by feature detection below, never by these flags.
Compat.isVanilla   = interfaceNumber < 20000
Compat.isTBC       = interfaceNumber >= 20000 and interfaceNumber < 30000
Compat.isWrath     = interfaceNumber >= 30000 and interfaceNumber < 40000
Compat.isCata      = interfaceNumber >= 40000 and interfaceNumber < 50000
Compat.isModern    = interfaceNumber >= 100000          -- Dragonflight / TWW+
Compat.isClassicWrath = Compat.isWrath and interfaceNumber >= 30400  -- WotLK Classic vs 3.3.5a

-- Feature flags (the things we actually branch on).
local HAS_C_QUESTLOG   = _G.C_QuestLog ~= nil and _G.C_QuestLog.GetNumQuestLogEntries ~= nil
local HAS_C_MAP        = _G.C_Map ~= nil and _G.C_Map.GetBestMapForUnit ~= nil
local HAS_C_TIMER      = _G.C_Timer ~= nil and _G.C_Timer.After ~= nil
local HAS_GETSPEC      = type(_G.GetSpecialization) == "function"
local HAS_NUM_GROUP    = type(_G.GetNumGroupMembers) == "function"

Compat.hasCQuestLog = HAS_C_QUESTLOG

----------------------------------------------------------------------
-- Timer  (C_Timer.After is MoP+; on 3.3.5 we roll our own via OnUpdate)
----------------------------------------------------------------------

local timerFrame = CreateFrame("Frame")
local pending = {}    -- list of { remaining = sec, fn = func }

timerFrame:SetScript("OnUpdate", function(self, elapsed)
  if #pending == 0 then return end
  for i = #pending, 1, -1 do
    local t = pending[i]
    t.remaining = t.remaining - elapsed
    if t.remaining <= 0 then
      table.remove(pending, i)
      local ok, err = pcall(t.fn)
      if not ok and ns.Debug then
        ns.Debug("timer callback error: " .. tostring(err))
      end
    end
  end
end)

function Compat.After(seconds, fn)
  if HAS_C_TIMER then
    _G.C_Timer.After(seconds, fn)
  else
    pending[#pending + 1] = { remaining = seconds, fn = fn }
  end
end

----------------------------------------------------------------------
-- Safe ReloadUI (blocked during combat -> defer until combat ends)
----------------------------------------------------------------------

local reloadQueued = false
local combatWatcher = CreateFrame("Frame")
combatWatcher:RegisterEvent("PLAYER_REGEN_ENABLED")
combatWatcher:SetScript("OnEvent", function()
  if reloadQueued then
    reloadQueued = false
    ReloadUI()
  end
end)

-- Returns true if the reload happened now, false if it was deferred.
function Compat.SafeReload()
  if InCombatLockdown and InCombatLockdown() then
    reloadQueued = true
    return false
  end
  ReloadUI()
  return true
end

function Compat.ReloadIsQueued()
  return reloadQueued
end

----------------------------------------------------------------------
-- Player basics
----------------------------------------------------------------------

function Compat.GetPlayerName()
  return (UnitName("player"))
end

function Compat.GetPlayerLevel()
  return UnitLevel("player") or 0
end

-- Returns localizedClass, classToken (e.g. "Guerriero", "WARRIOR")
function Compat.GetPlayerClass()
  local localized, token = UnitClass("player")
  return localized, token
end

function Compat.GetPlayerRace()
  local localized, token = UnitRace("player")
  return localized, token
end

function Compat.GetFactionGroup()
  local f = UnitFactionGroup("player")   -- "Alliance" / "Horde"
  return f
end

----------------------------------------------------------------------
-- Zone / position
----------------------------------------------------------------------

function Compat.GetZone()
  local realZone = GetRealZoneText and GetRealZoneText() or (GetZoneText and GetZoneText()) or ""
  local subZone  = GetSubZoneText and GetSubZoneText() or ""
  return realZone, subZone
end

-- Returns x, y in 0..100 (percent) plus the map name, or nil if unavailable.
function Compat.GetPlayerPosition()
  if HAS_C_MAP then
    local ok, mapID = pcall(_G.C_Map.GetBestMapForUnit, "player")
    if ok and mapID then
      local ok2, pos = pcall(_G.C_Map.GetPlayerMapPosition, mapID, "player")
      if ok2 and pos then
        local x, y = pos:GetXY()
        if x and y then
          local info = _G.C_Map.GetMapInfo and _G.C_Map.GetMapInfo(mapID)
          return x * 100, y * 100, info and info.name or nil
        end
      end
    end
    return nil
  else
    -- 3.3.5 path
    if SetMapToCurrentZone then pcall(SetMapToCurrentZone) end
    if GetPlayerMapPosition then
      local ok, x, y = pcall(GetPlayerMapPosition, "player")
      if ok and x and y and (x > 0 or y > 0) then
        local mapName = GetMapInfo and select(1, GetMapInfo()) or (GetZoneText and GetZoneText())
        return x * 100, y * 100, mapName
      end
    end
    return nil
  end
end

----------------------------------------------------------------------
-- Spec / role detection
----------------------------------------------------------------------

-- For 3.3.5 we infer spec & role from where the player spent the most talent
-- points. (classToken, primaryTabIndex) -> { spec = "...", role = "tank|healer|dps" }
-- Ambiguous specs (Feral druid, Death Knight) default to dps and can be
-- overridden by the player in the addon config.
local TALENT_ROLE = {
  WARRIOR     = { [1] = {spec="Arms",         role="dps"},    [2] = {spec="Fury",          role="dps"},    [3] = {spec="Protection", role="tank"} },
  PALADIN     = { [1] = {spec="Holy",         role="healer"}, [2] = {spec="Protection",    role="tank"},   [3] = {spec="Retribution", role="dps"} },
  HUNTER      = { [1] = {spec="Beast Mastery",role="dps"},    [2] = {spec="Marksmanship",  role="dps"},    [3] = {spec="Survival",   role="dps"} },
  ROGUE       = { [1] = {spec="Assassination",role="dps"},    [2] = {spec="Combat",        role="dps"},    [3] = {spec="Subtlety",   role="dps"} },
  PRIEST      = { [1] = {spec="Discipline",   role="healer"}, [2] = {spec="Holy",          role="healer"}, [3] = {spec="Shadow",     role="dps"} },
  DEATHKNIGHT = { [1] = {spec="Blood",        role="dps"},    [2] = {spec="Frost",         role="dps"},    [3] = {spec="Unholy",     role="dps"} },
  SHAMAN      = { [1] = {spec="Elemental",    role="dps"},    [2] = {spec="Enhancement",   role="dps"},    [3] = {spec="Restoration",role="healer"} },
  MAGE        = { [1] = {spec="Arcane",       role="dps"},    [2] = {spec="Fire",          role="dps"},    [3] = {spec="Frost",      role="dps"} },
  WARLOCK     = { [1] = {spec="Affliction",   role="dps"},    [2] = {spec="Demonology",    role="dps"},    [3] = {spec="Destruction",role="dps"} },
  DRUID       = { [1] = {spec="Balance",      role="dps"},    [2] = {spec="Feral",         role="dps"},    [3] = {spec="Restoration",role="healer"} },
}

-- Returns spec (string|nil), role ("tank"|"healer"|"dps"|"unknown")
function Compat.GetSpecAndRole()
  -- Retail / modern: ask the game directly.
  if HAS_GETSPEC then
    local ok, idx = pcall(_G.GetSpecialization)
    if ok and idx then
      local _, name = pcall(function() return select(2, _G.GetSpecializationInfo(_G.GetSpecialization())) end)
      local role
      if _G.GetSpecializationRole then
        local okr, r = pcall(_G.GetSpecializationRole, idx)
        if okr and r then
          role = (r == "TANK" and "tank") or (r == "HEALER" and "healer") or "dps"
        end
      end
      return (type(name) == "string" and name) or nil, role or "dps"
    end
  end

  -- 3.3.5 / WotLK: infer from talent tabs.
  if GetNumTalentTabs and GetTalentTabInfo then
    local _, classToken = UnitClass("player")
    local best, bestPoints = nil, -1
    local okTabs, numTabs = pcall(GetNumTalentTabs)
    if okTabs and numTabs then
      for tab = 1, numTabs do
        -- 3.3.5 signature: id, name, description, icon, pointsSpent, ...
        local ok, _id, _name, _desc, _icon, points = pcall(GetTalentTabInfo, tab)
        if ok and type(points) == "number" and points > bestPoints then
          bestPoints, best = points, tab
        end
      end
    end
    if best and classToken and TALENT_ROLE[classToken] and TALENT_ROLE[classToken][best] then
      local m = TALENT_ROLE[classToken][best]
      return m.spec, m.role
    end
  end

  return nil, "unknown"
end

----------------------------------------------------------------------
-- Group / instance
----------------------------------------------------------------------

-- Returns groupType ("solo"|"party"|"raid"), size
function Compat.GetGroupInfo()
  if HAS_NUM_GROUP then
    local n = GetNumGroupMembers() or 0
    if IsInRaid and IsInRaid() then return "raid", n end
    if n > 0 then return "party", n end
    return "solo", 1
  else
    local raid = (GetNumRaidMembers and GetNumRaidMembers()) or 0
    if raid > 0 then return "raid", raid end
    local party = (GetNumPartyMembers and GetNumPartyMembers()) or 0
    if party > 0 then return "party", party + 1 end
    return "solo", 1
  end
end

-- Returns inInstance(bool), instanceType(string), name(string|nil),
-- difficultyName(string|nil)
function Compat.GetInstanceInfo()
  local inInstance, instanceType = false, "none"
  if IsInInstance then
    local ok, a, b = pcall(IsInInstance)
    if ok then inInstance, instanceType = a and true or false, b or "none" end
  end
  local name, difficultyName
  if _G.GetInstanceInfo then
    local ok, n, _t, _diffIndex, diffName = pcall(_G.GetInstanceInfo)
    if ok then
      name = n
      difficultyName = diffName
    end
  end
  if not name then
    name = select(1, Compat.GetZone())
  end
  return inInstance, instanceType, name, difficultyName
end

----------------------------------------------------------------------
-- Target
----------------------------------------------------------------------

-- Returns nil if no target, else { name, classification, level, isDead, isEnemy }
function Compat.GetTargetInfo()
  if not (UnitExists and UnitExists("target")) then return nil end
  return {
    name           = UnitName("target"),
    classification = UnitClassification and UnitClassification("target") or "normal",
    level          = UnitLevel and UnitLevel("target") or nil,
    isDead         = UnitIsDead and UnitIsDead("target") or false,
    isEnemy        = UnitCanAttack and UnitCanAttack("player", "target") or false,
  }
end

----------------------------------------------------------------------
-- Quest log (the part that differs the most between clients)
----------------------------------------------------------------------

-- Returns numEntries (headers + quests), numQuests
function Compat.GetNumQuestLogEntries()
  if HAS_C_QUESTLOG then
    return _G.C_QuestLog.GetNumQuestLogEntries()
  end
  return GetNumQuestLogEntries()
end

-- Extract the numeric questID from a quest log index, cross-version.
local function questIDFromLink(index)
  if not GetQuestLink then return nil end
  local link = GetQuestLink(index)
  if not link then return nil end
  local id = link:match("|Hquest:(%d+):")
  return id and tonumber(id) or nil
end

-- Normalized quest entry:
-- { title, level, isHeader, isComplete, isDaily, questID, tag, group }
function Compat.GetQuestLogTitle(index)
  -- (1) Modern namespaced API (retail + modern Classic). NOTE: C_QuestLog.GetInfo
  -- has NO isComplete field; completion is queried via C_QuestLog.IsComplete.
  if HAS_C_QUESTLOG and _G.C_QuestLog.GetInfo then
    local info = _G.C_QuestLog.GetInfo(index)
    if not info then return nil end
    local complete = false
    if not info.isHeader and info.questID and _G.C_QuestLog.IsComplete then
      local ok, c = pcall(_G.C_QuestLog.IsComplete, info.questID)
      complete = (ok and c) and true or false
    end
    return {
      title      = info.title,
      level      = info.level,
      isHeader   = info.isHeader and true or false,
      isComplete = complete,
      isDaily    = (info.frequency and info.frequency ~= 0) and true or false,
      questID    = info.questID,
      tag        = nil,
      group      = info.suggestedGroup,
    }
  elseif interfaceNumber < 40000 then
    -- (2) 3.3.5a / TBC / Vanilla positional signature (questID added in 3.3.0):
    -- title, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questID
    local title, level, questTag, suggestedGroup, isHeader, _isCollapsed, isComplete, isDaily, questID = GetQuestLogTitle(index)
    if title == nil then return nil end
    return {
      title      = title,
      level      = level,
      isHeader   = isHeader and true or false,
      -- isComplete is +1 (complete) / -1 (failed) / nil in 3.3.5a.
      isComplete = (isComplete == 1 or isComplete == true),
      isDaily    = isDaily and true or false,
      questID    = (not isHeader) and (questID or questIDFromLink(index)) or nil,
      tag        = questTag,
      group      = suggestedGroup,
    }
  else
    -- (3) Post-6.0 global signature (e.g. a Cata-era client without GetInfo):
    -- title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID
    local title, level, suggestedGroup, isHeader, _isCollapsed, isComplete, frequency, questID = GetQuestLogTitle(index)
    if title == nil then return nil end
    return {
      title      = title,
      level      = level,
      isHeader   = isHeader and true or false,
      isComplete = (isComplete == 1 or isComplete == true),
      isDaily    = (frequency and frequency ~= 0) and true or false,
      questID    = (not isHeader) and (questID or questIDFromLink(index)) or nil,
      tag        = nil,
      group      = suggestedGroup,
    }
  end
end

-- Returns descriptionText, objectivesText for the quest at `index`
-- (questID required on modern clients).
function Compat.GetQuestText(index, questID)
  if HAS_C_QUESTLOG then
    -- Modern: text comes from the quest log frame data; fall back gracefully.
    local desc = _G.C_QuestLog.GetQuestDescription and questID and _G.C_QuestLog.GetQuestDescription(questID) or nil
    return desc, nil
  else
    if SelectQuestLogEntry then SelectQuestLogEntry(index) end
    if GetQuestLogQuestText then
      local desc, obj = GetQuestLogQuestText()
      return desc, obj
    end
  end
  return nil, nil
end

-- Returns a list of objectives: { {text, type, finished, have, need}, ... }
function Compat.GetQuestObjectives(index, questID)
  local out = {}
  if HAS_C_QUESTLOG and _G.C_QuestLog.GetQuestObjectives and questID then
    local ok, objs = pcall(_G.C_QuestLog.GetQuestObjectives, questID)
    if ok and objs then
      for _, o in ipairs(objs) do
        out[#out + 1] = {
          text     = o.text,
          type     = o.type,
          finished = o.finished and true or false,
          have     = o.numFulfilled,
          need     = o.numRequired,
        }
      end
    end
    return out
  else
    if SelectQuestLogEntry then SelectQuestLogEntry(index) end
    if not (GetNumQuestLeaderBoards and GetQuestLogLeaderBoard) then return out end
    local n = GetNumQuestLeaderBoards(index) or 0
    for i = 1, n do
      local text, objType, finished = GetQuestLogLeaderBoard(i, index)
      if text then
        -- 3.3.5 text looks like "Slain Boars: 3/8" -> pull have/need if present.
        local have, need = text:match("(%d+)%s*/%s*(%d+)")
        out[#out + 1] = {
          text     = text,
          type     = objType,
          finished = finished and true or false,
          have     = have and tonumber(have) or nil,
          need     = need and tonumber(need) or nil,
        }
      end
    end
    return out
  end
end

-- Best-effort reward XP for the quest at `index` (after SelectQuestLogEntry on
-- 3.3.5). Returns a number or nil if the client does not expose it.
function Compat.GetQuestRewardXP(index, questID)
  if HAS_C_QUESTLOG and _G.GetQuestLogRewardXP and questID then
    local ok, xp = pcall(_G.GetQuestLogRewardXP, questID)
    if ok and type(xp) == "number" then return xp end
  end
  if GetQuestLogRewardXP then
    if SelectQuestLogEntry then SelectQuestLogEntry(index) end
    local ok, xp = pcall(GetQuestLogRewardXP)
    if ok and type(xp) == "number" and xp > 0 then return xp end
  end
  return nil
end

-- Quest difficulty colour relative to the player level: returns one of
-- "trivial" (gray), "low" (green), "standard" (yellow), "hard" (orange),
-- "very_hard" (red). Useful to flag low-value quests on high-XP servers.
function Compat.GetQuestDifficulty(questLevel, playerLevel)
  if not questLevel or not playerLevel then return "unknown" end
  local diff = questLevel - playerLevel
  if diff >= 5 then return "very_hard" end
  if diff >= 3 then return "hard" end
  if diff >= -2 then return "standard" end
  -- Approximate the classic "gray" threshold.
  local grayBand
  if playerLevel <= 5 then grayBand = -100
  elseif playerLevel <= 39 then grayBand = -math.floor(playerLevel / 10) - 5
  elseif playerLevel <= 59 then grayBand = -math.floor(playerLevel / 5) - 1
  else grayBand = -9 end
  if questLevel <= (playerLevel + grayBand) then return "trivial" end
  return "low"
end

return Compat
