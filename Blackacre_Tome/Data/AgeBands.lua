Blackacre = Blackacre or {}

-- Longevity profiles: band thresholds in chronological years of age.
-- Bands are ordered; first matching maxAge wins.

Blackacre.LongevityProfiles = {
    mortal = {
        label = "Mortal span",
        bands = {
            { id = "child", maxAge = 12, text = "still a child of the hearth" },
            { id = "youth", maxAge = 17, text = "youth on the edge of the road" },
            { id = "young_adult", maxAge = 25, text = "young adult, newly blooded by the world" },
            { id = "adult", maxAge = 40, text = "in the prime of mortal years" },
            { id = "veteran", maxAge = 60, text = "veteran of hard seasons" },
            { id = "elder", maxAge = 99999, text = "elder among short-lived peoples" },
        },
        adultAt = 18,
        comingOfAgeStart = 14,
        comingOfAgeEnd = 22,
    },
    long_lived = {
        label = "Long-lived",
        bands = {
            { id = "child", maxAge = 40, text = "still young by their people's reckoning" },
            { id = "youth", maxAge = 80, text = "coming into long adulthood" },
            { id = "young_adult", maxAge = 200, text = "a younger adult of centuries" },
            { id = "adult", maxAge = 500, text = "settled into long adulthood" },
            { id = "veteran", maxAge = 1000, text = "aged in the long count" },
            { id = "elder", maxAge = 999999, text = "ancient among the long-lived" },
        },
        adultAt = 100,
        comingOfAgeStart = 60,
        comingOfAgeEnd = 150,
    },
    elf = {
        label = "Elven span",
        bands = {
            { id = "child", maxAge = 100, text = "a child by elven count" },
            { id = "youth", maxAge = 300, text = "youth among the stars' children" },
            { id = "young_adult", maxAge = 1000, text = "young by millennia, adult by deed" },
            { id = "adult", maxAge = 5000, text = "in the long adulthood of the elves" },
            { id = "veteran", maxAge = 10000, text = "veteran of ages; witness of ruin and vigil" },
            { id = "elder", maxAge = 999999, text = "elder of the Long Vigil and older nights" },
        },
        adultAt = 300,
        comingOfAgeStart = 200,
        comingOfAgeEnd = 500,
    },
    earthen = {
        label = "Earthen / titan-forged",
        bands = {
            { id = "child", maxAge = 50, text = "newly shaped or newly aware" },
            { id = "youth", maxAge = 200, text = "learning the weight of stone and oath" },
            { id = "young_adult", maxAge = 1000, text = "proven in the deep places" },
            { id = "adult", maxAge = 10000, text = "steadfast as the ordered world" },
            { id = "veteran", maxAge = 50000, text = "memory of keepers and long dark" },
            { id = "elder", maxAge = 9999999, text = "as old as vaults and star-metal" },
        },
        adultAt = 200,
        comingOfAgeStart = 100,
        comingOfAgeEnd = 400,
    },
    dracthyr = {
        label = "Dracthyr",
        bands = {
            { id = "child", maxAge = 20, text = "barely fledged in this age" },
            { id = "youth", maxAge = 50, text = "young weaver of visage and scale" },
            { id = "young_adult", maxAge = 200, text = "adult of the flights' design" },
            { id = "adult", maxAge = 2000, text = "tempered — if memory of stasis counts" },
            { id = "veteran", maxAge = 20000, text = "forged in Scaleborn fire, scarred by ages" },
            { id = "elder", maxAge = 999999, text = "elder of Neltharion's experiment" },
        },
        adultAt = 50,
        comingOfAgeStart = 30,
        comingOfAgeEnd = 100,
        preferStasis = true,
    },
    undead = {
        label = "Undead span",
        bands = {
            { id = "child", maxAge = 12, text = "a brief living childhood, if any" },
            { id = "youth", maxAge = 17, text = "cut short or twisted young" },
            { id = "young_adult", maxAge = 30, text = "death found them early in life" },
            { id = "adult", maxAge = 60, text = "a full mortal life before the grave" },
            { id = "veteran", maxAge = 200, text = "long in undeath" },
            { id = "elder", maxAge = 99999, text = "ancient among the restless" },
        },
        adultAt = 18,
        comingOfAgeStart = 14,
        comingOfAgeEnd = 22,
    },
}

-- Map UnitRace localization-insensitive tokens where possible
Blackacre.RaceLongevityMap = {
    Human = "mortal",
    Orc = "mortal",
    Dwarf = "mortal",
    NightElf = "elf",
    Scourge = "undead",
    Tauren = "mortal",
    Gnome = "mortal",
    Troll = "mortal",
    Goblin = "mortal",
    BloodElf = "elf",
    Draenei = "long_lived",
    Worgen = "mortal",
    Pandaren = "mortal",
    Nightborne = "elf",
    HighmountainTauren = "mortal",
    VoidElf = "elf",
    LightforgedDraenei = "long_lived",
    ZandalariTroll = "mortal",
    KulTiran = "mortal",
    DarkIronDwarf = "mortal",
    Vulpera = "mortal",
    MagharOrc = "mortal",
    Mechagnome = "mortal",
    Dracthyr = "dracthyr",
    Earthen = "earthen",
    EarthenDwarf = "earthen",
}

function Blackacre.DetectLongevityProfile()
    local _, raceFile = UnitRace("player")
    if raceFile and Blackacre.RaceLongevityMap[raceFile] then
        return Blackacre.RaceLongevityMap[raceFile]
    end
    -- fallback: scan localized race name
    local raceLoc = UnitRace("player") or ""
    local lower = raceLoc:lower()
    if lower:find("elf", 1, true) or lower:find("nightborne", 1, true) then return "elf" end
    if lower:find("draenei", 1, true) then return "long_lived" end
    if lower:find("dracthyr", 1, true) then return "dracthyr" end
    if lower:find("earthen", 1, true) then return "earthen" end
    if lower:find("undead", 1, true) or lower:find("forsaken", 1, true) then return "undead" end
    return "mortal"
end

function Blackacre.GetLongevityProfileId()
    local id = Blackacre.YearCalendar and Blackacre.YearCalendar.EnsureIdentity and Blackacre.YearCalendar.EnsureIdentity()
    if id and id.longevityProfile and id.longevityProfile ~= "auto" then
        if Blackacre.LongevityProfiles[id.longevityProfile] then
            return id.longevityProfile
        end
    end
    return Blackacre.DetectLongevityProfile()
end

function Blackacre.GetLongevityProfile()
    local pid = Blackacre.GetLongevityProfileId()
    return Blackacre.LongevityProfiles[pid] or Blackacre.LongevityProfiles.mortal, pid
end

function Blackacre.GetAgeBand(ageYears)
    ageYears = tonumber(ageYears) or 0
    if ageYears < 0 then ageYears = 0 end
    local profile = Blackacre.GetLongevityProfile()
    for _, band in ipairs(profile.bands) do
        if ageYears <= band.maxAge then
            return band, profile
        end
    end
    return profile.bands[#profile.bands], profile
end