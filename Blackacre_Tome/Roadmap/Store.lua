Blackacre = Blackacre or {}
Blackacre.Roadmap = Blackacre.Roadmap or {}
Blackacre.Roadmap.Store = {}

local function EnsureDB()
    Blackacre.CharDB.roadmap = Blackacre.CharDB.roadmap or {
        active = nil,
        history = {},
        lockPrompts = true,
        lastLockPromptLevel = nil,
    }
    return Blackacre.CharDB.roadmap
end

function Blackacre.Roadmap.Store.Init()
    EnsureDB()
end

function Blackacre.Roadmap.GetActive()
    return EnsureDB().active
end

function Blackacre.Roadmap.LockPromptsEnabled()
    local db = EnsureDB()
    if db.lockPrompts == nil then return true end
    return db.lockPrompts
end

function Blackacre.Roadmap.SetLockPrompts(on)
    EnsureDB().lockPrompts = on and true or false
end

function Blackacre.Roadmap.Store.StartPreset(presetId)
    local preset = Blackacre.GetRoadmapPreset(presetId)
    if not preset then return nil end
    local steps = Blackacre.BuildRoadmapSteps(preset.steps)
    if #steps == 0 then return nil end
    steps[1].status = "active"
    local active = {
        id = Blackacre.NewID(),
        presetId = presetId,
        name = preset.name,
        blurb = preset.blurb,
        startedAt = time(),
        currentIndex = 1,
        steps = steps,
        levelLockedAt = nil,
    }
    EnsureDB().active = active
    Blackacre.Chronicle.Capture.AddEntry("ROADMAP", {
        stage = "begin",
        title = "Expedition begun: " .. preset.name,
        roadmapName = preset.name,
        zoneName = steps[1].name,
    }, "auto")
    return active
end

function Blackacre.Roadmap.Store.StartCustom(name, zoneIdList)
    local steps = Blackacre.BuildRoadmapSteps(zoneIdList)
    if #steps == 0 then return nil end
    steps[1].status = "active"
    local active = {
        id = Blackacre.NewID(),
        presetId = "custom",
        name = name or "Custom expedition",
        blurb = "A path of your own charting.",
        startedAt = time(),
        currentIndex = 1,
        steps = steps,
        levelLockedAt = nil,
    }
    EnsureDB().active = active
    Blackacre.Chronicle.Capture.AddEntry("ROADMAP", {
        stage = "begin",
        title = "Expedition begun: " .. active.name,
        roadmapName = active.name,
        zoneName = steps[1].name,
    }, "auto")
    return active
end

function Blackacre.Roadmap.Store.GetCurrentStep()
    local active = EnsureDB().active
    if not active then return nil end
    return active.steps[active.currentIndex]
end

function Blackacre.Roadmap.Store.Advance()
    local active = EnsureDB().active
    if not active then return end
    local cur = active.steps[active.currentIndex]
    if cur then
        cur.status = "done"
        Blackacre.Chronicle.Capture.AddEntry("ROADMAP", {
            stage = "chapter",
            title = "Chapter closed: " .. cur.name,
            roadmapName = active.name,
            zoneName = cur.name,
            lore = cur.lore,
        }, "auto")
    end
    active.currentIndex = active.currentIndex + 1
    local nextStep = active.steps[active.currentIndex]
    if nextStep then
        nextStep.status = "active"
        Blackacre.Chronicle.Capture.AddEntry("ROADMAP", {
            stage = "arrive",
            title = "Road opens: " .. nextStep.name,
            roadmapName = active.name,
            zoneName = nextStep.name,
            lore = nextStep.lore,
        }, "auto")
        if Blackacre.UI and Blackacre.UI.Theme then
            Blackacre.UI.Theme.Toast("Next chapter: " .. nextStep.name)
        end
    else
        Blackacre.Roadmap.Store.Complete()
    end
    if Blackacre.Roadmap.UI and Blackacre.Roadmap.UI.Refresh then
        Blackacre.Roadmap.UI.Refresh()
    end
end

function Blackacre.Roadmap.Store.Complete()
    local db = EnsureDB()
    local active = db.active
    if not active then return end
    Blackacre.Chronicle.Capture.AddEntry("ROADMAP", {
        stage = "complete",
        title = "Expedition complete: " .. active.name,
        roadmapName = active.name,
    }, "auto")
    table.insert(db.history, 1, {
        name = active.name,
        startedAt = active.startedAt,
        finishedAt = time(),
        presetId = active.presetId,
    })
    while #db.history > 15 do table.remove(db.history) end
    db.active = nil
    if Blackacre.UI and Blackacre.UI.Theme then
        Blackacre.UI.Theme.Toast("Expedition chart complete.")
    end
    if Blackacre.Roadmap.UI and Blackacre.Roadmap.UI.Refresh then
        Blackacre.Roadmap.UI.Refresh()
    end
end

function Blackacre.Roadmap.Store.Abandon()
    local db = EnsureDB()
    if not db.active then return end
    Blackacre.Chronicle.Capture.AddEntry("ROADMAP", {
        stage = "abandon",
        title = "Expedition abandoned: " .. (db.active.name or "path"),
        roadmapName = db.active.name,
    }, "manual")
    db.active = nil
    if Blackacre.Roadmap.UI and Blackacre.Roadmap.UI.Refresh then
        Blackacre.Roadmap.UI.Refresh()
    end
end

function Blackacre.Roadmap.Store.MarkLevelLock(level)
    local active = EnsureDB().active
    if not active then return end
    active.levelLockedAt = level
    local cur = active.steps[active.currentIndex]
    if cur then cur.status = "locked" end
    Blackacre.Chronicle.Capture.AddEntry("ROADMAP", {
        stage = "lock",
        title = string.format("Level lock at %d — lingering in %s", level, cur and cur.name or "the chapter"),
        roadmapName = active.name,
        zoneName = cur and cur.name or nil,
        lockLevel = level,
    }, "auto")
end