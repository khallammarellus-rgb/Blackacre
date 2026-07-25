InCharacter = InCharacter or {}
InCharacter.Lore = InCharacter.Lore or {}
InCharacter.Birthpath = {}

local function Identity()
    return InCharacter.YearCalendar.EnsureIdentity()
end

function InCharacter.Birthpath.GetEffectiveAge()
    local id = Identity()
    local birth = InCharacter.YearCalendar.GetBirthADP()
    if birth == nil then return nil end
    local present = InCharacter.YearCalendar.GetPresentADP()
    local chrono = present - birth

    if id.originMode == "stasis" and id.stasisUntilADP then
        local wake = tonumber(id.stasisUntilADP)
        if wake then
            -- conscious years this age since wake; pre-stasis life optional footnote
            local conscious = present - wake
            if conscious < 0 then conscious = 0 end
            return conscious, chrono, "stasis"
        end
    end
    if id.originMode == "awakened" and id.rebirthYearADP then
        local wake = tonumber(id.rebirthYearADP)
        if wake then
            return math.max(0, present - wake), chrono, "awakened"
        end
    end
    if id.originMode == "raised" and id.rebirthYearADP then
        local re = tonumber(id.rebirthYearADP)
        if re then
            return math.max(0, present - re), chrono, "raised"
        end
    end
    return chrono, chrono, id.originMode or "born"
end

function InCharacter.Birthpath.FormatAge()
    local eff, chrono, mode = InCharacter.Birthpath.GetEffectiveAge()
    if eff == nil then return "Age unknown (set birth year)" end
    local band = InCharacter.GetAgeBand(eff)
    local ageStr
    if eff >= 1000 then
        ageStr = string.format("~%d years", math.floor(eff + 0.5))
    else
        ageStr = string.format("%d years", math.floor(eff + 0.5))
    end
    if mode == "stasis" and chrono and chrono > eff + 10 then
        return string.format("%s conscious (%s) · %s chronological · %s", ageStr, band.text, InCharacter.Birthpath.FormatYears(chrono), mode)
    end
    return string.format("%s · %s", ageStr, band.text)
end

function InCharacter.Birthpath.FormatYears(n)
    n = math.floor(tonumber(n) or 0)
    if n >= 1000 then
        return string.format("~%d years", n)
    end
    return tostring(n) .. " years"
end

function InCharacter.Birthpath.GetSummary()
    local birth = InCharacter.YearCalendar.GetBirthADP()
    local present = InCharacter.YearCalendar.GetPresentADP()
    if birth == nil then
        return "No birth year set. Open Lineage (/ic birth) to begin the long count of your days."
    end
    local _, profileId = InCharacter.GetLongevityProfile()
    local profile = InCharacter.GetLongevityProfile()
    local birthEra = InCharacter.GetEraAtYear(birth)
    local presentEra = InCharacter.GetEraAtYear(present)
    local ageLine = InCharacter.Birthpath.FormatAge()
    return string.format(
        "Born %s (%s). Present %s (%s). %s. Longevity: %s.",
        InCharacter.YearCalendar.FormatYearADP(birth),
        birthEra and birthEra.name or "unknown era",
        InCharacter.YearCalendar.FormatYearADP(present),
        presentEra and presentEra.name or "present",
        ageLine,
        profile.label or profileId
    )
end

function InCharacter.Birthpath.GetAdultErasLived()
    local birth = InCharacter.YearCalendar.GetBirthADP()
    if birth == nil then return {} end
    local present = InCharacter.YearCalendar.GetPresentADP()
    local profile = InCharacter.GetLongevityProfile()
    local adultAt = profile.adultAt or 18
    local adultFrom = birth + adultAt
    if adultFrom > present then
        return {}
    end
    local id = Identity()
    if id.originMode == "stasis" and id.stasisUntilADP then
        -- eras of conscious adult life after wake, plus optional pre-stasis if they aged to adult before stasis
        local wake = tonumber(id.stasisUntilADP)
        local eras = InCharacter.ErasOverlapping(math.max(adultFrom, wake or adultFrom), present)
        return eras
    end
    return InCharacter.ErasOverlapping(adultFrom, present)
end

local function TagSet(eras)
    local set = {}
    for _, e in ipairs(eras or {}) do
        set[e.id] = true
        for _, t in ipairs(e.tags or {}) do
            set[t] = true
        end
    end
    return set
end

