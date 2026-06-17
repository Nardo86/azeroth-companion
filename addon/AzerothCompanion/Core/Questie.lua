--
-- Questie.lua -- OPTIONAL bridge to the Questie addon for coordinates.
--
-- Questie ships an enormous, accurate quest database (NPC/object spawn
-- coordinates, quest givers, turn-ins). When the player already has Questie
-- installed we borrow that data at RUNTIME (reading its in-memory tables) so
-- the assistant can say "go to (45.2, 63.1)" instead of guessing. When Questie
-- is absent we return nil and the assistant falls back to live quest-log text.
--
-- We only READ Questie's in-memory tables; we never copy or redistribute its
-- database files (its license is unclear - see docs/CREDITS.md).
--
-- API verified against the 3.3.5a fork Krigsgaldrnet/Questie-3.3.5 (~v9.5.1):
--   * detect:   IsAddOnLoaded("Questie-335") or _G.QuestieLoader; ready gate is
--               _G.Questie and Questie.started == true (DB init is async).
--   * modules:  QuestieLoader:ImportModule("QuestieDB" / "QuestiePlayer" / "ZoneDB")
--   * quest:    QuestieDB.GetQuest(questId)      -- DOT call
--               -> quest.ObjectiveData { {Type,Id,Text}, ... }, quest.Finisher {Type,Id,Name}
--   * spawns:   QuestieDB:GetNPC(id) / QuestieDB:GetObject(id)  -- COLON calls
--               -> .spawns = { [areaId] = { {x,y}, ... } }  (x,y are 0-100)
--   * computed: QuestiePlayer.currentQuestlog[questId].Objectives[i].spawnList
--   * zones:    ZoneDB:GetUiMapIdByAreaId(areaId)
--
-- Everything is wrapped in pcall: these are private APIs with no stability
-- guarantee, and we must never break the addon because Questie changed.
--

local ADDON, ns = ...

local Questie = {}
ns.Questie = Questie

local QuestieDB, QuestiePlayer, ZoneDB
local modulesResolved = false

local function resolveModules()
  if modulesResolved then return QuestieDB ~= nil end
  if _G.QuestieLoader and _G.QuestieLoader.ImportModule then
    pcall(function()
      QuestieDB     = _G.QuestieLoader:ImportModule("QuestieDB")
      QuestiePlayer = _G.QuestieLoader:ImportModule("QuestiePlayer")
      ZoneDB        = _G.QuestieLoader:ImportModule("ZoneDB")
    end)
  end
  modulesResolved = true
  return QuestieDB ~= nil
end

-- Available = loaded AND finished its async DB init (Questie.started).
function Questie.IsAvailable()
  local loaded = (_G.QuestieLoader ~= nil)
  if not loaded and _G.IsAddOnLoaded then
    local ok, isLoaded = pcall(_G.IsAddOnLoaded, "Questie-335")
    loaded = ok and isLoaded and true or false
  end
  if not loaded then return false end
  if not (_G.Questie and _G.Questie.started == true) then return false end
  return resolveModules()
end

local function areaName(areaId)
  if not ZoneDB or not areaId then return nil end
  local ok, name = pcall(function()
    -- Try a few accessors Questie/Blizzard expose; all best-effort.
    if ZoneDB.GetZoneNameByUiMapId and ZoneDB.GetUiMapIdByAreaId then
      local uiMap = ZoneDB:GetUiMapIdByAreaId(areaId)
      if uiMap then
        if _G.C_Map and _G.C_Map.GetMapInfo then
          local info = _G.C_Map.GetMapInfo(uiMap)
          if info then return info.name end
        end
        return ZoneDB:GetZoneNameByUiMapId(uiMap)
      end
    end
    return nil
  end)
  return ok and name or nil
end

-- The player's current zone name, set per call in GetQuestData so spawn
-- selection can prefer spawns where the player already is.
local currentZone = nil

