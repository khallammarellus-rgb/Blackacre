InCharacter = InCharacter or {}
InCharacter.Chronicle = InCharacter.Chronicle or {}
InCharacter.Chronicle.Capture = {}

local lastTitleIndex = nil
local suppressToasts = false

local function Toast(msg)
    if suppressToasts then return end
    local quiet = InCharacter.CharDB and InCharacter.CharDB.settings and InCharacter.CharDB.settings.quietNotifications
    if quiet then return end
    if InCharacter.UI and InCharacter.UI.Theme and InCharacter.UI.Theme.Toast then
        InCharacter.UI.Theme.Toast(msg)
    else
        InCharacter.Print(msg)
    end
end

local function MakeEntry(kind, facts, source)
    local context = InCharacter.Chronicle.Hooks.GetContext()
    facts = facts or {}
    facts.zoneName = facts.zoneName or context.zone
    local title, body = InCharacter.Chronicle.Hooks.Resolve(kind, facts, context)
    local zone = InCharacter.GetZoneContext()
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
    }
    InCharacter.Chronicle.Store.Add(entry)
    Toast("Journal updated: " .. (entry.title or kind))
    if InCharacter.Chronicle.UI and InCharacter.Chronicle.UI.OnNewEntry then
        InCharacter.Chronicle.UI.OnNewEntry(entry)
    end
    return entry
end

function InCharacter.Chronicle.Capture.AddEntry(kind, facts, source)
    return MakeEntry(kind, facts, source or "auto")
end

function InCharacter.Chronicle.Capture.AddManual(title, body, kind)
    kind = kind or "MANUAL"
    return MakeEntry(kind, {
        manualTitle = title,
        manualBody = body,
        title = title,
        body = body,
    }, "manual")
end

local function OnQuestTurnedIn(questID)
    if not questID then return end
    local name = C_QuestLog.GetTitleForQuestID and C_QuestLog.GetTitleForQuestID(questID)
    if not name or name == "" then
        name = "Quest #" .. tostring(questID)
    end
    MakeEntry("QUEST", {
        questId = questID,
        questName = name,
        name = name,
    })
end

local function OnAchievement(achievementID)
    if not achievementID then return end
    local _, name = GetAchievementInfo(achievementID)
    MakeEntry("ACHIEVEMENT", {
        achievementId = achievementID,
        achievementName = name or ("Achievement #" .. tostring(achievementID)),
        name = name,
    })
end

local function CheckTitleChange()
    if not GetCurrentTitle then return end
    local idx = GetCurrentTitle()
    if idx and idx > 0 and idx ~= lastTitleIndex then
        local titleName = GetTitleName(idx)
        if titleName and titleName ~= "" then
            -- GetTitleName often includes trailing space formatting
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

local function OnSkillMsg(msg)
    if not msg or msg == "" then return end
    -- Examples: "Your skill in Mining has increased to 75." / skill rank messages
    local skillName, rank = msg:match("[Yy]our skill in (.+) has increased to (%d+)")
    if not skillName then
        skillName, rank = msg:match("Skill in (.+) increased to (%d+)")
    end
    if skillName then
        MakeEntry("PROFESSION", {
            skillName = skillName,
            skillRank = tonumber(rank),
            raw = msg,
        })
    end
end

function InCharacter.Chronicle.Capture.Init()
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_LOGIN")
    frame:RegisterEvent("QUEST_TURNED_IN")
    frame:RegisterEvent("ACHIEVEMENT_EARNED")
    frame:RegisterEvent("KNOWN_TITLES_UPDATE")
    frame:RegisterEvent("CHAT_MSG_SKILL")
    frame:SetScript("OnEvent", function(_, event, ...)
        if event == "PLAYER_LOGIN" then
            if GetCurrentTitle then
                lastTitleIndex = GetCurrentTitle()
            end
        elseif event == "QUEST_TURNED_IN" then
            local questID = ...
            OnQuestTurnedIn(questID)
        elseif event == "ACHIEVEMENT_EARNED" then
            local achievementID = ...
            OnAchievement(achievementID)
        elseif event == "KNOWN_TITLES_UPDATE" then
            CheckTitleChange()
        elseif event == "CHAT_MSG_SKILL" then
            local msg = ...
            OnSkillMsg(msg)
        end
    end)
    -- Poll title occasionally (title equip does not always fire KNOWN_TITLES_UPDATE)
    C_Timer.NewTicker(15, CheckTitleChange)
end

function InCharacter.Chronicle.Capture.DebugAddSample()
    suppressToasts = true
    MakeEntry("QUEST", {
        questId = 0,
        questName = "The Waters of Teldrassil",
        zoneName = "Teldrassil",
    })
    suppressToasts = false
    InCharacter.Print("Sample chronicle entry added.")
end