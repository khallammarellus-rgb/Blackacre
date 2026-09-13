--[[
  Curated Path spines: wiki graph then Wowhead.
  ApplySpine runs after race files. questId 0 = title only; fill from Wowhead when verified.
  Method: race + place + event + citations, then live quests that FORCE the arc.
]]

Blackacre = Blackacre or {}

local function Q(id, title, zone, why, optional)
    return {
        questId = id or 0,
        title = title,
        zoneId = zone,
        why = why,
        optional = optional and true or false,
    }
end

local spines = {}

spines.human_7th_legion_conscript = {
    status = "drafting",
    wikiGraph = "7th Legion; Stormwind; Varian; High Command; Wintergarde / Dragonblight Front; "
        .. "Tol Barad; Twilight Highlands; BfA War Campaign (Alliance); Ready for War; "
        .. "The Eve of Battle; Razor Hill with Anduin; 7th Legion Magus. NOT Elwynn starter.",
    zones = {
        { zoneId = "dragonblight", note = "Wintergarde / 7th Legion Front vs Scourge" },
        { zoneId = "tiragarde", note = "Boralus mission table — Alliance war campaign" },
        { zoneId = "durotar", note = "Eve of Battle: Anduin at Razor Hill" },
    },
    quests = {
        Q(12466, "Chasing Icestorm: The 7th Legion Front", "dragonblight",
            "WotLK: report to Legion Commander Tyralion. First time the 7th is a home, not a rumor."),
        Q(12467, "Chasing Icestorm: Thel'zan's Phylactery", "dragonblight",
            "The Front's actual fight — phylactery, not a side camp."),
        Q(52746, "The War Campaign", "tiragarde",
            "BfA: Shaw and the 7th on the Wind's Redemption. Verify ID live."),
        Q(0, "The Eve of Battle", "durotar",
            "8.2.5 finale: Shaw brief, teleport, Anduin at Razor Hill. Fill Wowhead ID."),
    },
}

spines.dwarf_grim_batol_evacuee = {
    status = "drafting",
    wikiGraph = "Grim Batol; War of the Three Hammers; Modgud; Wildhammer; Red Dragonflight; "
        .. "Nekros Skullcrusher; Alexstrasza enslaved; Battle of Grim Batol; Twilight Highlands; "
        .. "Deathwing; Twilight's Hammer occupying Grim Batol; Cho'gall.",
    zones = {
        { zoneId = "wetlands", note = "Road from the mountain" },
        { zoneId = "twilight_highlands", note = "Grim Batol still stands; Twilight cult" },
    },
    quests = {
        Q(27590, "The Crucible of Carnage: The Twilight Terror!", "twilight_highlands",
            "Highlands: the mountain's new masters. Verify ID."),
        Q(27719, "Hammer of Twilight", "twilight_highlands",
            "Cho'gall / Twilight's Hammer at the gates of Grim Batol."),
        Q(28885, "Mr. Goldmine's Wild Ride", "twilight_highlands",
            "Grim Batol dungeon intro (Cata). Walk the halls you fled."),
    },
}

spines.dwarf_explorers_league = {
    status = "drafting",
    wikiGraph = "Explorers' League; Brann Bronzebeard; Ironforge Hall of Explorers; Uldaman; "
        .. "Ulduar; Titan-forged; Harrison Jones; Khaz Algar later. A Future Task (Uldum tease).",
    zones = {
        { zoneId = "dun_morogh", note = "Hall of Explorers" },
        { zoneId = "badlands", note = "Uldaman discs" },
        { zoneId = "storm_peaks", note = "Brann / Ulduar" },
    },
    quests = {
        Q(2278, "The Platinum Discs", "badlands",
            "Uldaman: the League's titan question. Classic ID — verify live."),
        Q(2964, "A Future Task", "ironforge",
            "Magellas: Uldum beckons. The map that stayed blank for years."),
        Q(12997, "The Earthen of Ulduar", "storm_peaks",
            "Brann's road north. Fill if ID drifts."),
    },
}

