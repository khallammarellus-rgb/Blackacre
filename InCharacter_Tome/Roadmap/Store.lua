InCharacter = InCharacter or {}
InCharacter.Roadmap = InCharacter.Roadmap or {}
InCharacter.Roadmap.Store = {}

local function EnsureDB()
    InCharacter.CharDB.roadmap = InCharacter.CharDB.roadmap or {
        active = nil,
        history = {},
        lockPrompts = true,
        lastLockPromptLevel = nil,
    }
    return InCharacter.CharDB.roadmap
end

function InCharacter.Roadmap.Store.Init()
    EnsureDB()
end

function InCharacter.Roadmap.GetActive()
    return EnsureDB().active
end

function InCharacter.Roadmap.LockPromptsEnabled()
    local db = EnsureDB()
    if db.lockPrompts == nil then return true end
    return db.lockPrompts
end

function InCharacter.Roadmap.SetLockPrompts(on)
    EnsureDB().lockPrompts = on and true or false
end

function InCharacter.Roadmap.Store.StartPreset(presetId)
    local preset = InCharacter.GetRoadmapPreset(presetId)
    if not preset then return nil end
    local steps = InCharacter.BuildRoadmapSteps(preset.steps)
    if #steps == 0 then return nil end
    steps[1].status = "active"
    local active = {
        id = InCharacter.NewID(),
        presetId = presetId,
        name = preset.name,
        blurb = preset.blurb,
        startedAt = time(),
        currentIndex = 1,
        steps = steps,
        levelLockedAt = nil,
    }
    EnsureDB().active = active
    InCharacter.Chronicle.Capture.AddEntry("ROADMAP", {
        stage = "begin",
        title = "Expedition begun: " .. preset.name,
        roadmapName = preset.name,
        zoneName = steps[1].name,
    }, "auto")
    return active
end

function InCharacter.Roadmap.Store.StartCustom(name, zoneIdList)
    local steps = InCharacter.BuildRoadmapSteps(zoneIdList)
    if #steps == 0 then return nil end
    steps[1].status = "active"
    local active = {
        id = InCharacter.NewID(),
        presetId = "custom",
        name = name or "Custom expedition",
        blurb = "A path of your own charting.",
        startedAt = time(),
        currentIndex = 1,
        steps = steps,
        levelLockedAt = nil,
    }
    EnsureDB().active = active
    InCharacter.Chronicle.Capture.AddEntry("ROADMAP", {
        stage = "begin",
        title = "Expedition begun: " .. active.name,
        roadmapName = active.name,
        zoneName = steps[1].name,
    }, "auto")
    return active
end

function InCharacter.Roadmap.Store.GetCurrentStep()
    local active = EnsureDB().active
    if not active then return nil end
    return active.steps[active.currentIndex]
end

function InCharacter.Roadmap.Store.Advance()
    local active = EnsureDB().active
    if not active then return end
    local cur = active.steps[active.currentIndex]
    if cur then
        cur.status = "done"
        InCharacter.Chronicle.Capture.AddEntry("ROADMAP", {
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
        InCharacter.Chronicle.Capture.AddEntry("ROADMAP", {
            stage = "arrive",
            title = "Road opens: " .. nextStep.name,
            roadmapName = active.name,
            zoneName = nextStep.name,
            lore = nextStep.lore,
        }, "auto")
        if InCharacter.UI and InCharacter.UI.Theme then
            InCharacter.UI.Theme.Toast("Next chapter: " .. nextStep.name)
        end
    else
        InCharacter.Roadmap.Store.Complete()
    end
    if InCharacter.Roadmap.UI and InCharacter.Roadmap.UI.Refresh then
        InCharacter.Roadmap.UI.Refresh()
    end
end

function InCharacter.Roadmap.Store.Complete()
    local db = EnsureDB()
    local active = db.active
    if not active then return end
    InCharacter.Chronicle.Capture.AddEntry("ROADMAP", {
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
    if InCharacter.UI and InCharacter.UI.Theme then
        InCharacter.UI.Theme.Toast("Expedition chart complete.")
    end
    if InCharacter.Roadmap.UI and InCharacter.Roadmap.UI.Refresh then
        InCharacter.Roadmap.UI.Refresh()
    end
end

function InCharacter.Roadmap.Store.Abandon()
    local db = EnsureDB()
    if not db.active then return end
    InCharacter.Chronicle.Capture.AddEntry("ROADMAP", {
        stage = "abandon",
        title = "Expedition abandoned: " .. (db.active.name or "path"),
        roadmapName = db.active.name,
    }, "manual")
    db.active = nil
    if InCharacter.Roadmap.UI and InCharacter.Roadmap.UI.Refresh then
        InCharacter.Roadmap.UI.Refresh()
    end
end

function InCharacter.Roadmap.Store.MarkLevelLock(level)
    local active = EnsureDB().active
    if not active then return end
    active.levelLockedAt = level
    local cur = active.steps[active.currentIndex]
    if cur then cur.status = "locked" end
    InCharacter.Chronicle.Capture.AddEntry("ROADMAP", {
        stage = "lock",
        title = string.format("Level lock at %d — lingering in %s", level, cur and cur.name or "the chapter"),
        roadmapName = active.name,
        zoneName = cur and cur.name or nil,
        lockLevel = level,
    }, "auto")
end