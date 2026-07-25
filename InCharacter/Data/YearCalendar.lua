InCharacter = InCharacter or {}
InCharacter.YearCalendar = {}

-- Approximate K.C. flavor calendar (not official lore authority).
-- Players may override year per entry in the journal editor.
-- Baseline: patch-era mapping for RP flavor only.

local DEFAULT_EPOCH_KC = 42 -- tunable flavor baseline for current expansion era

function InCharacter.YearCalendar.GetYearKC()
    local settings = InCharacter.CharDB and InCharacter.CharDB.settings
    if settings and settings.yearKCOffset then
        return (settings.yearKCBase or DEFAULT_EPOCH_KC) + (settings.yearKCOffset or 0)
    end
    return DEFAULT_EPOCH_KC
end

function InCharacter.YearCalendar.FormatYear(year)
    year = year or InCharacter.YearCalendar.GetYearKC()
    return string.format("%d K.C.", year)
end

function InCharacter.YearCalendar.SetBase(year)
    InCharacter.CharDB.settings = InCharacter.CharDB.settings or {}
    InCharacter.CharDB.settings.yearKCBase = tonumber(year) or DEFAULT_EPOCH_KC
end