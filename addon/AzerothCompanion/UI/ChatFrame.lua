--
-- ChatFrame.lua -- the in-game chat window.
--
-- A small, movable window with a scrolling transcript, an input box and
-- Send / Refresh buttons. Built in pure Lua (no XML) and feature-detecting the
-- backdrop API so it works on 3.3.5a as well as modern clients (where plain
-- frames need the "BackdropTemplate").
--

local ADDON, ns = ...

local UI = {}
ns.UI = UI

----------------------------------------------------------------------
-- localized chrome strings (UI is EN by default; status follows the
-- player's chosen assistant language where we have a translation)
----------------------------------------------------------------------

local STATUS = {
  en = {
    thinking = "Thinking...",
    waiting  = "Waiting for the companion app...",
    timeout  = "No answer yet - click Refresh (or type /ac get).",
    combat   = "Will send once combat ends...",
    manual   = "Queued. Type /reload, then click Refresh.",
  },
  it = {
    thinking = "Sto pensando...",
    waiting  = "Attendo il companion...",
    timeout  = "Ancora nessuna risposta - clic su Aggiorna (o /ac get).",
    combat   = "Invio al termine del combattimento...",
    manual   = "In coda. Digita /reload, poi clic su Aggiorna.",
  },
}

local function L(key)
  local lang = ns.Config and ns.Config.GetEffectiveLanguage() or "en"
  local tbl = STATUS[lang] or STATUS.en
  return tbl[key] or STATUS.en[key] or key
end

----------------------------------------------------------------------
-- frame helpers (cross-version backdrop)
----------------------------------------------------------------------

local BACKDROP = {
  bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
  tile = true, tileSize = 32, edgeSize = 32,
  insets = { left = 11, right = 12, top = 12, bottom = 11 },
}

local function withBackdrop(frame, backdrop)
  if frame.SetBackdrop then
    frame:SetBackdrop(backdrop or BACKDROP)
  end
  return frame
end

local function newFrame(ftype, name, parent, extraTemplate)
  local hasBackdropTemplate = (_G.BackdropTemplateMixin ~= nil)
  local template = extraTemplate
  if hasBackdropTemplate and ftype == "Frame" then
    template = template and (template .. ",BackdropTemplate") or "BackdropTemplate"
  end
  return CreateFrame(ftype, name, parent or UIParent, template)
end

----------------------------------------------------------------------
-- build
----------------------------------------------------------------------

local frame, transcript, input, statusText

local function addLine(text, r, g, b)
  if not transcript then return end
  text = tostring(text or "")
  -- ScrollingMessageFrame handles one logical line per AddMessage; split on
  -- embedded newlines so multi-paragraph answers render correctly.
  for rawline in (text .. "\n"):gmatch("(.-)\n") do
    local line = (rawline ~= "" and rawline) or " "
    transcript:AddMessage(line, r or 1, g or 1, b or 1)
  end
end

local function buildFrame()
  if frame then return frame end

  frame = newFrame("Frame", "AzerothCompanionFrame", UIParent)
  withBackdrop(frame)
  frame:SetSize(440, 320)
  frame:SetPoint("CENTER")
  frame:SetFrameStrata("DIALOG")
  frame:SetClampedToScreen(true)
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", frame.StartMoving)
  frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local point, _, relPoint, x, y = self:GetPoint()
    if ns.Config and ns.Config.db then
      ns.Config.db.framePos = { point = point, relPoint = relPoint, x = x, y = y }
    end
  end)
  frame:Hide()

  -- restore saved position
  if ns.Config and ns.Config.db and ns.Config.db.framePos then
    local p = ns.Config.db.framePos
    frame:ClearAllPoints()
    frame:SetPoint(p.point or "CENTER", UIParent, p.relPoint or "CENTER", p.x or 0, p.y or 0)
  end

  -- title
  local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOP", 0, -16)
  title:SetText("Azeroth Companion")

  -- close button
  local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", -6, -6)
  close:SetScript("OnClick", function() frame:Hide() end)

  -- transcript (scrolling message frame) in a sunken panel
  local scrollBG = newFrame("Frame", nil, frame)
  scrollBG:SetPoint("TOPLEFT", 16, -44)
  scrollBG:SetPoint("BOTTOMRIGHT", -16, 76)
  withBackdrop(scrollBG, {
    bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 },
  })
  if scrollBG.SetBackdropColor then scrollBG:SetBackdropColor(0, 0, 0, 0.5) end

  transcript = CreateFrame("ScrollingMessageFrame", "AzerothCompanionTranscript", scrollBG)
  transcript:SetPoint("TOPLEFT", 8, -8)
  transcript:SetPoint("BOTTOMRIGHT", -8, 8)
  transcript:SetFontObject(ChatFontNormal or GameFontHighlight)
  transcript:SetJustifyH("LEFT")
  transcript:SetFading(false)
  transcript:SetMaxLines(500)
  transcript:SetHyperlinksEnabled(true)
  transcript:EnableMouseWheel(true)
  transcript:SetScript("OnMouseWheel", function(self, delta)
    if delta > 0 then
      if IsShiftKeyDown() then self:ScrollToTop() else self:ScrollUp() end
    else
      if IsShiftKeyDown() then self:ScrollToBottom() else self:ScrollDown() end
    end
  end)

  -- status line
  statusText = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  statusText:SetPoint("BOTTOMLEFT", 18, 52)
  statusText:SetPoint("BOTTOMRIGHT", -18, 52)
  statusText:SetJustifyH("LEFT")
  statusText:SetText("")

  -- bottom row: [ input .......... ] [ Send ] [ Refresh ]
  -- Anchored relationally (right to left) so the widths can never overlap.
  local refresh = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  refresh:SetSize(72, 24)
  refresh:SetPoint("BOTTOMRIGHT", -8, 16)
  refresh:SetText("Refresh")
  refresh:SetScript("OnClick", function() ns.Bridge.Refresh() end)

  local send = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
  send:SetSize(64, 24)
  send:SetPoint("BOTTOMRIGHT", refresh, "BOTTOMLEFT", -6, 0)
  send:SetText("Send")
  send:SetScript("OnClick", function()
    local text = input:GetText()
    input:SetText("")
    if text and text ~= "" then ns.Bridge.Ask(text) end
  end)

  input = CreateFrame("EditBox", "AzerothCompanionInput", frame, "InputBoxTemplate")
  input:SetPoint("BOTTOMLEFT", 22, 18)
  input:SetPoint("BOTTOMRIGHT", send, "BOTTOMLEFT", -12, 2)
  input:SetHeight(24)
  input:SetAutoFocus(false)
  input:SetFontObject(ChatFontNormal or GameFontHighlight)
  input:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
  input:SetScript("OnEnterPressed", function(self)
    local text = self:GetText()
    self:SetText("")
    self:ClearFocus()
    if text and text ~= "" then ns.Bridge.Ask(text) end
  end)

  return frame
