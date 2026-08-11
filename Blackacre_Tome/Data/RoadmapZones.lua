Blackacre = Blackacre or {}

-- Seed expedition chart data. Levels are approximate retail bands for RP pacing.
-- peakStartADP/peakEndADP = soft historical peak for birth-path scoring.
-- lockAt = suggested level to pause XP before leaving the chapter.

Blackacre.RoadmapZoneCatalog = {
    { id = "elwynn", name = "Elwynn Forest", levelMin = 1, levelMax = 10, faction = "Alliance", hubs = { "Goldshire", "Northshire" }, lore = "Human hearthlands; kobolds, gnolls, and the shadow of Stormwind's peace.", lockAt = 10, eraTags = { "first_war", "vanilla", "classic" }, peakStartADP = 0, peakEndADP = 30, minAgeSuggest = 10, maxAgeSuggest = 80, tone = "childhood_home" },
    { id = "westfall", name = "Westfall", levelMin = 10, levelMax = 20, faction = "Alliance", hubs = { "Sentinel Hill" }, lore = "Dusty farms, Defias whispers, and people pushed to the edge.", lockAt = 20, eraTags = { "vanilla", "classic" }, peakStartADP = 25, peakEndADP = 30, minAgeSuggest = 14, maxAgeSuggest = 60, tone = "aftermath" },
    { id = "redridge", name = "Redridge Mountains", levelMin = 15, levelMax = 25, faction = "Alliance", hubs = { "Lakeshire" }, lore = "Orcish pressure on a lakeside town that will not break.", lockAt = 25, eraTags = { "first_war", "vanilla" }, peakStartADP = 1, peakEndADP = 30, minAgeSuggest = 16, maxAgeSuggest = 50, tone = "war_front" },
    { id = "duskwood", name = "Duskwood", levelMin = 20, levelMax = 30, faction = "Alliance", hubs = { "Darkshire" }, lore = "Night, worgen, and the thin line between living and dead.", lockAt = 30, eraTags = { "first_war", "vanilla" }, peakStartADP = 3, peakEndADP = 30, minAgeSuggest = 16, maxAgeSuggest = 80, tone = "aftermath" },
    { id = "stranglethorn", name = "Northern Stranglethorn", levelMin = 25, levelMax = 35, faction = "Neutral", hubs = { "Rebel Camp", "Grom'gol" }, lore = "Jungle heat, troll empires, and hunter's pride.", lockAt = 35, eraTags = { "vanilla", "classic" }, peakStartADP = 20, peakEndADP = 30, minAgeSuggest = 16, maxAgeSuggest = 60, tone = "modern" },
    { id = "dun_morogh", name = "Dun Morogh", levelMin = 1, levelMax = 10, faction = "Alliance", hubs = { "Kharanos", "Coldridge" }, lore = "Dwarven snow, troggs, and the forge-light of Ironforge.", lockAt = 10, eraTags = { "second_war", "vanilla" }, peakStartADP = 5, peakEndADP = 30, minAgeSuggest = 10, maxAgeSuggest = 200, tone = "childhood_home" },
    { id = "loch_modan", name = "Loch Modan", levelMin = 10, levelMax = 20, faction = "Alliance", hubs = { "Thelsamar" }, lore = "Broken dam, mountain passes, and dwarven watchfulness.", lockAt = 20, eraTags = { "second_war", "vanilla" }, peakStartADP = 5, peakEndADP = 30, minAgeSuggest = 14, maxAgeSuggest = 200, tone = "war_front" },
    { id = "wetlands", name = "Wetlands", levelMin = 20, levelMax = 30, faction = "Alliance", hubs = { "Menethil Harbor" }, lore = "Fog, raptors, and the long road to the north.", lockAt = 30, eraTags = { "second_war", "vanilla" }, peakStartADP = 5, peakEndADP = 30, minAgeSuggest = 16, maxAgeSuggest = 80, tone = "war_front" },
    { id = "teldrassil", name = "Teldrassil", levelMin = 1, levelMax = 10, faction = "Alliance", hubs = { "Dolanaar", "Shadowglen" }, lore = "The world tree's shadow; balance, corruption, and night elven duty.", lockAt = 10, eraTags = { "long_vigil", "third_war", "vanilla", "elf" }, peakStartADP = -9900, peakEndADP = 30, minAgeSuggest = 0, maxAgeSuggest = 20000, tone = "ancient_home" },
    { id = "darkshore", name = "Darkshore", levelMin = 10, levelMax = 20, faction = "Alliance", hubs = { "Lor'danel", "Auberdine (memory)" }, lore = "Ruined coasts, elementals, and grief that still walks the shore.", lockAt = 20, eraTags = { "long_vigil", "cata", "vanilla", "elf" }, peakStartADP = -5000, peakEndADP = 35, minAgeSuggest = 0, maxAgeSuggest = 20000, tone = "aftermath" },
    { id = "ashenvale", name = "Ashenvale", levelMin = 15, levelMax = 30, faction = "Neutral", hubs = { "Astranaar", "Splintertree" }, lore = "Forest war — elves and orcs writing the same map in blood.", lockAt = 30, eraTags = { "long_vigil", "third_war", "vanilla", "elf" }, peakStartADP = -2000, peakEndADP = 35, minAgeSuggest = 0, maxAgeSuggest = 20000, tone = "war_front" },
    { id = "durotar", name = "Durotar", levelMin = 1, levelMax = 10, faction = "Horde", hubs = { "Razor Hill", "Valley of Trials" }, lore = "Orcish hard land; honor learned under a hard sun.", lockAt = 10, eraTags = { "third_war", "vanilla" }, peakStartADP = 20, peakEndADP = 30, minAgeSuggest = 10, maxAgeSuggest = 80, tone = "childhood_home" },
    { id = "barrens", name = "Northern Barrens", levelMin = 10, levelMax = 20, faction = "Horde", hubs = { "The Crossroads" }, lore = "Crossroads of the Horde; quilboar, centaur, and wide sky.", lockAt = 20, eraTags = { "third_war", "vanilla" }, peakStartADP = 20, peakEndADP = 30, minAgeSuggest = 14, maxAgeSuggest = 80, tone = "modern" },
    { id = "mulgore", name = "Mulgore", levelMin = 1, levelMax = 10, faction = "Horde", hubs = { "Bloodhoof Village", "Red Cloud Mesa" }, lore = "Tauren plains, ancestors, and the quiet strength of the Earth Mother.", lockAt = 10, eraTags = { "third_war", "vanilla" }, peakStartADP = 20, peakEndADP = 30, minAgeSuggest = 10, maxAgeSuggest = 120, tone = "childhood_home" },
    { id = "stonetalon", name = "Stonetalon Mountains", levelMin = 20, levelMax = 30, faction = "Neutral", hubs = { "Sun Rock Retreat", "Windshear Hold" }, lore = "Venture Company scars and mountain paths between factions.", lockAt = 30, eraTags = { "vanilla", "classic" }, peakStartADP = 25, peakEndADP = 32, minAgeSuggest = 16, maxAgeSuggest = 80, tone = "modern" },
    { id = "tirisfal", name = "Tirisfal Glades", levelMin = 1, levelMax = 10, faction = "Horde", hubs = { "Brill", "Deathknell" }, lore = "Forsaken rebirth; plague, identity, and the shadow of Lordaeron.", lockAt = 10, eraTags = { "third_war", "vanilla", "scourge" }, peakStartADP = 20, peakEndADP = 30, minAgeSuggest = 0, maxAgeSuggest = 200, tone = "aftermath" },
    { id = "silverpine", name = "Silverpine Forest", levelMin = 10, levelMax = 20, faction = "Horde", hubs = { "The Sepulcher" }, lore = "Worgen borders, gilnean ghosts, and forsaken strategy.", lockAt = 20, eraTags = { "third_war", "cata", "vanilla" }, peakStartADP = 20, peakEndADP = 35, minAgeSuggest = 14, maxAgeSuggest = 200, tone = "war_front" },
    { id = "hillsbrad", name = "Hillsbrad Foothills", levelMin = 15, levelMax = 30, faction = "Neutral", hubs = { "Tarren Mill", "Southshore (memory)" }, lore = "Old Alliance-Horde bitterness still echoes in the hills.", lockAt = 30, eraTags = { "second_war", "vanilla" }, peakStartADP = 5, peakEndADP = 30, minAgeSuggest = 16, maxAgeSuggest = 80, tone = "war_front" },
    { id = "ghostlands", name = "Ghostlands", levelMin = 10, levelMax = 20, faction = "Horde", hubs = { "Tranquillien" }, lore = "Blood elven scars; Scourge and the long walk toward Silvermoon.", lockAt = 20, eraTags = { "third_war", "bc", "elf" }, peakStartADP = 20, peakEndADP = 28, minAgeSuggest = 0, maxAgeSuggest = 10000, tone = "aftermath" },
    { id = "azuremyst", name = "Azuremyst Isle", levelMin = 1, levelMax = 10, faction = "Alliance", hubs = { "Azure Watch", "Ammen Vale" }, lore = "Draenei landing; crystal light and the crash that became a home.", lockAt = 10, eraTags = { "bc" }, peakStartADP = 26, peakEndADP = 28, minAgeSuggest = 0, maxAgeSuggest = 25000, tone = "modern" },
    { id = "bloodmyst", name = "Bloodmyst Isle", levelMin = 10, levelMax = 20, faction = "Alliance", hubs = { "Blood Watch" }, lore = "Red mist, satyr, and the cost of crash-site survival.", lockAt = 20, eraTags = { "bc" }, peakStartADP = 26, peakEndADP = 28, minAgeSuggest = 0, maxAgeSuggest = 25000, tone = "modern" },
    { id = "eversong", name = "Eversong Woods", levelMin = 1, levelMax = 10, faction = "Horde", hubs = { "Falconwing Square", "Fairbreeze" }, lore = "Golden woods of Quel'Thalas; beauty edged with loss.", lockAt = 10, eraTags = { "highborne_exile", "third_war", "bc", "elf" }, peakStartADP = -6800, peakEndADP = 28, minAgeSuggest = 0, maxAgeSuggest = 10000, tone = "ancient_home" },
    -- Ancient-relevant stubs
    { id = "hyjal", name = "Mount Hyjal", levelMin = 80, levelMax = 90, faction = "Neutral", hubs = { "Nordrassil" }, lore = "World tree and the Long Vigil's heart; Legion scars and Cenarius's memory.", lockAt = 90, eraTags = { "war_of_ancients", "sundering", "long_vigil", "cata", "elf" }, peakStartADP = -10000, peakEndADP = 35, minAgeSuggest = 0, maxAgeSuggest = 30000, tone = "primordial" },
    { id = "azshara_zone", name = "Azshara", levelMin = 10, levelMax = 60, faction = "Neutral", hubs = { "Bilgewater Harbor", "Ruins" }, lore = "Highborne ruin and naga memory; pride shattered by the Sundering.", lockAt = 60, eraTags = { "war_of_ancients", "sundering", "elf", "cata" }, peakStartADP = -10000, peakEndADP = 35, minAgeSuggest = 0, maxAgeSuggest = 30000, tone = "ancient_war" },
    { id = "forbidden_reach", name = "Forbidden Reach", levelMin = 58, levelMax = 70, faction = "Neutral", hubs = { "Morqut" }, lore = "Dracthyr stasis broken; Neltharion's laboratory of scale and will.", lockAt = 70, eraTags = { "scaleborn", "df", "dracthyr", "dragon" }, peakStartADP = -25000, peakEndADP = 42, minAgeSuggest = 0, maxAgeSuggest = 50000, tone = "primordial" },
    { id = "uldaman", name = "Uldaman", levelMin = 40, levelMax = 50, faction = "Neutral", hubs = { "Dig site" }, lore = "Titan vaults and earthen memory beneath the earth.", lockAt = 50, eraTags = { "ordering", "vanilla", "earthen", "titan" }, peakStartADP = -200000, peakEndADP = 45, minAgeSuggest = 0, maxAgeSuggest = 999999, tone = "primordial" },
}