spines.gnome_third_war_engineer = {
    status = "drafting",
    wikiGraph = "Gnomeregan; Sicco Thermaplugg; Mekkatorque; troggs; radiation; Invasion of Gnomeregan "
        .. "(between 2nd and 3rd War); Tinker Town exile; Operation: Gnomeregan; Cata gnome intro.",
    zones = {
        { zoneId = "dun_morogh", note = "New Tinkertown / Gnomeregan" },
    },
    quests = {
        Q(27635, "Decontamination", "dun_morogh",
            "Cata gnome: you walk the poison. Verify chain start if rolled elsewhere."),
        Q(27674, "To the Surface", "dun_morogh",
            "Out of the city that killed your kin."),
        Q(25393, "Operation: Gnomeregan", "dun_morogh",
            "Pre-Cata reclaim. Optional if the Cata intro already tells it."),
    },
}

spines.gnome_si7_saboteur = {
    status = "drafting",
    wikiGraph = "SI:7; Mathias Shaw; Stormwind; gnomish engineering; Kelsey Steelspark (BfA 7th); "
        .. "Crapopolis / mechagon overlap is another Path.",
    zones = {
        { zoneId = "stormwind", note = "SI:7 headquarters" },
        { zoneId = "tiragarde", note = "Kelsey with the 7th" },
    },
    quests = {
        Q(0, "Mathias Shaw — current Stormwind breadcrumb", "stormwind",
            "Fill live Shaw intro from Wowhead (IDs change by expansion)."),
        Q(0, "Kelsey Steelspark foothold (Zuldazar)", "zuldazar",
            "BfA: gnome SI:7 on the 7th Legion boat."),
    },
}

spines.nightelf_ancient_kaldorei_druid = {
    status = "drafting",
    wikiGraph = "Night elf; Cenarius; Malfurion; Nordrassil; War of the Ancients; Sundering; "
        .. "druids of the wild; Moonglade; Emerald Dream; Teldrassil planted 23 ADP.",
    zones = {
        { zoneId = "moonglade", note = "Circle" },
        { zoneId = "mount_hyjal", note = "Nordrassil / Ancients" },
    },
    quests = {
        Q(25316, "As Hyjal Burns", "mount_hyjal",
            "Cata Hyjal: the World Tree you remember is on fire again."),
        Q(25317, "Protect the World Tree", "mount_hyjal",
            "Cenarius's charge in the present."),
        Q(25578, "Return to Nordrassil", "mount_hyjal",
            "Cap of the early Hyjal defense. Verify ID."),
    },
}

spines.nightelf_amirdrassil_rallied = {
    status = "drafting",
    wikiGraph = "Amirdrassil; Guardians of the Dream; Fyrakk; Bel'ameth; Teldrassil burned (BfA); "
        .. "Tyrande's hunt; Night elf heritage Honor of the Goddess is a DIFFERENT Path beat.",
    zones = {
        { zoneId = "emerald_dream", note = "Guardians of the Dream campaign" },
        { zoneId = "amirdrassil", note = "New home" },
    },
    quests = {
        Q(76317, "Call of the Dream", "emerald_dream",
            "10.2 campaign start. Verify live ID."),
        Q(78643, "The Bloom of Life / Amirdrassil raid attune", "amirdrassil",
            "Fill finale title from Wowhead (Fyrakk campaign last quest)."),
    },
}

spines.draenei_roaming_herald_draenor = {
    status = "drafting",
    wikiGraph = "Draenei; Velen; Exodar; Genedar crash; Azuremyst; Bloodmyst; TBC starting zone; "
        .. "Argus memory; Heritage of the Draenei (Telhamat / Embaari) is a recap Path, not this one.",
    zones = {
        { zoneId = "azuremyst", note = "Crash and first sermons" },
        { zoneId = "hellfire", note = "Honor Hold / Dark Portal — the world you fled to" },
    },
    quests = {
        Q(9280, "Replenishing the Healing Crystals", "azuremyst",
            "Exodar crash: you are still a herald, not a Stormwind soldier."),
        Q(9314, "Word from the Crash", "azuremyst",
            "The crashed ship is the congregation."),
        Q(10254, "Force Commander Danath", "hellfire",
            "TBC: Alliance Expedition. The Herald walks Outland."),
    },
}

spines.draenei_revenant_eredar_redeemed = {
    status = "drafting",
    wikiGraph = "Eredar; Argus; Kil'jaeden; Archimonde; Velen's schism; Krokuun; Antoran Wastes; "
        .. "Lightforged vs those who stayed; Xe'ra. Distinct from Lightforged Path.",
    zones = {
        { zoneId = "krokuun", note = "Argus: the home that fell" },
    },
    quests = {
        Q(47203, "Light's Charge", "krokuun",
            "Argus intro. Verify current breadcrumb."),
        Q(47431, "Annihilan Assault / Antorus attune", "antoran_wastes",
            "Fill last Argus campaign quest from Wowhead."),
    },
}