end

----------------------------------------------------------------------
-- public API
----------------------------------------------------------------------

function UI.EnsureBuilt()
  return buildFrame()
end

function UI.Show()
  buildFrame()
  frame:Show()
end

function UI.Hide()
  if frame then frame:Hide() end
end

function UI.Toggle()
  buildFrame()
  if frame:IsShown() then frame:Hide() else frame:Show() end
end

function UI.IsShown()
  return frame and frame:IsShown()
end

function UI.ShowSelf(question)
  buildFrame()
  addLine("|cff66ccffYou:|r " .. question, 0.7, 0.85, 1)
end

function UI.ShowAnswer(text, req, ans)
  buildFrame()
  local prefix = "|cff66ff66Companion:|r "
  addLine(prefix .. (text or ""), 0.8, 1, 0.8)
  if ans and ans.model then
    addLine("|cff888888(" .. tostring(ans.model) .. ")|r", 0.5, 0.5, 0.5)
  end
  if statusText then statusText:SetText("") end
  if frame and not frame:IsShown() then frame:Show() end
end

function UI.ShowError(err, req)
  buildFrame()
  addLine("|cffff5555Companion error:|r " .. tostring(err), 1, 0.4, 0.4)
  if statusText then statusText:SetText("") end
  if frame and not frame:IsShown() then frame:Show() end
end

function UI.ShowStatus(state)
  buildFrame()
  if statusText then statusText:SetText(L(state) or "") end
end

function UI.AddSystem(text)
  buildFrame()
  addLine("|cffffd100" .. tostring(text) .. "|r", 1, 0.82, 0)
end

return UI
