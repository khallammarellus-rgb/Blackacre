InCharacter = InCharacter or {}
InCharacter.PostEditor = {}

local beaconFrame
local bulletinFrame

local function CreateBackdropFrame(name, width, height, point, relPoint, x, y)
    local f = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
    f:SetSize(width, height)
    f:SetPoint(point, UIParent, relPoint, x, y)
    if InCharacter.UI and InCharacter.UI.Theme and InCharacter.UI.Theme.ApplyParchmentBackdrop then
        InCharacter.UI.Theme.ApplyParchmentBackdrop(f, 0.96)
    else
        f:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        f:SetBackdropColor(0, 0, 0, 0.85)
    end
    f:Hide()
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -2, -2)
    tinsert(UISpecialFrames, name)
    return f
end

local function CreateDropdown(parent, name, items, x, y, width)
    local dropdown = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", x, y)
    UIDropDownMenu_SetWidth(dropdown, width or 140)
    dropdown.items = items
    UIDropDownMenu_Initialize(dropdown, function(self, level)
        local info = UIDropDownMenu_CreateInfo()
        for i, item in ipairs(self.items) do
            info.text = item
            info.value = item
            info.func = function(btn)
                UIDropDownMenu_SetSelectedID(dropdown, btn:GetID())
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetSelectedID(dropdown, 1)
    return dropdown
end

local function GetDropdownValue(dropdown)
    local id = UIDropDownMenu_GetSelectedID(dropdown)
    return dropdown.items and dropdown.items[id] or dropdown.items[1]
end

local function BuildBeaconEditor()
    beaconFrame = CreateBackdropFrame("InCharacterBeaconEditor", 440, 340, "CENTER", "CENTER", 0, 40)
    local title = beaconFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -12)
    title:SetText("Emit a beacon")
    if InCharacter.UI and InCharacter.UI.Theme then
        InCharacter.UI.Theme.GoldTitle(title)
    end

    local hint = beaconFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hint:SetPoint("TOPLEFT", 16, -36)
    hint:SetWidth(400)
    hint:SetText("One short IC breadcrumb. Invisible to chat — others see a soft talking-head. 24h life · 15m between emits · one active.")
    if InCharacter.UI and InCharacter.UI.Theme then InCharacter.UI.Theme.InkFont(hint) end

    local templates = InCharacter.SentenceTemplates.GetTemplates()
    local templateNames = {}
    for _, t in ipairs(templates) do
        templateNames[#templateNames + 1] = t.label
    end
    beaconFrame.templateDropdown = CreateDropdown(beaconFrame, "ICBeaconTemplate", templateNames, 0, -70, 180)

    beaconFrame.slotDropdowns = {}
    local slotNames = { "disposition", "role", "intent", "location" }
    local y = -110
    for _, slot in ipairs(slotNames) do
        local label = beaconFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        label:SetPoint("TOPLEFT", 16, y)
        label:SetText(slot:sub(1, 1):upper() .. slot:sub(2))
        beaconFrame.slotDropdowns[slot] = CreateDropdown(
            beaconFrame, "ICBeacon" .. slot,
            InCharacter.SentenceTemplates.GetSlotOptions(slot), 100, y + 8, 160
        )
        y = y - 36
    end

    beaconFrame.preview = beaconFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    beaconFrame.preview:SetPoint("TOPLEFT", 16, -260)
    beaconFrame.preview:SetWidth(400)
    beaconFrame.preview:SetJustifyH("LEFT")
    beaconFrame.preview:SetText("")

    beaconFrame.nameZone = CreateFrame("CheckButton", nil, beaconFrame, "UICheckButtonTemplate")
    beaconFrame.nameZone:SetPoint("BOTTOMLEFT", 12, 48)
    beaconFrame.nameZone:SetChecked(true)
    local nz = beaconFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    nz:SetPoint("LEFT", beaconFrame.nameZone, "RIGHT", 0, 0)
    nz:SetText("Show name in zone")

    beaconFrame.nameProx = CreateFrame("CheckButton", nil, beaconFrame, "UICheckButtonTemplate")
    beaconFrame.nameProx:SetPoint("LEFT", nz, "RIGHT", 16, 0)
    beaconFrame.nameProx:SetChecked(true)
    local np = beaconFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    np:SetPoint("LEFT", beaconFrame.nameProx, "RIGHT", 0, 0)
    np:SetText("Show name nearby")

    local function CurrentSlots(template)
        local slots = {}
        for _, slot in ipairs(template.slots) do
            local dd = beaconFrame.slotDropdowns[slot]
            if dd then slots[slot] = GetDropdownValue(dd) end
        end
        return slots
    end

    local previewBtn = CreateFrame("Button", nil, beaconFrame, "UIPanelButtonTemplate")
    previewBtn:SetSize(80, 24)
    previewBtn:SetPoint("BOTTOMLEFT", 16, 14)
    previewBtn:SetText("Preview")
    previewBtn:SetScript("OnClick", function()
        local ti = UIDropDownMenu_GetSelectedID(beaconFrame.templateDropdown) or 1
        local template = templates[ti]
        local resolved = InCharacter.SentenceTemplates.Resolve(template.id, CurrentSlots(template))
        beaconFrame.preview:SetText(resolved and resolved.shortText or "")
    end)

    local emit = CreateFrame("Button", nil, beaconFrame, "UIPanelButtonTemplate")
    emit:SetSize(100, 24)
    emit:SetPoint("LEFT", previewBtn, "RIGHT", 8, 0)
    emit:SetText("Emit")
    emit:SetScript("OnClick", function()
        local ti = UIDropDownMenu_GetSelectedID(beaconFrame.templateDropdown) or 1
        local template = templates[ti]
        local beacon = InCharacter.Lifecycle.CreateBeacon(template.id, CurrentSlots(template), {
            showNameZone = beaconFrame.nameZone:GetChecked(),
            showNameProximity = beaconFrame.nameProx:GetChecked(),
        })
        if not beacon then return end
        if InCharacter.Lifecycle.PostBeacon(beacon) then
            InCharacter.Print("Beacon emitted (invisible to chat).")
            beaconFrame:Hide()
        end
    end)

    local stop = CreateFrame("Button", nil, beaconFrame, "UIPanelButtonTemplate")
    stop:SetSize(110, 24)
    stop:SetPoint("LEFT", emit, "RIGHT", 8, 0)
    stop:SetText("Withdraw")
    stop:SetScript("OnClick", function()
        InCharacter.Lifecycle.StopBeacon()
    end)
end

local function BuildBulletinEditor()
    bulletinFrame = CreateBackdropFrame("InCharacterBulletinEditor", 440, 360, "CENTER", "CENTER", 0, -20)
    local title = bulletinFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -12)
    title:SetText("Post a bulletin")
    if InCharacter.UI and InCharacter.UI.Theme then
        InCharacter.UI.Theme.GoldTitle(title)
    end

    local titleLabel = bulletinFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    titleLabel:SetPoint("TOPLEFT", 16, -44)
    titleLabel:SetText("Title")

    bulletinFrame.titleEdit = CreateFrame("EditBox", nil, bulletinFrame, "InputBoxTemplate")
    bulletinFrame.titleEdit:SetSize(380, 24)
    bulletinFrame.titleEdit:SetPoint("TOPLEFT", 16, -62)
    bulletinFrame.titleEdit:SetAutoFocus(false)

    local bodyLabel = bulletinFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    bodyLabel:SetPoint("TOPLEFT", 16, -96)
    bodyLabel:SetText("Bulletin text (in-character)")

    bulletinFrame.bodyEdit = CreateFrame("EditBox", nil, bulletinFrame, "InputBoxTemplate")
    bulletinFrame.bodyEdit:SetSize(380, 80)
    bulletinFrame.bodyEdit:SetMultiLine(true)
    bulletinFrame.bodyEdit:SetPoint("TOPLEFT", 16, -114)
    bulletinFrame.bodyEdit:SetAutoFocus(false)

    local defaults = InCharacter.TRP3Bridge and InCharacter.TRP3Bridge.GetProfileDefaults and InCharacter.TRP3Bridge.GetProfileDefaults()
    local guided = string.format(
        "I, %s, of %s, seek %s",
        defaults and defaults.charName or UnitName("player"),
        InCharacter.CharDB.residence ~= "" and InCharacter.CharDB.residence or "[your residence]",
        "[your request]"
    )
    bulletinFrame.bodyEdit:SetText(guided)

    local residenceLabel = bulletinFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    residenceLabel:SetPoint("TOPLEFT", 16, -200)
    residenceLabel:SetText("Residence (remembered per character)")

    bulletinFrame.residenceEdit = CreateFrame("EditBox", nil, bulletinFrame, "InputBoxTemplate")
    bulletinFrame.residenceEdit:SetSize(200, 24)
    bulletinFrame.residenceEdit:SetPoint("TOPLEFT", 16, -218)
    bulletinFrame.residenceEdit:SetText(InCharacter.CharDB.residence or "")
    bulletinFrame.residenceEdit:SetAutoFocus(false)

    local scopeLabel = bulletinFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    scopeLabel:SetPoint("TOPLEFT", 240, -200)
    scopeLabel:SetText("Seal / scope")

    local scopes = { "INDIVIDUAL", "GROUP", "GUILD", "FACTION" }
    bulletinFrame.scopeDropdown = CreateDropdown(bulletinFrame, "ICBulletinScope", scopes, 240, -212, 120)

    bulletinFrame.boardHint = bulletinFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    bulletinFrame.boardHint:SetPoint("TOPLEFT", 16, -248)
    bulletinFrame.boardHint:SetWidth(400)
    bulletinFrame.boardHint:SetJustifyH("LEFT")

    local post = CreateFrame("Button", nil, bulletinFrame, "UIPanelButtonTemplate")
    post:SetSize(100, 24)
    post:SetPoint("BOTTOMRIGHT", -16, 16)
    post:SetText("Post")
    post:SetScript("OnClick", function()
        local nearby = InCharacter.Boards.GetNearbyBoard()
        if not nearby then
            InCharacter.Print("Stand near a bulletin board to post.")
            return
        end
        local titleText = bulletinFrame.titleEdit:GetText() or ""
        local bodyText = bulletinFrame.bodyEdit:GetText() or ""
        if InCharacter.TRP3Bridge and InCharacter.TRP3Bridge.RememberResidence then
            InCharacter.TRP3Bridge.RememberResidence(bulletinFrame.residenceEdit:GetText())
        end

        local function doPost()
            local scopeIndex = UIDropDownMenu_GetSelectedID(bulletinFrame.scopeDropdown) or 1
            local bulletin = InCharacter.Lifecycle.CreateBulletin(titleText, bodyText, nearby.id, scopes[scopeIndex])
            InCharacter.Lifecycle.PostBulletin(bulletin)
            InCharacter.Print("Bulletin posted to " .. nearby.displayName .. ".")
            bulletinFrame:Hide()
            if InCharacter.BoardView and InCharacter.BoardView.Show then
                InCharacter.BoardView.Show()
            end
        end

        if InCharacter.ProfanityFilter.ValidateBulletin
            and InCharacter.ProfanityFilter.ValidateBulletin(titleText, bodyText, doPost) then
            doPost()
        elseif InCharacter.ProfanityFilter.ValidateNotice
            and InCharacter.ProfanityFilter.ValidateNotice(titleText, bodyText, doPost) then
            doPost()
        elseif not InCharacter.ProfanityFilter.ValidateBulletin and not InCharacter.ProfanityFilter.ValidateNotice then
            doPost()
        end
    end)

    local boardBtn = CreateFrame("Button", nil, bulletinFrame, "UIPanelButtonTemplate")
    boardBtn:SetSize(120, 24)
    boardBtn:SetPoint("BOTTOMLEFT", 16, 16)
    boardBtn:SetText("View board")
    boardBtn:SetScript("OnClick", function()
        if InCharacter.BoardView and InCharacter.BoardView.Show then
            InCharacter.BoardView.Show()
        end
    end)
end

function InCharacter.PostEditor.Init()
    BuildBeaconEditor()
    BuildBulletinEditor()
end

function InCharacter.PostEditor.ShowBeaconEditor()
    if beaconFrame then
        local p = InCharacter.Lifecycle.EnsurePresenceDB()
        beaconFrame.nameZone:SetChecked(p.showNameZone ~= false)
        beaconFrame.nameProx:SetChecked(p.showNameProximity ~= false)
        beaconFrame:Show()
    end
end

function InCharacter.PostEditor.ShowBulletinEditor()
    if bulletinFrame then
        local board = InCharacter.Boards.GetNearbyBoard()
        if bulletinFrame.boardHint then
            if board then
                bulletinFrame.boardHint:SetText("Posting to: " .. board.displayName)
            else
                bulletinFrame.boardHint:SetText("No board in range — move closer to a bulletin board to post.")
            end
        end
        bulletinFrame:Show()
    end
end

InCharacter.PostEditor.ShowNoticeEditor = InCharacter.PostEditor.ShowBulletinEditor
