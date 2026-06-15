--
-- Knowledge.lua -- LOCAL boss/role tips, no companion, no /reload.
--
-- The dungeon & raid tips in KnowledgeData.lua are static facts, so we don't
-- need the LLM (or the file-bridge round-trip) to surface them. This module
-- matches the player's current instance + target against that baked-in DB and
-- prints role-appropriate tips INSTANTLY, in-game. That makes it safe to use
-- mid-pull, where a /reload would be risky.
--
-- The matching mirrors the companion's KnowledgeBase (azeroth_companion.py) so
-- the in-game answer and the LLM-grounding answer agree: substring match on the
-- instance name/aliases, then focus a boss by the question or the live target.
--

local ADDON, ns = ...

local Knowledge = {}
ns.Knowledge = Knowledge

local function lower(s) return (s or ""):lower() end

-- contains: plain (non-pattern) substring test, both already lowercased.
local function contains(hay, needle)
  if needle == "" then return false end
  return hay:find(needle, 1, true) ~= nil
end

-- Find the instance whose name/alias appears in (instanceName + " " + query).
-- Mirrors KnowledgeBase.find_instance.
function Knowledge.FindInstance(instanceName, query)
  local data = ns.KnowledgeData
  if not data or not data.instances then return nil end
  local hay = lower(instanceName) .. " " .. lower(query)
  for _, inst in ipairs(data.instances) do
    local names = { inst.name }
    if inst.aliases then
      for _, a in ipairs(inst.aliases) do names[#names + 1] = a end
    end
    for _, n in ipairs(names) do
      if contains(hay, lower(n)) then return inst end
    end
  end
  return nil
end

-- Focus a boss within an instance: first by the question text, then by the live
-- target name (bidirectional substring). Mirrors KnowledgeBase._focus_boss.
function Knowledge.FocusBoss(inst, query, targetName)
  if not inst or not inst.bosses then return nil end
  local q = lower(query)
  for _, boss in ipairs(inst.bosses) do
    if contains(q, lower(boss.name)) then return boss end
  end
  local tn = lower(targetName)
  if tn ~= "" then
    for _, boss in ipairs(inst.bosses) do
      local bn = lower(boss.name)
      if bn ~= "" and (contains(bn, tn) or contains(tn, bn)) then return boss end
    end
  end
  return nil
end

-- Resolve the situation from live game state, allowing a free-text override
-- (e.g. the player typed "/ac boss keleseth" outside the instance).
-- Returns inst, boss, role (role is "tank"|"healer"|"dps"|"unknown").
function Knowledge.Resolve(query)
  query = query or ""
  local _, _, instanceName = ns.Compat.GetInstanceInfo()
  local target = ns.Compat.GetTargetInfo()
  local targetName = target and target.name or nil
  local role = ns.Config.GetEffectiveRole()

  local inst = Knowledge.FindInstance(instanceName, query)
  -- Outside a known instance the player can still ask by name via the query.
  if not inst and query ~= "" then
    inst = Knowledge.FindInstance(query, query)
  end
  local boss = inst and Knowledge.FocusBoss(inst, query, targetName) or nil
  return inst, boss, role
end

----------------------------------------------------------------------
-- Rendering
----------------------------------------------------------------------

local ROLE_LABEL = { tank = "TANK", healer = "HEALER", dps = "DPS" }

-- Build the lines for an instance/boss focused on `role`. When `allRoles` is
-- false we show only the player's role bullets (compact, in-combat friendly).
local function buildLines(inst, boss, role, allRoles)
  local lines = {}
  lines[#lines + 1] = string.format("|cff66ccff%s|r |cff888888(%s)|r",
    inst.name, inst.levelRange or inst.type or "")

  if boss then
    lines[#lines + 1] = string.format("|cffffd100%s|r - %s", boss.name, boss.summary or "")
    if boss.positioning then
      lines[#lines + 1] = "|cffaaaaaaPositioning:|r " .. boss.positioning
    end
    local order = allRoles and { "tank", "healer", "dps" } or { role }
    local shown = false
    for _, r in ipairs(order) do
      local bullets = boss[r]
      if bullets and #bullets > 0 then
        shown = true
        local you = (r == role) and " |cff00ff00(YOU)|r" or ""
        lines[#lines + 1] = string.format("|cffffd100%s|r%s:", ROLE_LABEL[r] or r:upper(), you)
        for _, b in ipairs(bullets) do
          lines[#lines + 1] = "  - " .. b
        end
      end
    end
    if not shown then
      lines[#lines + 1] = "(No role tips recorded for this boss.)"
    end
  else
    local names = {}
    for _, b in ipairs(inst.bosses or {}) do names[#names + 1] = b.name end
    if #names > 0 then
      lines[#lines + 1] = "Bosses: " .. table.concat(names, ", ")
    end
    for i, tip in ipairs(inst.generalTips or {}) do
      if i > 4 then break end
      lines[#lines + 1] = "  - " .. tip
    end
    lines[#lines + 1] = "|cff888888(Target a boss or type its name for role tips.)|r"
  end
  return lines
end

-- Public: print tips for the current situation to the local chat frame.
-- opts = { query=string, allRoles=bool }. Returns true if anything matched.
function Knowledge.Show(opts)
  opts = opts or {}
  local inst, boss, role = Knowledge.Resolve(opts.query)
  if not inst then
    ns.Print("no local tips for this place. " ..
      "Try |cffffd100/ac boss <name>|r, or ask freely with |cffffd100/ac <question>|r.")
    return false
  end
  for _, line in ipairs(buildLines(inst, boss, role, opts.allRoles)) do
    ns.Print(line)
  end
  return true
end

return Knowledge
