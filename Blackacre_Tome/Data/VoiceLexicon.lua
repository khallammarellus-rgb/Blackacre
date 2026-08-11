Blackacre = Blackacre or {}
Blackacre.VoiceLexicon = {}

-- rules: { from, to } whole-word unless plain=true (substring).
-- Densify carefully — lite accents only.

Blackacre.VoiceLexicon.dwarf = {
    label = "Dwarven",
    rules = {
        { "you", "ye" },
        { "your", "yer" },
        { "you're", "ye're" },
        { "my", "me" },
        { "I am", "I be", plain = true },
        { "isn't", "isnae" },
        { "cannot", "canna" },
        { "don't", "dinna" },
        { "to the", "tae the", plain = true },
        { "about", "aboot" },
    },
}

Blackacre.VoiceLexicon.orc = {
    label = "Orcish",
    rules = {
        { "hello", "lok'tar" },
        { "goodbye", "lok'tar ogar" },
        { "friend", "brother" },
        { "friends", "brothers" },
        { "yes", "zug zug" },
        { "strength", "strength and honor" },
    },
}

Blackacre.VoiceLexicon.undead = {
    label = "Forsaken",
    rules = {
        { "I am", "I remain", plain = true },
        { "I'm", "I remain" },
        { "alive", "unliving" },
        { "life", "unlife" },
        { "death", "the grave" },
        { "hello", "dark lady watch over you" },
    },
}

Blackacre.VoiceLexicon.goblin = {
    label = "Goblin",
    rules = {
        { "friend", "partner" },
        { "friends", "partners" },
        { "money", "gold" },
        { "deal", "sweet deal" },
        { "expensive", "premium" },
        { "please", "do me a favor" },
    },
}

Blackacre.VoiceLexicon.blood_elf = {
    label = "Sin'dorei",
    rules = {
        { "magic", "the arcane" },
        { "mage", "magister" },
        { "hello", "bal'a dash" },
        { "goodbye", "al diel shala" },
        { "friend", "anaria" },
    },
}

Blackacre.VoiceLexicon.night_elf = {
    label = "Kaldorei",
    rules = {
        { "hello", "elune-adore" },
        { "goodbye", "andé'thoras-ethil" },
        { "goddess", "Elune" },
        { "nature", "the wilds" },
        { "forest", "the wood" },
    },
}

Blackacre.VoiceLexicon.tauren = {
    label = "Shu'halo",
    rules = {
        { "hello", "ish-ne-alo por-ah" },
        { "earth", "the Earth Mother" },
        { "ancestors", "the ancestors" },
        { "peace", "peace and patience" },
        { "friend", "walks-with-us" },
    },
}

Blackacre.VoiceLexicon.draenei = {
    label = "Draenei",
    rules = {
        { "hello", "dichromi" },
        { "light", "the Light" },
        { "friend", "friend of the naaru" },
        { "peace", "peace be with you" },
    },
}

Blackacre.VoiceLexicon.pandaren = {
    label = "Pandaren",
    rules = {
        { "hello", "hao" },
        { "friend", "brew-friend" },
        { "fight", "spar" },
        { "food", "a fine meal" },
        { "patience", "the way of patience" },
    },
}

Blackacre.VoiceLexicon.vulpera = {
    label = "Vulpera",
    rules = {
        { "cart", "caravan" },
        { "home", "the caravan" },
        { "friend", "packmate" },
        { "treasure", "shiny" },
        { "desert", "the dunes" },
    },
}

Blackacre.VoiceLexicon.human = {
    label = "Common (Alliance formal)",
    rules = {
        { "yeah", "yes" },
        { "gonna", "going to" },
        { "wanna", "wish to" },
        { "kid", "youth" },
        { "guys", "friends" },
    },
}

-- Lite Cape cadence: sparse substitutions; applied all-or-nothing (never mixed with another profile).
Blackacre.VoiceLexicon.afrikaans = {
    label = "Cape cadence (lite)",
    rules = {
        { "thing", "'ting" },
        { "things", "'tings" },
        { "yes", "ja" },
        { "no", "nee" },
        { "what", "wat" },
        { "with", "met" },
    },
}
