Blackacre = Blackacre or {}
Blackacre.UI = Blackacre.UI or {}
Blackacre.UI.JournalFrame = {}

-- Two-page open-book journal for embedding in the Chronicle spread.
-- leftHost  = table of contents (left page)
-- rightHost = open page / editor (right page)

function Blackacre.UI.JournalFrame.Create(name, titleText, opts)
    opts = opts or {}
    local parent = opts.parent or UIParent
    local embedded = opts.embedded == true or (parent ~= UIParent)
    local tocParent = opts.tocParent
    local pageParent = opts.pageParent

    local frame = CreateFrame("Frame", name, parent)
    if embedded then
        frame:SetAllPoints(parent)
    else
        frame:SetSize(760, 520)
        frame:SetPoint("CENTER")
        frame:SetFrameStrata("HIGH")
        frame:Hide()
        tinsert(UISpecialFrames, name)
    end
    if frame.SetClipsChildren then frame:SetClipsChildren(true) end

    -- Two-page mode when Tome provides left/right hosts
    if tocParent and pageParent then
        frame.leftHost = CreateFrame("Frame", nil, tocParent)
        frame.leftHost:SetAllPoints(tocParent)
        frame.rightHost = CreateFrame("Frame", nil, pageParent)
        frame.rightHost:SetAllPoints(pageParent)
        -- Root is a non-blocking marker (children live on the two pages)
        frame:SetSize(1, 1)
        frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
        frame:EnableMouse(false)
    else
        local sidePad, topPad, bottomPad = 8, 8, 36
        frame.leftHost = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        frame.leftHost:SetPoint("TOPLEFT", sidePad, -topPad)
        frame.leftHost:SetPoint("BOTTOMLEFT", sidePad, bottomPad)
        frame.leftHost:SetWidth(260)
        Blackacre.UI.Theme.ApplyOpenBookPage(frame.leftHost)

        frame.rightHost = CreateFrame("Frame", nil, frame, "BackdropTemplate")
        frame.rightHost:SetPoint("TOPLEFT", frame.leftHost, "TOPRIGHT", 8, 0)
        frame.rightHost:SetPoint("BOTTOMRIGHT", -sidePad, bottomPad)
        Blackacre.UI.Theme.ApplyOpenBookPage(frame.rightHost)
    end

    if frame.leftHost.SetClipsChildren then frame.leftHost:SetClipsChildren(true) end
    if frame.rightHost.SetClipsChildren then frame.rightHost:SetClipsChildren(true) end

    -- TOC header (left page only — no duplicate body title)
    frame.leftTitle = frame.leftHost:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.leftTitle:SetPoint("TOPLEFT", 14, -12)
    frame.leftTitle:SetText("Table of Contents")
    Blackacre.UI.Theme.GoldTitle(frame.leftTitle)

    frame.leftHint = frame.leftHost:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.leftHint:SetPoint("TOPLEFT", 14, -36)
    frame.leftHint:SetPoint("TOPRIGHT", -14, -36)
    frame.leftHint:SetJustifyH("LEFT")
    frame.leftHint:SetText("Search or choose a page — then read on the right.")
    Blackacre.UI.Theme.ApplyMailBodyFont(frame.leftHint, 0)

    -- Right page: single title field only (no stacked title + rightTitle)
    frame.rightTitle = frame.rightHost:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.rightTitle:SetPoint("TOPLEFT", 16, -12)
    frame.rightTitle:SetPoint("TOPRIGHT", -16, -12)
    frame.rightTitle:SetJustifyH("LEFT")
    frame.rightTitle:SetText("Select an entry")
    Blackacre.UI.Theme.GoldTitle(frame.rightTitle)

    -- Footer for action buttons sits on right page bottom
    frame.footer = CreateFrame("Frame", nil, frame.rightHost)
    frame.footer:SetPoint("BOTTOMLEFT", 10, 8)
    frame.footer:SetPoint("BOTTOMRIGHT", -10, 8)
    frame.footer:SetHeight(32)

    frame.footerHint = frame.footer:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.footerHint:SetPoint("LEFT", 0, 0)
    frame.footerHint:SetText("")
    Blackacre.UI.Theme.ApplyMailBodyFont(frame.footerHint, -1)

    frame._icEmbedded = embedded
    frame._icTwoPage = tocParent ~= nil
    frame._icSidePad = 10
    frame._icTopPad = 8
    frame._icBottomPad = 40

    function frame:SetJournalTitle(text)
        if frame.leftTitle then frame.leftTitle:SetText(text or "Table of Contents") end
    end

    function frame:SetSubtitle(text)
        if frame.leftHint then frame.leftHint:SetText(text or "") end
    end

    return frame
end
