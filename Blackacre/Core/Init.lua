local AceAddon = LibStub("AceAddon-3.0")
local AceEvent = LibStub("AceEvent-3.0")

Blackacre = Blackacre or {}
Blackacre.VERSION = "2.0.0-dev"
Blackacre.PREFIX = "BA_RP"
Blackacre.CHANNEL_NAME = "BA_Channel"
Blackacre.SEP = "\031"
Blackacre._loadedPackages = Blackacre._loadedPackages or {}

Blackacre.STATUS = {
    ACTIVE = "ACTIVE",
    EXPIRED = "EXPIRED",
    DRAFT = "DRAFT",
    REMOVED = "REMOVED",
}

Blackacre.SCOPE = {
    INDIVIDUAL = "INDIVIDUAL",
    GROUP = "GROUP",
    GUILD = "GUILD",
    FACTION = "FACTION",
}

-- Defaults used only when no saved data exists (new install).
local function DefaultAccountDB()
    return {
        beacons = {},
        bulletins = {},
        notices = {}, -- legacy alias migrated to bulletins
        cache = {},
        mutes = {},
        history = {},
    }
end

local function DefaultCharDB()
    return {
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
end

--- One-time pull from old "In Character" SavedVariables (if still present in WTF).
--- TOC still lists InCharacterDB / InCharacterCharDB so Blizzard loads them for migration.
local function MigrateFromInCharacter()
    if type(InCharacterDB) == "table" and (not BlackacreDB or not BlackacreDB._migratedFromIC) then
        -- Prefer old data when new table is empty/unmarked
        local newEmpty = not BlackacreDB or not next(BlackacreDB) or (BlackacreDB.beacons and not next(BlackacreDB.beacons) and not BlackacreDB._migratedFromIC)
        if newEmpty or not BlackacreDB._migratedFromIC then
            BlackacreDB = InCharacterDB
            BlackacreDB._migratedFromIC = true
        end
    end
    if type(InCharacterCharDB) == "table" and (not BlackacreCharDB or not BlackacreCharDB._migratedFromIC) then
        local newEmpty = not BlackacreCharDB or not next(BlackacreCharDB) or (BlackacreCharDB.chronicle and not BlackacreCharDB._migratedFromIC)
        if newEmpty or not BlackacreCharDB._migratedFromIC then
            BlackacreCharDB = InCharacterCharDB
            BlackacreCharDB._migratedFromIC = true
        end
    end
end

MigrateFromInCharacter()

BlackacreDB = BlackacreDB or DefaultAccountDB()
BlackacreCharDB = BlackacreCharDB or DefaultCharDB()
if not BlackacreDB._migratedFromIC and type(InCharacterDB) ~= "table" then
    -- Fresh install under Blackacre name only
    BlackacreDB._migratedFromIC = true
end

local addon = AceAddon:NewAddon("Blackacre", "AceEvent-3.0", "AceComm-3.0")
Blackacre.addon = addon

--- Child packages call this after their files load (RequiredDeps: Blackacre).
function Blackacre.RegisterPackage(name, initFn)
    if not name or not initFn then return end
    if Blackacre._loadedPackages[name] then return end
    Blackacre._loadedPackages[name] = true
    initFn()
end

function Blackacre.HasPackage(name)
    return Blackacre._loadedPackages[name] == true
end

function Blackacre.NewID()
    return string.format("%08x%04x", time(), math.random(0, 0xFFFF))
end

function Blackacre.GetZoneContext()
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

function Blackacre.IsMuted(ownerGUID)
    return BlackacreDB.mutes[ownerGUID] == true
end

function Blackacre.GetCharName()
    if Blackacre.TRP3Bridge then
        local trpName = Blackacre.TRP3Bridge.GetCharacterName()
        if trpName and trpName ~= "" then
            return trpName
        end
    end
    return UnitName("player")
end

function Blackacre.Print(msg)
    print("|cffc9a227Blackacre:|r " .. msg)
end

local function NeedPackage(pkg, feature)
    Blackacre.Print(string.format("%s requires the |cffc9a227%s|r package (enable it in AddOns).", feature, pkg))
end

function addon:OnInitialize()
    -- Re-run migration in case SavedVariables finished loading after file parse
    MigrateFromInCharacter()
    BlackacreDB = BlackacreDB or DefaultAccountDB()
    BlackacreCharDB = BlackacreCharDB or DefaultCharDB()

    Blackacre.DB = BlackacreDB
    Blackacre.CharDB = BlackacreCharDB
    -- Migrate older chars missing chronicle/settings keys
    Blackacre.CharDB.settings = Blackacre.CharDB.settings or {}
    Blackacre.CharDB.chronicle = Blackacre.CharDB.chronicle or { entries = {} }
    Blackacre.CharDB.gate = Blackacre.CharDB.gate or { ground = false, flying = false }
    Blackacre.CharDB.hardcore = Blackacre.CharDB.hardcore or {
        deathCount = 0,
        encumbranceActive = false,
        mountViolations = 0,
        flyViolations = 0,
        encumbranceViolations = 0,
    }
    Blackacre.CharDB.survival = Blackacre.CharDB.survival or {
        enabled = true,
        hunger = 85,
        thirst = 85,
        exposure = 90,
        hideMeters = false,
    }
    Blackacre.CharDB.afterlife = Blackacre.CharDB.afterlife or {
        active = nil,
        history = {},
        promptOnDeath = true,
    }
    Blackacre.CharDB.roadmap = Blackacre.CharDB.roadmap or {
        active = nil,
        history = {},
        lockPrompts = true,
    }
    Blackacre.CharDB.pvp = Blackacre.CharDB.pvp or {
        enabled = true,
        lastReports = {},
    }
    Blackacre.CharDB.presence = Blackacre.CharDB.presence or {
        receiveBeacons = true,
        lastEmitAt = nil,
        activeBeaconId = nil,
        showNameZone = true,
        showNameProximity = true,
    }

    -- Core only — Presence / Tome / Survival self-init via RegisterPackage
    Blackacre.Comms.Init(self)
    Blackacre.Lifecycle.Init()
    Blackacre.History.Init()
    Blackacre.MinimapButton.Init()
end

function addon:OnEnable()
    Blackacre.Comms.Enable()
end

-- Primary: /ba and /blackacre. Alias: /ic (old In Character muscle memory).
SLASH_BLACKACRE1 = "/ba"
SLASH_BLACKACRE2 = "/blackacre"
SLASH_BLACKACRE3 = "/ic"
SlashCmdList["BLACKACRE"] = function(msg)
    msg = strtrim(msg or ""):lower()
    if msg == "ping" then
        Blackacre.Comms.SendPing()
    elseif msg == "beacon" then
        if Blackacre.PostEditor and Blackacre.PostEditor.ShowBeaconEditor then
            Blackacre.PostEditor.ShowBeaconEditor()
        else
            NeedPackage("Blackacre Presence", "Beacons")
        end
    elseif msg == "bulletin" then
        if Blackacre.PostEditor and Blackacre.PostEditor.ShowBulletinEditor then
            Blackacre.PostEditor.ShowBulletinEditor()
        else
            NeedPackage("Blackacre Presence", "Bulletins")
        end
    elseif msg == "history" then
        Blackacre.History.Show()
    elseif msg == "tome" or msg == "chronicle" or msg == "log" or msg == "journal" then
        if Blackacre.TomeHub and Blackacre.TomeHub.Toggle then
            Blackacre.TomeHub.Toggle(msg == "tome" and nil or "chronicle")
        elseif Blackacre.Chronicle and Blackacre.Chronicle.UI then
            Blackacre.Chronicle.UI.Toggle()
        else
            NeedPackage("Blackacre Tome", "The Tome")
        end
    elseif msg == "setup" or msg == "tutorial" or msg == "onboard" then
        if Blackacre.SetupWizard and Blackacre.SetupWizard.Show then
            Blackacre.SetupWizard.Show()
        else
            NeedPackage("Blackacre Tome", "Setup")
        end
    elseif msg == "voice" or msg == "accent" then
        if Blackacre.TomeHub and Blackacre.TomeHub.Show then
            Blackacre.TomeHub.Show("voice")
        else
            NeedPackage("Blackacre Tome", "Voice")
        end
    elseif msg == "sample" then
        if Blackacre.Chronicle and Blackacre.Chronicle.Capture then
            Blackacre.Chronicle.Capture.DebugAddSample()
        else
            NeedPackage("Blackacre Tome", "Chronicle")
        end
    elseif msg == "hardcore" or msg == "gates" or msg == "hc" then
        if Blackacre.TomeHub and Blackacre.TomeHub.Show then
            Blackacre.TomeHub.Show("honor")
        elseif Blackacre.Hardcore and Blackacre.Hardcore.UI then
            Blackacre.Hardcore.UI.Toggle()
        else
            NeedPackage("Blackacre Tome", "Hardcore")
        end
    elseif msg == "survival" or msg == "meters" or msg == "condition" then
        if Blackacre.Survival and Blackacre.Survival.UI then
            Blackacre.Survival.UI.Toggle()
        else
            NeedPackage("Blackacre Survival", "Survival")
        end
    elseif msg == "eat" then
        if Blackacre.Survival and Blackacre.Survival.Engine then
            Blackacre.Survival.Engine.Recover("eat", 22)
        else
            NeedPackage("Blackacre Survival", "Survival")
        end
    elseif msg == "drink" then
        if Blackacre.Survival and Blackacre.Survival.Engine then
            Blackacre.Survival.Engine.Recover("drink", 22)
        else
            NeedPackage("Blackacre Survival", "Survival")
        end
    elseif msg == "rest" then
        if not (Blackacre.Survival and Blackacre.Survival.Engine) then
            NeedPackage("Blackacre Survival", "Survival")
        elseif UnitAffectingCombat and UnitAffectingCombat("player") then
            Blackacre.Print("You cannot truly rest in combat.")
        else
            Blackacre.Survival.Engine.Recover("rest", 18)
        end
    elseif msg == "survival off" then
        if Blackacre.Survival and Blackacre.Survival.Engine then
            Blackacre.Survival.Engine.SetEnabled(false)
            Blackacre.Print("Survival meters disabled for this character.")
            if Blackacre.Survival.UI then Blackacre.Survival.UI.Refresh() end
        else
            NeedPackage("Blackacre Survival", "Survival")
        end
    elseif msg == "survival on" then
        if Blackacre.Survival and Blackacre.Survival.Engine then
            Blackacre.Survival.Engine.SetEnabled(true)
            Blackacre.Print("Survival meters enabled.")
            if Blackacre.Survival.UI then Blackacre.Survival.UI.ShowPanel() end
        else
            NeedPackage("Blackacre Survival", "Survival")
        end
    elseif msg == "afterlife" or msg == "death" or msg == "return" then
        if Blackacre.TomeHub and Blackacre.TomeHub.Show then
            Blackacre.TomeHub.Show("realms")
        elseif Blackacre.Afterlife and Blackacre.Afterlife.UI then
            Blackacre.Afterlife.UI.Toggle()
        else
            NeedPackage("Blackacre Tome", "Afterlife")
        end
    elseif msg == "realms" then
        if Blackacre.TomeHub and Blackacre.TomeHub.Show then
            Blackacre.TomeHub.Show("realms")
            if Blackacre.Afterlife and Blackacre.Afterlife.UI and Blackacre.Afterlife.UI.ShowRealmPicker then
                Blackacre.Afterlife.UI.ShowRealmPicker()
            end
        else
            NeedPackage("Blackacre Tome", "Afterlife")
        end
    elseif msg == "roadmap" or msg == "road" or msg == "expedition" or msg == "chart" then
        if Blackacre.TomeHub and Blackacre.TomeHub.Show then
            Blackacre.TomeHub.Show("road")
        elseif Blackacre.Roadmap and Blackacre.Roadmap.UI then
            Blackacre.Roadmap.UI.Toggle()
        else
            NeedPackage("Blackacre Tome", "Roadmap")
        end
    elseif msg == "birth" or msg == "identity" or msg == "lineage" or msg == "age" then
        if Blackacre.TomeHub and Blackacre.TomeHub.Show then
            Blackacre.TomeHub.Show("lineage")
        elseif Blackacre.LineageUI then
            Blackacre.LineageUI.Toggle()
        else
            NeedPackage("Blackacre Tome", "Lineage")
        end
    elseif msg == "birth human" then
        if Blackacre.Birthpath then Blackacre.Birthpath.DebugSampleHuman() else NeedPackage("Blackacre Tome", "Lineage") end
    elseif msg == "birth elf" then
        if Blackacre.Birthpath then Blackacre.Birthpath.DebugSampleElf() else NeedPackage("Blackacre Tome", "Lineage") end
    elseif msg == "birth dracthyr" then
        if Blackacre.Birthpath then Blackacre.Birthpath.DebugSampleDracthyr() else NeedPackage("Blackacre Tome", "Lineage") end
    elseif msg == "export" then
        if Blackacre.Share and Blackacre.Share.Export then
            Blackacre.Share.Export.CopyToClipboard()
        else
            NeedPackage("Blackacre Tome", "Share")
        end
    elseif msg:match("^share%s+") then
        local target = msg:match("^share%s+(.+)$")
        Blackacre.Comms.RequestSummary(strtrim(target or ""))
    elseif msg == "share" then
        Blackacre.Print("Usage: /ic share PlayerName  — or /ic export for TRP3 paste")
    elseif msg == "pvpsample" then
        if Blackacre.PvP and Blackacre.PvP.AfterAction then
            Blackacre.PvP.AfterAction.DebugSample()
        else
            NeedPackage("Blackacre Tome", "PvP")
        end
    elseif msg == "pvp off" then
        if Blackacre.PvP and Blackacre.PvP.AfterAction then
            Blackacre.PvP.AfterAction.SetEnabled(false)
            Blackacre.Print("PvP after-action reports disabled.")
        else
            NeedPackage("Blackacre Tome", "PvP")
        end
    elseif msg == "pvp on" then
        if Blackacre.PvP and Blackacre.PvP.AfterAction then
            Blackacre.PvP.AfterAction.SetEnabled(true)
            Blackacre.Print("PvP after-action reports enabled.")
        else
            NeedPackage("Blackacre Tome", "PvP")
        end
    elseif msg == "beacons off" then
        Blackacre.Lifecycle.EnsurePresenceDB().receiveBeacons = false
        Blackacre.Print("Beacon receive off.")
        if Blackacre.BeaconPins then Blackacre.BeaconPins.Refresh() end
    elseif msg == "beacons on" then
        Blackacre.Lifecycle.EnsurePresenceDB().receiveBeacons = true
        Blackacre.Print("Beacon receive on.")
    elseif msg == "packages" or msg == "version" then
        local list = {}
        for name in pairs(Blackacre._loadedPackages) do
            table.insert(list, name)
        end
        table.sort(list)
        Blackacre.Print(string.format("v%s core · packages: %s",
            Blackacre.VERSION,
            (#list > 0) and table.concat(list, ", ") or "(none — enable Presence/Tome/Survival)"))
    elseif msg == "" then
        if Blackacre.Flyout and Blackacre.Flyout.Toggle then
            Blackacre.Flyout.Toggle()
        else
            Blackacre.Print("Enable |cffc9a227Blackacre Presence|r for the presence panel. /ic packages")
        end
    else
        Blackacre.Print("Commands: /ic, /ic setup, /ic tome, /ic beacon, /ic bulletin, /ic voice, /ic birth, /ic roadmap, /ic hardcore, /ic survival, /ic afterlife, /ic export, /ic packages")
    end
end
