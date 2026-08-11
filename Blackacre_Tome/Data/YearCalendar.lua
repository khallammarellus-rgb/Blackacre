Blackacre = Blackacre or {}
Blackacre.YearCalendar = {}

-- Portal-relative calendar (ADP = years After Dark Portal; negative = BDP).
-- Year 0 ADP = Dark Portal opens = 592 K.C. (Timeline, warcraft.wiki.gg)

Blackacre.YearCalendar.PORTAL_YEAR_KC = 592
Blackacre.YearCalendar.DEFAULT_PRESENT_ADP = 42

function Blackacre.YearCalendar.EnsureIdentity()
    Blackacre.CharDB = Blackacre.CharDB or BlackacreCharDB
    Blackacre.CharDB.identity = Blackacre.CharDB.identity or {
        birthYearADP = nil,
        birthEraId = nil,
        birthPlace = "",
        presentYearADP = Blackacre.YearCalendar.DEFAULT_PRESENT_ADP,
        calendarDisplay = "AUTO",
        longevityProfile = "auto",
        originMode = "born",
        stasisUntilADP = nil,
        deathYearADP = nil,
        rebirthYearADP = nil,
    }
    local id = Blackacre.CharDB.identity
    if id.presentYearADP == nil then
        id.presentYearADP = Blackacre.YearCalendar.DEFAULT_PRESENT_ADP
    end
    -- Migrate old yearKCBase flavor into presentYearADP once
    if id.birthYearADP == nil and Blackacre.CharDB.settings and Blackacre.CharDB.settings.yearKCBase then
        -- old default 42 was already portal-ish flavor
        id.presentYearADP = Blackacre.CharDB.settings.yearKCBase or id.presentYearADP
    end
    return id
end

function Blackacre.YearCalendar.GetPresentADP()
    local id = Blackacre.YearCalendar.EnsureIdentity()
    return tonumber(id.presentYearADP) or Blackacre.YearCalendar.DEFAULT_PRESENT_ADP
end

function Blackacre.YearCalendar.SetPresentADP(year)
    local id = Blackacre.YearCalendar.EnsureIdentity()
    id.presentYearADP = tonumber(year) or Blackacre.YearCalendar.DEFAULT_PRESENT_ADP
end

function Blackacre.YearCalendar.GetBirthADP()
    local id = Blackacre.YearCalendar.EnsureIdentity()
    return id.birthYearADP ~= nil and tonumber(id.birthYearADP) or nil
end

function Blackacre.YearCalendar.SetBirthADP(year, eraId)
    local id = Blackacre.YearCalendar.EnsureIdentity()
    id.birthYearADP = tonumber(year)
    if eraId then id.birthEraId = eraId end
end

function Blackacre.YearCalendar.ToKC(yearADP)
    yearADP = tonumber(yearADP)
    if yearADP == nil then return nil end
    return Blackacre.YearCalendar.PORTAL_YEAR_KC + yearADP
end

function Blackacre.YearCalendar.FromKC(yearKC)
    yearKC = tonumber(yearKC)
    if yearKC == nil then return nil end
    return yearKC - Blackacre.YearCalendar.PORTAL_YEAR_KC
end

function Blackacre.YearCalendar.FormatYearADP(yearADP, displayMode)
    yearADP = tonumber(yearADP)
    if yearADP == nil then return "?" end
    displayMode = displayMode or (Blackacre.YearCalendar.EnsureIdentity().calendarDisplay or "AUTO")

    local adpStr
    if yearADP < 0 then
        adpStr = string.format("%d BDP", math.abs(yearADP))
    elseif yearADP == 0 then
        adpStr = "0 ADP (Dark Portal)"
    else
        adpStr = string.format("%d ADP", yearADP)
    end

    local kc = Blackacre.YearCalendar.ToKC(yearADP)
    local kcOk = yearADP >= -Blackacre.YearCalendar.PORTAL_YEAR_KC
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
function Blackacre.YearCalendar.GetYearKC()
    return Blackacre.YearCalendar.ToKC(Blackacre.YearCalendar.GetPresentADP())
end

function Blackacre.YearCalendar.FormatYear(year)
    if year and year > 200 then
        -- treat as K.C. number from old call sites
        local adp = Blackacre.YearCalendar.FromKC(year)
        return Blackacre.YearCalendar.FormatYearADP(adp)
    end
    return Blackacre.YearCalendar.FormatYearADP(year or Blackacre.YearCalendar.GetPresentADP())
end

function Blackacre.YearCalendar.SetBase(year)
    -- legacy: interpret as present ADP if small, else K.C.
    year = tonumber(year)
    if not year then return end
    if year > 200 then
        Blackacre.YearCalendar.SetPresentADP(Blackacre.YearCalendar.FromKC(year))
    else
        Blackacre.YearCalendar.SetPresentADP(year)
    end
end

function Blackacre.YearCalendar.GetChronologicalAge()
    local birth = Blackacre.YearCalendar.GetBirthADP()
    if birth == nil then return nil end
    return Blackacre.YearCalendar.GetPresentADP() - birth
end