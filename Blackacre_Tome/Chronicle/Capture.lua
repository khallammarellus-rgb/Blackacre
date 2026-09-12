Blackacre = Blackacre or {}
Blackacre.Chronicle = Blackacre.Chronicle or {}
Blackacre.Chronicle.Capture = {}

local lastTitleIndex = nil
local suppressToasts = false
local lastRepScan = 0

local BLOCKED_KINDS = {
    SURVIVAL = true,
    HC_MOUNT = true,
    HC_FLY = true,
    HC_ENCUMBRANCE = true,
    PROFESSION = true,
    QUEST = true, -- individual turn-ins; QUESTLINE / META_QUEST only
}

local STANDING_NAME = {
    [4] = "Friendly",
    [5] = "Honored",
    [6] = "Revered",
    [7] = "Exalted",
    [8] = "Paragon",
}

local function Toast(msg)
    if suppressToasts then return end
    local quiet = Blackacre.CharDB and Blackacre.CharDB.settings and Blackacre.CharDB.settings.quietNotifications
    if quiet then return end
    if Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.Toast then
        Blackacre.UI.Theme.Toast(msg)
    else
        Blackacre.Print(msg)
    end
end

local function StoryDB()
    Blackacre.CharDB = Blackacre.CharDB or {}
    Blackacre.CharDB.chronicleStory = Blackacre.CharDB.chronicleStory or {
        chains = {},
        repStanding = {},
        renown = {},
    }
    return Blackacre.CharDB.chronicleStory
end

local function MakeEntry(kind, facts, source)
    if kind and BLOCKED_KINDS[kind] then
        return nil
    end
    local context = Blackacre.Chronicle.Hooks.GetContext()
    facts = facts or {}
    facts.zoneName = facts.zoneName or context.zone
    local title, body = Blackacre.Chronicle.Hooks.Resolve(kind, facts, context)
    local zone = Blackacre.GetZoneContext()
    local entry = {
        kind = kind,
        source = source or "auto",
        facts = facts,
        context = context,
        title = title,
        body = body,
        zoneId = zone.zoneId,
        zoneName = zone.zoneName,
        yearKC = context.yearKC,
        createdAt = time(),
        editedAt = time(),
        pinned = false,
        tags = {},
        editable = true,
    }
    Blackacre.Chronicle.Store.Add(entry)
    Toast("Journal updated: " .. (entry.title or kind))
    if Blackacre.Chronicle.UI and Blackacre.Chronicle.UI.OnNewEntry then
        Blackacre.Chronicle.UI.OnNewEntry(entry)
    end
    return entry
end

function Blackacre.Chronicle.Capture.AddEntry(kind, facts, source)
    if kind and BLOCKED_KINDS[kind] then
        return nil
    end
    return MakeEntry(kind, facts, source or "auto")
end

function Blackacre.Chronicle.Capture.AddManual(title, body, kind)
    kind = kind or "MANUAL"
    return MakeEntry(kind, {
        manualTitle = title,
        manualBody = body,
        title = title,
        body = body,
    }, "manual")
end

local function QuestClassification(questID)
    if C_QuestInfoSystem and C_QuestInfoSystem.GetQuestClassification then
        local ok, c = pcall(C_QuestInfoSystem.GetQuestClassification, questID)
        if ok then return c end
    end
    return nil
end

local function IsMetaQuest(questID)
    if C_QuestLog and C_QuestLog.IsMetaQuest then
        local ok, v = pcall(C_QuestLog.IsMetaQuest, questID)
        if ok and v then return true end
    end
    local c = QuestClassification(questID)
    local E = Enum and Enum.QuestClassification
    if c and E and c == E.Meta then
        return true
    end
    return false
end

