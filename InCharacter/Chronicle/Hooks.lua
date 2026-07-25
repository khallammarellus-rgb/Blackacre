InCharacter = InCharacter or {}
InCharacter.Chronicle = InCharacter.Chronicle or {}
InCharacter.Chronicle.Hooks = {}

local function GetSeasoning(level)
    level = level or 1
    for _, band in ipairs(InCharacter.HookSeasoning or {}) do
        if level <= band.maxLevel then
            return band.text
        end
    end
    return "on the path"
end

function InCharacter.Chronicle.Hooks.GetContext()
    local raceLoc = UnitRace("player") or "unknown"
    local classLoc = UnitClass("player") or "adventurer"
    local level = UnitLevel("player") or 1
    local spec = ""
    if GetSpecialization then
        local idx = GetSpecialization()
        if idx then
            local _, name = GetSpecializationInfo(idx)
            spec = name or ""
        end
    end
    local zone = InCharacter.GetZoneContext()
    return {
        name = InCharacter.GetCharName(),
        race = raceLoc,
        class = classLoc,
        level = level,
        spec = spec,
        zone = zone.zoneName ~= "" and zone.zoneName or "unknown lands",
        zoneId = zone.zoneId,
        subzone = zone.subzone,
        yearKC = InCharacter.YearCalendar.GetYearKC(),
        seasoning = GetSeasoning(level),
    }
end

local function Fill(template, slots)
    return (template:gsub("{(%w+)}", function(key)
        local v = slots[key]
        if v == nil or v == "" then
            return ""
        end
        return tostring(v)
    end)):gsub("%s+", " "):gsub("%s+([%.,;:])", "%1"):gsub("^%s+", ""):gsub("%s+$", "")
end

function InCharacter.Chronicle.Hooks.Resolve(kind, facts, context)
    context = context or InCharacter.Chronicle.Hooks.GetContext()
    facts = facts or {}
    local banks = InCharacter.HookTemplates or {}
    local list = banks[kind] or banks.DEFAULT or { "In {yearKC}, {name} marked an event." }
    local template = list[math.random(1, #list)]

    local slots = {
        name = context.name,
        race = context.race,
        class = context.class,
        level = tostring(context.level),
        zone = facts.zoneName or context.zone,
        yearKC = InCharacter.YearCalendar.FormatYear(facts.yearKC or context.yearKC),
        seasoning = context.seasoning,
        kind = kind or "NOTE",
        questName = facts.questName or facts.name or "an unnamed trial",
        achievementName = facts.achievementName or facts.name or "an unnamed feat",
        titleName = facts.titleName or facts.name or "an untitled honor",
        skillName = facts.skillName or "their craft",
        skillRank = facts.skillRank and tostring(facts.skillRank) or "a new rank",
        manualTitle = facts.manualTitle or facts.title or "a private note",
        manualBody = facts.manualBody or facts.body or "",
        bagDetail = facts.bagDetail or "an oversized pack",
        spec = context.spec or "",
        specClause = (context.spec and context.spec ~= "") and (" (" .. context.spec .. ")") or "",
    }

    local body = Fill(template, slots)
    local title
    if kind == "QUEST" then
        title = facts.questName or "Quest completed"
    elseif kind == "ACHIEVEMENT" then
        title = facts.achievementName or "Achievement"
    elseif kind == "TITLE" then
        title = facts.titleName or "Title gained"
    elseif kind == "PROFESSION" then
        title = (facts.skillName or "Profession") .. " advanced"
    elseif kind == "MANUAL" then
        title = facts.manualTitle or facts.title or "Journal note"
    elseif kind == "DEATH" then
        title = facts.title or ("Fell in " .. (facts.zoneName or slots.zone or "the field"))
    elseif kind == "HC_ENCUMBRANCE" then
        title = facts.title or "Encumbrance broken"
    elseif kind == "HC_MOUNT" then
        title = facts.title or "Mounted without ground rite"
    elseif kind == "HC_FLY" then
        title = facts.title or "Flew without sky rite"
    else
        title = facts.title or kind or "Entry"
    end

    return title, body
end

function InCharacter.Chronicle.Hooks.Regenerate(entry)
    if not entry then return end
    local context = entry.context or InCharacter.Chronicle.Hooks.GetContext()
    local title, body = InCharacter.Chronicle.Hooks.Resolve(entry.kind, entry.facts, context)
    entry.title = title
    entry.body = body
    entry.editedAt = time()
    return entry
end