Blackacre = Blackacre or {}
Blackacre.Chronicle = Blackacre.Chronicle or {}
Blackacre.Chronicle.Capture = {}

local lastTitleIndex = nil
local titleReady = false
local suppressToasts = false
local lastRepScan = 0

local BLOCKED_KINDS = {
    SURVIVAL = true,
    HC_MOUNT = true,
    HC_FLY = true,
    HC_ENCUMBRANCE = true,
}

local STANDING_NAME = {
    [4] = "Friendly",
    [5] = "Honored",
    [6] = "Revered",
    [7] = "Exalted",
    [8] = "Paragon",
}

local function Toast(msg, kit)
    if suppressToasts then return end
    local quiet = Blackacre.CharDB and Blackacre.CharDB.settings and Blackacre.CharDB.settings.quietNotifications
    if quiet then return end
    if Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.Toast then
        Blackacre.UI.Theme.Toast(msg, kit)
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
    facts = facts or {}
    if kind and BLOCKED_KINDS[kind] and not facts.playerChose then
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
    Toast("Journal updated: " .. (entry.title or kind), "journal")
    if Blackacre.Chronicle.UI and Blackacre.Chronicle.UI.OnNewEntry then
        Blackacre.Chronicle.UI.OnNewEntry(entry)
    end
    return entry
end

function Blackacre.Chronicle.Capture.AddEntry(kind, facts, source)
    if kind == "ROADMAP" and Blackacre.Compat and Blackacre.Compat.IsForever and Blackacre.Compat.IsForever() then
        return nil
    end
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

local pendingOffer
local journalIntent = false
local sawRewardPanel = false
local journalBtn
local inkedQuest = {}

local function QuestPaneTexts()
    local title = (GetTitleText and GetTitleText()) or ""
    local offer = (GetQuestText and GetQuestText()) or ""
    local reward = (GetRewardText and GetRewardText()) or ""
    if reward == "" and GetProgressText then
        reward = GetProgressText() or ""
    end
    if QuestInfoDescriptionText and QuestInfoDescriptionText.GetText then
        local pane = QuestInfoDescriptionText:GetText() or ""
        if pane ~= "" then
            if offer == "" then
                offer = pane
            elseif reward == "" then
                reward = pane
            end
        end
    end
    return title, offer, reward
end

local function PromptEveryQuest()
    local s = Blackacre.CharDB and Blackacre.CharDB.settings
    if s and s.promptEveryQuest ~= nil then
        return s.promptEveryQuest and true or false
    end
    return Blackacre.Compat and Blackacre.Compat.IsForever and Blackacre.Compat.IsForever()
end

local function SceneBits(snapshot)
    if not snapshot or not Blackacre.Chronicle.Prompt then
        return nil
    end
    local title, body = Blackacre.Chronicle.Prompt.Build(snapshot)
    local opening = body and body:match("^(.-)\n") or nil
    local npc = snapshot.giverName and ("I spoke with " .. snapshot.giverName .. ".") or nil
    return { opening = opening, npc = npc, title = title, body = body }
end

local function InkPrompt(kind, snapshot, extraFacts)
    extraFacts = extraFacts or {}
    local title, body
    if Blackacre.Chronicle.Prompt and Blackacre.Chronicle.Prompt.Build then
        title, body = Blackacre.Chronicle.Prompt.Build(snapshot, extraFacts)
    else
        title = extraFacts.title or "A page"
        body = extraFacts.body or ""
    end
    return MakeEntry(kind, {
        questId = extraFacts.questId,
        zoneName = snapshot and (snapshot.subzone or snapshot.zone) or extraFacts.zoneName,
        title = title,
        promptTitle = title,
        promptBody = body,
        lineId = extraFacts.lineId,
        lineName = extraFacts.lineName,
        playerChose = extraFacts.playerChose and true or (kind == "QUEST"),
    })
end

