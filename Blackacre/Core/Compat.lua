-- Client flavor helpers: Retail Midnight vs WoW Forever (internal game type Camelot).
-- Forever shares Mainline's UI architecture (12.1.5-era APIs) with a vanilla-era world.
-- Detect via interface version: Forever beta is 1.60.x → 16001; Retail is 12xxxxx.

Blackacre = Blackacre or {}
Blackacre.Compat = {}

local FOREVER_INTERFACE_MIN = 16000
local FOREVER_INTERFACE_MAX = 19999

-- Vanilla-era playable race file tokens (UnitRace). Skyborne / new Forever races
-- still match if they are the player's own race (see PathAllowed).
local VANILLA_RACE_FILES = {
    Human = true,
    Dwarf = true,
    Gnome = true,
    NightElf = true,
    Orc = true,
    Troll = true,
    Tauren = true,
    Scourge = true,
    Skyborne = true,
}

-- Afterlife rites whose lore exists before Outland. Shadowlands covenants stay Retail-only.
local FOREVER_AFTERLIFE = {
    spirit_world = true,
    emerald_dream = true,
    emerald_nightmare = true,
    twisting_nether = true,
    elemental_planes = true,
    other_side = true,
}

-- Roadmap presets that require post-vanilla continents or allied races.
local FOREVER_HIDDEN_PRESETS = {
    alliance_draenei = true,
    horde_blood_elf = true,
    ancient_kalimdor = true,
    dracthyr_wake = true,
}

-- Era tags that mean "this zone is a later expansion's playable map".
local POST_VANILLA_ZONE_TAGS = {
    bc = true,
    wrath = true,
    cata = true,
    mop = true,
    wod = true,
    legion = true,
    bfa = true,
    sl = true,
    df = true,
    tww = true,
}

-- Art dump (_classic_beta_\BlizzardInterfaceArt): only these Theme paths were missing.
local TEXTURE_REMAPS = {
    ["Interface\\QuestFrame\\UI-QuestLog-Empty-Top"] = "Interface\\QuestFrame\\UI-QUESTLOG-EMPTY-TOPLEFT",
    ["Interface\\MINIMAP\\UI-Minimap-Pin"] = "Interface\\MINIMAP\\Minimap-Waypoint-MapPin-Tracked",
}

local cached

local function Detect()
    if cached then
        return cached
    end
    local version, _, _, interface = GetBuildInfo()
    interface = tonumber(interface) or 0
    local isForever = interface >= FOREVER_INTERFACE_MIN and interface < FOREVER_INTERFACE_MAX
    cached = {
        version = version or "",
        interface = interface,
        isForever = isForever,
        isRetail = not isForever,
    }
    return cached
end

function Blackacre.Compat.GetFlavor()
    return Detect()
end

function Blackacre.Compat.IsForever()
    return Detect().isForever
end

function Blackacre.Compat.IsRetail()
    return Detect().isRetail
end

-- Forever presents rulesets instead of the Retail realm picker.  AceDB still
-- builds its own internal character key from GetRealmName(), so use the
-- stable game-mode record for Blackacre's default profile when the client
-- exposes it.  This value is only a namespace for our profile name; it does
-- not replace AceDB's internal mapping or the explicit per-character pointer.
function Blackacre.Compat.GetProfileScope()
    if not Detect().isForever then
        local realm = GetRealmName and GetRealmName()
        return type(realm) == "string" and realm ~= "" and realm or "Realm"
    end

    if C_GameRules and C_GameRules.GetCurrentGameModeRecordID then
        local ok, recordID = pcall(C_GameRules.GetCurrentGameModeRecordID)
        if ok and type(recordID) == "number" and recordID > 0 then
            return "Forever ruleset " .. tostring(recordID)
        end
    end
    return "Forever"
end

--- Vanilla-era Forever has no licensed player flying.
function Blackacre.Compat.HasPlayerFlying()
    return not Detect().isForever
end

--- Present-year default: Age of Adventure (25 ADP) on Forever; War Within (42) on Retail.
function Blackacre.Compat.DefaultPresentADP()
    if Detect().isForever then
        return 25
    end
    return 42
end

--- Total RP 3 is Retail-only until an official Forever port exists. Never call TRP3_API on Forever.
function Blackacre.Compat.SupportsTRP3()
    return not Detect().isForever
end

function Blackacre.Compat.HasTRP3()
    return Blackacre.Compat.SupportsTRP3() and TRP3_API ~= nil and TRP3_API.profile ~= nil
end

function Blackacre.Compat.ResolveTexture(path)
    if type(path) ~= "string" then
        return path
    end
    if Detect().isForever and TEXTURE_REMAPS[path] then
        return TEXTURE_REMAPS[path]
    end
    return path
end

function Blackacre.Compat.ApplyTextureRemaps(textures)
    if type(textures) ~= "table" or not Detect().isForever then
        return
    end
    for key, path in pairs(textures) do
        if type(path) == "string" and TEXTURE_REMAPS[path] then
            textures[key] = TEXTURE_REMAPS[path]
        end
    end
end

function Blackacre.Compat.GetPlayerRaceFile()
    local _, raceFile = UnitRace("player")
    return raceFile
end

function Blackacre.Compat.IsVanillaRace(raceFile)
    return raceFile and VANILLA_RACE_FILES[raceFile] == true
end

--- Life Path allowed on this client. Empty races[] = general (always shown).
function Blackacre.Compat.PathAllowed(path)
    if not path or not Detect().isForever then
        return true
    end
    local races = path.races
    if type(races) ~= "table" or #races == 0 then
        return true
    end
    local playerRace = Blackacre.Compat.GetPlayerRaceFile()
    for i = 1, #races do
        local r = races[i]
        if VANILLA_RACE_FILES[r] or (playerRace and r == playerRace) then
            return true
        end
    end
    return false
end

function Blackacre.Compat.AfterlifePathAllowed(path)
    if not path or not Detect().isForever then
        return true
    end
    return FOREVER_AFTERLIFE[path.id] == true
end

function Blackacre.Compat.RoadmapPresetAllowed(preset)
    if not preset or not Detect().isForever then
        return true
    end
    return FOREVER_HIDDEN_PRESETS[preset.id] ~= true
end

function Blackacre.Compat.ZoneFitsFlavor(zone)
    if not zone or not Detect().isForever then
        return true
    end
    local tags = zone.eraTags
    if type(tags) ~= "table" then
        return true
    end
    local hasVanillaEra = false
    local hasPostVanilla = false
    for i = 1, #tags do
        local t = tags[i]
        if t == "vanilla" or t == "classic" or t == "first_war" or t == "second_war" or t == "third_war" then
            hasVanillaEra = true
        elseif POST_VANILLA_ZONE_TAGS[t] then
            hasPostVanilla = true
        end
    end
    if hasVanillaEra then
        return true
    end
    return not hasPostVanilla
end

function Blackacre.Compat.FlavorLabel()
    local f = Detect()
    if f.isForever then
        return string.format("WoW Forever (%s / %d)", f.version, f.interface)
    end
    return string.format("Retail (%s / %d)", f.version, f.interface)
end
