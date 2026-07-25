InCharacter = InCharacter or {}
InCharacter.Roadmap = InCharacter.Roadmap or {}
InCharacter.Roadmap.Engine = {}

local function SoftToast(msg)
    if InCharacter.UI and InCharacter.UI.Theme and InCharacter.UI.Theme.Toast then
        InCharacter.UI.Theme.Toast(msg)
    else
        InCharacter.Print(msg)
    end
end

function InCharacter.Roadmap.Engine.CheckLevelLock()
    if not InCharacter.Roadmap.LockPromptsEnabled() then return end
    local active = InCharacter.Roadmap.GetActive()
    if not active then return end
    local step = active.steps[active.currentIndex]
    if not step or not step.lockAt then return end

    local level = UnitLevel("player") or 1
    local db = InCharacter.CharDB.roadmap
    if level < step.lockAt then return end
    if db.lastLockPromptLevel == level and active.levelLockedAt == level then return end
    if active.levelLockedAt and active.levelLockedAt >= step.lockAt then return end

    -- Prompt once per level threshold
    if db.lastLockPromptLevel == level then return end
    db.lastLockPromptLevel = level

    StaticPopup_Show("INCHARACTER_LEVEL_LOCK", step.name, tostring(step.lockAt), {
        stepName = step.name,
        lockAt = step.lockAt,
        lore = step.lore,
    })
end

function InCharacter.Roadmap.Engine.Init()
    StaticPopupDialogs["INCHARACTER_LEVEL_LOCK"] = {
        text = "Your expedition chart suggests lingering in %s around level %s.\n\nConsider locking experience (game settings) so the story can breathe.\nThis addon cannot force an XP lock.",
        button1 = "Mark locked in journal",
        button2 = "Keep leveling",
        OnAccept = function(_, data)
            local level = UnitLevel("player") or (data and data.lockAt) or 1
            InCharacter.Roadmap.Store.MarkLevelLock(level)
            SoftToast("Level lock noted in the chronicle. Use game XP lock if you wish.")
            if InCharacter.Roadmap.UI and InCharacter.Roadmap.UI.Refresh then
                InCharacter.Roadmap.UI.Refresh()
            end
        end,
        OnCancel = function()
            SoftToast("The road continues without pause.")
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_LEVEL_UP")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_LEVEL_UP" or event == "PLAYER_ENTERING_WORLD" then
            C_Timer.After(1, InCharacter.Roadmap.Engine.CheckLevelLock)
        end
    end)
end