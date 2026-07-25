InCharacter = InCharacter or {}
InCharacter.Afterlife = InCharacter.Afterlife or {}
InCharacter.Afterlife.PathTracker = {}

local function EnsureDB()
    InCharacter.CharDB.afterlife = InCharacter.CharDB.afterlife or {
        active = nil,
        history = {},
        promptOnDeath = true,
    }
    return InCharacter.CharDB.afterlife
end

function InCharacter.Afterlife.GetActive()
    return EnsureDB().active
end

function InCharacter.Afterlife.IsPromptOnDeath()
    local db = EnsureDB()
    if db.promptOnDeath == nil then return true end
    return db.promptOnDeath
end

function InCharacter.Afterlife.SetPromptOnDeath(on)
    EnsureDB().promptOnDeath = on and true or false
end

function InCharacter.Afterlife.PathTracker.Start(pathId, deathZone)
    local path = InCharacter.GetAfterlifePath(pathId)
    if not path then return nil end
    local db = EnsureDB()
    db.active = {
        pathId = pathId,
        pathName = path.name,
        startedAt = time(),
        deathZone = deathZone or (InCharacter.GetZoneContext().zoneName or ""),
        completed = {},
    }
    InCharacter.Chronicle.Capture.AddEntry("AFTERLIFE", {
        pathId = pathId,
        pathName = path.name,
        stage = "begin",
        title = "Entered " .. path.name,
        deathZone = db.active.deathZone,
    }, "auto")
    if InCharacter.Afterlife.UI and InCharacter.Afterlife.UI.Refresh then
        InCharacter.Afterlife.UI.Refresh()
    end
    if InCharacter.UI and InCharacter.UI.Theme then
        InCharacter.UI.Theme.Toast("Your soul walks " .. path.name .. ".")
    end
    return db.active
end

function InCharacter.Afterlife.PathTracker.CompleteTask(taskId)
    local active = EnsureDB().active
    if not active then return false end
    local path = InCharacter.GetAfterlifePath(active.pathId)
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
    InCharacter.Chronicle.Capture.AddEntry("AFTERLIFE", {
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
        InCharacter.Afterlife.PathTracker.FinishReturn()
    else
        if InCharacter.Afterlife.UI and InCharacter.Afterlife.UI.Refresh then
            InCharacter.Afterlife.UI.Refresh()
        end
    end
    return true
end

function InCharacter.Afterlife.PathTracker.FinishReturn()
    local db = EnsureDB()
    local active = db.active
    if not active then return end
    local path = InCharacter.GetAfterlifePath(active.pathId)
    local pathName = path and path.name or active.pathName or "the afterlife"

    InCharacter.Chronicle.Capture.AddEntry("AFTERLIFE", {
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

    if InCharacter.UI and InCharacter.UI.Theme then
        InCharacter.UI.Theme.Toast("You return to the living from " .. pathName .. ".")
    end
    if InCharacter.Afterlife.UI and InCharacter.Afterlife.UI.Refresh then
        InCharacter.Afterlife.UI.Refresh()
    end
end

function InCharacter.Afterlife.PathTracker.Abandon()
    local db = EnsureDB()
    if not db.active then return end
    local name = db.active.pathName or "the path"
    db.active = nil
    InCharacter.Chronicle.Capture.AddEntry("AFTERLIFE", {
        stage = "abandon",
        title = "Abandoned the road of " .. name,
    }, "manual")
    if InCharacter.Afterlife.UI and InCharacter.Afterlife.UI.Refresh then
        InCharacter.Afterlife.UI.Refresh()
    end
end

function InCharacter.Afterlife.PathTracker.Progress()
    local active = EnsureDB().active
    if not active then return 0, 0 end
    local path = InCharacter.GetAfterlifePath(active.pathId)
    if not path then return 0, 0 end
    local done = 0
    for _, t in ipairs(path.tasks) do
        if active.completed[t.id] then done = done + 1 end
    end
    return done, #path.tasks
end

function InCharacter.Afterlife.PathTracker.OnDeath()
    if not InCharacter.Afterlife.IsPromptOnDeath() then return end
    if EnsureDB().active then return end
    C_Timer.After(1.5, function()
        if InCharacter.Afterlife.UI and InCharacter.Afterlife.UI.ShowRealmPicker then
            InCharacter.Afterlife.UI.ShowRealmPicker()
        end
    end)
end

function InCharacter.Afterlife.PathTracker.Init()
    EnsureDB()
end