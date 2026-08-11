-- Blackacre Tome package bootstrap
Blackacre = Blackacre or {}

local function InitTome()
    Blackacre.CharDB = Blackacre.CharDB or {}
    Blackacre.CharDB.voice = Blackacre.CharDB.voice or {
        accent = "auto",
        applyToChronicle = true,
        applyToBulletins = false,
    }
    Blackacre.CharDB.setup = Blackacre.CharDB.setup or {
        completed = false,
        version = 1,
    }

    if Blackacre.YearCalendar and Blackacre.YearCalendar.EnsureIdentity then
        Blackacre.YearCalendar.EnsureIdentity()
    end
    if Blackacre.TomeHub and Blackacre.TomeHub.Init then
        Blackacre.TomeHub.Init()
    end
    if Blackacre.Chronicle then
        if Blackacre.Chronicle.Store and Blackacre.Chronicle.Store.Init then
            Blackacre.Chronicle.Store.Init()
        end
        if Blackacre.Chronicle.Capture and Blackacre.Chronicle.Capture.Init then
            Blackacre.Chronicle.Capture.Init()
        end
        if Blackacre.Chronicle.UI and Blackacre.Chronicle.UI.Init then
            Blackacre.Chronicle.UI.Init()
        end
    end
    if Blackacre.Hardcore then
        if Blackacre.Hardcore.Monitor and Blackacre.Hardcore.Monitor.Init then
            Blackacre.Hardcore.Monitor.Init()
        end
        if Blackacre.Hardcore.UI and Blackacre.Hardcore.UI.Init then
            Blackacre.Hardcore.UI.Init()
        end
    end
    if Blackacre.Afterlife then
        if Blackacre.Afterlife.PathTracker and Blackacre.Afterlife.PathTracker.Init then
            Blackacre.Afterlife.PathTracker.Init()
        end
        if Blackacre.Afterlife.UI and Blackacre.Afterlife.UI.Init then
            Blackacre.Afterlife.UI.Init()
        end
    end
    if Blackacre.Roadmap then
        if Blackacre.Roadmap.Store and Blackacre.Roadmap.Store.Init then
            Blackacre.Roadmap.Store.Init()
        end
        if Blackacre.Roadmap.Engine and Blackacre.Roadmap.Engine.Init then
            Blackacre.Roadmap.Engine.Init()
        end
        if Blackacre.Roadmap.UI and Blackacre.Roadmap.UI.Init then
            Blackacre.Roadmap.UI.Init()
        end
    end
    if Blackacre.PvP and Blackacre.PvP.AfterAction and Blackacre.PvP.AfterAction.Init then
        Blackacre.PvP.AfterAction.Init()
    end
    if Blackacre.LineageUI and Blackacre.LineageUI.Init then
        Blackacre.LineageUI.Init()
    end
    if Blackacre.SetupWizard and Blackacre.SetupWizard.Init then
        Blackacre.SetupWizard.Init()
    end
end

if Blackacre.RegisterPackage then
    Blackacre.RegisterPackage("Tome", InitTome)
else
    InitTome()
end
