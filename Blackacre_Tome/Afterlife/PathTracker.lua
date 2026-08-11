Blackacre = Blackacre or {}
Blackacre.Afterlife = Blackacre.Afterlife or {}
Blackacre.Afterlife.PathTracker = {}

local function EnsureDB()
    Blackacre.CharDB.afterlife = Blackacre.CharDB.afterlife or {
        active = nil,
        history = {},
        promptOnDeath = true,
    }
    return Blackacre.CharDB.afterlife
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

function Blackacre.Afterlife.PathTracker.Start(pathId, deathZone)
    local path = Blackacre.GetAfterlifePath(pathId)
    if not path then return nil end
    local db = EnsureDB()
    db.active = {
        pathId = pathId,
        pathName = path.name,
        startedAt = time(),
        deathZone = deathZone or (Blackacre.GetZoneContext().zoneName or ""),
        completed = {},
    }
    Blackacre.Chronicle.Capture.AddEntry("AFTERLIFE", {
        pathId = pathId,
        pathName = path.name,
        stage = "begin",
        title = "Entered " .. path.name,
        deathZone = db.active.deathZone,
    }, "auto")
    if Blackacre.Afterlife.UI and Blackacre.Afterlife.UI.Refresh then
        Blackacre.Afterlife.UI.Refresh()
    end
    if Blackacre.UI and Blackacre.UI.Theme then
        Blackacre.UI.Theme.Toast("Your soul walks " .. path.name .. ".")
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
    Blackacre.Chronicle.Capture.AddEntry("AFTERLIFE", {
        pathId = active.pathId,
        pathName = path.name,
        stage = "task",
        taskId = taskId,
        title = path.name .. ": " .. task.title,
        taskBody = task.body,
    }, "auto")

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

    if Blackacre.UI and Blackacre.UI.Theme then
        Blackacre.UI.Theme.Toast("You return to the living from " .. pathName .. ".")
    end
    if Blackacre.Afterlife.UI and Blackacre.Afterlife.UI.Refresh then
        Blackacre.Afterlife.UI.Refresh()
    end
end

function Blackacre.Afterlife.PathTracker.Abandon()
    local db = EnsureDB()
    if not db.active then return end
    local name = db.active.pathName or "the path"
    db.active = nil
    Blackacre.Chronicle.Capture.AddEntry("AFTERLIFE", {
        stage = "abandon",
        title = "Abandoned the road of " .. name,
    }, "manual")
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
    if not Blackacre.Afterlife.IsPromptOnDeath() then return end
    if EnsureDB().active then return end
    C_Timer.After(1.5, function()
        if Blackacre.Afterlife.UI and Blackacre.Afterlife.UI.ShowRealmPicker then
            Blackacre.Afterlife.UI.ShowRealmPicker()
        end
    end)
end

function Blackacre.Afterlife.PathTracker.Init()
    EnsureDB()
end