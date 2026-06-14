--
-- Context.lua -- snapshot of the player's live situation.
--
-- This is what makes answers PERTINENT instead of generic: instead of hoping
-- the model guesses what you are doing, we read your real quest log, position,
-- target, role and instance straight from the game and ship that as structured
-- context with every question.
--

local ADDON, ns = ...

local Context = {}
ns.Context = Context

local MAX_QUESTS = 25     -- safety cap on payload size

local function round(n, places)
  if type(n) ~= "number" then return n end
  local m = 10 ^ (places or 1)
  return math.floor(n * m + 0.5) / m
end

-- Build the active-quest list from the quest log.
local function buildQuests()
  local Compat = ns.Compat
  local Config = ns.Config
  local playerLevel = Compat.GetPlayerLevel()
  local useQuestie = Config.Get("useQuestie") and ns.Questie and ns.Questie.IsAvailable()

  local quests = {}
  local num = Compat.GetNumQuestLogEntries() or 0
  for index = 1, num do
    if #quests >= MAX_QUESTS then break end
    local q = Compat.GetQuestLogTitle(index)
    if q and not q.isHeader then
      local objectives = Compat.GetQuestObjectives(index, q.questID)
      local entry = {
        index      = index,
        title      = q.title,
        level      = q.level,
        questID    = q.questID,
        isComplete = q.isComplete,
        isDaily    = q.isDaily,
        difficulty = Compat.GetQuestDifficulty(q.level, playerLevel),
        objectives = objectives,
      }
      local xp = Compat.GetQuestRewardXP(index, q.questID)
      if xp then entry.rewardXP = xp end

      -- Optional: enrich with Questie coordinates / zone for "where to go".
      if useQuestie and q.questID then
        local qd = ns.Questie.GetQuestData(q.questID)
        if qd then entry.questie = qd end
      end

      quests[#quests + 1] = entry
    end
  end
  return quests
end

-- Public: assemble the full context table (plain Lua table, JSON-friendly).
function Context.Build()
  local Compat = ns.Compat
  local Config = ns.Config

  local localizedClass, classToken = Compat.GetPlayerClass()
  local spec = select(1, Compat.GetSpecAndRole())
  local role = (Config.GetEffectiveRole())
  local realZone, subZone = Compat.GetZone()
  local x, y, mapName = Compat.GetPlayerPosition()
  local inInstance, instanceType, instanceName, difficultyName = Compat.GetInstanceInfo()
  local groupType, groupSize = Compat.GetGroupInfo()
  local target = Compat.GetTargetInfo()

  local ctx = {
    client = {
      interface = Compat.interfaceNumber,
      locale    = (GetLocale and GetLocale()) or "enUS",
    },
    prefs = {
      language     = Config.GetEffectiveLanguage(),
      verbosity    = Config.Get("verbosity"),
      xpMultiplier = Config.Get("xpMultiplier"),
    },
    player = {
      name    = Compat.GetPlayerName(),
      level   = Compat.GetPlayerLevel(),
      class   = localizedClass,
      classId = classToken,
      race    = select(1, Compat.GetPlayerRace()),
      faction = Compat.GetFactionGroup(),
      spec    = spec,
      role    = role,
    },
    location = {
      zone     = realZone,
      subZone  = subZone,
      mapName  = mapName,
      x        = round(x, 1),
      y        = round(y, 1),
    },
    instance = inInstance and {
      name       = instanceName,
      type       = instanceType,
      difficulty = difficultyName,
      groupType  = groupType,
      groupSize  = groupSize,
    } or nil,
    group = {
      type = groupType,
      size = groupSize,
    },
    target = target,
    quests = buildQuests(),
  }

  return ctx
end

return Context
