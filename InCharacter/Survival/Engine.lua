InCharacter = InCharacter or {}
InCharacter.Survival = InCharacter.Survival or {}
InCharacter.Survival.Engine = {}

local TICK_SEC = 12
local CRITICAL = 15
local COLLAPSE = 5

local lastCriticalToast = { hunger = 0, thirst = 0, exposure = 0 }
local lastCriticalLog = { hunger = 0, thirst = 0, exposure = 0 }
local CRITICAL_COOLDOWN = 180

local function EnsureDB()
    InCharacter.CharDB.survival = InCharacter.CharDB.survival or {
        enabled = true,
        hunger = 85,
        thirst = 85,
        exposure = 90,
        lastTick = time(),
        hideMeters = false,
    }
    local s = InCharacter.CharDB.survival
    s.hunger = s.hunger or 85
    s.thirst = s.thirst or 85
    s.exposure = s.exposure or 90
    if s.enabled == nil then s.enabled = true end
    return s
end

local function Clamp(v)
    if v < 0 then return 0 end
    if v > 100 then return 100 end
    return v
end

function InCharacter.Survival.GetState()
    local s = EnsureDB()
    local zone = InCharacter.GetZoneContext()
    local climate = InCharacter.ZoneClimate.GetProfile(zone.zoneId, zone.zoneName)
    return {
        enabled = s.enabled,
        hunger = s.hunger,
        thirst = s.thirst,
        exposure = s.exposure,
        climate = climate,
        zoneName = zone.zoneName,
        indoors = IsIndoors and IsIndoors() or false,
        resting = IsResting and IsResting() or false,
        inCombat = UnitAffectingCombat and UnitAffectingCombat("player") or false,
        hideMeters = s.hideMeters,
    }
end

local function MaybeWarn(meter, value)
    local now = time()
    if value > CRITICAL then return end
    if now - (lastCriticalToast[meter] or 0) < 60 then return end
    lastCriticalToast[meter] = now
    local labels = { hunger = "Hunger", thirst = "Thirst", exposure = "Exposure" }
    local msg = string.format("%s grows dire (%d).", labels[meter] or meter, math.floor(value))
    if InCharacter.UI and InCharacter.UI.Theme and InCharacter.UI.Theme.Toast then
        InCharacter.UI.Theme.Toast(msg)
    else
        InCharacter.Print(msg)
    end

    if value <= COLLAPSE and (now - (lastCriticalLog[meter] or 0) >= CRITICAL_COOLDOWN) then
        lastCriticalLog[meter] = now
        if InCharacter.Chronicle and InCharacter.Chronicle.Capture then
            InCharacter.Chronicle.Capture.AddEntry("SURVIVAL", {
                meter = meter,
                value = value,
                title = (labels[meter] or meter) .. " critical",
            }, "auto")
        end
    end
end

function InCharacter.Survival.Engine.Tick()
    local s = EnsureDB()
    if not s.enabled then return end

    local zone = InCharacter.GetZoneContext()
    local climate = InCharacter.ZoneClimate.GetProfile(zone.zoneId, zone.zoneName)
    local indoors = IsIndoors and IsIndoors()
    local resting = IsResting and IsResting()
    local combat = UnitAffectingCombat and UnitAffectingCombat("player")

    -- Base decay per tick (scaled by climate)
    local hungerLoss = 0.8 + climate.hunger * 1.4
    local thirstLoss = 0.9 + climate.thirst * 1.6
    local exposureLoss = 0.3 + climate.exposure * 1.8

    if combat then
        hungerLoss = hungerLoss * 1.5
        thirstLoss = thirstLoss * 1.4
    end
    if indoors then
        exposureLoss = exposureLoss * 0.25
        thirstLoss = thirstLoss * 0.85
    end
    if resting then
        hungerLoss = hungerLoss * 0.5
        thirstLoss = thirstLoss * 0.5
        exposureLoss = exposureLoss * 0.4
        -- Slow natural recovery while resting in civilized shelter
        s.hunger = Clamp(s.hunger + 0.4)
        s.thirst = Clamp(s.thirst + 0.5)
        s.exposure = Clamp(s.exposure + 0.8)
    end

    s.hunger = Clamp(s.hunger - hungerLoss)
    s.thirst = Clamp(s.thirst - thirstLoss)
    s.exposure = Clamp(s.exposure - exposureLoss)
    s.lastTick = time()

    MaybeWarn("hunger", s.hunger)
    MaybeWarn("thirst", s.thirst)
    MaybeWarn("exposure", s.exposure)

    if InCharacter.Survival.UI and InCharacter.Survival.UI.Refresh then
        InCharacter.Survival.UI.Refresh()
    end
