-- In Character Presence package bootstrap (runs after RequiredDeps: InCharacter)
InCharacter = InCharacter or {}

local function InitPresence()
    if InCharacter.BeaconHead and InCharacter.BeaconHead.Init then
        InCharacter.BeaconHead.Init()
    end
    if InCharacter.BeaconPins and InCharacter.BeaconPins.Init then
        InCharacter.BeaconPins.Init()
    end
    if InCharacter.Flyout and InCharacter.Flyout.Init then
        InCharacter.Flyout.Init()
    end
    if InCharacter.BoardView and InCharacter.BoardView.Init then
        InCharacter.BoardView.Init()
    end
    if InCharacter.PostEditor and InCharacter.PostEditor.Init then
        InCharacter.PostEditor.Init()
    end
end

if InCharacter.RegisterPackage then
    InCharacter.RegisterPackage("Presence", InitPresence)
else
    InitPresence()
end
