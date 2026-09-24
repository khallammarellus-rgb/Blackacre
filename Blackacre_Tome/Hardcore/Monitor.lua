Blackacre = Blackacre or {}
Blackacre.Hardcore = Blackacre.Hardcore or {}
Blackacre.Hardcore.Monitor = {}

-- Honor-system monitor: logs stains; does not enforce server rules.
local ALLOWED_BAG_SLOTS = 6
local REAGENT_BAG_ID = 5 -- retail reagent bag

local lastBagSignature = ""
local mountStainActive = false
local flyStainActive = false
local deathLock = false
local bagWait = false
local mountWait = false
local mountTicker

local function EnsureHardcoreDB()
    Blackacre.CharDB.hardcore = Blackacre.CharDB.hardcore or {
        deathCount = 0,
        lastDeathAt = nil,
        encumbranceActive = false,
        mountViolations = 0,
        flyViolations = 0,
        encumbranceViolations = 0,
    }
    Blackacre.CharDB.gate = Blackacre.CharDB.gate or { ground = false, flying = false }
    return Blackacre.CharDB.hardcore
end

function Blackacre.Hardcore.GetStatus()
    local hc = EnsureHardcoreDB()
    local gate = Blackacre.CharDB.gate
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
    Blackacre.Chronicle.Capture.AddEntry("HC_ENCUMBRANCE", {
        bagDetail = table.concat(offenders, ", "),
        title = "Encumbrance: oversized packs",
    }, "auto")
end

local function IsPlayerFlying()
    if Blackacre.Compat and Blackacre.Compat.HasPlayerFlying and not Blackacre.Compat.HasPlayerFlying() then
        return false
    end
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
    local gate = Blackacre.CharDB.gate
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
                Blackacre.Chronicle.Capture.AddEntry("HC_FLY", {
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
                Blackacre.Chronicle.Capture.AddEntry("HC_MOUNT", {
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
    local zone = Blackacre.GetZoneContext()
    Blackacre.Chronicle.Capture.AddEntry("DEATH", {
        zoneName = zone.zoneName,
        deathIndex = hc.deathCount,
        title = "Death #" .. tostring(hc.deathCount) .. " - " .. (zone.zoneName or "unknown"),
    }, "auto")
    if Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.Toast then
        Blackacre.UI.Theme.Toast("Death #" .. tostring(hc.deathCount) .. " in " .. (zone.zoneName or "unknown"), "maw")
    end
    if Blackacre.Hardcore.UI and Blackacre.Hardcore.UI.Refresh then
        Blackacre.Hardcore.UI.Refresh()
    end
    if Blackacre.Afterlife and Blackacre.Afterlife.PathTracker then
        Blackacre.Afterlife.PathTracker.OnDeath()
    end
    C_Timer.After(5, function()
        deathLock = false
    end)
end

local function StopMountWatch()
    if mountTicker then
        mountTicker:Cancel()
        mountTicker = nil
    end
end

local function StartMountWatch()
    if mountTicker then return end
    -- Only while mounted. Takeoff can happen after the mount event; idle players are not polled.
    -- Forever has no player flight (Compat.HasPlayerFlying); this watch is a no-op there until you mount.
    mountTicker = C_Timer.NewTicker(3, function()
        if not (IsMounted and IsMounted()) then
            mountStainActive = false
            flyStainActive = false
            StopMountWatch()
            return
        end
        CheckMount()
    end)
end

local function ScheduleBags()
    if bagWait then return end
    bagWait = true
    C_Timer.After(0.35, function()
        bagWait = false
        CheckBags()
    end)
end

local function ScheduleMount()
    if mountWait then return end
    mountWait = true
    C_Timer.After(0.2, function()
        mountWait = false
        CheckMount()
        if IsMounted and IsMounted() then
            StartMountWatch()
        else
            StopMountWatch()
        end
    end)
end

function Blackacre.Hardcore.Monitor.Init()
    EnsureHardcoreDB()
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    frame:RegisterEvent("PLAYER_DEAD")
    frame:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
    -- UNIT_AURA on the player fires all through combat and was scheduling a timer per aura.
    -- Mount display (and the while-mounted watch) is enough for the ground/sky rite.
    if not pcall(frame.RegisterEvent, frame, "BAG_UPDATE_DELAYED") then
        frame:RegisterEvent("BAG_UPDATE")
    end
    frame:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_DEAD" then
            OnDeath()
            return
        end
        if event == "BAG_UPDATE_DELAYED" or event == "BAG_UPDATE" or event == "PLAYER_EQUIPMENT_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
            ScheduleBags()
        end
        if event == "PLAYER_MOUNT_DISPLAY_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
            ScheduleMount()
        end
    end)
end

function Blackacre.Hardcore.SetGroundGate(complete)
    Blackacre.CharDB.gate.ground = complete and true or false
    mountStainActive = false
    if Blackacre.Hardcore.UI and Blackacre.Hardcore.UI.Refresh then
        Blackacre.Hardcore.UI.Refresh()
    end
end

function Blackacre.Hardcore.SetFlyingGate(complete)
    Blackacre.CharDB.gate.flying = complete and true or false
    flyStainActive = false
    if Blackacre.Hardcore.UI and Blackacre.Hardcore.UI.Refresh then
        Blackacre.Hardcore.UI.Refresh()
    end
end