Blackacre = Blackacre or {}
Blackacre.BeaconPins = {}

local pool = {}
local active = {}

local function ReceiveEnabled()
    local p = Blackacre.CharDB and Blackacre.CharDB.presence
    if p and p.receiveBeacons == false then return false end
    return true
end

local function ReleaseAll()
    for id, pin in pairs(active) do
        pin:Hide()
        pin.beacon = nil
        active[id] = nil
        pool[#pool + 1] = pin
    end
end

local function CreatePin()
    local scrollContainer = WorldMapFrame and WorldMapFrame.ScrollContainer
    if not scrollContainer or not scrollContainer.Child then return nil end
    local button = CreateFrame("Button", nil, scrollContainer.Child)
    button:SetSize(22, 22)
    button:SetFrameStrata("DIALOG")
    local texture = button:CreateTexture(nil, "OVERLAY")
    texture:SetAllPoints()
    texture:SetTexture("Interface\\WorldMap\\WorldMapPartyIcon")
    button:SetScript("OnEnter", function(self)
        local beacon = self.beacon
        if not beacon then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(beacon.breadcrumb or beacon.shortText or "A presence", 1, 1, 1, true)
        if beacon.charName and beacon.charName ~= "" then
            GameTooltip:AddLine(beacon.charName, 0.8, 0.7, 0.3)
        end
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", GameTooltip_Hide)
    return button
end

local function PlacePin(button, beacon)
    local scrollContainer = WorldMapFrame.ScrollContainer
    local child = scrollContainer and scrollContainer.Child
    if not child then return end
    local cw = child:GetWidth()
    local ch = child:GetHeight()
    local x = (beacon.coords and beacon.coords.x) or 0.5
    local y = (beacon.coords and beacon.coords.y) or 0.5
    button.beacon = beacon
    button:SetParent(child)
    button:ClearAllPoints()
    button:SetPoint("CENTER", child, "TOPLEFT", x * cw, -y * ch)
    button:Show()
end

local function Acquire(beacon)
    local button = pool[#pool]
    if button then
        pool[#pool] = nil
    else
        button = CreatePin()
    end
    if not button then return nil end
    PlacePin(button, beacon)
    return button
end

function Blackacre.BeaconPins.Refresh()
    if not ReceiveEnabled() or not WorldMapFrame or not WorldMapFrame:IsShown() or not WorldMapFrame.ScrollContainer then
        ReleaseAll()
        return
    end
    ReleaseAll()
    local mapID = WorldMapFrame:GetMapID()
    local mapNameLower
    local now = time()
    for _, b in pairs(BlackacreDB.beacons or {}) do
        local same = b.zoneId == mapID
        if not same and b.zoneName and b.zoneName ~= "" then
            if not mapNameLower and C_Map and C_Map.GetMapInfo then
                local info = C_Map.GetMapInfo(mapID)
                local mapName = info and info.name
                mapNameLower = mapName and mapName:lower() or ""
            end
            if mapNameLower and mapNameLower ~= "" and mapNameLower == b.zoneName:lower() then
                same = true
            end
        end
        if same and (not b.expiresAt or b.expiresAt >= now) then
            local pin = Acquire(b)
            if pin then
                active[b.id] = pin
            end
        end
    end
end

function Blackacre.BeaconPins.Init()
    if not WorldMapFrame then return end
    hooksecurefunc(WorldMapFrame, "OnMapChanged", function()
        Blackacre.BeaconPins.Refresh()
    end)
    WorldMapFrame:HookScript("OnShow", function()
        C_Timer.After(0.2, Blackacre.BeaconPins.Refresh)
    end)
end
