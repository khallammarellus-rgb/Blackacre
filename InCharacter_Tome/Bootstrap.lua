-- In Character Tome package bootstrap
InCharacter = InCharacter or {}

local function InitTome()
    InCharacter.CharDB = InCharacter.CharDB or {}
    InCharacter.CharDB.voice = InCharacter.CharDB.voice or {
        accent = "auto",
        applyToChronicle = true,
        applyToBulletins = false,
    }
    InCharacter.CharDB.setup = InCharacter.CharDB.setup or {
        completed = false,
        version = 1,
    }

    if InCharacter.YearCalendar and InCharacter.YearCalendar.EnsureIdentity then
        InCharacter.YearCalendar.EnsureIdentity()
    end
    if InCharacter.TomeHub and InCharacter.TomeHub.Init then
        InCharacter.TomeHub.Init()
    end
    if InCharacter.Chronicle then
        if InCharacter.Chronicle.Store and InCharacter.Chronicle.Store.Init then
            InCharacter.Chronicle.Store.Init()
        end
        if InCharacter.Chronicle.Capture and InCharacter.Chronicle.Capture.Init then
            InCharacter.Chronicle.Capture.Init()
        end
        if InCharacter.Chronicle.UI and InCharacter.Chronicle.UI.Init then
            InCharacter.Chronicle.UI.Init()
        end
    end
    if InCharacter.Hardcore then
        if InCharacter.Hardcore.Monitor and InCharacter.Hardcore.Monitor.Init then
            InCharacter.Hardcore.Monitor.Init()
        end
        if InCharacter.Hardcore.UI and InCharacter.Hardcore.UI.Init then
            InCharacter.Hardcore.UI.Init()
        end
    end
    if InCharacter.Afterlife then
        if InCharacter.Afterlife.PathTracker and InCharacter.Afterlife.PathTracker.Init then
            InCharacter.Afterlife.PathTracker.Init()
        end
        if InCharacter.Afterlife.UI and InCharacter.Afterlife.UI.Init then
            InCharacter.Afterlife.UI.Init()
        end
    end
    if InCharacter.Roadmap then
        if InCharacter.Roadmap.Store and InCharacter.Roadmap.Store.Init then
            InCharacter.Roadmap.Store.Init()
        end
        if InCharacter.Roadmap.Engine and InCharacter.Roadmap.Engine.Init then
            InCharacter.Roadmap.Engine.Init()
        end
        if InCharacter.Roadmap.UI and InCharacter.Roadmap.UI.Init then
            InCharacter.Roadmap.UI.Init()
        end
    end
    if InCharacter.PvP and InCharacter.PvP.AfterAction and InCharacter.PvP.AfterAction.Init then
        InCharacter.PvP.AfterAction.Init()
    end
    if InCharacter.LineageUI and InCharacter.LineageUI.Init then
        InCharacter.LineageUI.Init()
    end
    if InCharacter.SetupWizard and InCharacter.SetupWizard.Init then
        InCharacter.SetupWizard.Init()
    end
end

if InCharacter.RegisterPackage then
    InCharacter.RegisterPackage("Tome", InitTome)
else
    InitTome()
end
