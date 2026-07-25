-- In Character Survival package bootstrap
InCharacter = InCharacter or {}

local function InitSurvival()
    if InCharacter.Survival then
        if InCharacter.Survival.Engine and InCharacter.Survival.Engine.Init then
            InCharacter.Survival.Engine.Init()
        end
        if InCharacter.Survival.UI and InCharacter.Survival.UI.Init then
            InCharacter.Survival.UI.Init()
        end
    end
end

if InCharacter.RegisterPackage then
    InCharacter.RegisterPackage("Survival", InitSurvival)
else
    InitSurvival()
end
