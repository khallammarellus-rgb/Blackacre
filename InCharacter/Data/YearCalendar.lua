InCharacter = InCharacter or {}
InCharacter.YearCalendar = {}

-- Portal-relative calendar (ADP = years After Dark Portal; negative = BDP).
-- Year 0 ADP = Dark Portal opens = 592 K.C. (Timeline, warcraft.wiki.gg)

InCharacter.YearCalendar.PORTAL_YEAR_KC = 592
InCharacter.YearCalendar.DEFAULT_PRESENT_ADP = 42

function InCharacter.YearCalendar.EnsureIdentity()
    InCharacter.CharDB = InCharacter.CharDB or InCharacterCharDB
    InCharacter.CharDB.identity = InCharacter.CharDB.identity or {
        birthYearADP = nil,
        birthEraId = nil,
        birthPlace = "",
        presentYearADP = InCharacter.YearCalendar.DEFAULT_PRESENT_ADP,
        calendarDisplay = "AUTO",
        longevityProfile = "auto",
        originMode = "born",
        stasisUntilADP = nil,
        deathYearADP = nil,
        rebirthYearADP = nil,
    }
    local id = InCharacter.CharDB.identity
    if id.presentYearADP == nil then
        id.presentYearADP = InCharacter.YearCalendar.DEFAULT_PRESENT_ADP
    end
    -- Migrate old yearKCBase flavor into presentYearADP once
    if id.birthYearADP == nil and InCharacter.CharDB.settings and InCharacter.CharDB.settings.yearKCBase then
        -- old default 42 was already portal-ish flavor
        id.presentYearADP = InCharacter.CharDB.settings.yearKCBase or id.presentYearADP
    end
    return id
end

function InCharacter.YearCalendar.GetPresentADP()
    local id = InCharacter.YearCalendar.EnsureIdentity()
    return tonumber(id.presentYearADP) or InCharacter.YearCalendar.DEFAULT_PRESENT_ADP
end

function InCharacter.YearCalendar.SetPresentADP(year)
    local id = InCharacter.YearCalendar.EnsureIdentity()
    id.presentYearADP = tonumber(year) or InCharacter.YearCalendar.DEFAULT_PRESENT_ADP
end

function InCharacter.YearCalendar.GetBirthADP()
    local id = InCharacter.YearCalendar.EnsureIdentity()
    return id.birthYearADP ~= nil and tonumber(id.birthYearADP) or nil
end

function InCharacter.YearCalendar.SetBirthADP(year, eraId)
    local id = InCharacter.YearCalendar.EnsureIdentity()
    id.birthYearADP = tonumber(year)
    if eraId then id.birthEraId = eraId end
end

function InCharacter.YearCalendar.ToKC(yearADP)
    yearADP = tonumber(yearADP)
    if yearADP == nil then return nil end
    return InCharacter.YearCalendar.PORTAL_YEAR_KC + yearADP
end

function InCharacter.YearCalendar.FromKC(yearKC)
    yearKC = tonumber(yearKC)
    if yearKC == nil then return nil end
    return yearKC - InCharacter.YearCalendar.PORTAL_YEAR_KC
end

function InCharacter.YearCalendar.FormatYearADP(yearADP, displayMode)
    yearADP = tonumber(yearADP)
    if yearADP == nil then return "?" end
    displayMode = displayMode or (InCharacter.YearCalendar.EnsureIdentity().calendarDisplay or "AUTO")

    local adpStr
    if yearADP < 0 then
        adpStr = string.format("%d BDP", math.abs(yearADP))
    elseif yearADP == 0 then
        adpStr = "0 ADP (Dark Portal)"
    else
        adpStr = string.format("%d ADP", yearADP)
    end

    local kc = InCharacter.YearCalendar.ToKC(yearADP)
    local kcOk = yearADP >= -InCharacter.YearCalendar.PORTAL_YEAR_KC
    local kcStr = kcOk and string.format("%d K.C.", kc) or nil

    if displayMode == "ADP" then
        return adpStr
    elseif displayMode == "KC" and kcStr then
        return kcStr
    elseif displayMode == "BOTH" and kcStr then
        return adpStr .. " · " .. kcStr
    elseif displayMode == "AUTO" then
        if yearADP < -100 then
            return adpStr -- deep past: avoid nonsense K.C.
        elseif kcStr then
            return adpStr .. " · " .. kcStr
        end
        return adpStr
    end
    return adpStr
end

-- Back-compat for chronicle hooks that still call GetYearKC / FormatYear
function InCharacter.YearCalendar.GetYearKC()
    return InCharacter.YearCalendar.ToKC(InCharacter.YearCalendar.GetPresentADP())
end

function InCharacter.YearCalendar.FormatYear(year)
    if year and year > 200 then
        -- treat as K.C. number from old call sites
        local adp = InCharacter.YearCalendar.FromKC(year)
        return InCharacter.YearCalendar.FormatYearADP(adp)
    end
    return InCharacter.YearCalendar.FormatYearADP(year or InCharacter.YearCalendar.GetPresentADP())
end

function InCharacter.YearCalendar.SetBase(year)
    -- legacy: interpret as present ADP if small, else K.C.
    year = tonumber(year)
    if not year then return end
    if year > 200 then
        InCharacter.YearCalendar.SetPresentADP(InCharacter.YearCalendar.FromKC(year))
    else
        InCharacter.YearCalendar.SetPresentADP(year)
    end
end

function InCharacter.YearCalendar.GetChronologicalAge()
    local birth = InCharacter.YearCalendar.GetBirthADP()
    if birth == nil then return nil end
    return InCharacter.YearCalendar.GetPresentADP() - birth
end