spines.lightforged_argus_legion = {
    status = "drafting",
    wikiGraph = "Lightforged draenei; Army of the Light; Xe'ra; Vindicaar; Argus; Turalyon; Alleria; "
        .. "Heritage of the Lightforged (short allied hand-in) vs this Path (the war).",
    zones = {
        { zoneId = "krokuun", note = "Army of the Light" },
        { zoneId = "vindicaar", note = "The ship is the city" },
    },
    quests = {
        Q(47221, "The Hand of Fate", "stormwind",
            "Alliance Argus call. Verify."),
        Q(48107, "The Sigil of Awakening", "krokuun",
            "Army of the Light campaign beat."),
    },
}

spines.lightforged_silver_hand = {
    status = "drafting",
    wikiGraph = "Knights of the Silver Hand; Alonsus Faol; Turalyon; Lightforged paladin overlap; "
        .. "Legion class hall Sanctum of Light; not Stratholme founding (that's Human/Silver Hand memory).",
    zones = {
        { zoneId = "eastern_plaguelands", note = "Light's Hope / Sanctum" },
    },
    quests = {
        Q(38710, "An Urgent Gathering", "eastern_plaguelands",
            "Legion paladin hall. Optional if not paladin — Path still names the order."),
        Q(39696, "The Silver Hand", "eastern_plaguelands",
            "Fill current class-hall finale if paladin; else skip."),
    },
}

spines.voidelf_fall_before_void = {
    status = "drafting",
    wikiGraph = "Void elf; Alleria; Locus-Walker; Telogrus; Umbric; void corruption; "
        .. "Midnight Rage of the Ren'dorei (Trial of Wrath) is a LATER beat on this spine.",
    zones = {
        { zoneId = "telogrus", note = "The rift you chose" },
        { zoneId = "voidstorm", note = "Midnight: the void presses back" },
    },
    quests = {
        Q(49756, "For the Greater Good", "telogrus",
            "Allied race intro. Verify ID."),
        Q(0, "Trial of Wrath", "voidstorm",
            "Midnight Ren'dorei chapter finale — HeritageCapstones."),
    },
}

spines.voidelf_twilight_escape = {
    status = "drafting",
    wikiGraph = "Twilight's Hammer; Cho'gall; Old Gods; void-adjacent cult vs Ren'dorei scholarship. "
        .. "This Path is the almost-cultist who ran to Alleria instead of the Hammer.",
    zones = {
        { zoneId = "twilight_highlands", note = "Cult you left" },
        { zoneId = "telogrus", note = "Where you ran" },
    },
    quests = {
        Q(25674, "Futile Pride", "twilight_highlands",
            "Cata Twilight Highlands: Hammer's voice. Verify chain."),
        Q(27380, "Nightmare / Iso'rath", "twilight_highlands",
            "Old God breath. Then you leave this road for Telogrus."),
    },
}

spines.worgen_alpha_prime_abduction = {
    status = "drafting",
    wikiGraph = "Alpha Prime; Wolf Cult; Gilneas; Scythe of Elune; Arugal; Velinde Starsong; "
        .. "Curse origin; Genn; Northgate Rebellion is the OTHER worgen Path.",
    zones = {
        { zoneId = "gilneas", note = "The night the cult took you" },
        { zoneId = "duskwood", note = "Velinde / Roland's Doom — Scythe memory" },
    },
    quests = {
        Q(14078, "Lockdown!", "gilneas",
            "Worgen intro: the city closes. Verify Cata ID still live."),
        Q(14154, "By the Skin of His Teeth", "gilneas",
            "Alpha Prime's hunt in the streets."),
        Q(26760, "Cry For the Moon", "duskwood",
            "Scythe of Elune breadcrumb — the curse's older name."),
    },
}

spines.worgen_aid_alliance = {
    status = "drafting",
    wikiGraph = "Gilneas rejoins Alliance; Tess; Genn; Stormwind; Battle for Lordaeron; "
        .. "Heritage of Gilneas is a recap, not this Path.",
    zones = {
        { zoneId = "gilneas", note = "Evacuation" },
        { zoneId = "stormwind", note = "The lion's roof" },
    },
    quests = {
        Q(14467, "Alas, Gilneas!", "gilneas",
            "You leave the wall. Verify ID."),
        Q(14402, "Escape to Stormwind / The Battle for Gilneas aftermath", "stormwind",
            "Fill current hand-in to Stormwind from Wowhead."),
    },
}

