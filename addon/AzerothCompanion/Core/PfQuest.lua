--
-- PfQuest.lua -- OPTIONAL runtime bridge to pfQuest for coordinates.
--
-- A second, version-agnostic coordinate source alongside Questie. pfQuest
-- (shagu/pfQuest; 3.3.5 port Bennylavaa/pfQuest-wotlk) is clearly GPLv3, but we
-- only READ its in-memory tables at runtime (we ship none of its data), so
-- there is no license entanglement with this MIT addon.
--
-- pfQuest data layout (read-only):
--   pfDB.quests.data[questID] = { start = {U=,O=,I=}, ["end"] = {U=,O=,I=},
--                                 obj = {U=,O=,I=}, ... }  -- U=units O=objects I=items
--   pfDB.units.data[npcId]    = { coords = { {x, y, zoneId, respawn}, ... }, ... }
--   pfDB.objects.data[objId]  = { coords = { {x, y, zoneId, respawn}, ... }, ... }
--   pfDB.units.loc[npcId]     = "localized name"   (also objects.loc / quests.loc)
--   x,y are 0-100. Everything here is pcall-guarded against shape changes.
--

local ADDON, ns = ...

local PfQuest = {}
ns.PfQuest = PfQuest

local function db()
  return _G.pfDB
end

function PfQuest.IsAvailable()
  local loaded = false
  if _G.IsAddOnLoaded then
    for _, name in ipairs({ "pfQuest", "pfQuest-wotlk", "pfQuest_Vanilla", "pfQuest-tbc" }) do
      local ok, isLoaded = pcall(_G.IsAddOnLoaded, name)
      if ok and isLoaded then loaded = true break end
    end
  end
  local d = db()
  if not loaded and type(d) ~= "table" then return false end
  return (type(d) == "table" and type(d.units) == "table" and type(d.quests) == "table") and true or false
end

local function nameFrom(section, id)
  local d = db()
  local loc = d and d[section] and d[section].loc
  local v = loc and loc[id]
  -- pfQuest loc entries are usually the plain name string.
  if type(v) == "string" then return v end
  if type(v) == "table" then return v[1] or v.name end
  return nil
end

local function zoneName(zoneId)
  if not zoneId then return nil end
  local ok, name = pcall(function()
    if _G.pfMap and _G.pfMap.zones and _G.pfMap.zones[zoneId] then
      return _G.pfMap.zones[zoneId]
    end
    if _G.pfDatabase and _G.pfDatabase.zones and _G.pfDatabase.zones[zoneId] then
      return _G.pfDatabase.zones[zoneId]
    end
    return nil
  end)
  return ok and name or nil
end

-- Accepts a pfQuest unit/object data entry and returns a single {x,y,zoneId}.
-- Tolerates either { coords = {...} } or the coords list directly.
local function firstCoord(entry)
  if type(entry) ~= "table" then return nil end
  local list = entry.coords or entry
  if type(list) ~= "table" then return nil end
  for _, c in ipairs(list) do
    if type(c) == "table" and type(c[1]) == "number" and type(c[2]) == "number" then
      return { x = c[1], y = c[2], zoneId = c[3] }
    end
  end
  return nil
end

local function unitSpawn(id)
  local d = db()
  local entry = d and d.units and d.units.data and d.units.data[id]
  local s = firstCoord(entry)
  if s then s.name = nameFrom("units", id); s.zone = zoneName(s.zoneId) end
  return s
end

local function objectSpawn(id)
  local d = db()
  local entry = d and d.objects and d.objects.data and d.objects.data[id]
  local s = firstCoord(entry)
  if s then s.name = nameFrom("objects", id); s.zone = zoneName(s.zoneId) end
  return s
end

-- Same return shape as Questie.GetQuestData:
-- { source="pfquest", finisher = {name,zone,x,y}, objectives = { {name,zone,x,y}, ... } }
function PfQuest.GetQuestData(questID)
  if not PfQuest.IsAvailable() or not questID then return nil end

  local ok, result = pcall(function()
    local d = db()
    local q = d.quests and d.quests.data and d.quests.data[questID]
    if type(q) ~= "table" then return nil end

    local data = { objectives = {}, source = "pfquest" }

    -- Turn-in (the "end" group): prefer an NPC, fall back to an object.
    local fin = q["end"]
    if type(fin) == "table" then
      if type(fin.U) == "table" then
        for _, id in ipairs(fin.U) do local s = unitSpawn(id); if s then data.finisher = s; break end end
      end
      if not data.finisher and type(fin.O) == "table" then
        for _, id in ipairs(fin.O) do local s = objectSpawn(id); if s then data.finisher = s; break end end
      end
    end

    -- Objectives (the "obj" group): units to kill and objects to use.
    local obj = q.obj
    if type(obj) == "table" then
      if type(obj.U) == "table" then
        for _, id in ipairs(obj.U) do
          local s = unitSpawn(id)
          if s then data.objectives[#data.objectives + 1] = s end
          if #data.objectives >= 6 then break end
        end
      end
      if type(obj.O) == "table" and #data.objectives < 6 then
        for _, id in ipairs(obj.O) do
          local s = objectSpawn(id)
          if s then data.objectives[#data.objectives + 1] = s end
          if #data.objectives >= 6 then break end
        end
      end
    end

    if #data.objectives == 0 then data.objectives = nil end
    if not data.finisher and not data.objectives then return nil end
    return data
  end)

  return ok and result or nil
end

return PfQuest
