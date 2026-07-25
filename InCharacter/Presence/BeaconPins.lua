InCharacter = InCharacter or {}
InCharacter.BeaconPins = {}

local pins = {}

local function ReceiveEnabled()
    local p = InCharacter.CharDB and InCharacter.CharDB.presence
    if p and p.receiveBeacons == false then return false end
    return true
end

local function ClearPins()
    for _, pin in pairs(pins) do
        pin:Hide()
        pin:SetParent(nil)
    end
    wipe(pins)
end

local function CreateMapPin(beacon)
    if not WorldMapFrame or not WorldMapFrame.ScrollContainer then return nil end
    local scrollContainer = WorldMapFrame.ScrollContainer
    local button = CreateFrame("Button", nil, scrollContainer.Child)
    button:SetSize(22, 22)
    button:SetFrameStrata("DIALOG")
    local texture = button:CreateTexture(nil, "OVERLAY")
    texture:SetAllPoints()
    texture:SetTexture("Interface\\WorldMap\\WorldMapPartyIcon")
    local cw = scrollContainer.Child:GetWidth()
    local ch = scrollContainer.Child:GetHeight()
    local x = (beacon.coords and beacon.coords.x) or 0.5
    local y = (beacon.coords and beacon.coords.y) or 0.5
    button:SetPoint("CENTER", scrollContainer.Child, "TOPLEFT", x * cw, -y * ch)
    local crumb = beacon.breadcrumb or beacon.shortText or "A presence"
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(crumb, 1, 1, 1, true)
        if beacon.charName and beacon.charName ~= "" then
            GameTooltip:AddLine(beacon.charName, 0.8, 0.7, 0.3)
        end
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", GameTooltip_Hide)
    return button
end

function InCharacter.BeaconPins.Refresh()
    ClearPins()
    if not ReceiveEnabled() then return end
    if not WorldMapFrame or not WorldMapFrame:IsShown() then return end
    local mapID = WorldMapFrame:GetMapID()
    local now = time()
    for _, b in pairs(InCharacterDB.beacons or {}) do
        if b.zoneId == mapID and (not b.expiresAt or b.expiresAt >= now) then
            local pin = CreateMapPin(b)
            if pin then
                pins[b.id] = pin
                pin:Show()
            end
        end
    end
end

function InCharacter.BeaconPins.Init()
    if not WorldMapFrame then return end
    hooksecurefunc(WorldMapFrame, "OnMapChanged", function()
        InCharacter.BeaconPins.Refresh()
    end)
    WorldMapFrame:HookScript("OnShow", function()
        C_Timer.After(0.2, InCharacter.BeaconPins.Refresh)
    end)
end
