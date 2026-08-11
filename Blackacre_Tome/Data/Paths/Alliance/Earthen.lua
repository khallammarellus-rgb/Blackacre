-- Life Paths: Earthen (retail earthen; race token may be Earthen / EarthenDwarf — adjust if needed)
Blackacre.Paths.Register({
    id = "earthen_curse_of_flesh_limbo",
    name = "Limbo of the Curse of Flesh",
    blurb = "Stone that almost became meat — you remember the almost.",
    era = "past",
    faction = "Alliance", -- earthen can be either; soft default Alliance-allied; free pick
    races = { "Earthen", "EarthenDwarf" },
    tags = { "titan", "curse_of_flesh", "uldaman", "ordering" },
    birthplaceHints = { "Uldaman", "Khaz Algar", "Deepholm" },
    eraTags = { "ordering", "titan" },
    zones = {},
    quests = {},
    tomeSeed = { title = "Almost flesh", body = "The edict was incomplete. So are you — on purpose." },
    status = "stub",
})

Blackacre.Paths.Register({
    id = "earthen_nerubian_containment",
    name = "Awakened: Nerubian Containment",
    blurb = "You rose to hold the dark under Khaz Algar — webs, orders, and waking duty.",
    era = "contemporary",
    faction = "Any",
    races = { "Earthen", "EarthenDwarf" },
    tags = { "nerubian", "khaz_algar", "tww", "awakened" },
    birthplaceHints = { "Khaz Algar", "Dornogal", "Azj-Kahet" },
    eraTags = { "tww" },
    zones = {},
    quests = {},
    tomeSeed = { title = "Orders in stone", body = "Containment is not peace. It is a promise you keep daily." },
    status = "stub",
})
