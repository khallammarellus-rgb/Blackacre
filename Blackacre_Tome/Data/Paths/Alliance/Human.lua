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
    zones = {
        { zoneId = "dragonblight", note = "Wintergarde Keep; 7th Legion Front on the Path of the Titans" },
        { zoneId = "tiragarde", note = "Wind's Redemption — Halford's BfA war table" },
        { zoneId = "durotar", note = "Eve of Battle: 7th Legion Magus teleports you to Anduin at Razor Hill" },
    },
    quests = {
        { questId = 12235, title = "Naxxramas and the Fall of Wintergarde", optional = false, zoneId = "dragonblight",
          why = "Wyrmbane: Naxxramas over the keep, Thel'zan in the lower village. Conscript reports in." },
        { questId = 12466, title = "Chasing Icestorm: The 7th Legion Front", optional = false, zoneId = "dragonblight",
          why = "Report to Legion Commander Tyralion. The 7th is a home, not a rumor." },
        { questId = 12473, title = "An End And A Beginning", optional = false, zoneId = "dragonblight",
          why = "Thel'zan dies; Wyrmbane sends you to Fordragon. Wintergarde chain cap." },
        { questId = 52654, title = "The War Campaign", optional = false, zoneId = "tiragarde",
          why = "Alliance: report to Halford on the Wind's Redemption. (52746 is Horde — do not use.)" },
        { questId = 56494, title = "The Eve of Battle", optional = false, zoneId = "durotar",
          why = "Shaw briefs; magus teleports; Anduin at Razor Hill. Chain finale is Old Soldier (57002)." },
    },
    tomeSeed = {
        title = "Writ of the Seventh",
        body = "The wax was still warm. Wyrmbane's name sat under the lion. Wintergarde taught you what the writ meant: Naxxramas over the roofs, ghouls in the square, a Front on a road of dragon bones. Years later the same tabard is on a ship in Boralus. Shaw talks. A magus opens a door to Razor Hill. The 7th does not ask if you were born in Elwynn. It asks if you will stand.",
    },
    status = "drafting",
})