spines.darkiron_defector_mogdud = {
    status = "drafting",
    wikiGraph = "Dark Iron; Modgud; Thaurissan; War of Three Hammers; Shadowforge; Ragnaros; "
        .. "Moira; Alliance allied race. Heritage of the Dark Iron = recap.",
    zones = {
        { zoneId = "searing_gorge", note = "Blackrock / Shadowforge road" },
        { zoneId = "blackrock_depths", note = "The city you defected from" },
    },
    quests = {
        Q(4341, "Kharan Mighthammer", "searing_gorge",
            "Classic BRD political chain. Verify live."),
        Q(4001, "What Is Going On?", "blackrock_depths",
            "Princess Moira — the defection's reason."),
        Q(0, "The Anvil-Thane's Designs", "shadowforge",
            "Later Dark Iron heritage extra chain. Fill ID."),
    },
}

spines.darkiron_firelands_attunement = {
    status = "drafting",
    wikiGraph = "Firelands; Ragnaros; Sulfuron; Hyjal Cata; Molten Front; Dark Iron fire bargains.",
    zones = {
        { zoneId = "mount_hyjal", note = "Portal to Firelands" },
        { zoneId = "firelands", note = "The old god of the clan" },
    },
    quests = {
        Q(29201, "Through the Gates of Hell", "mount_hyjal",
            "Molten Front / Firelands attune."),
        Q(29214, "The Shadow Wardens", "mount_hyjal",
            "Fill Molten Front cap from Wowhead."),
    },
}

spines.earthen_curse_of_flesh_limbo = {
    status = "drafting",
    wikiGraph = "Earthen; titan-forged; Curse of Flesh; Uldaman; Ulduar; Khaz Algar; "
        .. "Heritage of Khaz Algar; Machine Speakers vs Oathsworn.",
    zones = {
        { zoneId = "isle_of_dorn", note = "Awake and unfinished" },
    },
    quests = {
        Q(0, "The War Within earthen intro", "isle_of_dorn",
            "Fill TWW earthen starter finale from Wowhead."),
        Q(0, "Heritage of Khaz Algar", "isle_of_dorn",
            "Allied/heritage hand-in when added to live."),
    },
}

spines.earthen_nerubian_containment = {
    status = "drafting",
    wikiGraph = "Nerubian; Azj-Kahet; Queen Ansurek; Black Blood; Earthen as titan jailers of the deep.",
    zones = {
        { zoneId = "azj_kahet", note = "The containment failed" },
    },
    quests = {
        Q(0, "Azj-Kahet campaign finale", "azj_kahet",
            "TWW zone campaign last quest — C_QuestLine will catch it; list title from Wowhead."),
    },
}

spines.pandaren_shado_pan_origins = {
    status = "drafting",
    wikiGraph = "Shado-Pan; Taran Zhu; Townlong; Sha; Mantid; Pandaren Revolution (ancient) vs this Path (the order).",
    zones = {
        { zoneId = "townlong", note = "Shado-Pan Monastery / Garrison" },
        { zoneId = "kun_lai", note = "Shado-Pan Monastery dungeon" },
    },
    quests = {
        Q(30769, "First Assault", "townlong",
            "Townlong Shado-Pan chain. Verify."),
        Q(30935, "Fisherman's Tale / Taran Zhu", "townlong",
            "Fill Townlong capstone from Wowhead."),
    },
}

spines.pandaren_traveling_chef = {
    status = "drafting",
    wikiGraph = "Pandaren cooking; Valley of the Four Winds; Nomsy; Sungshin Ironpaw; "
        .. "Heritage A New Tradition is a DIFFERENT Path (racial identity).",
    zones = {
        { zoneId = "valley_four_winds", note = "Halfhill kitchens" },
    },
    quests = {
        Q(31281, "So You Want to Be a Chef...", "valley_four_winds",
            "Ironpaw: the road is a recipe."),
        Q(31536, "Preserving Freshness", "valley_four_winds",
            "Fill cooking-train cap if IDs moved."),
    },
}

