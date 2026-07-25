InCharacter = InCharacter or {}
InCharacter.UI = InCharacter.UI or {}
InCharacter.UI.JournalFrame = {}

-- Shared two-panel journal shell (index left, page right).
-- Modules call Create() and fill leftHost / rightHost.

function InCharacter.UI.JournalFrame.Create(name, titleText)
    local frame = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
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

    InCharacter.UI.Theme.ApplyParchmentBackdrop(frame, 0.98)

    -- Decorative top edge strip
    local headerBar = frame:CreateTexture(nil, "ARTWORK")
    headerBar:SetPoint("TOPLEFT", 8, -8)
    headerBar:SetPoint("TOPRIGHT", -8, -8)
    headerBar:SetHeight(36)
    headerBar:SetColorTexture(0.45, 0.32, 0.14, 0.35)

    local icon = frame:CreateTexture(nil, "OVERLAY")
    icon:SetSize(28, 28)
    icon:SetPoint("TOPLEFT", 14, -12)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")

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

    -- Left panel (index)
    frame.leftHost = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.leftHost:SetPoint("TOPLEFT", 16, -60)
    frame.leftHost:SetPoint("BOTTOMLEFT", 16, 48)
    frame.leftHost:SetWidth(260)
    frame.leftHost:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = InCharacter.UI.Theme.Textures.tooltipEdge,
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    frame.leftHost:SetBackdropColor(0.95, 0.90, 0.78, 0.55)
    frame.leftHost:SetBackdropBorderColor(0.45, 0.35, 0.2, 0.9)

    frame.leftTitle = frame.leftHost:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.leftTitle:SetPoint("TOPLEFT", 10, -8)
    frame.leftTitle:SetText("Chronology")
    InCharacter.UI.Theme.InkFont(frame.leftTitle, "header")

    -- Right panel (page)
    frame.rightHost = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.rightHost:SetPoint("TOPLEFT", frame.leftHost, "TOPRIGHT", 12, 0)
    frame.rightHost:SetPoint("BOTTOMRIGHT", -16, 48)
    frame.rightHost:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = InCharacter.UI.Theme.Textures.tooltipEdge,
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    frame.rightHost:SetBackdropColor(0.97, 0.93, 0.82, 0.7)
    frame.rightHost:SetBackdropBorderColor(0.45, 0.35, 0.2, 0.9)

    frame.rightTitle = frame.rightHost:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.rightTitle:SetPoint("TOPLEFT", 12, -10)
    frame.rightTitle:SetPoint("TOPRIGHT", -12, -10)
    frame.rightTitle:SetJustifyH("LEFT")
    frame.rightTitle:SetText("Select an entry")
    InCharacter.UI.Theme.InkFont(frame.rightTitle, "header")

    -- Bottom action bar
    frame.footer = CreateFrame("Frame", nil, frame)
    frame.footer:SetPoint("BOTTOMLEFT", 16, 10)
    frame.footer:SetPoint("BOTTOMRIGHT", -16, 10)
    frame.footer:SetHeight(32)

    frame.footerHint = frame.footer:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    frame.footerHint:SetPoint("LEFT", 0, 0)
    frame.footerHint:SetText("Ink fades; the road remains. Entries may be edited freely.")

    function frame:SetJournalTitle(text)
        frame.title:SetText(text or "Journal")
    end

    function frame:SetSubtitle(text)
        frame.subtitle:SetText(text or "")
    end

    return frame
end