end

local function SoftToast(msg)
    if InCharacter.UI and InCharacter.UI.Theme and InCharacter.UI.Theme.Toast then
        InCharacter.UI.Theme.Toast(msg)
    else
        InCharacter.Print(msg)
    end
end

function InCharacter.Survival.Engine.Recover(kind, amount)
    local s = EnsureDB()
    amount = amount or 20
    if kind == "hunger" or kind == "eat" then
        s.hunger = Clamp(s.hunger + amount)
        SoftToast("You take food and feel steadier.")
    elseif kind == "thirst" or kind == "drink" then
        s.thirst = Clamp(s.thirst + amount)
        SoftToast("You drink deep; the dust of the road fades.")
    elseif kind == "exposure" or kind == "rest" then
        s.exposure = Clamp(s.exposure + amount)
        s.hunger = Clamp(s.hunger + amount * 0.25)
        s.thirst = Clamp(s.thirst + amount * 0.25)
        SoftToast("You rest and warm yourself against the world.")
    elseif kind == "full" then
        s.hunger = Clamp(s.hunger + amount)
        s.thirst = Clamp(s.thirst + amount)
        s.exposure = Clamp(s.exposure + amount)
    end
    if InCharacter.Survival.UI and InCharacter.Survival.UI.Refresh then
        InCharacter.Survival.UI.Refresh()
    end
end

function InCharacter.Survival.Engine.SetEnabled(on)
    EnsureDB().enabled = on and true or false
    if InCharacter.Survival.UI and InCharacter.Survival.UI.Refresh then
        InCharacter.Survival.UI.Refresh()
    end
end

function InCharacter.Survival.Engine.Init()
    EnsureDB()
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("ZONE_CHANGED")
    frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    frame:RegisterEvent("ZONE_CHANGED_INDOORS")
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:RegisterUnitEvent("UNIT_AURA", "player")
    frame:SetScript("OnEvent", function(_, event)
        if event == "UNIT_AURA" then
            -- Well Fed / Drink style recovery (best-effort via aura names)
            for i = 1, 40 do
                local aura = C_UnitAuras and C_UnitAuras.GetAuraDataByIndex and C_UnitAuras.GetAuraDataByIndex("player", i, "HELPFUL")
                if not aura then break end
                local name = aura.name or ""
                local lower = name:lower()
                if lower:find("well fed", 1, true) or lower:find("food", 1, true) then
                    -- light passive top-up while buffed; throttle via last food tick
                    local s = EnsureDB()
                    s._foodBuff = true
                elseif lower:find("drink", 1, true) or lower:find("refreshment", 1, true) then
                    local s = EnsureDB()
                    s._drinkBuff = true
                end
            end
        else
            if InCharacter.Survival.UI and InCharacter.Survival.UI.Refresh then
                InCharacter.Survival.UI.Refresh()
            end
        end
    end)

    C_Timer.NewTicker(TICK_SEC, function()
        local s = EnsureDB()
        if s._foodBuff then
            s.hunger = Clamp(s.hunger + 1.5)
            s._foodBuff = false
        end
        if s._drinkBuff then
            s.thirst = Clamp(s.thirst + 1.5)
            s._drinkBuff = false
        end
        InCharacter.Survival.Engine.Tick()
    end)
end