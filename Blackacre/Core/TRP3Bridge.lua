Blackacre = Blackacre or {}
Blackacre.TRP3Bridge = {}

function Blackacre.TRP3Bridge.IsAvailable()
    return TRP3_API ~= nil and TRP3_API.profile ~= nil
end

function Blackacre.TRP3Bridge.GetProfileDefaults()
    if not Blackacre.TRP3Bridge.IsAvailable() then
        return nil
    end
    local profile = TRP3_API.profile.getPlayerCurrentProfile()
    if not profile or not profile.player then
        return nil
    end
    local chars = profile.player.characteristics or {}
    local info = profile.player.about or {}
    return {
        charName = chars.FN or UnitName("player"),
        race = chars.RA or "",
        class = chars.CL or "",
        title = chars.TI or "",
        residence = Blackacre.CharDB.residence or "",
    }
end

function Blackacre.TRP3Bridge.GetCharacterName()
    local defaults = Blackacre.TRP3Bridge.GetProfileDefaults()
    return defaults and defaults.charName or UnitName("player")
end

function Blackacre.TRP3Bridge.RememberResidence(value)
    if value and value ~= "" then
        Blackacre.CharDB.residence = value
    end
end