Blackacre = Blackacre or {}
Blackacre.UI = Blackacre.UI or {}
Blackacre.UI.JournalFrame = {}

-- Two-panel journal shell, designed for embedding in the Tome page host.

function Blackacre.UI.JournalFrame.Create(name, titleText, opts)
    opts = opts or {}
    local parent = opts.parent or UIParent
    local embedded = opts.embedded == true or (parent ~= UIParent)

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
        Blackacre.UI.Theme.ApplyFilledPanel(frame, 0.96, "page")
    end
    if frame.SetClipsChildren then frame:SetClipsChildren(true) end

    local topPad = embedded and 22 or 52
    local bottomPad = embedded and 40 or 48
    local sidePad = 10

    if not embedded then
        frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        frame.title:SetPoint("TOPLEFT", 16, -14)
        frame.title:SetText(titleText or "Journal")
        Blackacre.UI.Theme.GoldTitle(frame.title)
        frame.subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        frame.subtitle:SetPoint("TOPLEFT", 16, -36)
        frame.subtitle:SetText("A private ledger of deeds and days")
        Blackacre.UI.Theme.InkFont(frame.subtitle)
        local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT", -2, -2)
        frame.closeButton = close
    else
        frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        frame.title:SetPoint("TOPLEFT", sidePad, -6)
        frame.title:SetText(titleText or "Chronology")
        Blackacre.UI.Theme.InkFont(frame.title, "header")
        frame.subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        frame.subtitle:SetPoint("LEFT", frame.title, "RIGHT", 12, 0)
        frame.subtitle:SetText("Quests, feats, titles — told in order")
    end

    frame.leftHost = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.leftHost:SetPoint("TOPLEFT", sidePad, -topPad)
    frame.leftHost:SetPoint("BOTTOMLEFT", sidePad, bottomPad)
    frame.leftHost:SetWidth(embedded and 230 or 250)
    Blackacre.UI.Theme.ApplyFilledPanel(frame.leftHost, 0.9, "panel")
    if frame.leftHost.SetClipsChildren then frame.leftHost:SetClipsChildren(true) end

    frame.leftTitle = frame.leftHost:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.leftTitle:SetPoint("TOPLEFT", 10, -8)
    frame.leftTitle:SetText("Chronology")
    Blackacre.UI.Theme.InkFont(frame.leftTitle, "header")

    frame.rightHost = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.rightHost:SetPoint("TOPLEFT", frame.leftHost, "TOPRIGHT", 10, 0)
    frame.rightHost:SetPoint("BOTTOMRIGHT", -sidePad, bottomPad)
    Blackacre.UI.Theme.ApplyFilledPanel(frame.rightHost, 0.94, "page")
    if frame.rightHost.SetClipsChildren then frame.rightHost:SetClipsChildren(true) end

    frame.rightTitle = frame.rightHost:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.rightTitle:SetPoint("TOPLEFT", 12, -10)
    frame.rightTitle:SetPoint("TOPRIGHT", -12, -10)
    frame.rightTitle:SetJustifyH("LEFT")
    frame.rightTitle:SetText("Select an entry")
    Blackacre.UI.Theme.InkFont(frame.rightTitle, "header")

    frame.footer = CreateFrame("Frame", nil, frame)
    frame.footer:SetPoint("BOTTOMLEFT", sidePad, embedded and 6 or 10)
    frame.footer:SetPoint("BOTTOMRIGHT", -sidePad, embedded and 6 or 10)
    frame.footer:SetHeight(30)

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
    frame._icSidePad = sidePad
    frame._icTopPad = topPad
    frame._icBottomPad = bottomPad
    return frame
end
