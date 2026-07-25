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
        meterName = facts.meter == "hunger" and "hunger"
            or facts.meter == "thirst" and "thirst"
            or facts.meter == "exposure" and "exposure"
            or facts.meterName or "vital strength",
        meterValue = facts.value and tostring(math.floor(facts.value)) or "low",
        pathName = facts.pathName or "an unnamed afterlife",
        afterlifeDetail = facts.stage == "begin" and ("The road opened after a fall in " .. (facts.deathZone or context.zone or "unknown lands") .. ".")
            or facts.stage == "task" and (facts.taskBody or "A rite was fulfilled.")
            or facts.stage == "return" and ("They returned to the living from " .. (facts.pathName or "death's realm") .. ".")
            or facts.stage == "abandon" and "The path was left unfinished."
            or (facts.taskBody or "A soul-rite was marked."),
        roadmapName = facts.roadmapName or "an unnamed road",
        roadmapDetail = facts.stage == "begin" and ("First ink on the chart points toward " .. (facts.zoneName or "unknown lands") .. ".")
            or facts.stage == "arrive" and ("The road opens into " .. (facts.zoneName or "a new land") .. ". " .. (facts.lore or ""))
            or facts.stage == "chapter" and ("They close the chapter of " .. (facts.zoneName or "that land") .. ". " .. (facts.lore or ""))
            or facts.stage == "lock" and ("They choose to linger near level " .. tostring(facts.lockLevel or "?") .. " in " .. (facts.zoneName or "place") .. ", so the story may breathe.")
            or facts.stage == "complete" and "The expedition chart is finished — for now."
            or facts.stage == "abandon" and "The chart is folded away unfinished."
            or (facts.lore or "The road continues."),
        mapName = facts.mapName or "the field",
        outcomeLine = facts.outcomeLine or "The skirmish ended.",
        damageText = facts.damageText or "unknown",
        healingText = facts.healingText or "unknown",
        deaths = facts.deaths and tostring(facts.deaths) or "0",
        killingBlows = facts.killingBlows and tostring(facts.killingBlows) or "0",
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
    elseif kind == "SURVIVAL" then
        title = facts.title or "Survival critical"
    elseif kind == "AFTERLIFE" then
        title = facts.title or ("Afterlife: " .. (facts.pathName or "unknown"))
    elseif kind == "ROADMAP" then
        title = facts.title or ("Road: " .. (facts.roadmapName or "expedition"))
    elseif kind == "PVP" then
        title = facts.title or ("Field report: " .. (facts.mapName or "battle"))
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