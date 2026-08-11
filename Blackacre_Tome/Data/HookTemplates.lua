Blackacre = Blackacre or {}

-- Template banks by chronicle kind. {slots} filled by Chronicle.Hooks.
Blackacre.HookTemplates = {
    QUEST = {
        "In the year {yearKC}, {name} completed a trial in {zone}: {questName}. As a {level}-seasoned {race} {class}{specClause}, they marked another step on the long road of their story.",
        "Beneath the skies of {zone}, {name} brought an end to the matter known as \"{questName}.\" The deed spoke of a {race} {class} still learning the weight of their choices — level {level}, yet already leaving footprints in the dust of legend.",
        "It is written that in {yearKC}, {name} faced the charge of \"{questName}\" in {zone}. Their {class} craft{specClause} served them well; the realm will remember, if only in a traveler's private journal.",
        "When the task \"{questName}\" was finished in {zone}, {name} closed that chapter. A {race} of {level} winters' strength, they carried the lesson forward into whatever comes next.",
    },
    ACHIEVEMENT = {
        "In {yearKC}, {name} earned recognition: {achievementName}. The feat joined the quiet ledger of a {race} {class}'s rising name.",
        "Word spreads of {name}'s deed — \"{achievementName}\" — claimed while they yet walked as a level {level} {class}. Let the journal hold what glory the world forgets.",
    },
    TITLE = {
        "From this day in {yearKC}, {name} may be known as {titleName}. A new name for a {race} {class} whose path has not yet found its end.",
        "The title \"{titleName}\" settled upon {name} like a mantle. Whether honor or burden, the journal records it true.",
    },
    PROFESSION = {
        "By torchlight and practice, {name} advanced in {skillName} ({skillRank}). The hands of a {class} learn more than war alone.",
        "In {yearKC}, {name}'s craft in {skillName} reached {skillRank}. Trade and toil write their own kind of epic.",
    },
    MANUAL = {
        "In {yearKC}, {name} set down a personal note: {manualTitle}. {manualBody}",
        "Journal entry of {name}, {race} {class}, level {level} — {manualTitle}. {manualBody}",
    },
    DEATH = {
        "In {yearKC}, {name} fell in {zone}. The {race} {class} tasted the border of mortality — a hard page in any traveler's ledger.",
        "Death found {name} beneath the skies of {zone}. Whether spirit-roads or darker realms await, the journal records the fall at level {level}.",
    },
    HC_ENCUMBRANCE = {
        "Honor strained: {name} bore packs beyond the six-slot burden ({bagDetail}). The road grows heavier when the pack grows greedy.",
        "In {yearKC}, {name}'s baggage exceeded the old compact — {bagDetail}. Encumbrance is a choice; the chronicle will not pretend otherwise.",
    },
    HC_MOUNT = {
        "Without completing the ground-mount rite, {name} took saddle in {zone}. Speed without sanction leaves a mark on hardcore honor.",
        "Hooves and harness before the gatekeeper's leave — {name} rode unsworn. The journal notes the shortcut.",
    },
    HC_FLY = {
        "Wings before blessing: {name} took to the air in {zone} without the flying rite. Sky-roads, too, have their oaths.",
        "In {yearKC}, {name} flew unlicensed over {zone}. The hardcore ledger records the ascent.",
    },
    SURVIVAL = {
        "In {zone}, {name}'s body reminded them they are mortal — {meterName} failed them ({meterValue}). The road asks a price in more than blood.",
        "A hard page: {name}, level {level}, found {meterName} at its end in {zone}. Survival is a story the bones tell first.",
    },
    AFTERLIFE = {
        "In {yearKC}, {name}'s spirit walked {pathName}. {afterlifeDetail} So the ledger of death and return is written.",
        "Beyond the living maps, {name} tread {pathName}. {afterlifeDetail} When flesh called again, the {race} {class} answered.",
    },
    ROADMAP = {
        "In {yearKC}, {name} set their boots to the expedition \"{roadmapName}\". {roadmapDetail}",
        "The chart turns: {name}, a {race} {class} of level {level}, marks \"{roadmapName}\" — {roadmapDetail}",
    },
    PVP = {
        "After the clash at {mapName}, {name} set down a field report. {outcomeLine} Steel told its measure in wounds dealt ({damageText}) and mended ({healingText}); deaths borne: {deaths}. A {race} {class} does not leave the field without a story.",
        "In {yearKC}, {name} walked from {mapName}. {outcomeLine} The ledger of war lists {damageText} force spent, {healingText} grace given, {killingBlows} finishing blows. Let glory and grit both be inked.",
    },
    DEFAULT = {
        "In the year {yearKC}, {name} marked a moment in their tale ({kind}). The {race} {class} continues onward from {zone}.",
    },
}

-- Level-band flavor fragments for optional templates that use {seasoning}
Blackacre.HookSeasoning = {
    { maxLevel = 20, text = "young and untested" },
    { maxLevel = 40, text = "still early on the path" },
    { maxLevel = 60, text = "seasoned by road and trial" },
    { maxLevel = 80, text = "hard-forged by long campaign" },
    { maxLevel = 999, text = "weathered as old stone" },
}