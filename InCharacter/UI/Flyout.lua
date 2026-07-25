InCharacter = InCharacter or {}
InCharacter.Flyout = {}

local MAX_VISIBLE = 6
local frame
local rows = {}

local function ReceiveEnabled()
    local p = InCharacter.CharDB and InCharacter.CharDB.presence
    if p and p.receiveBeacons == false then return false end
    return true
end

local function GetActiveBeacons()
    local list = {}
    local seen = {}
    local ctx = InCharacter.GetZoneContext()
    local now = time()
    local function addBeacon(beacon)
        if not beacon then return end
        if beacon.expiresAt and beacon.expiresAt < now then return end
        if beacon.zoneId and beacon.zoneId ~= 0 and ctx.zoneId ~= beacon.zoneId then return end
        if seen[beacon.id] then return end
        seen[beacon.id] = true
        list[#list + 1] = beacon
    end
    for _, beacon in pairs(InCharacterDB.beacons or {}) do
        addBeacon(beacon)
    end
    table.sort(list, function(a, b)
        return (a.receivedAt or a.createdAt or 0) > (b.receivedAt or b.createdAt or 0)
    end)
    return list
end

local function CreateRow(parent, index)
    local row = CreateFrame("Button", nil, parent)
    row:SetSize(280, 22)
    row:SetPoint("TOPLEFT", 8, -40 - (index - 1) * 24)
    row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.text:SetPoint("LEFT", 4, 0)
    row.text:SetWidth(260)
    row.text:SetJustifyH("LEFT")
    return row
end

function InCharacter.Flyout.Init()
    frame = CreateFrame("Frame", "InCharacterFlyout", UIParent, "BackdropTemplate")
    frame:SetSize(300, 220)
    frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -40, -120)
    if InCharacter.UI and InCharacter.UI.Theme and InCharacter.UI.Theme.ApplyParchmentBackdrop then
        InCharacter.UI.Theme.ApplyParchmentBackdrop(frame, 0.94)
    else
        frame:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        frame:SetBackdropColor(0, 0, 0, 0.75)
    end
    frame:Hide()
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    tinsert(UISpecialFrames, "InCharacterFlyout")

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 12, -10)
    title:SetText("Presence")

    frame.subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.subtitle:SetPoint("TOPLEFT", 12, -26)
    frame.subtitle:SetText("Beacons in this zone (no chat spam)")

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -2, -2)

    for i = 1, MAX_VISIBLE do
        rows[i] = CreateRow(frame, i)
    end

    frame.moreText = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    frame.moreText:SetPoint("BOTTOMLEFT", 12, 36)

    frame.recvCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    frame.recvCheck:SetPoint("BOTTOMLEFT", 8, 6)
    frame.recvCheck:SetScript("OnClick", function(self)
        local p = InCharacter.Lifecycle.EnsurePresenceDB()
        p.receiveBeacons = self:GetChecked() and true or false
        if InCharacter.BeaconPins and InCharacter.BeaconPins.Refresh then
            InCharacter.BeaconPins.Refresh()
        end
        InCharacter.Print(p.receiveBeacons and "Beacon receive on." or "Beacon receive off.")
    end)
    local rl = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    rl:SetPoint("LEFT", frame.recvCheck, "RIGHT", 0, 0)
    rl:SetText("Receive beacons")

    local beaconBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    beaconBtn:SetSize(70, 20)
    beaconBtn:SetPoint("BOTTOMRIGHT", -10, 10)
    beaconBtn:SetText("Emit")
    beaconBtn:SetScript("OnClick", function()
        InCharacter.PostEditor.ShowBeaconEditor()
    end)

    local bullBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    bullBtn:SetSize(80, 20)
    bullBtn:SetPoint("RIGHT", beaconBtn, "LEFT", -4, 0)
    bullBtn:SetText("Bulletin")
    bullBtn:SetScript("OnClick", function()
        InCharacter.PostEditor.ShowBulletinEditor()
    end)
end

function InCharacter.Flyout.Refresh()
    if not frame or not frame:IsShown() then return end
    InCharacter.Flyout.Populate()
end

function InCharacter.Flyout.Populate()
    if not ReceiveEnabled() then
        for i = 1, MAX_VISIBLE do rows[i]:Hide() end
        frame.moreText:SetText("Beacon receive is off.")
        frame.moreText:Show()
        return
    end
    local beacons = GetActiveBeacons()
    local shown = math.min(#beacons, MAX_VISIBLE)
    for i = 1, MAX_VISIBLE do
        local row = rows[i]
        if i <= shown then
            local beacon = beacons[i]
            local label = beacon.breadcrumb or beacon.shortText or "A presence"
            if beacon.charName and beacon.charName ~= "" then
                label = label .. "  |cffc9a227(" .. beacon.charName .. ")|r"
            end
            row.text:SetText(label)
            row:Show()
            row:SetScript("OnClick", function()
                -- Local only — no chat. Whisper only if name known.
                if beacon.charName and beacon.charName ~= "" then
                    ChatFrame_SendTell(beacon.charName)
                end
            end)
        else
            row:Hide()
        end
    end
    if #beacons > MAX_VISIBLE then
        frame.moreText:SetText("+" .. (#beacons - MAX_VISIBLE) .. " more")
        frame.moreText:Show()
    else
        frame.moreText:Hide()
    end
    frame:SetHeight(70 + shown * 24 + 40)
end

function InCharacter.Flyout.Toggle()
    if not frame then return end
    if frame:IsShown() then
        frame:Hide()
    else
        local p = InCharacter.Lifecycle.EnsurePresenceDB()
        frame.recvCheck:SetChecked(p.receiveBeacons ~= false)
        if InCharacter.MinimapButton and InCharacter.MinimapButton.ClearNotify then
            InCharacter.MinimapButton.ClearNotify()
        end
        InCharacter.Flyout.Populate()
        frame:Show()
    end
end

function InCharacter.Flyout.OnBeaconDiscovered(beacon)
    if InCharacter.MinimapButton and InCharacter.MinimapButton.Notify then
        if not (InCharacter.CharDB.settings and InCharacter.CharDB.settings.quietNotifications) then
            InCharacter.MinimapButton.Notify()
        end
    end
    InCharacter.Flyout.Refresh()
end
