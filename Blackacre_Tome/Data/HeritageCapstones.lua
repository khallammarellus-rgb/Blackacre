--[[
  Known heritage / campaign FINAL quests (English titles + optional IDs).
  Capture treats these as QUESTLINE finales even if C_QuestLine is quiet.
  Fill questId from Wowhead when verified. Titles are enUS.
  Sources: warcraft.wiki.gg Heritage_* pages, Midnight_campaign.
]]

Blackacre = Blackacre or {}
Blackacre.HeritageCapstones = Blackacre.HeritageCapstones or {}

-- keyed by lowercase title
local byTitle = {}
local byId = {}

local rows = {
    { race = "Human", faction = "Alliance", set = "Lion's Heritage",
      startTitle = "An Urgent Matter", endTitle = "Go with Honor, Friend",
      wiki = "https://warcraft.wiki.gg/wiki/Lion%27s_Heritage" },
    { race = "NightElf", faction = "Alliance", set = "Heritage of the Kaldorei",
      startTitle = "The Clarion Call", endTitle = "Honor of the Goddess",
      wiki = "https://warcraft.wiki.gg/wiki/Heritage_of_the_Kaldorei" },
    { race = "BloodElf", faction = "Horde", set = "Heritage of the Sin'dorei",
      startTitle = "The Pride of the Sin'dorei", endTitle = "The Fall of the Sunwell",
      endId = 54096,
      wiki = "https://warcraft.wiki.gg/wiki/Heritage_of_the_Sin%27dorei" },
    { race = "Scourge", faction = "Horde", set = "Heritage of Lordaeron",
      startTitle = "Unliving Summons", endTitle = "I Am Forsaken",
      wiki = "https://warcraft.wiki.gg/wiki/Heritage_of_Lordaeron" },
    { race = "Orc", faction = "Horde", set = "Heritage of Draenor",
      startTitle = "A Summon to Orgrimmar", endTitle = "Aka'magosh",
      wiki = "https://warcraft.wiki.gg/wiki/Heritage_of_Draenor" },
    { race = "Dwarf", faction = "Alliance", set = "Heritage of the Bronzebeard",
      endTitle = nil, wiki = "https://warcraft.wiki.gg/wiki/Heritage_of_the_Bronzebeard" },
    { race = "Gnome", faction = "Alliance", set = "Heritage of Gnomeregan",
      wiki = "https://warcraft.wiki.gg/wiki/Heritage_of_Gnomeregan" },
    { race = "Worgen", faction = "Alliance", set = "Heritage of Gilneas",
      wiki = "https://warcraft.wiki.gg/wiki/Heritage_of_Gilneas" },
    { race = "Draenei", faction = "Alliance", set = "Heritage of the Draenei",
      wiki = "https://warcraft.wiki.gg/wiki/Heritage_of_the_Draenei" },
    { race = "Pandaren", faction = "Any", set = "Heritage of the Wandering Isle",
      endTitle = "A New Tradition",
      wiki = "https://warcraft.wiki.gg/wiki/Heritage_of_the_Wandering_Isle" },
    { race = "Tauren", faction = "Horde", set = "Heritage of the Shu'halo",
      wiki = "https://warcraft.wiki.gg/wiki/Heritage_of_the_Shu%27halo" },
    { race = "Troll", faction = "Horde", set = "Heritage of the Darkspear",
      wiki = "https://warcraft.wiki.gg/wiki/Heritage_of_the_Darkspear" },
    { race = "Goblin", faction = "Horde", set = "Heritage of Kezan",
      wiki = "https://warcraft.wiki.gg/wiki/Heritage_of_Kezan" },
    { race = "VoidElf", faction = "Alliance", set = "Heritage of the Ren'dorei",
      wiki = "https://warcraft.wiki.gg/wiki/Heritage_of_the_Ren%27dorei" },
    { race = "LightforgedDraenei", faction = "Alliance", set = "Heritage of the Lightforged",
      wiki = "https://warcraft.wiki.gg/wiki/Heritage_of_the_Lightforged" },
    { race = "DarkIronDwarf", faction = "Alliance", set = "Heritage of the Dark Iron",
      wiki = "https://warcraft.wiki.gg/wiki/Heritage_of_the_Dark_Iron" },
    { race = "KulTiran", faction = "Alliance", set = "Heritage of Kul Tiras",
      wiki = "https://warcraft.wiki.gg/wiki/Heritage_of_Kul_Tiras" },
    { race = "Mechagnome", faction = "Alliance", set = "Heritage of the Mechagnome",
      wiki = "https://warcraft.wiki.gg/wiki/Heritage_of_the_Mechagnome" },
    { race = "Nightborne", faction = "Horde", set = "Heritage of the Shal'dorei",
      wiki = "https://warcraft.wiki.gg/wiki/Heritage_of_the_Shal%27dorei" },
    { race = "HighmountainTauren", faction = "Horde", set = "Heritage of Highmountain",
      wiki = "https://warcraft.wiki.gg/wiki/Heritage_of_Highmountain" },
    { race = "MagharOrc", faction = "Horde", set = "Heritage of the Mag'har",
      wiki = "https://warcraft.wiki.gg/wiki/Heritage_of_the_Mag%27har" },
    { race = "ZandalariTroll", faction = "Horde", set = "Heritage of the Zandalari",
      wiki = "https://warcraft.wiki.gg/wiki/Heritage_of_the_Zandalari" },
    { race = "Vulpera", faction = "Horde", set = "Heritage of the Vulpera",
      wiki = "https://warcraft.wiki.gg/wiki/Heritage_of_the_Vulpera" },
    { race = "Earthen", faction = "Any", set = "Heritage of Khaz Algar",
      wiki = "https://warcraft.wiki.gg/wiki/Heritage_of_Khaz_Algar" },
    { race = "Haranir", faction = "Any", set = "Heritage of the Haranir",
      startTitle = "Initiation Day", endTitle = "Stranger in a New Land",
      wiki = "https://warcraft.wiki.gg/wiki/Midnight_campaign" },
    -- Midnight campaign beats (log last of each chapter)
    { race = "", faction = "Any", set = "Midnight intro: The Light's Summons",
      startTitle = "Midnight", endTitle = "Light's Last Stand",
      wiki = "https://warcraft.wiki.gg/wiki/Midnight_campaign" },
    { race = "VoidElf", faction = "Alliance", set = "Rage of the Ren'dorei",
      startTitle = "The Pursuit Continues", endTitle = "Trial of Wrath",
      wiki = "https://warcraft.wiki.gg/wiki/Midnight_campaign" },
}

for i = 1, #rows do
    local r = rows[i]
    if r.endTitle then
        byTitle[r.endTitle:lower()] = r
    end
    if r.endId then
        byId[r.endId] = r
    end
end

Blackacre.HeritageCapstones.List = rows

function Blackacre.HeritageCapstones.Match(questID, questName)
    if questID and byId[questID] then
        return byId[questID]
    end
    if questName and questName ~= "" then
        return byTitle[questName:lower()]
    end
    return nil
end
