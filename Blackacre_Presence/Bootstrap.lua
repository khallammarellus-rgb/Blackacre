-- Blackacre Presence package bootstrap (runs after RequiredDeps: Blackacre)
Blackacre = Blackacre or {}

local function InitPresence()
    if Blackacre.BeaconHead and Blackacre.BeaconHead.Init then
        Blackacre.BeaconHead.Init()
    end
    if Blackacre.BeaconPins and Blackacre.BeaconPins.Init then
        Blackacre.BeaconPins.Init()
    end
    if Blackacre.Flyout and Blackacre.Flyout.Init then
        Blackacre.Flyout.Init()
    end
    if Blackacre.BoardView and Blackacre.BoardView.Init then
        Blackacre.BoardView.Init()
    end
    if Blackacre.PostEditor and Blackacre.PostEditor.Init then
        Blackacre.PostEditor.Init()
    end
end

if Blackacre.RegisterPackage then
    Blackacre.RegisterPackage("Presence", InitPresence)
else
    InitPresence()
end