spines.dracthyr_nefarion_drakonid = {
    status = "drafting",
    wikiGraph = "Nefarian; Black dragonflight; drakonid; Forbidden Reach; Sarkareth; "
        .. "Aberrus; no heritage set yet.",
    zones = {
        { zoneId = "forbidden_reach", note = "Waking" },
        { zoneId = "zaralek", note = "Black flight's sin" },
    },
    quests = {
        Q(64864, "Awaken, Dracthyr", "forbidden_reach",
            "Evoker intro. Verify."),
        Q(72965, "The Legacy of Neltharion / Sarkareth", "zaralek",
            "Fill Aberrus campaign last quest."),
    },
}

spines.dracthyr_blue_dragonflight_charge = {
    status = "drafting",
    wikiGraph = "Blue dragonflight; Malygos; Kalecgos; Azure Span; Sindragosa; Charge of the Dragonflights.",
    zones = {
        { zoneId = "azure_span", note = "Kalec's charge" },
    },
    quests = {
        Q(65890, "The Azure Span", "azure_span",
            "DF campaign: blue flight."),
        Q(66422, "Vault of the Incarnates attune / Kalec", "azure_span",
            "Fill Azure Span finale from Wowhead."),
    },
}

spines.orc_blackhand_veteran = {
    status = "drafting",
    wikiGraph = "Blackhand; Old Horde; First War; Blackrock Spire; Orgrim; Rend; "
        .. "Heritage Aka'magosh is a LATER recap (Kosh'harg), not the veteran years.",
    zones = {
        { zoneId = "burning_steppes", note = "Blackrock" },
        { zoneId = "hellfire", note = "The Portal you came through" },
    },
    quests = {
        Q(4903, "Warlord's Command", "burning_steppes",
            "Classic Blackrock: Rend's Horde. Verify live."),
        Q(0, "Aka'magosh", "durotar",
            "Heritage of Draenor finale — recap, optional last beat."),
    },
}

spines.orc_new_horde_roots = {
    status = "drafting",
    wikiGraph = "Thrall; Durotar; Orgrimmar; internment camps; Warsong; Echo Isles later is troll Path.",
    zones = {
        { zoneId = "durotar", note = "Red earth" },
        { zoneId = "orgrimmar", note = "The city you built" },
    },
    quests = {
        Q(25152, "Your Place In The World", "durotar",
            "Cata orc start. Verify."),
        Q(25187, "Lost in the Floods", "durotar",
            "Sen'jin / Echo Isles neighbor — keep light; Darkspear has its own Path."),
        Q(0, "The Kosh'harg", "durotar",
            "Heritage middle; roots, not Blackhand's war."),
    },
}

spines.undead_kelthuzad_risen = {
    status = "drafting",
    wikiGraph = "Kel'Thuzad; Cult of the Damned; Scholomance; Naxxramas; Stratholme as Scourge capital; "
        .. "NOT Forsaken heritage (I Am Forsaken) — that is the other undead Path.",
    zones = {
        { zoneId = "western_plaguelands", note = "Scholomance / Andorhal" },
        { zoneId = "dragonblight", note = "Naxxramas after it flew" },
    },
    quests = {
        Q(838, "Scholomance", "western_plaguelands",
            "Classic key. Verify Cata+ replacement."),
        Q(13315, "Sneak Preview", "dragonblight",
            "Naxxramas Wrath: the necropolis you served or fled."),
    },
}

spines.undead_fourth_war_plaguespreader = {
    status = "drafting",
    wikiGraph = "Fourth War; Blight; Underhold; Sylvanas; Lordaeron siege; Heritage of Lordaeron recap "
        .. "is I Am Forsaken — this Path is the blight you chose to spread.",
    zones = {
        { zoneId = "tirisfal", note = "Siege of Lordaeron" },
        { zoneId = "darkshore", note = "Blight in the west" },
    },
    quests = {
        Q(51796, "The Battle for Lordaeron", "tirisfal",
            "BfA intro. You are the plague's hand or its witness."),
        Q(0, "I Am Forsaken", "tirisfal",
            "Heritage capstone — optional last page, not the blight itself."),
    },
}

