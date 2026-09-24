Blackacre = Blackacre or {}
Blackacre.Afterlife = Blackacre.Afterlife or {}
Blackacre.Afterlife.PathTracker = {}

local function EnsureDB()
    Blackacre.CharDB.afterlife = Blackacre.CharDB.afterlife or {
        active = nil,
        history = {},
        promptOnDeath = true,
        chosenPathId = nil,
        deityId = nil,
        resurrectCount = 0,
    }
    local db = Blackacre.CharDB.afterlife
    if db.promptOnDeath == nil then db.promptOnDeath = true end
    db.history = db.history or {}
    db.resurrectCount = db.resurrectCount or 0
    return db
end

local function InBattleground()
    if C_PvP and C_PvP.IsBattleground and C_PvP.IsBattleground() then
        return true
    end
    if UnitInBattleground and UnitInBattleground("player") then
        return true
    end
    return false
end

function Blackacre.Afterlife.GetActive()
    return EnsureDB().active
end

function Blackacre.Afterlife.IsPromptOnDeath()
    local db = EnsureDB()
    if db.promptOnDeath == nil then return true end
    return db.promptOnDeath
end

function Blackacre.Afterlife.SetPromptOnDeath(on)
    EnsureDB().promptOnDeath = on and true or false
end

--- Setup only: pick a realm. Does not start rite progress or write a Tome page.
function Blackacre.Afterlife.Choose(pathId)
    local path = Blackacre.GetAfterlifePath(pathId)
    if not path then return nil end
    local db = EnsureDB()
    if db.active then
        return nil
    end
    db.chosenPathId = pathId
    if Blackacre.Afterlife.UI and Blackacre.Afterlife.UI.Refresh then
        Blackacre.Afterlife.UI.Refresh()
    end
    return path
end

function Blackacre.Afterlife.SetDeity(deityId)
    EnsureDB().deityId = deityId
    if Blackacre.Afterlife.UI and Blackacre.Afterlife.UI.Refresh then
        Blackacre.Afterlife.UI.Refresh()
    end
end

function Blackacre.Afterlife.GetChosenPath()
    local id = EnsureDB().chosenPathId
    return id and Blackacre.GetAfterlifePath(id) or nil
end

function Blackacre.Afterlife.PathTracker.Start(pathId, deathZone)
    local db = EnsureDB()
    pathId = pathId or db.chosenPathId
    local path = Blackacre.GetAfterlifePath(pathId)
    if not path then return nil end
    if db.active then return db.active end
    db.chosenPathId = pathId
    db.active = {
        pathId = pathId,
        pathName = path.name,
        startedAt = time(),
        deathZone = deathZone or (Blackacre.GetZoneContext().zoneName or ""),
        completed = {},
    }
    if Blackacre.Afterlife.UI and Blackacre.Afterlife.UI.Refresh then
        Blackacre.Afterlife.UI.Refresh()
    end
    if Blackacre.UI and Blackacre.UI.Theme then
        Blackacre.UI.Theme.Toast("Your soul will seek " .. path.name .. " to be guided back", "maw")
    end
    return db.active
end

function Blackacre.Afterlife.PathTracker.CompleteTask(taskId)
    local active = EnsureDB().active
    if not active then return false end
    local path = Blackacre.GetAfterlifePath(active.pathId)
    if not path then return false end

    local task
    for _, t in ipairs(path.tasks) do
        if t.id == taskId then
            task = t
            break
        end
    end
    if not task then return false end
    if active.completed[taskId] then return true end

    active.completed[taskId] = time()

    local allDone = true
    for _, t in ipairs(path.tasks) do
        if not active.completed[t.id] then
            allDone = false
            break
        end
    end
    if allDone then
        Blackacre.Afterlife.PathTracker.FinishReturn()
    else
        if Blackacre.Afterlife.UI and Blackacre.Afterlife.UI.Refresh then
            Blackacre.Afterlife.UI.Refresh()
        end
    end
    return true
end