-- Pick a spawn from a Questie spawns table { [areaId] = {{x,y},...} }.
-- Prefers the player's current zone; otherwise the area with the most spawn
-- points. Returns { areaId, zone, x, y, count } where `count` is the number of
-- spawn points in the chosen area -- a density hint: a higher count means the
-- objective is faster to complete there (lets the assistant flag dense quests).
local function firstSpawn(spawns)
  if type(spawns) ~= "table" then return nil end
  local bestArea, bestCoord, bestCount, bestZone = nil, nil, -1, nil
  for areaId, coords in pairs(spawns) do
    if type(coords) == "table" and type(coords[1]) == "table" then
      local zone = areaName(areaId)
      local count = #coords
      if currentZone and zone and zone == currentZone then
        return { areaId = areaId, zone = zone, x = coords[1][1], y = coords[1][2], count = count }
      end
      if count > bestCount then
        bestArea, bestCoord, bestCount, bestZone = areaId, coords[1], count, zone
      end
    end
  end
  if bestCoord then
    return { areaId = bestArea, zone = bestZone, x = bestCoord[1], y = bestCoord[2], count = bestCount }
  end
  return nil
end

local function npcSpawn(id)
  if not (QuestieDB and QuestieDB.GetNPC and id) then return nil end
  local ok, npc = pcall(function() return QuestieDB:GetNPC(id) end)
  if ok and npc and npc.spawns then
    local s = firstSpawn(npc.spawns)
    if s then s.name = npc.name end
    return s
  end
  return nil
end

local function objectSpawn(id)
  if not (QuestieDB and QuestieDB.GetObject and id) then return nil end
  local ok, obj = pcall(function() return QuestieDB:GetObject(id) end)
  if ok and obj and obj.spawns then
    local s = firstSpawn(obj.spawns)
    if s then s.name = obj.name end
    return s
  end
  return nil
end

-- True when the quest leads to or follows other quests (part of a chain). Such
-- quests are worth keeping even when their XP looks low. Best-effort: these are
-- private Questie fields with no stability guarantee, so each access is checked.
local function isChained(quest)
  if type(quest) ~= "table" then return nil end
  local function filled(v) return type(v) == "table" and next(v) ~= nil end
  if type(quest.nextQuestInChain) == "number" and quest.nextQuestInChain ~= 0 then return true end
  if filled(quest.childQuests) or filled(quest.preQuestSingle)
     or filled(quest.preQuestGroup) or filled(quest.exclusiveTo) then
    return true
  end
  return false
end

-- Returns a compact "where to go" table for a quest, or nil. `zone` is the
-- player's current zone, used to prefer nearby spawns.
-- { finisher = {name,zone,x,y,count}, objectives = { {name,zone,x,y,count}, ... },
--   chain = true }   -- `chain` is lifted onto the quest entry by Context.lua.
function Questie.GetQuestData(questID, zone)
  if not Questie.IsAvailable() or not questID then return nil end

  currentZone = zone
  local ok, result = pcall(function()
    local data = { objectives = {} }

    -- 1) Prefer Questie's computed, per-objective spawn lists (already by zone).
    if QuestiePlayer and QuestiePlayer.currentQuestlog then
      local q = QuestiePlayer.currentQuestlog[questID]
      if q and type(q.Objectives) == "table" then
        for _, o in ipairs(q.Objectives) do
          if type(o.spawnList) == "table" then
            for _, info in pairs(o.spawnList) do
              if type(info) == "table" and info.Spawns then
                local s = firstSpawn(info.Spawns)
                if s then
                  s.name = info.Name or s.name
                  data.objectives[#data.objectives + 1] = s
                  break
                end
              end
            end
          end
          if #data.objectives >= 6 then break end
        end
      end
    end

    -- 2) Static DB lookup (works even for quests not yet computed).
    if QuestieDB and QuestieDB.GetQuest then
      local quest = QuestieDB.GetQuest(questID)
      if quest then
        if isChained(quest) then data.chain = true end
        if quest.Finisher and quest.Finisher.Id then
          local s = npcSpawn(quest.Finisher.Id)
          if s then
            s.name = quest.Finisher.Name or s.name
            data.finisher = s
          end
        end
        if #data.objectives == 0 and type(quest.ObjectiveData) == "table" then
          for _, od in ipairs(quest.ObjectiveData) do
            local s
            if od.Type == "monster" or od.Type == "killcredit" then
              s = npcSpawn(od.Id)
            elseif od.Type == "object" then
              s = objectSpawn(od.Id)
            end
            if s then
              s.objective = od.Text
              data.objectives[#data.objectives + 1] = s
            end
            if #data.objectives >= 6 then break end
          end
        end
      end
    end

    if #data.objectives == 0 then data.objectives = nil end
    if not data.finisher and not data.objectives and not data.chain then return nil end
    return data
  end)

  currentZone = nil
  return ok and result or nil
end

return Questie
