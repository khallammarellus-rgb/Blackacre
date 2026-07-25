local AceAddon = LibStub("AceAddon-3.0")
local AceEvent = LibStub("AceEvent-3.0")

InCharacter = InCharacter or {}
InCharacter.VERSION = "0.9.0"
InCharacter.PREFIX = "IC_RP"
InCharacter.CHANNEL_NAME = "IC_Channel"
InCharacter.SEP = "\031"

InCharacter.STATUS = {
    ACTIVE = "ACTIVE",
    EXPIRED = "EXPIRED",
    DRAFT = "DRAFT",
    REMOVED = "REMOVED",
}

InCharacter.SCOPE = {
    INDIVIDUAL = "INDIVIDUAL",
    GROUP = "GROUP",
    GUILD = "GUILD",
    FACTION = "FACTION",
}

InCharacterDB = InCharacterDB or {
    beacons = {},
    bulletins = {},
    notices = {}, -- legacy alias migrated to bulletins
    cache = {},
    mutes = {},
    history = {},
}

InCharacterCharDB = InCharacterCharDB or {
    residence = "",
    filters = { hardExclude = {}, softPriority = {} },
    settings = {
        noticeTTLDays = 3,
        bulletinTTLDays = 3,
        quietNotifications = false,
        yearKCBase = 42,
        yearKCOffset = 0,
    },
    chronicle = {
        entries = {},
    },
    gate = {
        ground = false,
        flying = false,
    },
    hardcore = {
        deathCount = 0,
        encumbranceActive = false,
        mountViolations = 0,
        flyViolations = 0,
        encumbranceViolations = 0,
    },
    survival = {
        enabled = true,
        hunger = 85,
        thirst = 85,
        exposure = 90,
        hideMeters = false,
    },
    afterlife = {
        active = nil,
        history = {},
        promptOnDeath = true,
    },
    roadmap = {
        active = nil,
        history = {},
        lockPrompts = true,
    },
    pvp = {
        enabled = true,
        lastReports = {},
    },
    identity = {
        birthYearADP = nil,
        birthEraId = nil,
        birthPlace = "",
        presentYearADP = 42,
        calendarDisplay = "AUTO",
        longevityProfile = "auto",
        originMode = "born",
        stasisUntilADP = nil,
        deathYearADP = nil,
        rebirthYearADP = nil,
    },
}

local addon = AceAddon:NewAddon("InCharacter", "AceEvent-3.0", "AceComm-3.0")
InCharacter.addon = addon

function InCharacter.NewID()
    return string.format("%08x%04x", time(), math.random(0, 0xFFFF))
end

function InCharacter.GetZoneContext()
    local mapID = C_Map.GetBestMapForUnit("player")
    local subzone = GetSubZoneText() or ""
    local zoneName = ""
    if mapID then
        local info = C_Map.GetMapInfo(mapID)
        zoneName = info and info.name or ""
    end
    local x, y = 0, 0
    if mapID then
        local pos = C_Map.GetPlayerMapPosition(mapID, "player")
        if pos then
            x, y = pos:GetXY()
        end
    end
    return {
        zoneId = mapID or 0,
        subzone = subzone,
        zoneName = zoneName,
        coords = { x = x, y = y },
    }
end

function InCharacter.IsMuted(ownerGUID)
    return InCharacterDB.mutes[ownerGUID] == true
end

function InCharacter.GetCharName()
    if InCharacter.TRP3Bridge then
        local trpName = InCharacter.TRP3Bridge.GetCharacterName()
        if trpName and trpName ~= "" then
            return trpName
        end
    end
    return UnitName("player")
end

function InCharacter.Print(msg)
    print("|cffc9a227In Character:|r " .. msg)
end

function addon:OnInitialize()
    InCharacter.DB = InCharacterDB
    InCharacter.CharDB = InCharacterCharDB
    -- Migrate older chars missing chronicle/settings keys
    InCharacter.CharDB.settings = InCharacter.CharDB.settings or {}
    InCharacter.CharDB.chronicle = InCharacter.CharDB.chronicle or { entries = {} }
    InCharacter.CharDB.gate = InCharacter.CharDB.gate or { ground = false, flying = false }
    InCharacter.CharDB.hardcore = InCharacter.CharDB.hardcore or {
        deathCount = 0,
        encumbranceActive = false,
        mountViolations = 0,
        flyViolations = 0,
        encumbranceViolations = 0,
    }
    InCharacter.CharDB.survival = InCharacter.CharDB.survival or {
        enabled = true,
        hunger = 85,
        thirst = 85,
        exposure = 90,
        hideMeters = false,
    }
    InCharacter.CharDB.afterlife = InCharacter.CharDB.afterlife or {
        active = nil,
        history = {},
        promptOnDeath = true,
    }
    InCharacter.CharDB.roadmap = InCharacter.CharDB.roadmap or {
        active = nil,
        history = {},
        lockPrompts = true,
    }
    InCharacter.CharDB.pvp = InCharacter.CharDB.pvp or {
        enabled = true,
        lastReports = {},
    }
    InCharacter.YearCalendar.EnsureIdentity()
    InCharacter.CharDB.presence = InCharacter.CharDB.presence or {
        receiveBeacons = true,
        lastEmitAt = nil,
        activeBeaconId = nil,
        showNameZone = true,
        showNameProximity = true,
    }

    InCharacter.Comms.Init(self)
    InCharacter.Lifecycle.Init()
    InCharacter.History.Init()
    InCharacter.Chronicle.Store.Init()
    InCharacter.Chronicle.Capture.Init()
    InCharacter.Chronicle.UI.Init()
    InCharacter.Hardcore.Monitor.Init()
    InCharacter.Hardcore.UI.Init()
    InCharacter.Survival.Engine.Init()
    InCharacter.Survival.UI.Init()
    InCharacter.Afterlife.PathTracker.Init()
    InCharacter.Afterlife.UI.Init()
    InCharacter.Roadmap.Store.Init()
    InCharacter.Roadmap.Engine.Init()
    InCharacter.Roadmap.UI.Init()
    InCharacter.PvP.AfterAction.Init()
    InCharacter.LineageUI.Init()
    InCharacter.BeaconHead.Init()
    InCharacter.BeaconPins.Init()
    InCharacter.MinimapButton.Init()
    InCharacter.Flyout.Init()
    InCharacter.BoardView.Init()
    InCharacter.PostEditor.Init()
