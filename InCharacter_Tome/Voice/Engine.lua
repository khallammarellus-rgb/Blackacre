InCharacter = InCharacter or {}
InCharacter.Voice = {}

-- Accent profiles are applied all-or-nothing: one profile per character/entry.
-- Never mix profiles. Replacements run in fixed order for the chosen profile only.

local function EnsureVoiceDB()
    InCharacter.CharDB = InCharacter.CharDB or {}
    InCharacter.CharDB.voice = InCharacter.CharDB.voice or {
        accent = "auto",
        applyToChronicle = true,
        applyToBulletins = false,
    }
    return InCharacter.CharDB.voice
end

-- UnitRace file tokens (locale-independent) → profile id
local RACE_FILE_MAP = {
    Dwarf = "dwarf",
    DarkIronDwarf = "dwarf",
    Orc = "orc",
    MagharOrc = "orc",
    Scourge = "undead",
    Goblin = "goblin",
    BloodElf = "blood_elf",
    NightElf = "night_elf",
    Nightborne = "night_elf",
    Tauren = "tauren",
    HighmountainTauren = "tauren",
    Draenei = "draenei",
    LightforgedDraenei = "draenei",
    Pandaren = "pandaren",
    Vulpera = "vulpera",
    Human = "human",
    KulTiran = "human",
}

function InCharacter.Voice.ListProfiles()
    local list = { "auto", "none" }
    for id in pairs(InCharacter.VoiceLexicon or {}) do
        list[#list + 1] = id
    end
    table.sort(list)
    return list
end

function InCharacter.Voice.ResolveProfile()
    local v = EnsureVoiceDB()
    local accent = v.accent or "auto"
    if accent == "none" then return "none" end
    if accent ~= "auto" then return accent end
    local _, raceFile = UnitRace("player")
    return (raceFile and RACE_FILE_MAP[raceFile]) or "none"
end

local function WordBoundaryReplace(text, from, to)
    -- Case-insensitive whole-word style replace; keep simple for addon Lua.
    local pattern = "%f[%w]" .. from:gsub("(%W)", "%%%1") .. "%f[%W]"
    local out = text:gsub(pattern, to)
    -- Leading word
    pattern = "^" .. from:gsub("(%W)", "%%%1") .. "%f[%W]"
    out = out:gsub(pattern, to)
    -- Capitalized variant if from is lowercase
    if from:match("^%l") then
        local cap = from:sub(1, 1):upper() .. from:sub(2)
        local toCap = to:sub(1, 1):upper() .. to:sub(2)
        pattern = "%f[%w]" .. cap:gsub("(%W)", "%%%1") .. "%f[%W]"
        out = out:gsub(pattern, toCap)
    end
    return out
end

function InCharacter.Voice.Apply(text, profileId)
    if not text or text == "" then return text end
    profileId = profileId or InCharacter.Voice.ResolveProfile()
    if not profileId or profileId == "none" then return text end
    local lex = InCharacter.VoiceLexicon and InCharacter.VoiceLexicon[profileId]
    if not lex or not lex.rules or #lex.rules == 0 then return text end

    local out = text
    for _, rule in ipairs(lex.rules) do
        local from, to = rule[1], rule[2]
        if from and to then
            if rule.plain then
                out = out:gsub(from, to)
            else
                out = WordBoundaryReplace(out, from, to)
            end
        end
    end
    return out
end

function InCharacter.Voice.MaybeApplyChronicle(text)
    local v = EnsureVoiceDB()
    if v.applyToChronicle == false then return text end
    return InCharacter.Voice.Apply(text)
end

function InCharacter.Voice.MaybeApplyBulletin(text)
    local v = EnsureVoiceDB()
    if not v.applyToBulletins then return text end
    return InCharacter.Voice.Apply(text)
end

--- Soft OOC linter for free text (bulletins). Returns warning string or nil.
function InCharacter.Voice.SoftOOCLint(text)
    if not text or text == "" then return nil end
    local lower = text:lower()
    local flags = {}
    if lower:find("%(%s*ooc") or lower:find("%[ooc") or lower:find("ooc:") then
        flags[#flags + 1] = "OOC tags"
    end
    if lower:find("%f[%w]lfg%f[%W]") or lower:find("%f[%w]irl%f[%W]") or lower:find("%f[%w]brb%f[%W]")
        or lower:find("%f[%w]afk%f[%W]") or lower:find("%f[%w]pst%f[%W]") then
        flags[#flags + 1] = "forum-speak"
    end
    if lower:find("%f[%w]lol%f[%W]") or lower:find("%f[%w]lmao%f[%W]") or lower:find("%f[%w]omg%f[%W]") then
        flags[#flags + 1] = "modern slang"
    end
    if #flags == 0 then return nil end
    return "This might read as out-of-character (" .. table.concat(flags, ", ") .. "). Post anyway?"
end
