local AceAddon = LibStub("AceAddon-3.0")
local AceEvent = LibStub("AceEvent-3.0")

InCharacter = InCharacter or {}
InCharacter.VERSION = "1.0.0"
InCharacter.PREFIX = "IC_RP"
InCharacter.CHANNEL_NAME = "IC_Channel"
InCharacter.SEP = "\031"
InCharacter._loadedPackages = InCharacter._loadedPackages or {}

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

--- Child packages call this after their files load (RequiredDeps: InCharacter).
function InCharacter.RegisterPackage(name, initFn)
    if not name or not initFn then return end
    if InCharacter._loadedPackages[name] then return end
    InCharacter._loadedPackages[name] = true
    initFn()
end

function InCharacter.HasPackage(name)
    return InCharacter._loadedPackages[name] == true
end

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

local function NeedPackage(pkg, feature)
    InCharacter.Print(string.format("%s requires the |cffc9a227%s|r package (enable it in AddOns).", feature, pkg))
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
    InCharacter.CharDB.presence = InCharacter.CharDB.presence or {
        receiveBeacons = true,
        lastEmitAt = nil,
        activeBeaconId = nil,
        showNameZone = true,
        showNameProximity = true,
    }

    -- Core only — Presence / Tome / Survival self-init via RegisterPackage
    InCharacter.Comms.Init(self)
    InCharacter.Lifecycle.Init()
    InCharacter.History.Init()
    InCharacter.MinimapButton.Init()
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
        if InCharacter.PostEditor and InCharacter.PostEditor.ShowBeaconEditor then
            InCharacter.PostEditor.ShowBeaconEditor()
        else
            NeedPackage("In Character Presence", "Beacons")
        end
    elseif msg == "bulletin" then
        if InCharacter.PostEditor and InCharacter.PostEditor.ShowBulletinEditor then
            InCharacter.PostEditor.ShowBulletinEditor()
        else
            NeedPackage("In Character Presence", "Bulletins")
        end
    elseif msg == "history" then
        InCharacter.History.Show()
    elseif msg == "tome" or msg == "chronicle" or msg == "log" or msg == "journal" then
        if InCharacter.Chronicle and InCharacter.Chronicle.UI then
            InCharacter.Chronicle.UI.Toggle()
        else
            NeedPackage("In Character Tome", "The Tome")
        end
    elseif msg == "sample" then
        if InCharacter.Chronicle and InCharacter.Chronicle.Capture then
            InCharacter.Chronicle.Capture.DebugAddSample()
        else
            NeedPackage("In Character Tome", "Chronicle")
        end
    elseif msg == "hardcore" or msg == "gates" or msg == "hc" then
        if InCharacter.Hardcore and InCharacter.Hardcore.UI then
            InCharacter.Hardcore.UI.Toggle()
        else
            NeedPackage("In Character Tome", "Hardcore")
        end
    elseif msg == "survival" or msg == "meters" or msg == "condition" then
        if InCharacter.Survival and InCharacter.Survival.UI then
            InCharacter.Survival.UI.Toggle()
        else
            NeedPackage("In Character Survival", "Survival")
        end
    elseif msg == "eat" then
        if InCharacter.Survival and InCharacter.Survival.Engine then
            InCharacter.Survival.Engine.Recover("eat", 22)
        else
            NeedPackage("In Character Survival", "Survival")
        end
    elseif msg == "drink" then
        if InCharacter.Survival and InCharacter.Survival.Engine then
            InCharacter.Survival.Engine.Recover("drink", 22)
        else
            NeedPackage("In Character Survival", "Survival")
        end
    elseif msg == "rest" then
        if not (InCharacter.Survival and InCharacter.Survival.Engine) then
            NeedPackage("In Character Survival", "Survival")
        elseif UnitAffectingCombat and UnitAffectingCombat("player") then
            InCharacter.Print("You cannot truly rest in combat.")
        else
            InCharacter.Survival.Engine.Recover("rest", 18)
        end
    elseif msg == "survival off" then
        if InCharacter.Survival and InCharacter.Survival.Engine then
            InCharacter.Survival.Engine.SetEnabled(false)
            InCharacter.Print("Survival meters disabled for this character.")
            if InCharacter.Survival.UI then InCharacter.Survival.UI.Refresh() end
        else
            NeedPackage("In Character Survival", "Survival")
        end
    elseif msg == "survival on" then
        if InCharacter.Survival and InCharacter.Survival.Engine then
            InCharacter.Survival.Engine.SetEnabled(true)
            InCharacter.Print("Survival meters enabled.")
            if InCharacter.Survival.UI then InCharacter.Survival.UI.ShowPanel() end
        else
            NeedPackage("In Character Survival", "Survival")
        end
    elseif msg == "afterlife" or msg == "death" or msg == "return" then
        if InCharacter.Afterlife and InCharacter.Afterlife.UI then
            InCharacter.Afterlife.UI.Toggle()
        else
            NeedPackage("In Character Tome", "Afterlife")
        end
    elseif msg == "realms" then
        if InCharacter.Afterlife and InCharacter.Afterlife.UI then
            InCharacter.Afterlife.UI.ShowRealmPicker()
        else
            NeedPackage("In Character Tome", "Afterlife")
        end
    elseif msg == "roadmap" or msg == "road" or msg == "expedition" or msg == "chart" then
        if InCharacter.Roadmap and InCharacter.Roadmap.UI then
            InCharacter.Roadmap.UI.Toggle()
        else
            NeedPackage("In Character Tome", "Roadmap")
        end
    elseif msg == "birth" or msg == "identity" or msg == "lineage" or msg == "age" then
        if InCharacter.LineageUI then
            InCharacter.LineageUI.Toggle()
        else
            NeedPackage("In Character Tome", "Lineage")
        end
    elseif msg == "birth human" then
        if InCharacter.Birthpath then InCharacter.Birthpath.DebugSampleHuman() else NeedPackage("In Character Tome", "Lineage") end
    elseif msg == "birth elf" then
        if InCharacter.Birthpath then InCharacter.Birthpath.DebugSampleElf() else NeedPackage("In Character Tome", "Lineage") end
    elseif msg == "birth dracthyr" then
        if InCharacter.Birthpath then InCharacter.Birthpath.DebugSampleDracthyr() else NeedPackage("In Character Tome", "Lineage") end
    elseif msg == "export" then
        if InCharacter.Share and InCharacter.Share.Export then
            InCharacter.Share.Export.CopyToClipboard()
        else
            NeedPackage("In Character Tome", "Share")
        end
    elseif msg:match("^share%s+") then
        local target = msg:match("^share%s+(.+)$")
        InCharacter.Comms.RequestSummary(strtrim(target or ""))
    elseif msg == "share" then
        InCharacter.Print("Usage: /ic share PlayerName  — or /ic export for TRP3 paste")
    elseif msg == "pvpsample" then
        if InCharacter.PvP and InCharacter.PvP.AfterAction then
            InCharacter.PvP.AfterAction.DebugSample()
        else
            NeedPackage("In Character Tome", "PvP")
        end
    elseif msg == "pvp off" then
        if InCharacter.PvP and InCharacter.PvP.AfterAction then
            InCharacter.PvP.AfterAction.SetEnabled(false)
            InCharacter.Print("PvP after-action reports disabled.")
        else
            NeedPackage("In Character Tome", "PvP")
        end
    elseif msg == "pvp on" then
        if InCharacter.PvP and InCharacter.PvP.AfterAction then
            InCharacter.PvP.AfterAction.SetEnabled(true)
            InCharacter.Print("PvP after-action reports enabled.")
        else
            NeedPackage("In Character Tome", "PvP")
        end
    elseif msg == "beacons off" then
        InCharacter.Lifecycle.EnsurePresenceDB().receiveBeacons = false
        InCharacter.Print("Beacon receive off.")
        if InCharacter.BeaconPins then InCharacter.BeaconPins.Refresh() end
    elseif msg == "beacons on" then
        InCharacter.Lifecycle.EnsurePresenceDB().receiveBeacons = true
        InCharacter.Print("Beacon receive on.")
    elseif msg == "packages" or msg == "version" then
        local list = {}
        for name in pairs(InCharacter._loadedPackages) do
            table.insert(list, name)
        end
        table.sort(list)
        InCharacter.Print(string.format("v%s core · packages: %s",
            InCharacter.VERSION,
            (#list > 0) and table.concat(list, ", ") or "(none — enable Presence/Tome/Survival)"))
    elseif msg == "" then
        if InCharacter.Flyout and InCharacter.Flyout.Toggle then
            InCharacter.Flyout.Toggle()
        else
            InCharacter.Print("Enable |cffc9a227In Character Presence|r for the presence panel. /ic packages")
        end
    else
        InCharacter.Print("Commands: /ic, /ic beacon, /ic bulletin, /ic tome, /ic birth, /ic roadmap, /ic hardcore, /ic survival, /ic afterlife, /ic export, /ic packages")
    end
end