spines.tauren_fleeing_desolace = {
    status = "drafting",
    wikiGraph = "Desolace; centaur; Kolkar; Magatha; Cairne; Mulgore migration; Theradras.",
    zones = {
        { zoneId = "desolace", note = "The land that broke the tribes" },
        { zoneId = "mulgore", note = "Where you ran" },
    },
    quests = {
        Q(1432, "The Kolkar of Desolace", "desolace",
            "Classic centaur. Verify live."),
        Q(26184, "Centaur Bounty", "desolace",
            "Cata Desolace: the old war still on the map."),
    },
}

spines.tauren_sunwalker = {
    status = "drafting",
    wikiGraph = "Sunwalker; An'she; Aponi Brightmane; tauren paladin; not Shu'halo heritage recap.",
    zones = {
        { zoneId = "mulgore", note = "An'she" },
        { zoneId = "thunder_bluff", note = "The walkers" },
    },
    quests = {
        Q(30969, "A New Order", "mulgore",
            "Tauren paladin intro if paladin; else skip class quest."),
        Q(0, "Heritage of the Shu'halo finale", "mulgore",
            "Optional racial recap. Fill ID."),
    },
}

spines.troll_orgrim_horde = {
    status = "drafting",
    wikiGraph = "Orgrim Doomhammer; Darkspear join Thrall; Battle of Mount Hyjal; Sen'jin; Vol'jin.",
    zones = {
        { zoneId = "durotar", note = "The beach you chose" },
        { zoneId = "echo_isles", note = "Home retaken" },
    },
    quests = {
        Q(24622, "A Troll's Truest Companion", "echo_isles",
            "Cata troll start / Echo Isles reclaim."),
        Q(24814, "An Ancient Enemy", "echo_isles",
            "Zalazane — the island before Orgrimmar."),
    },
}

spines.troll_darkspear_courier = {
    status = "drafting",
    wikiGraph = "Vol'jin; Echo Isles; Orgrimmar embassy; courier between islands and the warchief.",
    zones = {
        { zoneId = "echo_isles", note = "Sen'jin" },
        { zoneId = "orgrimmar", note = "Messages to the hold" },
    },
    quests = {
        Q(26236, "Shredder Diplomacy / Vol'jin's command", "orgrimmar",
            "Fill Cata Vol'jin breadcrumb from Wowhead."),
        Q(26305, "Saving the Tiny Turtle / Echo Isles dailies", "echo_isles",
            "Prefer story beats over dailies — replace with Vol'jin's live chain."),
    },
}

spines.bloodelf_eldrethalas_highborne = {
    status = "drafting",
    wikiGraph = "Eldre'Thalas; Dire Maul; Shen'dralar; Prince Tortheldrin; Immol'thar; "
        .. "Highborne not yet blood elves — this Path is the spire that would not die.",
    zones = {
        { zoneId = "feralas", note = "Dire Maul" },
    },
    quests = {
        Q(27103, "Shards of Myzrael / Dire Maul tribute", "feralas",
            "Cata Dire Maul. Fill Shen'dralar chain IDs from Wowhead."),
        Q(27110, "The Madness Within", "feralas",
            "Tortheldrin. Verify."),
    },
}

spines.bloodelf_blood_knight = {
    status = "drafting",
    wikiGraph = "Blood Knight; Lady Liadrin; M'uru; Magisters' Terrace; Sunwell Plateau; "
        .. "The Fall of the Sunwell (heritage) is a recap of the Third War, not the order's founding.",
    zones = {
        { zoneId = "silvermoon", note = "Hall of Blood" },
        { zoneId = "isle_quel_danas", note = "M'uru / Sunwell" },
    },
    quests = {
        Q(9681, "A Study in Power", "silvermoon",
            "TBC Blood Knight. Paladin-only; Path still names the order."),
        Q(11488, "Magisters' Terrace", "isle_quel_danas",
            "Kael'thas. The stolen Light's end."),
        Q(54096, "The Fall of the Sunwell", "isle_quel_danas",
            "Heritage recap — optional last beat."),
    },
}

spines.goblin_cartel_bootlegger = {
    status = "drafting",
    wikiGraph = "Kezan; Trade Princes; Lost Isles; Gallywix; bootlegging; Heritage of Kezan recap later.",
    zones = {
        { zoneId = "kezan", note = "The deal" },
        { zoneId = "lost_isles", note = "The wreck" },
    },
    quests = {
        Q(14138, "Taking Care of Business", "kezan",
            "Goblin intro."),
        Q(14239, "Don't Go Into the Light!", "lost_isles",
            "The cartel after the mountain."),
    },
}

