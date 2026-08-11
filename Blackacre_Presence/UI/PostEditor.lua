Blackacre = Blackacre or {}
Blackacre.PostEditor = {}

local beaconFrame
local bulletinFrame

local function CreateBackdropFrame(name, width, height, point, relPoint, x, y)
    local f = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
    f:SetSize(width, height)
    f:SetPoint(point, UIParent, relPoint, x, y)
    if Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.ApplyParchmentBackdrop then
        Blackacre.UI.Theme.ApplyParchmentBackdrop(f, 0.96)
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
    beaconFrame = CreateBackdropFrame("BlackacreBeaconEditor", 440, 340, "CENTER", "CENTER", 0, 40)
    local title = beaconFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -12)
    title:SetText("Emit a beacon")
    if Blackacre.UI and Blackacre.UI.Theme then
        Blackacre.UI.Theme.GoldTitle(title)
    end

    local hint = beaconFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hint:SetPoint("TOPLEFT", 16, -36)
    hint:SetWidth(400)
    hint:SetText("One short IC breadcrumb. Invisible to chat — others see a soft talking-head. 24h life · 15m between emits · one active.")
    if Blackacre.UI and Blackacre.UI.Theme then Blackacre.UI.Theme.InkFont(hint) end

    local templates = Blackacre.SentenceTemplates.GetTemplates()
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
            Blackacre.SentenceTemplates.GetSlotOptions(slot), 100, y + 8, 160
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
        local resolved = Blackacre.SentenceTemplates.Resolve(template.id, CurrentSlots(template))
        beaconFrame.preview:SetText(resolved and resolved.shortText or "")
    end)

    local emit = CreateFrame("Button", nil, beaconFrame, "UIPanelButtonTemplate")
    emit:SetSize(100, 24)
    emit:SetPoint("LEFT", previewBtn, "RIGHT", 8, 0)
    emit:SetText("Emit")
    emit:SetScript("OnClick", function()
        local ti = UIDropDownMenu_GetSelectedID(beaconFrame.templateDropdown) or 1
        local template = templates[ti]
        local beacon = Blackacre.Lifecycle.CreateBeacon(template.id, CurrentSlots(template), {
            showNameZone = beaconFrame.nameZone:GetChecked(),
            showNameProximity = beaconFrame.nameProx:GetChecked(),
        })
        if not beacon then return end
        if Blackacre.Lifecycle.PostBeacon(beacon) then
            Blackacre.Print("Beacon emitted (invisible to chat).")
            beaconFrame:Hide()
        end
    end)

    local stop = CreateFrame("Button", nil, beaconFrame, "UIPanelButtonTemplate")
    stop:SetSize(110, 24)
    stop:SetPoint("LEFT", emit, "RIGHT", 8, 0)
    stop:SetText("Withdraw")
    stop:SetScript("OnClick", function()
        Blackacre.Lifecycle.StopBeacon()
    end)
end

