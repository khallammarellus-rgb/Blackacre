InCharacter = InCharacter or {}

-- Template banks by chronicle kind. {slots} filled by Chronicle.Hooks.
InCharacter.HookTemplates = {
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
    DEFAULT = {
        "In the year {yearKC}, {name} marked a moment in their tale ({kind}). The {race} {class} continues onward from {zone}.",
    },
}

-- Level-band flavor fragments for optional templates that use {seasoning}
InCharacter.HookSeasoning = {
    { maxLevel = 20, text = "young and untested" },
    { maxLevel = 40, text = "still early on the path" },
    { maxLevel = 60, text = "seasoned by road and trial" },
    { maxLevel = 80, text = "hard-forged by long campaign" },
    { maxLevel = 999, text = "weathered as old stone" },
}