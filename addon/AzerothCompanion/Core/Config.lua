--
-- Config.lua -- in-game settings, persisted to SavedVariables.
--
-- NOTE on responsibilities:
--   * The CONNECTION settings (endpoint URL, API key, model) live in the
--     COMPANION app's config.json, NOT here -- the addon cannot make HTTP
--     calls, so it has no use for an API key and we never want a secret key
--     sitting in a SavedVariables file.
--   * This file holds the GAMEPLAY preferences that shape the assistant's
--     answers (language, role override, server XP multiplier, verbosity).
--     They travel to the companion inside every request's context.
--

local ADDON, ns = ...

local Config = {}
ns.Config = Config

-- Defaults. AzerothCompanionDB (account-wide) is created/merged on load.
local DEFAULTS = {
  protocol       = 1,
  language       = "auto",   -- "auto" = use the client locale; or "it","en","es",...
  verbosity      = "normal", -- "short" | "normal" | "detailed"
  xpMultiplier   = 1,        -- set to e.g. 5 on a Warmane 5x realm for skip advice
  autoReload     = true,     -- auto /reload to flush the question and fetch the answer
  refreshDelay   = 3,        -- seconds to wait before the fetch reload
  maxAutoRefresh = 3,        -- give up auto-refreshing after this many tries
  useQuestie     = true,     -- pull coordinates from Questie when it is installed
  channelName    = "Companion",
  greeted        = false,
}

-- Per-character bits (role override is character specific).
local CHAR_DEFAULTS = {
  roleOverride = "auto",     -- "auto" | "tank" | "healer" | "dps"
}

local function mergeDefaults(target, defaults)
  for k, v in pairs(defaults) do
    if target[k] == nil then
      target[k] = v
    end
  end
  return target
end

function Config.Initialize()
  _G.AzerothCompanionDB = _G.AzerothCompanionDB or {}
  _G.AzerothCompanionCharDB = _G.AzerothCompanionCharDB or {}
  mergeDefaults(_G.AzerothCompanionDB, DEFAULTS)
  mergeDefaults(_G.AzerothCompanionCharDB, CHAR_DEFAULTS)
  Config.db = _G.AzerothCompanionDB
  Config.chardb = _G.AzerothCompanionCharDB
end

function Config.Get(key)
  if Config.db == nil then Config.Initialize() end
  return Config.db[key]
end

function Config.Set(key, value)
  if Config.db == nil then Config.Initialize() end
  Config.db[key] = value
  return value
end

function Config.GetChar(key)
  if Config.chardb == nil then Config.Initialize() end
  return Config.chardb[key]
end

function Config.SetChar(key, value)
  if Config.chardb == nil then Config.Initialize() end
  Config.chardb[key] = value
  return value
end

-- The role we actually report to the assistant: explicit override, else auto.
function Config.GetEffectiveRole()
  local override = Config.GetChar("roleOverride")
  if override and override ~= "auto" then
    return override, true
  end
  local _, role = ns.Compat.GetSpecAndRole()
  return role or "unknown", false
end

-- Resolve "auto" language to a concrete code using the client locale.
function Config.GetEffectiveLanguage()
  local lang = Config.Get("language")
  if lang and lang ~= "auto" then return lang end
  local locale = (GetLocale and GetLocale()) or "enUS"
  local map = {
    itIT = "it", enUS = "en", enGB = "en", deDE = "de", frFR = "fr",
    esES = "es", esMX = "es", ptBR = "pt", ruRU = "ru", koKR = "ko",
    zhCN = "zh", zhTW = "zh",
  }
  return map[locale] or "en"
end

return Config
