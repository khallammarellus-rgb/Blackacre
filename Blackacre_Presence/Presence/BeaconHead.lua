Blackacre = Blackacre or {}
Blackacre.BeaconHead = {}

-- Crumb delivery. Talking-head is abandoned; Found uses toast.

local SAY_YARDS = 20
local YELL_YARDS = 40
local SWITCH_COOLDOWN = 10 * 60

local localFrame

local function MapDistanceYards(ax, ay, bx, by)
    local dx = ((ax or 0) - (bx or 0)) * 1000
    local dy = ((ay or 0) - (by or 0)) * 1000
    return math.sqrt(dx * dx + dy * dy)
end

local function HeardDB()
    local p = Blackacre.Lifecycle.EnsurePresenceDB()
    p.heardBeacons = p.heardBeacons or {}
    return p.heardBeacons
end

local function SystemMsg(text)
    if not text or text == "" then return end
    local chat = DEFAULT_CHAT_FRAME
    if chat then
        chat:AddMessage("|cffc9a227Rumor:|r " .. text, 1, 0.82, 0)
    end
end

local function EnsureLocalFrame()
    if localFrame then return localFrame end
    local f = CreateFrame("Frame", "BlackacreLocalCrumb", UIParent, "BackdropTemplate")
    f:SetSize(420, 90)
    f:SetPoint("TOP", 0, -80)
    f:SetFrameStrata("DIALOG")
    if Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.ApplyParchmentBackdrop then
        Blackacre.UI.Theme.ApplyParchmentBackdrop(f, 0.95)
    end
    f.who = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.who:SetPoint("TOPLEFT", 14, -10)
    f.who:SetText("A local says")
    if Blackacre.UI and Blackacre.UI.Theme then Blackacre.UI.Theme.GoldTitle(f.who) end
    f.body = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.body:SetPoint("TOPLEFT", 14, -32)
    f.body:SetPoint("BOTTOMRIGHT", -14, 12)
    f.body:SetJustifyH("LEFT")
    f.body:SetJustifyV("TOP")
    f:Hide()
    localFrame = f
    return f
end

local function ShowLocal(text)
    if not text or text == "" then return end
    local f = EnsureLocalFrame()
    f.body:SetText(text)
    f:Show()
    C_Timer.After(8, function()
        if f:IsShown() then f:Hide() end
    end)
end

local function ShowFound(text)
    if not text or text == "" then return end
    if Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.Toast then
        Blackacre.UI.Theme.Toast(text)
    else
        Blackacre.Print(text)
    end
    if Minimap and Minimap.PingLocation then
        pcall(function() Minimap:PingLocation(0, 0) end)
    end
end

local function SameSubzone(beacon)
    local ctx = Blackacre.GetZoneContext()
    local a = (ctx.subzone or ""):lower()
    local b = (beacon.subzone or ""):lower()
    if a == "" and b == "" then
        return (ctx.zoneName or ""):lower() == (beacon.zoneName or ""):lower()
    end
    return a ~= "" and a == b
end

function Blackacre.BeaconHead.Deliver(beacon)
    if not beacon then return end
    local p = Blackacre.Lifecycle.EnsurePresenceDB()
    if p.seekingEnabled == false then return end
    if beacon.ownerGUID == UnitGUID("player") then return end

    local heard = HeardDB()
    local rec = heard[beacon.ownerGUID]
    local now = time()
    if rec and rec.id ~= beacon.id and rec.at and (now - rec.at) < SWITCH_COOLDOWN then
        return
    end
    if not rec or rec.id ~= beacon.id then
        rec = { id = beacon.id, rumor = false, lead = false, found = false, at = now }
        heard[beacon.ownerGUID] = rec
    end

    local ctx = Blackacre.GetZoneContext()
    local d = MapDistanceYards(
        ctx.coords and ctx.coords.x or 0,
        ctx.coords and ctx.coords.y or 0,
        beacon.coords and beacon.coords.x or 0,
        beacon.coords and beacon.coords.y or 0
    )

    if not rec.found and d <= SAY_YARDS and beacon.found and beacon.found ~= "" then
        rec.found = true
        rec.lead = true
        rec.rumor = true
        rec.at = now
        ShowFound(beacon.found)
        return
    end
    if not rec.lead and d <= YELL_YARDS and beacon.lead and beacon.lead ~= "" then
        rec.lead = true
        rec.rumor = true
        rec.at = now
        ShowLocal(beacon.lead)
        return
    end
    if not rec.rumor and SameSubzone(beacon) and beacon.rumor and beacon.rumor ~= "" then
        rec.rumor = true
        rec.at = now
        SystemMsg(beacon.rumor)
    end
end

function Blackacre.BeaconHead.OnCacheChanged(beacon)
    if beacon then
        Blackacre.BeaconHead.Deliver(beacon)
        return
    end
    local store = BlackacreDB and BlackacreDB.beacons
    if not store then return end
    local now = time()
    local mine = UnitGUID("player")
    for _, b in pairs(store) do
        if (not b.expiresAt or b.expiresAt >= now) and b.ownerGUID ~= mine then
            Blackacre.BeaconHead.Deliver(b)
        end
    end
end

function Blackacre.BeaconHead.Init()
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:RegisterEvent("ZONE_CHANGED")
    f:RegisterEvent("ZONE_CHANGED_INDOORS")
    f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    f:SetScript("OnEvent", function()
        C_Timer.After(0.3, Blackacre.BeaconHead.OnCacheChanged)
    end)
    if Blackacre.OnPlayerMove then
        Blackacre.OnPlayerMove(Blackacre.BeaconHead.OnCacheChanged)
    end
end