Blackacre.RoadmapPresets = {
    {
        id = "alliance_ek_classic",
        name = "Alliance — Eastern Kingdoms hearth road",
        faction = "Alliance",
        blurb = "From Northshire dust to jungle canopy — a classic human-dwarf pacing path.",
        steps = { "elwynn", "westfall", "redridge", "duskwood", "stranglethorn" },
    },
    {
        id = "alliance_kalimdor",
        name = "Alliance — Kalimdor night road",
        faction = "Alliance",
        blurb = "Teldrassil's shadow into Darkshore grief and Ashenvale war.",
        steps = { "teldrassil", "darkshore", "ashenvale" },
    },
    {
        id = "alliance_dwarf",
        name = "Alliance — Khaz Modan road",
        faction = "Alliance",
        blurb = "Snow to loch to fog — the dwarven approach to the wider world.",
        steps = { "dun_morogh", "loch_modan", "wetlands" },
    },
    {
        id = "alliance_draenei",
        name = "Alliance — Azuremyst landing",
        faction = "Alliance",
        blurb = "Crash, crystal, and the red isle beyond.",
        steps = { "azuremyst", "bloodmyst" },
    },
    {
        id = "horde_durotar",
        name = "Horde — Durotar & Barrens",
        faction = "Horde",
        blurb = "Trials, razor hills, and the Crossroads heartbeat of Kalimdor.",
        steps = { "durotar", "barrens", "stonetalon" },
    },
    {
        id = "horde_mulgore",
        name = "Horde — Mulgore plains road",
        faction = "Horde",
        blurb = "From mesa to Barrens under an open sky.",
        steps = { "mulgore", "barrens", "stonetalon" },
    },
    {
        id = "horde_forsaken",
        name = "Horde — Lordaeron shadow road",
        faction = "Horde",
        blurb = "Deathknell to Silverpine to the contested foothills.",
        steps = { "tirisfal", "silverpine", "hillsbrad" },
    },
    {
        id = "horde_blood_elf",
        name = "Horde — Quel'Thalas road",
        faction = "Horde",
        blurb = "Eversong gold into Ghostlands grey.",
        steps = { "eversong", "ghostlands" },
    },
    {
        id = "ancient_kalimdor",
        name = "Ancient — Kalimdor memory road",
        faction = "Neutral",
        blurb = "For those who remember the Vigil: Hyjal, Azshara's ruin, Ashenvale's green war.",
        steps = { "hyjal", "azshara_zone", "ashenvale", "teldrassil" },
    },
    {
        id = "dracthyr_wake",
        name = "Dracthyr — Wake of the Reach",
        faction = "Neutral",
        blurb = "From Forbidden Reach stasis into a world remade.",
        steps = { "forbidden_reach" },
    },
    {
        id = "earthen_vaults",
        name = "Earthen — Vaults and deep stone",
        faction = "Neutral",
        blurb = "Uldaman's ordered dark and the long memory of keepers.",
        steps = { "uldaman" },
    },
}

function Blackacre.GetRoadmapZone(zoneId)
    for _, z in ipairs(Blackacre.RoadmapZoneCatalog) do
        if z.id == zoneId then return z end
    end
    return nil
end

function Blackacre.GetRoadmapPreset(presetId)
    for _, p in ipairs(Blackacre.RoadmapPresets) do
        if p.id == presetId then return p end
    end
    return nil
end

function Blackacre.BuildRoadmapSteps(zoneIdList)
    local steps = {}
    for i, zid in ipairs(zoneIdList or {}) do
        local z = Blackacre.GetRoadmapZone(zid)
        if z then
            steps[#steps + 1] = {
                zoneId = z.id,
                name = z.name,
                levelMin = z.levelMin,
                levelMax = z.levelMax,
                hubs = z.hubs,
                lore = z.lore,
                lockAt = z.lockAt,
                index = i,
                status = "pending",
                eraTags = z.eraTags,
                peakStartADP = z.peakStartADP,
                peakEndADP = z.peakEndADP,
            }
        end
    end
    return steps
end
