--[[
  Quest-line buffer for the Tome.

  Onyxia attunement is the rule of thumb (historical, not live):
  many steps (Windsor, Katrana, the unfolding of Onyxia) — one journal
  page only when the capstone turns in, summarizing the road.

  Live retail: C_QuestLine tells us the chain; we remember beats in
  CharDB and ink a QUESTLINE page only on the last incomplete quest.
]]

Blackacre = Blackacre or {}
Blackacre.QuestLines = Blackacre.QuestLines or {}

local function EnsureDB()
    Blackacre.CharDB = Blackacre.CharDB or {}
    Blackacre.CharDB.chronicleStory = Blackacre.CharDB.chronicleStory or {
        chains = {},
        repStanding = {},
        renown = {},
    }
    return Blackacre.CharDB.chronicleStory
end

local function QuestTitle(questID)
    local name
    if C_QuestLog and C_QuestLog.GetTitleForQuestID then
        name = C_QuestLog.GetTitleForQuestID(questID)
    end
    if not name or name == "" then
        name = "Quest #" .. tostring(questID)
    end
    return name
end

local function IsComplete(questID)
    if C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted then
        return C_QuestLog.IsQuestFlaggedCompleted(questID)
    end
    return false
end

function Blackacre.QuestLines.GetLineInfo(questID)
    if not questID or not C_QuestLine then return nil end
    local mapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
    local info
    if C_QuestLine.GetQuestLineInfo then
        local ok, result = pcall(C_QuestLine.GetQuestLineInfo, questID, mapID)
        if ok then info = result end
        if not info then
            ok, result = pcall(C_QuestLine.GetQuestLineInfo, questID)
            if ok then info = result end
        end
    end
    return info
end

function Blackacre.QuestLines.GetLineQuests(lineId)
    if not lineId or not C_QuestLine or not C_QuestLine.GetQuestLineQuests then
        return {}
    end
    local ok, list = pcall(C_QuestLine.GetQuestLineQuests, lineId)
    if ok and type(list) == "table" then
        return list
    end
    return {}
end

function Blackacre.QuestLines.RememberBeat(questID, questName, zoneName)
    local info = Blackacre.QuestLines.GetLineInfo(questID)
    if not info then
        return nil
    end
    local lineId = info.questLineId or info.questLineID or info.id
    if not lineId then return info, nil end
    local db = EnsureDB()
    local row = db.chains[lineId] or {
        id = lineId,
        name = info.questLineName or info.name or "an unnamed road",
        quests = {},
    }
    row.name = info.questLineName or info.name or row.name
    row.quests[#row.quests + 1] = {
        id = questID,
        name = questName or QuestTitle(questID),
        zone = zoneName,
        at = time(),
    }
    db.chains[lineId] = row
    return info, row
end

--- True when every other quest in the line is already flagged complete.
function Blackacre.QuestLines.IsFinale(questID)
    local info = Blackacre.QuestLines.GetLineInfo(questID)
    if not info then return false, info, nil end
    local lineId = info.questLineId or info.questLineID or info.id
    local ids = Blackacre.QuestLines.GetLineQuests(lineId)
    if #ids == 0 then
        return false, info, lineId
    end
    for i = 1, #ids do
        local id = ids[i]
        if id ~= questID and not IsComplete(id) then
            return false, info, lineId
        end
    end
    return true, info, lineId
end

function Blackacre.QuestLines.BuildOnePager(lineId, finaleName, zoneName)
    local db = EnsureDB()
    local row = lineId and db.chains[lineId]
    local lineName = (row and row.name) or "a long road"
    local beats = {}
    if row then
        for i = 1, #row.quests do
            local q = row.quests[i]
            if q.name then
                beats[#beats + 1] = q.name
            end
        end
    end
    if finaleName and (not beats[#beats] or beats[#beats] ~= finaleName) then
        beats[#beats + 1] = finaleName
    end
    local road
    if #beats == 0 then
        road = finaleName or lineName
    elseif #beats == 1 then
        road = beats[1]
    else
        local last = table.remove(beats)
        road = table.concat(beats, "; ") .. "; until " .. last
    end
    local title = lineName
    local body = string.format(
        "This page is a traveler's digest of \"%s\" in %s — not every footstep, only the road's shape. %s. Edit this ink; the chronicle will not pretend it saw every hour.",
        lineName,
        zoneName or "unknown lands",
        road
    )
    return title, body, {
        lineId = lineId,
        lineName = lineName,
        finaleName = finaleName,
        beatCount = row and #row.quests or 0,
    }
end
