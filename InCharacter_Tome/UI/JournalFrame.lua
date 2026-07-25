InCharacter = InCharacter or {}
InCharacter.UI = InCharacter.UI or {}
InCharacter.UI.JournalFrame = {}

-- Two-panel journal shell. Can be freestanding or parented into the Tome hub.

function InCharacter.UI.JournalFrame.Create(name, titleText, opts)
    opts = opts or {}
    local parent = opts.parent or UIParent
    local embedded = opts.embedded == true

    local frame = CreateFrame("Frame", name, parent, "BackdropTemplate")
    if embedded then
        frame:SetAllPoints(parent)
    else
        frame:SetSize(760, 520)
        frame:SetPoint("CENTER")
        frame:SetFrameStrata("HIGH")
        frame:SetToplevel(true)
        frame:SetMovable(true)
        frame:EnableMouse(true)
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", frame.StartMoving)
        frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
        frame:SetClampedToScreen(true)
        frame:Hide()
        tinsert(UISpecialFrames, name)
        if InCharacter.UI.Theme.ApplyBookBackdrop then
            InCharacter.UI.Theme.ApplyBookBackdrop(frame, 0.98)
        else
            InCharacter.UI.Theme.ApplyParchmentBackdrop(frame, 0.98)
        end
    end

    local topPad = embedded and 8 or 60
    local bottomPad = embedded and 40 or 48
    local sidePad = embedded and 8 or 16

    if not embedded then
        local headerBar = frame:CreateTexture(nil, "ARTWORK")
        headerBar:SetPoint("TOPLEFT", 22, -8)
        headerBar:SetPoint("TOPRIGHT", -8, -8)
        headerBar:SetHeight(36)
        headerBar:SetColorTexture(0.45, 0.32, 0.14, 0.35)

        local icon = frame:CreateTexture(nil, "OVERLAY")
        icon:SetSize(28, 28)
        icon:SetPoint("TOPLEFT", 28, -12)
        icon:SetTexture(InCharacter.UI.Theme.Textures.questBook or "Interface\\Icons\\INV_Misc_Book_09")

        frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        frame.title:SetPoint("LEFT", icon, "RIGHT", 8, 0)
        frame.title:SetText(titleText or "Journal")
        InCharacter.UI.Theme.GoldTitle(frame.title)

        frame.subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        frame.subtitle:SetPoint("TOPLEFT", icon, "BOTTOMLEFT", 0, -6)
        frame.subtitle:SetText("A private ledger of deeds and days")
        InCharacter.UI.Theme.InkFont(frame.subtitle)

        local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT", -2, -2)
    else
        frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.title:SetPoint("TOPLEFT", sidePad, -2)
        frame.title:SetText(titleText or "Chronology")
        InCharacter.UI.Theme.InkFont(frame.title, "header")

        frame.subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        frame.subtitle:SetPoint("LEFT", frame.title, "RIGHT", 12, 0)
        frame.subtitle:SetText("Quests, feats, titles — told in order")
        topPad = 22
    end

    -- Left panel (index)
    frame.leftHost = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.leftHost:SetPoint("TOPLEFT", sidePad, -topPad)
    frame.leftHost:SetPoint("BOTTOMLEFT", sidePad, bottomPad)
    frame.leftHost:SetWidth(embedded and 240 or 260)
    InCharacter.UI.Theme.ApplyPagePanel(frame.leftHost, 0.58)

    frame.leftTitle = frame.leftHost:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.leftTitle:SetPoint("TOPLEFT", 10, -8)
    frame.leftTitle:SetText("Chronology")
    InCharacter.UI.Theme.InkFont(frame.leftTitle, "header")

    -- Right panel (page)
    frame.rightHost = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.rightHost:SetPoint("TOPLEFT", frame.leftHost, "TOPRIGHT", 10, 0)
    frame.rightHost:SetPoint("BOTTOMRIGHT", -sidePad, bottomPad)
    InCharacter.UI.Theme.ApplyPagePanel(frame.rightHost, 0.72)

    frame.rightTitle = frame.rightHost:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.rightTitle:SetPoint("TOPLEFT", 12, -10)
    frame.rightTitle:SetPoint("TOPRIGHT", -12, -10)
    frame.rightTitle:SetJustifyH("LEFT")
    frame.rightTitle:SetText("Select an entry")
    InCharacter.UI.Theme.InkFont(frame.rightTitle, "header")

    -- Bottom action bar
    frame.footer = CreateFrame("Frame", nil, frame)
    frame.footer:SetPoint("BOTTOMLEFT", sidePad, embedded and 4 or 10)
    frame.footer:SetPoint("BOTTOMRIGHT", -sidePad, embedded and 4 or 10)
    frame.footer:SetHeight(32)

    frame.footerHint = frame.footer:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    frame.footerHint:SetPoint("LEFT", 0, 0)
    frame.footerHint:SetText("Ink fades; the road remains.")

    function frame:SetJournalTitle(text)
        if frame.title then frame.title:SetText(text or "Journal") end
    end

    function frame:SetSubtitle(text)
        if frame.subtitle then frame.subtitle:SetText(text or "") end
    end

    frame._icEmbedded = embedded
    return frame
end