function InCharacter.Birthpath.AnnotateZone(zone)
    if type(zone) == "string" then
        zone = InCharacter.GetRoadmapZone(zone)
    end
    if not zone then return "stretch", 0 end
    local birth = InCharacter.YearCalendar.GetBirthADP()
    local present = InCharacter.YearCalendar.GetPresentADP()
    if birth == nil then return "stretch", 0 end

    local eff = InCharacter.Birthpath.GetEffectiveAge()
    local profile = InCharacter.GetLongevityProfile()
    local lived = TagSet(InCharacter.Birthpath.GetAdultErasLived())
    local score = 50
    local fit = "stretch"

    local peakStart = zone.peakStartADP or zone.levelMin -- fallback nonsense avoided
    if zone.peakStartADP then
        peakStart = zone.peakStartADP
        local peakEnd = zone.peakEndADP or peakStart
        if peakEnd < birth then
            fit = "legend_only"
            score = 20
        elseif peakStart > present then
            fit = "future"
            score = 15
        else
            fit = "natural"
            score = 70
        end
    end

    for _, tag in ipairs(zone.eraTags or {}) do
        if lived[tag] then
            score = score + 15
            if fit == "stretch" then fit = "natural" end
        end
    end

    local minA = zone.minAgeSuggest or 0
    local maxA = zone.maxAgeSuggest or 999999
    -- scale min/max if profile is elf and zone used mortal ages without profile key
    if profile.adultAt and profile.adultAt > 50 and (zone.minAgeSuggest or 0) < 50 then
        -- zone table mortal ages; for ancients treat minAge as soft only
        minA = 0
    end
    if eff and eff >= minA and eff <= maxA then
        score = score + 10
    elseif eff and eff < minA then
        score = score - 15
        if fit == "natural" then fit = "stretch" end
    end

    local coStart = birth + (profile.comingOfAgeStart or 14)
    local coEnd = birth + (profile.comingOfAgeEnd or 22)
    if zone.peakStartADP and zone.peakEndADP then
        if zone.peakEndADP >= coStart and zone.peakStartADP <= coEnd then
            score = score + 20
            fit = "natural"
        end
    end

    if score > 100 then score = 100 end
    if score < 0 then score = 0 end
    return fit, score
end

function InCharacter.Birthpath.GetZoneSuggestions(n)
    n = n or 5
    local list = {}
    for _, z in ipairs(InCharacter.RoadmapZoneCatalog or {}) do
        local fit, score = InCharacter.Birthpath.AnnotateZone(z)
        list[#list + 1] = { zone = z, fit = fit, score = score }
    end
    table.sort(list, function(a, b) return a.score > b.score end)
    local out = {}
    for i = 1, math.min(n, #list) do
        out[i] = list[i]
    end
    return out
end

function InCharacter.Birthpath.GetPresetSuggestions(n)
    n = n or 2
    local scored = {}
    for _, preset in ipairs(InCharacter.RoadmapPresets or {}) do
        local total, count = 0, 0
        for _, zid in ipairs(preset.steps or {}) do
            local z = InCharacter.GetRoadmapZone(zid)
            if z then
                local _, score = InCharacter.Birthpath.AnnotateZone(z)
                total = total + score
                count = count + 1
            end
        end
        local avg = count > 0 and (total / count) or 0
        scored[#scored + 1] = { preset = preset, score = avg }
    end
    table.sort(scored, function(a, b) return a.score > b.score end)
    local out = {}
    for i = 1, math.min(n, #scored) do
        out[i] = scored[i]
    end
    return out
end

function InCharacter.Birthpath.ChartFromBirth()
    local suggestions = InCharacter.Birthpath.GetPresetSuggestions(1)
    if #suggestions == 0 then
        InCharacter.Print("No roadmap presets available.")
        return nil
    end
    local preset = suggestions[1].preset
    InCharacter.Roadmap.Store.StartPreset(preset.id)
    InCharacter.Print("Expedition charted from lineage: " .. preset.name)
    if InCharacter.Roadmap.UI and InCharacter.Roadmap.UI.Refresh then
        InCharacter.Roadmap.UI.Refresh()
    end
    return preset
end

function InCharacter.Birthpath.OnBirthSet()
    local birth = InCharacter.YearCalendar.GetBirthADP()
    if birth == nil then return end
    local summary = InCharacter.Birthpath.GetSummary()
    InCharacter.Chronicle.Capture.AddEntry("MANUAL", {
        manualTitle = "Lineage recorded",
        manualBody = summary,
        title = "Lineage recorded",
        body = summary,
    }, "manual")
end

function InCharacter.Birthpath.DebugSampleHuman()
    InCharacter.YearCalendar.SetBirthADP(2, "first_war")
    InCharacter.YearCalendar.SetPresentADP(20)
    local id = Identity()
    id.originMode = "born"
    id.longevityProfile = "mortal"
    id.stasisUntilADP = nil
    InCharacter.Print(InCharacter.Birthpath.GetSummary())
end

function InCharacter.Birthpath.DebugSampleElf()
    InCharacter.YearCalendar.SetBirthADP(-10000, "war_of_ancients")
    InCharacter.YearCalendar.SetPresentADP(42)
    local id = Identity()
    id.originMode = "born"
    id.longevityProfile = "elf"
    InCharacter.Print(InCharacter.Birthpath.GetSummary())
end

function InCharacter.Birthpath.DebugSampleDracthyr()
    InCharacter.YearCalendar.SetBirthADP(-22000, "scaleborn")
    InCharacter.YearCalendar.SetPresentADP(41)
    local id = Identity()
    id.originMode = "stasis"
    id.stasisUntilADP = 40
    id.longevityProfile = "dracthyr"
    InCharacter.Print(InCharacter.Birthpath.GetSummary())
end