local function BuildBulletinEditor()
    bulletinFrame = CreateBackdropFrame("BlackacreBulletinEditor", 440, 360, "CENTER", "CENTER", 0, -20)
    local title = bulletinFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -12)
    title:SetText("Post a bulletin")
    if Blackacre.UI and Blackacre.UI.Theme then
        Blackacre.UI.Theme.GoldTitle(title)
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

    local defaults = Blackacre.TRP3Bridge and Blackacre.TRP3Bridge.GetProfileDefaults and Blackacre.TRP3Bridge.GetProfileDefaults()
    local guided = string.format(
        "I, %s, of %s, seek %s",
        defaults and defaults.charName or UnitName("player"),
        Blackacre.CharDB.residence ~= "" and Blackacre.CharDB.residence or "[your residence]",
        "[your request]"
    )
    bulletinFrame.bodyEdit:SetText(guided)

    local residenceLabel = bulletinFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    residenceLabel:SetPoint("TOPLEFT", 16, -200)
    residenceLabel:SetText("Residence (remembered per character)")

    bulletinFrame.residenceEdit = CreateFrame("EditBox", nil, bulletinFrame, "InputBoxTemplate")
    bulletinFrame.residenceEdit:SetSize(200, 24)
    bulletinFrame.residenceEdit:SetPoint("TOPLEFT", 16, -218)
    bulletinFrame.residenceEdit:SetText(Blackacre.CharDB.residence or "")
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
        local nearby = Blackacre.Boards.GetNearbyBoard()
        if not nearby then
            Blackacre.Print("Stand near a bulletin board to post. Use View board → Known boards for the map.")
            return
        end
        local titleText = bulletinFrame.titleEdit:GetText() or ""
        local bodyText = bulletinFrame.bodyEdit:GetText() or ""
        if Blackacre.TRP3Bridge and Blackacre.TRP3Bridge.RememberResidence then
            Blackacre.TRP3Bridge.RememberResidence(bulletinFrame.residenceEdit:GetText())
        end

        local function doPost()
            if Blackacre.Voice and Blackacre.Voice.MaybeApplyBulletin then
                bodyText = Blackacre.Voice.MaybeApplyBulletin(bodyText)
                titleText = Blackacre.Voice.MaybeApplyBulletin(titleText)
            end
            local scopeIndex = UIDropDownMenu_GetSelectedID(bulletinFrame.scopeDropdown) or 1
            local bulletin = Blackacre.Lifecycle.CreateBulletin(titleText, bodyText, nearby.id, scopes[scopeIndex])
            Blackacre.Lifecycle.PostBulletin(bulletin)
            local short = "P"
            if Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.SealLabel then
                local _, s = Blackacre.UI.Theme.SealLabel(scopes[scopeIndex])
                short = s or "P"
            end
            Blackacre.Print(string.format("Bulletin sealed [%s] at %s.", short, nearby.displayName))
            bulletinFrame:Hide()
            if Blackacre.BoardView and Blackacre.BoardView.Show then
                Blackacre.BoardView.Show()
            end
        end

        local function afterOOC()
            if Blackacre.ProfanityFilter.ValidateBulletin
                and Blackacre.ProfanityFilter.ValidateBulletin(titleText, bodyText, doPost) then
                doPost()
            elseif Blackacre.ProfanityFilter.ValidateNotice
                and Blackacre.ProfanityFilter.ValidateNotice(titleText, bodyText, doPost) then
                doPost()
            elseif not Blackacre.ProfanityFilter.ValidateBulletin and not Blackacre.ProfanityFilter.ValidateNotice then
                doPost()
            end
        end

        local oocWarn = Blackacre.Voice and Blackacre.Voice.SoftOOCLint
            and Blackacre.Voice.SoftOOCLint(titleText .. " " .. bodyText)
        if oocWarn then
            StaticPopupDialogs["Blackacre_OOC_BULLETIN"] = {
                text = oocWarn,
                button1 = "Post anyway",
                button2 = "Revise",
                OnAccept = function() afterOOC() end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
            }
            StaticPopup_Show("Blackacre_OOC_BULLETIN")
        else
            afterOOC()
        end
    end)

    local boardBtn = CreateFrame("Button", nil, bulletinFrame, "UIPanelButtonTemplate")
    boardBtn:SetSize(120, 24)
    boardBtn:SetPoint("BOTTOMLEFT", 16, 16)
    boardBtn:SetText("View board")
    boardBtn:SetScript("OnClick", function()
        if Blackacre.BoardView and Blackacre.BoardView.Show then
            Blackacre.BoardView.Show()
        end
    end)

    local knownBtn = CreateFrame("Button", nil, bulletinFrame, "UIPanelButtonTemplate")
    knownBtn:SetSize(110, 24)
    knownBtn:SetPoint("LEFT", boardBtn, "RIGHT", 8, 0)
    knownBtn:SetText("Known boards")
    knownBtn:SetScript("OnClick", function()
        if Blackacre.BoardView and Blackacre.BoardView.ShowKnownBoards then
            Blackacre.BoardView.ShowKnownBoards()
        end
    end)
end

function Blackacre.PostEditor.Init()
    BuildBeaconEditor()
    BuildBulletinEditor()
end

function Blackacre.PostEditor.ShowBeaconEditor()
    if beaconFrame then
        local p = Blackacre.Lifecycle.EnsurePresenceDB()
        beaconFrame.nameZone:SetChecked(p.showNameZone ~= false)
        beaconFrame.nameProx:SetChecked(p.showNameProximity ~= false)
        beaconFrame:Show()
    end
end

function Blackacre.PostEditor.ShowBulletinEditor()
    if bulletinFrame then
        local board = Blackacre.Boards.GetNearbyBoard()
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

Blackacre.PostEditor.ShowNoticeEditor = Blackacre.PostEditor.ShowBulletinEditor