function Blackacre.Afterlife.PathTracker.FinishReturn()
    local db = EnsureDB()
    local active = db.active
    if not active then return end
    local path = Blackacre.GetAfterlifePath(active.pathId)
    local pathName = path and path.name or active.pathName or "the afterlife"

    Blackacre.Chronicle.Capture.AddEntry("AFTERLIFE", {
        pathId = active.pathId,
        pathName = pathName,
        stage = "return",
        title = "Returned from " .. pathName,
        deathZone = active.deathZone,
    }, "auto")

    table.insert(db.history, 1, {
        pathId = active.pathId,
        pathName = pathName,
        startedAt = active.startedAt,
        finishedAt = time(),
        deathZone = active.deathZone,
    })
    while #db.history > 20 do
        table.remove(db.history)
    end
    db.active = nil
    db.returnsByRite = (db.returnsByRite or 0) + 1

    if Blackacre.UI and Blackacre.UI.Theme then
        Blackacre.UI.Theme.Toast("You return to the living from " .. pathName .. ".", "maw")
    end
    if Blackacre.Afterlife.UI and Blackacre.Afterlife.UI.Refresh then
        Blackacre.Afterlife.UI.Refresh()
    end
end

function Blackacre.Afterlife.PathTracker.Abandon()
    local db = EnsureDB()
    if not db.active then return end
    db.active = nil
    if Blackacre.Afterlife.UI and Blackacre.Afterlife.UI.Refresh then
        Blackacre.Afterlife.UI.Refresh()
    end
end

function Blackacre.Afterlife.PathTracker.Progress()
    local active = EnsureDB().active
    if not active then return 0, 0 end
    local path = Blackacre.GetAfterlifePath(active.pathId)
    if not path then return 0, 0 end
    local done = 0
    for _, t in ipairs(path.tasks) do
        if active.completed[t.id] then done = done + 1 end
    end
    return done, #path.tasks
end

function Blackacre.Afterlife.PathTracker.OnDeath()
    if InBattleground() then return end
    local db = EnsureDB()
    if db.active then return end
    C_Timer.After(1.5, function()
        if InBattleground() then return end
        if EnsureDB().active then return end
        if Blackacre.Afterlife.IsPromptOnDeath() then
            if db.chosenPathId then
                Blackacre.Afterlife.PathTracker.Start(db.chosenPathId)
            elseif Blackacre.Afterlife.UI and Blackacre.Afterlife.UI.ShowRealmPicker then
                Blackacre.Afterlife.UI.ShowRealmPicker()
            end
            return
        end
        StaticPopupDialogs["Blackacre_START_RITE"] = StaticPopupDialogs["Blackacre_START_RITE"] or {
            text = "Start your Rite of Return?",
            button1 = "Begin the rite",
            button2 = "Not this death",
            OnAccept = function()
                local d = EnsureDB()
                if d.chosenPathId then
                    Blackacre.Afterlife.PathTracker.Start(d.chosenPathId)
                elseif Blackacre.Afterlife.UI and Blackacre.Afterlife.UI.ShowRealmPicker then
                    Blackacre.Afterlife.UI.ShowRealmPicker()
                end
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        StaticPopup_Show("Blackacre_START_RITE")
    end)
end

function Blackacre.Afterlife.PathTracker.OnResurrect()
    local db = EnsureDB()
    db.resurrectCount = (db.resurrectCount or 0) + 1
    if Blackacre.Afterlife.UI and Blackacre.Afterlife.UI.Refresh then
        Blackacre.Afterlife.UI.Refresh()
    end
end

function Blackacre.Afterlife.GetCounts()
    local db = EnsureDB()
    local deaths = 0
    if Blackacre.CharDB and Blackacre.CharDB.hardcore then
        deaths = Blackacre.CharDB.hardcore.deathCount or 0
    end
    return {
        deaths = deaths,
        resurrections = db.resurrectCount or 0,
        returns = db.returnsByRite or #db.history,
    }
end

function Blackacre.Afterlife.PathTracker.Init()
    EnsureDB()
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_UNGHOST")
    f:SetScript("OnEvent", function()
        Blackacre.Afterlife.PathTracker.OnResurrect()
    end)
end