local function EnsureJournalButton()
    local complete = _G.QuestFrameCompleteQuestButton
    if not complete then
        return nil
    end
    if journalBtn then
        return journalBtn
    end
    local parent = complete:GetParent() or _G.QuestFrameRewardPanel or _G.QuestFrame
    journalBtn = CreateFrame("Button", "BlackacreJournalThisButton", parent, "UIPanelButtonTemplate")
    journalBtn:SetSize(120, 22)
    journalBtn:SetPoint("LEFT", complete, "RIGHT", 6, 0)
    journalBtn:SetText("Journal This")
    journalBtn:SetFrameLevel((complete:GetFrameLevel() or 1) + 1)
    journalBtn:SetScript("OnClick", function(self)
        self:Disable()
        if Blackacre.Chronicle.Prompt and Blackacre.Chronicle.Prompt.CaptureGiver then
            Blackacre.Chronicle.Prompt.CaptureGiver()
        end
        local questID = (GetQuestID and GetQuestID()) or nil
        if questID and inkedQuest[questID] then
            return
        end
        if questID then
            inkedQuest[questID] = true
        end
        local snapshot = Blackacre.Chronicle.Prompt and Blackacre.Chronicle.Prompt.Snapshot
            and Blackacre.Chronicle.Prompt.Snapshot() or nil
        local qTitle, offer, reward = QuestPaneTexts()
        -- Write now. Do not wait for the complete-quest button.
        InkPrompt("QUEST", snapshot, {
            questId = questID,
            playerChose = true,
            questName = qTitle,
            questOffer = offer,
            questReward = reward,
        })
        journalIntent = false
    end)
    return journalBtn
end

local function PrepareJournalButton()
    sawRewardPanel = true
    journalIntent = false
    if not PromptEveryQuest() then
        if journalBtn then
            journalBtn:Hide()
        end
        return
    end
    local btn = EnsureJournalButton()
    if btn then
        btn:Show()
        btn:Enable()
    end
    if Blackacre.Chronicle.Prompt and Blackacre.Chronicle.Prompt.CaptureGiver then
        Blackacre.Chronicle.Prompt.CaptureGiver()
    end
end

