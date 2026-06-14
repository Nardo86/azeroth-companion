-- luacheck configuration for the Azeroth Companion addon.
std = "lua51"
max_line_length = false
codes = true

-- We write to these globals on purpose.
globals = {
  "AzerothCompanionDB",
  "AzerothCompanionCharDB",
  "AzerothCompanion_Inbox_b64",
  "AzerothCompanion_Inbox_proto",
  "AzerothCompanionFrame",
  "AzerothCompanionTranscript",
  "AzerothCompanionInput",
  "SLASH_AZEROTHCOMPANION1",
  "SLASH_AZEROTHCOMPANION2",
  "SLASH_AZEROTHCOMPANION3",
  "SlashCmdList",
  "StaticPopupDialogs",
}

-- WoW client API surface we read (subset we actually use).
read_globals = {
  "CreateFrame", "UIParent", "GetBuildInfo", "GetLocale", "time",
  "C_Timer", "C_Map", "C_QuestLog",
  "GetSpecialization", "GetSpecializationInfo", "GetSpecializationRole",
  "UnitClass", "UnitRace", "UnitFactionGroup", "UnitLevel", "UnitName",
  "UnitExists", "UnitClassification", "UnitIsDead", "UnitCanAttack",
  "GetRealZoneText", "GetZoneText", "GetSubZoneText", "GetMinimapZoneText",
  "SetMapToCurrentZone", "GetPlayerMapPosition", "GetMapInfo",
  "IsInInstance", "GetInstanceInfo", "GetNumGroupMembers", "IsInRaid",
  "GetNumRaidMembers", "GetNumPartyMembers",
  "GetNumQuestLogEntries", "GetQuestLogTitle", "SelectQuestLogEntry",
  "GetQuestLogQuestText", "GetNumQuestLeaderBoards", "GetQuestLogLeaderBoard",
  "GetQuestLogRewardXP", "GetQuestLink",
  "GetNumTalentTabs", "GetTalentTabInfo",
  "InCombatLockdown", "ReloadUI", "IsAddOnLoaded", "IsShiftKeyDown",
  "StaticPopup_Show",
  "DEFAULT_CHAT_FRAME", "ChatFrame1",
  "ChatFontNormal", "GameFontNormal", "GameFontNormalLarge",
  "GameFontHighlight", "GameFontDisableSmall",
  "BackdropTemplateMixin",
  "QuestieLoader", "Questie",
  "ACCEPT", "CANCEL",
}

-- Don't nag about these in addon code.
ignore = {
  "212",  -- unused argument (event handlers have fixed signatures)
  "213",  -- unused loop variable
  "542",  -- empty if branch
}

exclude_files = { "addon/AzerothCompanion/Libs/json.lua" }  -- vendored, leave as-is