spines.goblin_gazlowe_loyalist = {
    status = "drafting",
    wikiGraph = "Gazlowe; Ratchet; Undermine; Gallywix vs Gazlowe; TWW Undermine campaign.",
    zones = {
        { zoneId = "the_barrens", note = "Ratchet" },
        { zoneId = "undermine", note = "The city under the deal" },
    },
    quests = {
        Q(14034, "Club Foote", "the_barrens",
            "Classic Ratchet Gazlowe. Verify."),
        Q(0, "Undermine campaign finale", "undermine",
            "TWW: Gazlowe's city. C_QuestLine last quest."),
    },
}

spines.highmountain_life = {
    status = "drafting",
    wikiGraph = "Highmountain tauren; Huln; Eagle / Moose / River / Skyhorn; Legion Highmountain zone; "
        .. "Heritage of Highmountain short hand-in.",
    zones = {
        { zoneId = "highmountain", note = "The four tribes" },
    },
    quests = {
        Q(38990, "The Rivermane / The Skyhorn", "highmountain",
            "Legion Highmountain campaign. Fill tribe-finale IDs."),
        Q(39780, "Huln's War — The Arrival", "highmountain",
            "Huln flashback. Verify."),
    },
}

spines.highmountain_ebyssian = {
    status = "drafting",
    wikiGraph = "Ebyssian; Wrathion; Highmountain; black dragonflight redeemed; DF Aspects.",
    zones = {
        { zoneId = "highmountain", note = "Ebonhorn" },
        { zoneId = "waking_shores", note = "The black flight's second chance" },
    },
    quests = {
        Q(40983, "An Urgent Warning (Ebonhorn)", "highmountain",
            "Legion: Ebonhorn unmasked. Verify."),
        Q(66128, "To Tyrhold! / Aspects", "thaldraszus",
            "DF: Ebyssian among Aspects. Fill."),
    },
}

spines.maghar_nerzhul_escape = {
    status = "drafting",
    wikiGraph = "Mag'har; AU Draenor; Grommash; Yrel's Lightbound; exodus to Azeroth; Heritage short.",
    zones = {
        { zoneId = "frostfire", note = "AU Draenor" },
        { zoneId = "orgrimmar", note = "Exile's gate" },
    },
    quests = {
        Q(51443, "Mission Statement", "orgrimmar",
            "Mag'har unlock scenario. Verify."),
        Q(0, "Heritage of the Mag'har", "orgrimmar",
            "Short allied hand-in."),
    },
}

spines.maghar_nagrand_resettle = {
    status = "drafting",
    wikiGraph = "Nagrand (AU); Warsong; Mag'har clans settling after Yrel.",
    zones = {
        { zoneId = "nagrand_draenor", note = "The grass you kept" },
    },
    quests = {
        Q(34769, "A Choice to Make", "nagrand_draenor",
            "WoD Nagrand. Verify."),
        Q(35169, "And Justice for Thrall", "nagrand_draenor",
            "WoD Nagrand finale."),
    },
}

spines.zandalari_mogu_war = {
    status = "drafting",
    wikiGraph = "Zandalari; Lei Shen; mogu; Isle of Thunder; Zandalar forever; Rastakhan.",
    zones = {
        { zoneId = "isle_of_thunder", note = "The old war" },
        { zoneId = "zuldazar", note = "The empire that remembers" },
    },
    quests = {
        Q(32644, "The Assault on Zeb'tula", "isle_of_thunder",
            "MoP: Zandalari–mogu. Verify."),
        Q(0, "Heritage of the Zandalari", "zuldazar",
            "Allied hand-in."),
    },
}

spines.zandalari_loa_communion = {
    status = "drafting",
    wikiGraph = "Loa; Rezan; Bwonsamdi; Krag'wa; Pa'ku; Gonk; Dazar'alor; Rastakhan's death; Talanji.",
    zones = {
        { zoneId = "zuldazar", note = "The pyramids" },
        { zoneId = "nazmir", note = "Blood loa" },
    },
    quests = {
        Q(47432, "The Bargain is Struck", "zuldazar",
            "BfA loa intro. Verify."),
        Q(51555, "The Loa of Death / Rastakhan", "zuldazar",
            "Fill Dazar'alor campaign last quest."),
    },
}

