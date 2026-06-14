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

-- Pull the first spawn out of a Questie spawns table { [areaId] = {{x,y},...} }.
local function firstSpawn(spawns)
  if type(spawns) ~= "table" then return nil end
  for areaId, coords in pairs(spawns) do
    if type(coords) == "table" and type(coords[1]) == "table" then
      local c = coords[1]
      return { areaId = areaId, zone = areaName(areaId), x = c[1], y = c[2] }
    end
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

-- Returns a compact "where to go" table for a quest, or nil.
-- { finisher = {name,zone,x,y}, objectives = { {name,zone,x,y}, ... } }
function Questie.GetQuestData(questID)
  if not Questie.IsAvailable() or not questID then return nil end

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
    if not data.finisher and not data.objectives then return nil end
    return data
  end)

  return ok and result or nil
end

return Questie
