Blackacre = Blackacre or {}
Blackacre.BeaconHead = {}

local frame
local model
local text
local lastRollAt = 0
local rollIndex = 1
local animToken = 0

local function Cfg()
    return Blackacre.BeaconConfig or {
        ROLL_INTERVAL = 240,
        MIN_ROLL_GAP = 60,
        HEAD_HOLD = 5,
        YELL_RANGE_YARDS = 40,
    }
end

local function ReceiveEnabled()
    local p = Blackacre.Lifecycle and Blackacre.Lifecycle.EnsurePresenceDB and Blackacre.Lifecycle.EnsurePresenceDB()
    if p and p.receiveBeacons == false then return false end
    return true
end

local function MapDistanceYards(ax, ay, bx, by)
    -- Rough: treat full map as ~1000 yards (good enough for yell-ish proximity)
    local dx = (ax - bx) * 1000
    local dy = (ay - by) * 1000
    return math.sqrt(dx * dx + dy * dy)
end

local function IsNear(beacon)
    local ctx = Blackacre.GetZoneContext()
    if not ctx.coords or not beacon.coords then return false end
    local d = MapDistanceYards(ctx.coords.x, ctx.coords.y, beacon.coords.x or 0, beacon.coords.y or 0)
    local range = Cfg().YELL_RANGE_YARDS or 40
    return d <= range
end

local function ResolveUnitToken(beacon)
    if not beacon then return nil end
    local name = beacon.charName or beacon.senderName
    if not name or name == "" then return nil end
    if UnitExists("target") and UnitName("target") == name then return "target" end
    if UnitExists("mouseover") and UnitName("mouseover") == name then return "mouseover" end
    if UnitExists("focus") and UnitName("focus") == name then return "focus" end
    for i = 1, 40 do
        local u = "nameplate" .. i
        if UnitExists(u) and UnitName(u) == name then return u end
    end
    return nil
end

local function ZoneBeacons()
    local list = {}
    local ctx = Blackacre.GetZoneContext()
    local now = time()
    local myGuid = UnitGUID("player")
    for _, b in pairs(BlackacreDB.beacons or {}) do
        if b.ownerGUID ~= myGuid
            and b.zoneId == ctx.zoneId
            and (not b.expiresAt or b.expiresAt >= now) then
            list[#list + 1] = b
        end
    end
    table.sort(list, function(a, b)
        return (a.receivedAt or 0) > (b.receivedAt or 0)
    end)
    return list
end

local function SetHoodModel()
    if not model then return end
    model:ClearModel()
    local ids = Blackacre.BeaconHoodDisplayIDs or { 10044 }
    for _, id in ipairs(ids) do
        model:SetDisplayInfo(id)
        if model:GetModelFileID() and model:GetModelFileID() ~= 0 then
            break
        end
    end
    model:SetCamera(0)
    model:SetPosition(0, 0, 0)
end

local function SetPlayerModel(beacon)
    if not model then return false end
    local unit = ResolveUnitToken(beacon)
    if unit then
        model:ClearModel()
        model:SetUnit(unit)
        model:SetCamera(0)
        return true
    end
    return false
end

local function EnsureFrame()
    if frame then return end
    frame = CreateFrame("Frame", "BlackacreBeaconHead", UIParent, "BackdropTemplate")
    frame:SetSize(320, 72)
    frame:SetPoint("TOP", UIParent, "TOP", 0, -80)
    frame:SetFrameStrata("HIGH")
    frame:EnableMouse(false)
    frame:SetAlpha(0)
    frame:Hide()
    if Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.ApplyParchmentBackdrop then
        Blackacre.UI.Theme.ApplyParchmentBackdrop(frame, 0.92)
    else
        frame:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 },
        })
        frame:SetBackdropColor(0, 0, 0, 0.7)
    end

    model = CreateFrame("PlayerModel", nil, frame)
    model:SetSize(56, 56)
    model:SetPoint("LEFT", 8, 0)
    model:EnableMouse(false)

    text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    text:SetPoint("TOPLEFT", model, "TOPRIGHT", 10, -8)
    text:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 8)
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    text:SetWordWrap(true)
    if Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.InkFont then
        Blackacre.UI.Theme.InkFont(text)
    end
end

local function FadeTo(targetAlpha, duration, onDone)
    animToken = animToken + 1
    local token = animToken
    local start = frame:GetAlpha()
    local elapsed = 0
    frame:SetScript("OnUpdate", function(self, dt)
        if token ~= animToken then return end
        elapsed = elapsed + dt
        local t = duration > 0 and math.min(1, elapsed / duration) or 1
        self:SetAlpha(start + (targetAlpha - start) * t)
        if t >= 1 then
            self:SetScript("OnUpdate", nil)
            if onDone then onDone() end
        end
    end)
end

function Blackacre.BeaconHead.ShowBeacon(beacon)
    if not ReceiveEnabled() or not beacon then return end
    EnsureFrame()
    local crumb = beacon.breadcrumb or beacon.shortText or "A presence stirs nearby."
    text:SetText(crumb)

    local near = IsNear(beacon)
    local showPlayer = near and (beacon.showNameProximity or beacon.showNameZone)
        and beacon.charName and beacon.charName ~= ""
    local usedPlayer = false
    if showPlayer then
        usedPlayer = SetPlayerModel(beacon)
    end
    if not usedPlayer then
        SetHoodModel()
    end

    frame:Show()
    frame:SetAlpha(0)
    lastRollAt = time()
    FadeTo(1, 0.45, function()
        C_Timer.After(Cfg().HEAD_HOLD or 5, function()
            if frame and frame:IsShown() then
                FadeTo(0, 0.6, function()
                    frame:Hide()
                end)
            end
        end)
    end)
end

function Blackacre.BeaconHead.RollNext()
    if not ReceiveEnabled() then return end
    local now = time()
    if now - lastRollAt < (Cfg().MIN_ROLL_GAP or 60) then return end
    local list = ZoneBeacons()
    if #list == 0 then return end

    local near, far = {}, {}
    for _, b in ipairs(list) do
        if IsNear(b) then
            near[#near + 1] = b
        else
            far[#far + 1] = b
        end
    end
    local pool = #near > 0 and near or far
    if #pool == 0 then return end
    rollIndex = ((rollIndex - 1) % #pool) + 1
    local pick = pool[rollIndex]
    rollIndex = rollIndex + 1
    Blackacre.BeaconHead.ShowBeacon(pick)
end

function Blackacre.BeaconHead.OnCacheChanged()
    -- soft: do not force immediate roll on every packet
end

function Blackacre.BeaconHead.Init()
    EnsureFrame()
    local f = CreateFrame("Frame")
    f:RegisterEvent("ZONE_CHANGED")
    f:RegisterEvent("ZONE_CHANGED_INDOORS")
    f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:SetScript("OnEvent", function(_, event)
        if not ReceiveEnabled() then return end
        if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
            C_Timer.After(3, function()
                Blackacre.BeaconHead.RollNext()
            end)
        else
            -- subzone change: gentle advance
            C_Timer.After(0.8, function()
                Blackacre.BeaconHead.RollNext()
            end)
        end
    end)
    C_Timer.NewTicker((Cfg().ROLL_INTERVAL or 240), function()
        if ReceiveEnabled() then
            Blackacre.BeaconHead.RollNext()
        end
    end)
end
