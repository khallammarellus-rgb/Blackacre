InCharacter = InCharacter or {}
InCharacter.Hardcore = InCharacter.Hardcore or {}
InCharacter.Hardcore.Monitor = {}

-- Honor-system monitor: logs stains; does not enforce server rules.
local ALLOWED_BAG_SLOTS = 6
local REAGENT_BAG_ID = 5 -- retail reagent bag

local lastBagSignature = ""
local mountStainActive = false
local flyStainActive = false
local deathLock = false

local function EnsureHardcoreDB()
    InCharacter.CharDB.hardcore = InCharacter.CharDB.hardcore or {
        deathCount = 0,
        lastDeathAt = nil,
        encumbranceActive = false,
        mountViolations = 0,
        flyViolations = 0,
        encumbranceViolations = 0,
    }
    InCharacter.CharDB.gate = InCharacter.CharDB.gate or { ground = false, flying = false }
    return InCharacter.CharDB.hardcore
end

function InCharacter.Hardcore.GetStatus()
    local hc = EnsureHardcoreDB()
    local gate = InCharacter.CharDB.gate
    return {
        deathCount = hc.deathCount or 0,
        encumbranceActive = hc.encumbranceActive and true or false,
        mountViolations = hc.mountViolations or 0,
        flyViolations = hc.flyViolations or 0,
        encumbranceViolations = hc.encumbranceViolations or 0,
        groundGate = gate.ground and true or false,
        flyingGate = gate.flying and true or false,
        clean = (hc.deathCount or 0) == 0
            and not hc.encumbranceActive
            and (hc.mountViolations or 0) == 0
            and (hc.flyViolations or 0) == 0,
    }
end

local function GetBagNumSlots(bagId)
    if C_Container and C_Container.GetContainerNumSlots then
        return C_Container.GetContainerNumSlots(bagId) or 0
    end
    if GetContainerNumSlots then
        return GetContainerNumSlots(bagId) or 0
    end
    return 0
end

local function ScanBags()
    local offenders = {}
    -- 1-4 equipped bags (0 = backpack, usually 16; we only judge worn bags 1-4)
    for bagId = 1, 4 do
        local slots = GetBagNumSlots(bagId)
        if slots > 0 and slots ~= ALLOWED_BAG_SLOTS then
            offenders[#offenders + 1] = string.format("bag %d (%d slots)", bagId, slots)
        end
    end
    -- Explicitly skip reagent bag (5)
    return offenders
end

local function CheckBags()
    local hc = EnsureHardcoreDB()
    local offenders = ScanBags()
    local signature = table.concat(offenders, "|")
    if signature == lastBagSignature then
        return
    end
    lastBagSignature = signature

    if #offenders == 0 then
        hc.encumbranceActive = false
        return
    end

    hc.encumbranceActive = true
    -- Log only when signature newly becomes non-empty or changes set of offenders
    hc.encumbranceViolations = (hc.encumbranceViolations or 0) + 1
    InCharacter.Chronicle.Capture.AddEntry("HC_ENCUMBRANCE", {
        bagDetail = table.concat(offenders, ", "),
        title = "Encumbrance: oversized packs",
    }, "auto")
end

local function IsPlayerFlying()
    if IsFlying and IsFlying() then
        return true
    end
    if IsFlyableArea and IsMounted and IsMounted() and IsFlyableArea() then
        -- Fallback: mounted in flyable area while airborne is hard to detect without IsFlying
        return false
    end
    return false
end

local function CheckMount()
    local hc = EnsureHardcoreDB()
    local gate = InCharacter.CharDB.gate
    if not IsMounted or not IsMounted() then
        mountStainActive = false
        flyStainActive = false
        return
    end

    local flying = IsPlayerFlying()
    if flying then
        if not gate.flying then
            if not flyStainActive then
                flyStainActive = true
                hc.flyViolations = (hc.flyViolations or 0) + 1
                InCharacter.Chronicle.Capture.AddEntry("HC_FLY", {
                    title = "Flew without sky rite",
                }, "auto")
            end
        else
            flyStainActive = false
        end
    else
        flyStainActive = false
        if not gate.ground then
            if not mountStainActive then
                mountStainActive = true
                hc.mountViolations = (hc.mountViolations or 0) + 1
                InCharacter.Chronicle.Capture.AddEntry("HC_MOUNT", {
                    title = "Mounted without ground rite",
                }, "auto")
            end
        else
            mountStainActive = false
        end
    end
end

local function OnDeath()
    if deathLock then return end
    deathLock = true
    local hc = EnsureHardcoreDB()
    hc.deathCount = (hc.deathCount or 0) + 1
    hc.lastDeathAt = time()
    local zone = InCharacter.GetZoneContext()
    InCharacter.Chronicle.Capture.AddEntry("DEATH", {
        zoneName = zone.zoneName,
        deathIndex = hc.deathCount,
        title = "Death #" .. tostring(hc.deathCount) .. " — " .. (zone.zoneName or "unknown"),
    }, "auto")
    if InCharacter.Hardcore.UI and InCharacter.Hardcore.UI.Refresh then
        InCharacter.Hardcore.UI.Refresh()
    end
    if InCharacter.Afterlife and InCharacter.Afterlife.PathTracker then
        InCharacter.Afterlife.PathTracker.OnDeath()
    end
    C_Timer.After(5, function()
        deathLock = false
    end)
end

function InCharacter.Hardcore.Monitor.Init()
    EnsureHardcoreDB()
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("BAG_UPDATE")
    frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    frame:RegisterEvent("PLAYER_DEAD")
    frame:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
    frame:RegisterUnitEvent("UNIT_AURA", "player")
    frame:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_DEAD" then
            OnDeath()
        elseif event == "BAG_UPDATE" or event == "PLAYER_EQUIPMENT_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
            C_Timer.After(0.3, CheckBags)
        end
        if event == "PLAYER_MOUNT_DISPLAY_CHANGED" or event == "UNIT_AURA" or event == "PLAYER_ENTERING_WORLD" then
            C_Timer.After(0.2, CheckMount)
        end
    end)
    C_Timer.NewTicker(3, function()
        if IsMounted and IsMounted() then
            CheckMount()
        end
    end)
end

function InCharacter.Hardcore.SetGroundGate(complete)
    InCharacter.CharDB.gate.ground = complete and true or false
    mountStainActive = false
    if InCharacter.Hardcore.UI and InCharacter.Hardcore.UI.Refresh then
        InCharacter.Hardcore.UI.Refresh()
    end
end

function InCharacter.Hardcore.SetFlyingGate(complete)
    InCharacter.CharDB.gate.flying = complete and true or false
    flyStainActive = false
    if InCharacter.Hardcore.UI and InCharacter.Hardcore.UI.Refresh then
        InCharacter.Hardcore.UI.Refresh()
    end
end