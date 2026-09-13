-- Life Paths: Human
Blackacre.Paths.Register({
    id = "human_stratholme_survivor",
    name = "Survivor of Stratholme",
    blurb = "You walked out of the culling — ash, plague, and a name you still answer to.",
    era = "past",
    faction = "Alliance",
    races = { "Human" },
    tags = { "scourge", "third_war", "lordaeron", "stratholme" },
    birthplaceHints = { "Stratholme", "Lordaeron", "Lordamere" },
    eraTags = { "third_war" },
    zones = {
        { zoneId = "eastern_plaguelands", note = "Darrowshire and the road to the gates" },
        { zoneId = "western_plaguelands", note = "Andorhal grain; Hearthglen; Gahrron's Withering" },
        { zoneId = "tanaris", note = "Caverns of Time — the Culling, if you walk the timeway" },
    },
    -- Curated spine (wiki Culling + Stratholme + Darrowshire, then Wowhead IDs).
    -- Not every Plaguelands errand. Forces the survivor through grain, purge, ghosts, chapel.
    quests = {
        { questId = 27383, title = "Little Pamela", optional = false, zoneId = "eastern_plaguelands",
          why = "Darrowshire child who lived; neighboring town fell days after Stratholme." },
        { questId = 27387, title = "The Battle of Darrowshire", optional = false, zoneId = "eastern_plaguelands",
          why = "Rewrite the slaughter Chromie cannot undo in Stratholme; Joseph Redpath's redemption." },
        { questId = 13149, title = "Dispelling Illusions", optional = false, zoneId = "tanaris",
          why = "CoT: prove the grain was plagued so Arthas still culls. Survivor watches the hour they fled." },
        { questId = 13151, title = "A Royal Escort", optional = false, zoneId = "tanaris",
          why = "Escort Arthas to Mal'Ganis. The Path does not log this as a Tome page unless it is a finale." },
        { questId = 5282, title = "The Restless Souls", optional = true, zoneId = "eastern_plaguelands",
          why = "Egan's mother died in the Culling; ghosts in the burning city. Classic ID — verify live." },
    },
    tomeSeed = {
        title = "Ash on the cobbles",
        body = "Grain from Andorhal. Uther and Jaina turned from the gates. You did not stay to argue. Fire, then the sea road, or the woods, or a ship that never made it. Years later the city still burns. This Path is not to relive every death — it is to walk Darrowshire, the timeway, and the chapel until you can write the hour without lying.",
    },
    status = "drafting",
})

Blackacre.Paths.Register({
    id = "human_7th_legion_conscript",
    name = "Conscript of the 7th Legion",
    blurb = "Stormwind's mailed fist called; you answered with steel and a signed writ.",
    era = "contemporary",
    faction = "Alliance",
    races = { "Human" },
    tags = { "7th_legion", "military", "alliance" },
    birthplaceHints = { "Stormwind", "Elwynn", "Westfall" },
    eraTags = { "cata", "mists", "wod", "legion", "bfa", "shadowlands", "df", "tww" },
    zones = {},
    quests = {},
    tomeSeed = {
        title = "Writ of the Seventh",
        body = "The lion on the seal was fresh wax. The road ahead was not.",
    },
    status = "stub",
})