spines.general_si7_agent = {
    status = "drafting",
    wikiGraph = "SI:7; Mathias Shaw; Stormwind; Uncrowned overlap optional; BfA Shaw on the boat.",
    zones = {
        { zoneId = "stormwind", note = "HQ" },
        { zoneId = "tiragarde", note = "War table" },
    },
    quests = {
        Q(0, "Mathias Shaw — current breadcrumb", "stormwind",
            "Fill live Shaw intro from Wowhead (IDs move)."),
        Q(0, "The Eve of Battle", "durotar",
            "Same 8.2.5 beat as 7th Legion Path — Shaw's war, not the legion's."),
    },
}

spines.general_dragonflight_aspect = {
    status = "drafting",
    wikiGraph = "Dragon Aspects; Alexstrasza; Nozdormu; Kalecgos; Ebyssian; Tyrande's wish; Valdrakken Accords.",
    zones = {
        { zoneId = "valdrakken", note = "The Accords" },
        { zoneId = "thaldraszus", note = "Tyrhold" },
    },
    quests = {
        Q(65435, "The Dragon Isles Await", "stormwind",
            "DF intro. Verify faction variant."),
        Q(67074, "A New Beginning / Aspects restored", "valdrakken",
            "Fill DF campaign finale from Wowhead."),
    },
}

spines.general_loa_follower = {
    status = "drafting",
    wikiGraph = "Loa as personal god; player fills WHICH loa. Spine is Zandalar communion + one shrine.",
    zones = {
        { zoneId = "zuldazar", note = "Name the loa in the seed" },
    },
    quests = {
        Q(47432, "The Bargain is Struck", "zuldazar",
            "Same door as zandalari_loa_communion; Path is the bargain, not the empire."),
        Q(0, "(player: shrine quest of chosen loa)", "zuldazar",
            "Leave blank until the player names Bwonsamdi / Krag'wa / Pa'ku / Gonk / Rezan."),
    },
}

spines.general_venthyr_reborn = {
    status = "drafting",
    wikiGraph = "Venthyr; Revendreth; Denathrius; Prince Renathal; Sire's fall; Ember Court.",
    zones = {
        { zoneId = "revendreth", note = "Pride and penance" },
    },
    quests = {
        Q(57174, "The Accuser's Sinstone", "revendreth",
            "SL Revendreth campaign. Verify."),
        Q(60176, "The Master of Lies", "revendreth",
            "Denathrius. Campaign finale."),
    },
}

spines.general_twilight_cultist = {
    status = "drafting",
    wikiGraph = "Twilight's Hammer; Cho'gall; Ogudei; Ahn'Qiraj; Cata Highlands; Old Gods; "
        .. "distinct from void elf Path (escape vs stay).",
    zones = {
        { zoneId = "twilight_highlands", note = "The choir" },
        { zoneId = "silithus", note = "The first hymn" },
    },
    quests = {
        Q(8280, "Securing the Supply Lines", "silithus",
            "AQ war. Verify live."),
        Q(27380, "Nightmare", "twilight_highlands",
            "Iso'rath / Hammer. Same zone as voidelf_twilight_escape — different ending."),
    },
}

spines.general_brawlers_guild = {
    status = "drafting",
    wikiGraph = "Brawler's Guild; Bizmo; The Fight Club; Season rotations. Flavor Path — weak auto-log.",
    zones = {
        { zoneId = "deeprun_tram", note = "Alliance arena" },
        { zoneId = "orgrimmar", note = "Horde arena" },
    },
    quests = {
        Q(0, "Welcome to the Brawl", "deeprun_tram",
            "Season intro — fill current ID from Wowhead (rotates)."),
    },
}

spines.general_pirate = {
    status = "drafting",
    wikiGraph = "Bloodsail; Blackwater; Irontide; Freehold; Flynn; Harlan Sweete; Plunderstorm optional.",
    zones = {
        { zoneId = "tiragarde", note = "Freehold" },
        { zoneId = "stranglethorn", note = "Bloodsail" },
    },
    quests = {
        Q(1036, "Avast Ye, Admiral!", "stranglethorn",
            "Bloodsail admiral. Classic."),
        Q(52148, "Freehold", "tiragarde",
            "Kul Tiran pirate dungeon / Flynn chain. Verify intro ID."),
    },
}

if Blackacre.Paths and Blackacre.Paths.ApplySpine then
    for id, data in pairs(spines) do
        Blackacre.Paths.ApplySpine(id, data)
    end
end