local function OfferJournal(snapshot, questID)
    if not PromptEveryQuest() then
        return
    end
    local quiet = Blackacre.CharDB and Blackacre.CharDB.settings and Blackacre.CharDB.settings.quietNotifications
    if quiet then
        return
    end
    pendingOffer = { snapshot = snapshot, questId = questID }
    if not StaticPopupDialogs["Blackacre_QUEST_PROMPT"] then
        StaticPopupDialogs["Blackacre_QUEST_PROMPT"] = {
            text = "Ink this in the Tome?\n\nA first-person Prompt will be written from this place, hour, weather, and whoever you spoke with — not the quest title.",
            button1 = "Journal this",
            button2 = "Not this errand",
            OnAccept = function()
                local offer = pendingOffer
                pendingOffer = nil
                if offer then
                    InkPrompt("QUEST", offer.snapshot, { questId = offer.questId, playerChose = true })
                end
            end,
            OnCancel = function()
                pendingOffer = nil
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
    end
    StaticPopup_Show("Blackacre_QUEST_PROMPT")
end

local function OnQuestTurnedIn(questID)
    if not questID then return end
    if inkedQuest[questID] then
        journalIntent = false
        sawRewardPanel = false
        return
    end
    if ShouldIgnoreQuest(questID) then return end

    local snapshot = Blackacre.Chronicle.Prompt and Blackacre.Chronicle.Prompt.Snapshot
        and Blackacre.Chronicle.Prompt.Snapshot() or nil
    local scene = SceneBits(snapshot)
    local zoneName = snapshot and (snapshot.subzone or snapshot.zone) or nil
    local name = C_QuestLog and C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(questID)

    if IsMetaQuest(questID) then
        InkPrompt("META_QUEST", snapshot, { questId = questID, zoneName = zoneName })
        journalIntent = false
        sawRewardPanel = false
        return
    end

    local heritage
    if not (Blackacre.Compat and Blackacre.Compat.IsForever and Blackacre.Compat.IsForever()) then
        heritage = Blackacre.HeritageCapstones and Blackacre.HeritageCapstones.Match(questID, name)
    end

    local isFinale, info, lineId
    if Blackacre.QuestLines then
        Blackacre.QuestLines.RememberBeat(questID, name, zoneName, scene)
        isFinale, info, lineId = Blackacre.QuestLines.IsFinale(questID)
        if not isFinale and lineId and C_QuestLine and C_QuestLine.IsComplete then
            local ok, done = pcall(C_QuestLine.IsComplete, lineId)
            if ok and done then
                isFinale = true
            end
        end
    end

    if isFinale or heritage then
        local extra = {}
        if Blackacre.QuestLines and Blackacre.QuestLines.BuildOnePager then
            local title, body, meta = Blackacre.QuestLines.BuildOnePager(lineId, name, zoneName, snapshot)
            extra.chain = nil
            extra.title = title
            extra.body = body
            extra.lineId = meta and meta.lineId or lineId
            extra.lineName = meta and meta.lineName
        end
        extra.questId = questID
        extra.zoneName = zoneName
        -- BuildOnePager already returns a Prompt body.
        MakeEntry("QUESTLINE", {
            questId = questID,
            zoneName = zoneName,
            title = extra.title,
            promptTitle = extra.title,
            promptBody = extra.body,
            lineId = extra.lineId,
            lineName = extra.lineName,
        })
        journalIntent = false
        sawRewardPanel = false
        return
    end

    if PromptEveryQuest() then
        local qTitle = name
        InkPrompt("QUEST", snapshot, {
            questId = questID,
            playerChose = true,
            questName = qTitle or "",
        })
        if questID then
            inkedQuest[questID] = true
        end
    elseif not sawRewardPanel then
        OfferJournal(snapshot, questID)
    end
    journalIntent = false
    sawRewardPanel = false
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
    local _, name, _, _, _, _, _, description = GetAchievementInfo(achievementID)
    name = name or ("Achievement #" .. tostring(achievementID))
    local detail = description or ""
    if IsFeatOfStrength(achievementID) then
        MakeEntry("FOS", {
            achievementId = achievementID,
            achievementName = name,
            achievementDetail = detail,
            name = name,
        })
        return
    end
    if IsMetaAchievement(achievementID) then
        MakeEntry("META_ACHIEVEMENT", {
            achievementId = achievementID,
            achievementName = name,
            achievementDetail = detail,
            name = name,
        })
        return
    end
    MakeEntry("ACHIEVEMENT", {
        achievementId = achievementID,
        achievementName = name,
        achievementDetail = detail,
        name = name,
    })
end

local function CheckTitleChange()
    if not titleReady or not GetCurrentTitle then return end
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
    local num
    local getData = C_Reputation and C_Reputation.GetFactionDataByIndex
    if C_Reputation and C_Reputation.GetNumFactions then
        num = C_Reputation.GetNumFactions()
    elseif GetNumFactions then
        num = GetNumFactions()
    end
    if not num or num < 1 then return end
    for i = 1, num do
        local factionId, standingId, name
        if getData then
            local data = getData(i)
            if type(data) == "table" and not data.isHeader then
                factionId = data.factionID or data.factionId
                standingId = data.reaction or data.standingId or data.currentStanding
                name = data.name
            end
        elseif GetFactionInfo then
            local n, _, standing, _, _, _, _, _, isHeader, _, _, _, _, factionIdArg = GetFactionInfo(i)
            if not isHeader then
                name = n
                standingId = standing
                factionId = factionIdArg
            end
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
    local professionReady = false
    local ECHELON_AT = { [75] = "apprentice", [150] = "journeyman", [225] = "expert", [300] = "artisan" }
    local function NoteProfessions(writeEntry)
        if not GetProfessions or not GetProfessionInfo then return end
        local db = StoryDB()
        db.professionEchelon = db.professionEchelon or {}
        local profs = { GetProfessions() }
        for i = 1, #profs do
            local idx = profs[i]
            if idx then
                local name, _, rank = GetProfessionInfo(idx)
                local echelon = name and ECHELON_AT[rank]
                if echelon then
                    local key = name .. ":" .. tostring(rank)
                    if not db.professionEchelon[key] then
                        db.professionEchelon[key] = true
                        if writeEntry then
                            MakeEntry("PROFESSION", {
                                skillName = name,
                                skillRank = rank,
                                echelon = echelon,
                                playerChose = true,
                            })
                        end
                    end
                end
            end
        end
    end

    frame:RegisterEvent("PLAYER_LOGIN")
    frame:RegisterEvent("SKILL_LINES_CHANGED")
    frame:RegisterEvent("QUEST_TURNED_IN")
    frame:RegisterEvent("QUEST_DETAIL")
    frame:RegisterEvent("QUEST_PROGRESS")
    frame:RegisterEvent("QUEST_COMPLETE")
    frame:RegisterEvent("GOSSIP_SHOW")
    frame:RegisterEvent("ACHIEVEMENT_EARNED")
    frame:RegisterEvent("KNOWN_TITLES_UPDATE")
    frame:RegisterEvent("UPDATE_FACTION")
    if frame.RegisterUnitEvent then
        frame:RegisterUnitEvent("UNIT_NAME_UPDATE", "player")
    else
        frame:RegisterEvent("UNIT_NAME_UPDATE")
    end
    -- Renown is a later-expansion system. Forever never fires it; don't listen.
    if not (Blackacre.Compat and Blackacre.Compat.IsForever and Blackacre.Compat.IsForever()) then
        pcall(frame.RegisterEvent, frame, "MAJOR_FACTION_RENOWN_LEVEL_CHANGED")
    end
    frame:SetScript("OnEvent", function(_, event, ...)
        if event == "PLAYER_LOGIN" then
            if GetCurrentTitle then
                lastTitleIndex = GetCurrentTitle()
            end
            titleReady = true
            C_Timer.After(3, ScanReputationBrackets)
            C_Timer.After(4, function()
                NoteProfessions(false)
                professionReady = true
            end)
        elseif event == "SKILL_LINES_CHANGED" then
            if professionReady then
                NoteProfessions(true)
            end
        elseif event == "QUEST_DETAIL" or event == "QUEST_PROGRESS" or event == "GOSSIP_SHOW" then
            if Blackacre.Chronicle.Prompt and Blackacre.Chronicle.Prompt.CaptureGiver then
                Blackacre.Chronicle.Prompt.CaptureGiver()
            end
        elseif event == "QUEST_COMPLETE" then
            PrepareJournalButton()
        elseif event == "QUEST_TURNED_IN" then
            OnQuestTurnedIn(...)
        elseif event == "ACHIEVEMENT_EARNED" then
            OnAchievement(...)
        elseif event == "KNOWN_TITLES_UPDATE" or event == "UNIT_NAME_UPDATE" then
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
end

function Blackacre.Chronicle.Capture.DebugAddSample()
    suppressToasts = true
    local snap = {
        hour = 5,
        minute = 12,
        zone = "Dun Morogh",
        subzone = "Coldridge Valley",
        weather = "snow",
        intensity = 0.4,
        giverName = "Sten Stoutarm",
        giverSex = 2,
    }
    local title, body = Blackacre.Chronicle.Prompt.Build(snap)
    MakeEntry("QUEST", {
        zoneName = "Coldridge Valley",
        title = title,
        promptTitle = title,
        promptBody = body,
        playerChose = true,
    })
    suppressToasts = false
    Blackacre.Print("Sample Prompt added (Coldridge morning).")
end
