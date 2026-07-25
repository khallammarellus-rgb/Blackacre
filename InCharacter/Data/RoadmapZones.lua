InCharacter = InCharacter or {}

-- Seed expedition chart data. Levels are approximate retail scaling bands for RP pacing.
-- lockAt = suggested level to pause XP before leaving the chapter (player controls real XP lock).

InCharacter.RoadmapZoneCatalog = {
    { id = "elwynn", name = "Elwynn Forest", levelMin = 1, levelMax = 10, faction = "Alliance", hubs = { "Goldshire", "Northshire" }, lore = "Human hearthlands; kobolds, gnolls, and the shadow of Stormwind's peace.", lockAt = 10 },
    { id = "westfall", name = "Westfall", levelMin = 10, levelMax = 20, faction = "Alliance", hubs = { "Sentinel Hill" }, lore = "Dusty farms, Defias whispers, and people pushed to the edge.", lockAt = 20 },
    { id = "redridge", name = "Redridge Mountains", levelMin = 15, levelMax = 25, faction = "Alliance", hubs = { "Lakeshire" }, lore = "Orcish pressure on a lakeside town that will not break.", lockAt = 25 },
    { id = "duskwood", name = "Duskwood", levelMin = 20, levelMax = 30, faction = "Alliance", hubs = { "Darkshire" }, lore = "Night, worgen, and the thin line between living and dead.", lockAt = 30 },
    { id = "stranglethorn", name = "Northern Stranglethorn", levelMin = 25, levelMax = 35, faction = "Neutral", hubs = { "Rebel Camp", "Grom'gol" }, lore = "Jungle heat, troll empires, and hunter's pride.", lockAt = 35 },
    { id = "dun_morogh", name = "Dun Morogh", levelMin = 1, levelMax = 10, faction = "Alliance", hubs = { "Kharanos", "Coldridge" }, lore = "Dwarven snow, troggs, and the forge-light of Ironforge.", lockAt = 10 },
    { id = "loch_modan", name = "Loch Modan", levelMin = 10, levelMax = 20, faction = "Alliance", hubs = { "Thelsamar" }, lore = "Broken dam, mountain passes, and dwarven watchfulness.", lockAt = 20 },
    { id = "wetlands", name = "Wetlands", levelMin = 20, levelMax = 30, faction = "Alliance", hubs = { "Menethil Harbor" }, lore = "Fog, raptors, and the long road to the north.", lockAt = 30 },
    { id = "teldrassil", name = "Teldrassil", levelMin = 1, levelMax = 10, faction = "Alliance", hubs = { "Dolanaar", "Shadowglen" }, lore = "The world tree's shadow; balance, corruption, and night elven duty.", lockAt = 10 },
    { id = "darkshore", name = "Darkshore", levelMin = 10, levelMax = 20, faction = "Alliance", hubs = { "Lor'danel", "Auberdine (memory)" }, lore = "Ruined coasts, elementals, and grief that still walks the shore.", lockAt = 20 },
    { id = "ashenvale", name = "Ashenvale", levelMin = 15, levelMax = 30, faction = "Neutral", hubs = { "Astranaar", "Splintertree" }, lore = "Forest war — elves and orcs writing the same map in blood.", lockAt = 30 },
    { id = "durotar", name = "Durotar", levelMin = 1, levelMax = 10, faction = "Horde", hubs = { "Razor Hill", "Valley of Trials" }, lore = "Orcish hard land; honor learned under a hard sun.", lockAt = 10 },
    { id = "barrens", name = "Northern Barrens", levelMin = 10, levelMax = 20, faction = "Horde", hubs = { "The Crossroads" }, lore = "Crossroads of the Horde; quilboar, centaur, and wide sky.", lockAt = 20 },
    { id = "mulgore", name = "Mulgore", levelMin = 1, levelMax = 10, faction = "Horde", hubs = { "Bloodhoof Village", "Red Cloud Mesa" }, lore = "Tauren plains, ancestors, and the quiet strength of the Earth Mother.", lockAt = 10 },
    { id = "stonetalon", name = "Stonetalon Mountains", levelMin = 20, levelMax = 30, faction = "Neutral", hubs = { "Sun Rock Retreat", "Windshear Hold" }, lore = "Venture Company scars and mountain paths between factions.", lockAt = 30 },
    { id = "tirisfal", name = "Tirisfal Glades", levelMin = 1, levelMax = 10, faction = "Horde", hubs = { "Brill", "Deathknell" }, lore = "Forsaken rebirth; plague, identity, and the shadow of Lordaeron.", lockAt = 10 },
    { id = "silverpine", name = "Silverpine Forest", levelMin = 10, levelMax = 20, faction = "Horde", hubs = { "The Sepulcher" }, lore = "Worgen borders, gilnean ghosts, and forsaken strategy.", lockAt = 20 },
    { id = "hillsbrad", name = "Hillsbrad Foothills", levelMin = 15, levelMax = 30, faction = "Neutral", hubs = { "Tarren Mill", "Southshore (memory)" }, lore = "Old Alliance-Horde bitterness still echoes in the hills.", lockAt = 30 },
    { id = "ghostlands", name = "Ghostlands", levelMin = 10, levelMax = 20, faction = "Horde", hubs = { "Tranquillien" }, lore = "Blood elven scars; Scourge and the long walk toward Silvermoon.", lockAt = 20 },
    { id = "azuremyst", name = "Azuremyst Isle", levelMin = 1, levelMax = 10, faction = "Alliance", hubs = { "Azure Watch", "Ammen Vale" }, lore = "Draenei landing; crystal light and the crash that became a home.", lockAt = 10 },
    { id = "bloodmyst", name = "Bloodmyst Isle", levelMin = 10, levelMax = 20, faction = "Alliance", hubs = { "Blood Watch" }, lore = "Red mist, satyr, and the cost of crash-site survival.", lockAt = 20 },
    { id = "eversong", name = "Eversong Woods", levelMin = 1, levelMax = 10, faction = "Horde", hubs = { "Falconwing Square", "Fairbreeze" }, lore = "Golden woods of Quel'Thalas; beauty edged with loss.", lockAt = 10 },
}

InCharacter.RoadmapPresets = {
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
}

function InCharacter.GetRoadmapZone(zoneId)
    for _, z in ipairs(InCharacter.RoadmapZoneCatalog) do
        if z.id == zoneId then return z end
    end
    return nil
end

function InCharacter.GetRoadmapPreset(presetId)
    for _, p in ipairs(InCharacter.RoadmapPresets) do
        if p.id == presetId then return p end
    end
    return nil
end

function InCharacter.BuildRoadmapSteps(zoneIdList)
    local steps = {}
    for i, zid in ipairs(zoneIdList or {}) do
        local z = InCharacter.GetRoadmapZone(zid)
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
                status = "pending", -- pending | active | done | locked
            }
        end
    end
    return steps
end