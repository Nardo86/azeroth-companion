--
-- Init.lua -- entry point: events, slash commands, bootstrap.
--

local ADDON, ns = ...

----------------------------------------------------------------------
-- console output helpers
----------------------------------------------------------------------

function ns.Print(msg)
  local f = DEFAULT_CHAT_FRAME or ChatFrame1
  if f then
    f:AddMessage("|cff66ccffAzeroth Companion|r: " .. tostring(msg))
  end
end

function ns.Debug(msg)
  if ns.Config and ns.Config.db and ns.Config.db.debug then
    ns.Print("|cff888888[debug]|r " .. tostring(msg))
  end
end

----------------------------------------------------------------------
-- paste dialog (clipboard / no-reload fallback mode)
----------------------------------------------------------------------

StaticPopupDialogs = StaticPopupDialogs or {}
StaticPopupDialogs["AZEROTHCOMPANION_PASTE"] = {
  text = "Paste the answer payload from the companion app:",
  button1 = _G.ACCEPT or "OK",
  button2 = _G.CANCEL or "Cancel",
  hasEditBox = true,
  editBoxWidth = 300,
  OnAccept = function(self)
    local box = self.editBox or (self.GetEditBox and self:GetEditBox())
    local txt = box and box:GetText()
    if txt and not ns.Bridge.IngestPasted(txt) then
      ns.Print("Could not read that payload.")
    end
  end,
  EditBoxOnEnterPressed = function(self)
    local parent = self:GetParent()
    local txt = self:GetText()
    if txt then ns.Bridge.IngestPasted(txt) end
    if parent and parent.Hide then parent:Hide() end
  end,
  EditBoxOnEscapePressed = function(self)
    local parent = self:GetParent()
    if parent and parent.Hide then parent:Hide() end
  end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
}

----------------------------------------------------------------------
-- slash commands
----------------------------------------------------------------------

local function printHelp()
  ns.Print("commands:")
  ns.Print("  /ac                 - toggle the window")
  ns.Print("  /ac <question>      - ask directly")
  ns.Print("  /ac get             - fetch the pending answer now")
  ns.Print("  /ac role <auto|tank|healer|dps>")
  ns.Print("  /ac xp <number>     - server XP multiplier (e.g. 5)")
  ns.Print("  /ac lang <auto|it|en|...>")
  ns.Print("  /ac verbosity <short|normal|detailed>")
  ns.Print("  /ac auto <on|off>   - auto /reload to send & fetch")
  ns.Print("  /ac paste           - paste an answer (no-reload mode)")
  ns.Print("  /ac status          - show current settings")
  ns.Print("  /ac reset           - reset the window position")
end

local function handleSlash(msg)
  msg = msg or ""
  local cmd, rest = msg:match("^(%S*)%s*(.-)$")
  cmd = (cmd or ""):lower()

  if cmd == "" then
    ns.UI.Toggle()
  elseif cmd == "get" or cmd == "refresh" then
    ns.Bridge.Refresh()
  elseif cmd == "help" then
    printHelp()
  elseif cmd == "show" then
    ns.UI.Show()
  elseif cmd == "hide" then
    ns.UI.Hide()
  elseif cmd == "paste" then
    StaticPopup_Show("AZEROTHCOMPANION_PASTE")
  elseif cmd == "role" then
    local v = (rest or ""):lower()
    if v == "auto" or v == "tank" or v == "healer" or v == "dps" then
      ns.Config.SetChar("roleOverride", v)
      ns.Print("role set to " .. v)
    else
      local role = ns.Config.GetEffectiveRole()
      ns.Print("current role: " .. tostring(role) .. " (use auto|tank|healer|dps)")
    end
  elseif cmd == "xp" then
    local n = tonumber(rest)
    if n and n >= 1 then
      ns.Config.Set("xpMultiplier", n)
      ns.Print("XP multiplier set to " .. n .. "x")
    else
      ns.Print("XP multiplier is " .. tostring(ns.Config.Get("xpMultiplier")) .. "x (usage: /ac xp 5)")
    end
  elseif cmd == "lang" or cmd == "language" then
    if rest and rest ~= "" then
      ns.Config.Set("language", rest:lower())
      ns.Print("language set to " .. rest:lower())
    else
      ns.Print("language: " .. tostring(ns.Config.Get("language")) .. " -> " .. ns.Config.GetEffectiveLanguage())
    end
  elseif cmd == "verbosity" or cmd == "verbose" then
    local v = (rest or ""):lower()
    if v == "short" or v == "normal" or v == "detailed" then
      ns.Config.Set("verbosity", v)
      ns.Print("verbosity set to " .. v)
    else
      ns.Print("verbosity is " .. tostring(ns.Config.Get("verbosity")))
    end
  elseif cmd == "auto" then
    local v = (rest or ""):lower()
    if v == "on" or v == "true" or v == "1" then
      ns.Config.Set("autoReload", true); ns.Print("auto-reload ON")
    elseif v == "off" or v == "false" or v == "0" then
      ns.Config.Set("autoReload", false); ns.Print("auto-reload OFF (use /reload + /ac get)")
    else
      ns.Print("auto-reload is " .. tostring(ns.Config.Get("autoReload")))
    end
  elseif cmd == "status" then
    local role, forced = ns.Config.GetEffectiveRole()
    ns.Print(string.format("lang=%s role=%s%s xp=%sx verbosity=%s auto=%s questie=%s",
      ns.Config.GetEffectiveLanguage(),
      tostring(role), forced and "(set)" or "(auto)",
      tostring(ns.Config.Get("xpMultiplier")),
      tostring(ns.Config.Get("verbosity")),
      tostring(ns.Config.Get("autoReload")),
      tostring(ns.Questie and ns.Questie.IsAvailable())))
  elseif cmd == "reset" then
    if ns.Config.db then ns.Config.db.framePos = nil end
    ns.Print("window position reset - /reload to apply")
  elseif cmd == "debug" then
    if ns.Config.db then
      ns.Config.db.debug = not ns.Config.db.debug
      ns.Print("debug " .. (ns.Config.db.debug and "ON" or "OFF"))
    end
  else
    -- treat the whole message as a question
    ns.Bridge.Ask(msg)
  end
end

----------------------------------------------------------------------
-- bootstrap
----------------------------------------------------------------------

local boot = CreateFrame("Frame")
boot:RegisterEvent("ADDON_LOADED")
boot:RegisterEvent("PLAYER_LOGIN")
boot:SetScript("OnEvent", function(self, event, arg1)
  if event == "ADDON_LOADED" and arg1 == ADDON then
    ns.Config.Initialize()

    SLASH_AZEROTHCOMPANION1 = "/ac"
    SLASH_AZEROTHCOMPANION2 = "/azeroth"
    SLASH_AZEROTHCOMPANION3 = "/companion"
    SlashCmdList["AZEROTHCOMPANION"] = handleSlash

    -- Deliver answers / continue polling from the previous reload.
    ns.Bridge.OnLoad()

  elseif event == "PLAYER_LOGIN" then
    if ns.Config.db and not ns.Config.db.greeted then
      ns.Config.db.greeted = true
      ns.Print("loaded! Type |cffffd100/ac|r to open, or |cffffd100/ac help|r. "
        .. "Remember to run the companion app for answers.")
    end
  end
end)
