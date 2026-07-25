InCharacter = InCharacter or {}
InCharacter.Hardcore = InCharacter.Hardcore or {}
InCharacter.Hardcore.UI = {}

local frame

local function StatusLine()
    local s = InCharacter.Hardcore.GetStatus()
    local honor = s.clean and "|cff2d8a2dUnstained|r" or "|cff8a2d2dStained|r"
    return string.format(
        "Honor: %s\nDeaths recorded: %d\nEncumbrance active: %s (events: %d)\nMount stains: %d · Sky stains: %d\nGround rite: %s · Flying rite: %s",
        honor,
        s.deathCount,
        s.encumbranceActive and "yes" or "no",
        s.encumbranceViolations,
        s.mountViolations,
        s.flyViolations,
        s.groundGate and "complete" or "unsworn",
        s.flyingGate and "complete" or "unsworn"
    )
end

local function Build()
    frame = CreateFrame("Frame", "InCharacterHardcorePanel", UIParent, "BackdropTemplate")
    frame:SetSize(440, 360)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("HIGH")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()
    tinsert(UISpecialFrames, "InCharacterHardcorePanel")
    InCharacter.UI.Theme.ApplyParchmentBackdrop(frame, 0.98)

    local icon = frame:CreateTexture(nil, "OVERLAY")
    icon:SetSize(28, 28)
    icon:SetPoint("TOPLEFT", 14, -12)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Note_06")

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("LEFT", icon, "RIGHT", 8, 0)
    frame.title:SetText("Hardcore Compact")
    InCharacter.UI.Theme.GoldTitle(frame.title)

    frame.sub = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.sub:SetPoint("TOPLEFT", 16, -48)
    frame.sub:SetWidth(400)
    frame.sub:SetJustifyH("LEFT")
    frame.sub:SetText("An honor ledger — the game will not force these rules. The journal will remember.")
    InCharacter.UI.Theme.InkFont(frame.sub)

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -2, -2)

    frame.status = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.status:SetPoint("TOPLEFT", 20, -90)
    frame.status:SetWidth(400)
    frame.status:SetJustifyH("LEFT")
    frame.status:SetSpacing(4)
    InCharacter.UI.Theme.InkFont(frame.status)

    local function MakeCheck(label, y, get, set)
        local cb = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", 18, y)
        cb:SetChecked(get())
        local text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        text:SetPoint("LEFT", cb, "RIGHT", 4, 0)
        text:SetText(label)
        InCharacter.UI.Theme.InkFont(text)
        cb:SetScript("OnClick", function(self)
            set(self:GetChecked())
            frame.status:SetText(StatusLine())
            InCharacter.UI.Theme.Toast(self:GetChecked() and "Rite marked complete." or "Rite marked unsworn.")
        end)
        return cb
    end

    frame.groundCheck = MakeCheck("Ground mount rite complete (IC gatekeeper)", -220, function()
        return InCharacter.CharDB.gate.ground
    end, function(v)
        InCharacter.Hardcore.SetGroundGate(v)
    end)

    frame.flyCheck = MakeCheck("Flying mount rite complete (IC gatekeeper)", -255, function()
        return InCharacter.CharDB.gate.flying
    end, function(v)
        InCharacter.Hardcore.SetFlyingGate(v)
    end)

    local openJournal = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    openJournal:SetSize(140, 24)
    openJournal:SetPoint("BOTTOMLEFT", 16, 16)
    openJournal:SetText("Open chronicle")
    openJournal:SetScript("OnClick", function()
        InCharacter.Chronicle.UI.Show()
    end)

    local refresh = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    refresh:SetSize(90, 24)
    refresh:SetPoint("BOTTOMRIGHT", -16, 16)
    refresh:SetText("Refresh")
    refresh:SetScript("OnClick", function()
        InCharacter.Hardcore.UI.Refresh()
    end)

    frame.footer = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    frame.footer:SetPoint("BOTTOM", 0, 44)
    frame.footer:SetText("Allowed worn bags: 6 slots each · Reagent bag ignored · Backpack unrestricted")
end

function InCharacter.Hardcore.UI.Init()
    -- lazy build on first show
end

function InCharacter.Hardcore.UI.Refresh()
    if not frame or not frame:IsShown() then return end
    frame.status:SetText(StatusLine())
    if frame.groundCheck then
        frame.groundCheck:SetChecked(InCharacter.CharDB.gate.ground)
    end
    if frame.flyCheck then
        frame.flyCheck:SetChecked(InCharacter.CharDB.gate.flying)
    end
end

function InCharacter.Hardcore.UI.Toggle()
    if not frame then
        Build()
    end
    if frame:IsShown() then
        frame:Hide()
    else
        frame.status:SetText(StatusLine())
        frame.groundCheck:SetChecked(InCharacter.CharDB.gate.ground)
        frame.flyCheck:SetChecked(InCharacter.CharDB.gate.flying)
        frame:Show()
    end
end