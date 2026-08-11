--[[
  PATH SCHEMA (Life Paths — Alternate Start)
  ==========================================
  Copy a block into a race file and fill it. Quests/zones stay empty until you scrub data.

  status:
    "stub"     — name/blurb only (default)
    "drafting" — you are actively filling zones/quests
    "ready"    — good enough to drive Roadmap/Tome later

  era:
    "past"          — historical / memory path
    "contemporary"  — closer to current retail timeline
    "general"       — not race-locked fantasy career

  races:
    UnitRace *file* tokens (locale-independent), e.g. Human, Orc, NightElf, Scourge, DarkIronDwarf.
    Empty table {} or omit = any race (still free-pick; UI can soft-suggest).

  zones:
    { zoneId = "elwynn", note = "optional IC note" }
    zoneId should match Blackacre.RoadmapZoneCatalog ids (or add a new zone row there).

  quests:
    { questId = 12345, title = "Optional label from Wowhead", optional = false, zoneId = "elwynn" }
    Paste questId from Wowhead URL: wowhead.com/quest=12345

  Free pick policy:
    Players may choose any path. races/faction/tags only score suggestions.

  NOT this file:
    AfterlifePaths.lua = death return rites (Bastion, Revendreth, …) — separate system.
]]

Blackacre = Blackacre or {}
Blackacre.Paths = Blackacre.Paths or {}

-- Empty template (not registered). For human copy-paste:
Blackacre.Paths.TEMPLATE = {
    id = "race_short_name",
    name = "Display Name",
    blurb = "One or two IC sentences.",
    era = "past", -- past | contemporary | general
    faction = "Alliance", -- Alliance | Horde | Any
    races = { "Human" },
    genders = nil, -- optional { "male", "female" }
    tags = {},
    birthplaceHints = {},
    residenceHints = {},
    eraTags = {},
    zones = {
        -- { zoneId = "elwynn", note = "" },
    },
    quests = {
        -- { questId = 0, title = "", optional = false, zoneId = "" },
    },
    levelLockHints = {
        -- { atLevel = 20, reason = "" },
    },
    tomeSeed = {
        title = "",
        body = "",
    },
    status = "stub",
}