end

function addon:OnEnable()
    InCharacter.Comms.Enable()
end

SLASH_INCHARACTER1 = "/ic"
SlashCmdList["INCHARACTER"] = function(msg)
    msg = strtrim(msg or ""):lower()
    if msg == "ping" then
        InCharacter.Comms.SendPing()
    elseif msg == "beacon" then
        InCharacter.PostEditor.ShowBeaconEditor()
    elseif msg == "bulletin" then
        InCharacter.PostEditor.ShowBulletinEditor()
    elseif msg == "history" then
        InCharacter.History.Show()
    elseif msg == "tome" or msg == "chronicle" or msg == "log" or msg == "journal" then
        InCharacter.Chronicle.UI.Toggle()
    elseif msg == "sample" then
        InCharacter.Chronicle.Capture.DebugAddSample()
    elseif msg == "hardcore" or msg == "gates" or msg == "hc" then
        InCharacter.Hardcore.UI.Toggle()
    elseif msg == "survival" or msg == "meters" or msg == "condition" then
        InCharacter.Survival.UI.Toggle()
    elseif msg == "eat" then
        InCharacter.Survival.Engine.Recover("eat", 22)
    elseif msg == "drink" then
        InCharacter.Survival.Engine.Recover("drink", 22)
    elseif msg == "rest" then
        if UnitAffectingCombat and UnitAffectingCombat("player") then
            InCharacter.Print("You cannot truly rest in combat.")
        else
            InCharacter.Survival.Engine.Recover("rest", 18)
        end
    elseif msg == "survival off" then
        InCharacter.Survival.Engine.SetEnabled(false)
        InCharacter.Print("Survival meters disabled for this character.")
        InCharacter.Survival.UI.Refresh()
    elseif msg == "survival on" then
        InCharacter.Survival.Engine.SetEnabled(true)
        InCharacter.Print("Survival meters enabled.")
        InCharacter.Survival.UI.ShowPanel()
    elseif msg == "afterlife" or msg == "death" or msg == "return" then
        InCharacter.Afterlife.UI.Toggle()
    elseif msg == "realms" then
        InCharacter.Afterlife.UI.ShowRealmPicker()
    elseif msg == "roadmap" or msg == "road" or msg == "expedition" or msg == "chart" then
        InCharacter.Roadmap.UI.Toggle()
    elseif msg == "birth" or msg == "identity" or msg == "lineage" or msg == "age" then
        InCharacter.LineageUI.Toggle()
    elseif msg == "birth human" then
        InCharacter.Birthpath.DebugSampleHuman()
    elseif msg == "birth elf" then
        InCharacter.Birthpath.DebugSampleElf()
    elseif msg == "birth dracthyr" then
        InCharacter.Birthpath.DebugSampleDracthyr()
    elseif msg == "export" then
        InCharacter.Share.Export.CopyToClipboard()
    elseif msg:match("^share%s+") then
        local target = msg:match("^share%s+(.+)$")
        InCharacter.Comms.RequestSummary(strtrim(target or ""))
    elseif msg == "share" then
        InCharacter.Print("Usage: /ic share PlayerName  — or /ic export for TRP3 paste")
    elseif msg == "pvpsample" then
        InCharacter.PvP.AfterAction.DebugSample()
    elseif msg == "pvp off" then
        InCharacter.PvP.AfterAction.SetEnabled(false)
        InCharacter.Print("PvP after-action reports disabled.")
    elseif msg == "pvp on" then
        InCharacter.PvP.AfterAction.SetEnabled(true)
        InCharacter.Print("PvP after-action reports enabled.")
    elseif msg == "beacons off" then
        InCharacter.Lifecycle.EnsurePresenceDB().receiveBeacons = false
        InCharacter.Print("Beacon receive off.")
        if InCharacter.BeaconPins then InCharacter.BeaconPins.Refresh() end
    elseif msg == "beacons on" then
        InCharacter.Lifecycle.EnsurePresenceDB().receiveBeacons = true
        InCharacter.Print("Beacon receive on.")
    elseif msg == "" then
        InCharacter.Flyout.Toggle()
    else
        InCharacter.Print("Commands: /ic, /ic beacon, /ic bulletin, /ic tome, /ic birth, /ic roadmap, /ic hardcore, /ic survival, /ic afterlife, /ic export")
    end
end