local function ShouldIgnoreQuest(questID)
    if C_QuestLog and C_QuestLog.IsWorldQuest and C_QuestLog.IsWorldQuest(questID) then
        return true
    end
    if C_QuestLog and C_QuestLog.IsQuestTask and C_QuestLog.IsQuestTask(questID) then
        return true
    end
    local c = QuestClassification(questID)
    local E = Enum and Enum.QuestClassification
    if c and E then
        if c == E.WorldQuest or c == E.BonusObjective or c == E.Recurring
            or c == E.Calling or c == E.Threat then
            return true
        end
    end
    return false
end

local function OnQuestTurnedIn(questID)
    if not questID then return end
    if ShouldIgnoreQuest(questID) then return end

    local name = C_QuestLog and C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(questID)
    if not name or name == "" then
        name = "Quest #" .. tostring(questID)
    end
    local zone = Blackacre.GetZoneContext()
    local zoneName = zone and zone.zoneName or nil

    if IsMetaQuest(questID) then
        MakeEntry("META_QUEST", {
            questId = questID,
            questName = name,
            name = name,
            zoneName = zoneName,
        })
        return
    end

    local heritage = Blackacre.HeritageCapstones and Blackacre.HeritageCapstones.Match(questID, name)
    if Blackacre.QuestLines then
        Blackacre.QuestLines.RememberBeat(questID, name, zoneName)
        local isFinale, info, lineId = Blackacre.QuestLines.IsFinale(questID)
        if isFinale or heritage then
            local title, body, extra = Blackacre.QuestLines.BuildOnePager(lineId, name, zoneName)
            local lineName = extra.lineName or (info and (info.questLineName or info.name))
            if heritage then
                lineName = heritage.set or lineName
            end
            MakeEntry("QUESTLINE", {
                questId = questID,
                questName = name,
                lineName = lineName,
                lineId = lineId,
                zoneName = zoneName,
                title = heritage and heritage.set or title,
                body = body,
                onePager = body,
            })
        end
    end
end

local function IsMetaAchievement(achievementID)
    if not GetAchievementNumCriteria then return false end
    local n = GetAchievementNumCriteria(achievementID) or 0
    if n < 2 then return false end
    local hits = 0
    for i = 1, n do
        local ok, _, criteriaType = pcall(GetAchievementCriteriaInfo, achievementID, i)
        if ok and (criteriaType == 8 or criteriaType == 36) then
            hits = hits + 1
        end
    end
    return hits >= 2
end

local function IsFeatOfStrength(achievementID)
    if AchievementUtil and AchievementUtil.IsFeatOfStrength then
        local ok, v = pcall(AchievementUtil.IsFeatOfStrength, achievementID)
        if ok and v then return true end
    end
    return false
end

local function OnAchievement(achievementID)
    if not achievementID then return end
    local _, name = GetAchievementInfo(achievementID)
    name = name or ("Achievement #" .. tostring(achievementID))
    if IsFeatOfStrength(achievementID) then
        MakeEntry("FOS", {
            achievementId = achievementID,
            achievementName = name,
            name = name,
        })
        return
    end
    if IsMetaAchievement(achievementID) then
        MakeEntry("META_ACHIEVEMENT", {
            achievementId = achievementID,
            achievementName = name,
            name = name,
        })
    end
end

local function CheckTitleChange()
    if not GetCurrentTitle then return end
    local idx = GetCurrentTitle()
    if idx and idx > 0 and idx ~= lastTitleIndex then
        local titleName = GetTitleName(idx)
        if titleName and titleName ~= "" then
            titleName = titleName:gsub("%s+$", "")
            MakeEntry("TITLE", {
                titleIndex = idx,
                titleName = titleName,
                name = titleName,
            })
        end
        lastTitleIndex = idx
    elseif idx then
        lastTitleIndex = idx
    end
end

local function ScanReputationBrackets()
    local db = StoryDB()
    db.repStanding = db.repStanding or {}
    if not C_Reputation then return end
    local num
    if C_Reputation.GetNumFactions then
        num = C_Reputation.GetNumFactions()
    elseif GetNumFactions then
        num = GetNumFactions()
    end
    if not num then return end
    for i = 1, num do
        local data
        if C_Reputation.GetFactionDataByIndex then
            local ok, d = pcall(C_Reputation.GetFactionDataByIndex, i)
            if ok then data = d end
        end
        local factionId, standingId, name
        if type(data) == "table" then
            factionId = data.factionID or data.factionId
            standingId = data.reaction or data.standingId or data.currentStanding
            name = data.name
        elseif GetFactionInfo then
            local n, _, standing = GetFactionInfo(i)
            name = n
            standingId = standing
        end
        if factionId and standingId then
            local prev = db.repStanding[factionId]
            db.repStanding[factionId] = standingId
            local label = STANDING_NAME[standingId]
            if label and prev and standingId > prev and STANDING_NAME[standingId] then
                MakeEntry("REPUTATION", {
                    factionId = factionId,
                    factionName = name or ("Faction #" .. tostring(factionId)),
                    standingId = standingId,
                    standingName = label,
                    name = name,
                })
            end
        end
    end
end

local function OnRenown(majorFactionID, newLevel)
    if not majorFactionID then return end
    local db = StoryDB()
    db.renown = db.renown or {}
    local data
    if C_MajorFactions and C_MajorFactions.GetMajorFactionData then
        local ok, d = pcall(C_MajorFactions.GetMajorFactionData, majorFactionID)
        if ok then data = d end
    end
    local name = data and data.name or ("Renown #" .. tostring(majorFactionID))
    local level = newLevel or (data and data.renownLevel)
    local isMax = data and (data.isMaxRenown or (data.renownLevelCap and level and level >= data.renownLevelCap))
    db.renown[majorFactionID] = level
    if isMax then
        MakeEntry("RENOWN", {
            factionId = majorFactionID,
            factionName = name,
            renownLevel = level,
            isMax = true,
            name = name,
            title = "Renown maxed: " .. name,
        })
    end
end

function Blackacre.Chronicle.Capture.Init()
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_LOGIN")
    frame:RegisterEvent("QUEST_TURNED_IN")
    frame:RegisterEvent("ACHIEVEMENT_EARNED")
    frame:RegisterEvent("KNOWN_TITLES_UPDATE")
    frame:RegisterEvent("UPDATE_FACTION")
    pcall(frame.RegisterEvent, frame, "MAJOR_FACTION_RENOWN_LEVEL_CHANGED")
    frame:SetScript("OnEvent", function(_, event, ...)
        if event == "PLAYER_LOGIN" then
            if GetCurrentTitle then
                lastTitleIndex = GetCurrentTitle()
            end
            C_Timer.After(3, ScanReputationBrackets)
        elseif event == "QUEST_TURNED_IN" then
            OnQuestTurnedIn(...)
        elseif event == "ACHIEVEMENT_EARNED" then
            OnAchievement(...)
        elseif event == "KNOWN_TITLES_UPDATE" then
            CheckTitleChange()
        elseif event == "UPDATE_FACTION" then
            local now = GetTime and GetTime() or time()
            if now - lastRepScan < 2 then return end
            lastRepScan = now
            ScanReputationBrackets()
        elseif event == "MAJOR_FACTION_RENOWN_LEVEL_CHANGED" then
            local id, newLevel = ...
            OnRenown(id, newLevel)
        end
    end)
    C_Timer.NewTicker(15, CheckTitleChange)
end

function Blackacre.Chronicle.Capture.DebugAddSample()
    suppressToasts = true
    MakeEntry("QUESTLINE", {
        questName = "The unfolding of Lady Prestor",
        lineName = "Onyxia attunement (vignette)",
        zoneName = "Stormwind City",
        title = "Onyxia attunement (vignette)",
        body = "This page is a traveler's digest of a long road — Windsor's truth, the court of Stormwind, the unmasking of Katrana Prestor — not every footstep. Edit this ink.",
        onePager = true,
    })
    suppressToasts = false
    Blackacre.Print("Sample questline digest added (Onyxia vignette).")
end
