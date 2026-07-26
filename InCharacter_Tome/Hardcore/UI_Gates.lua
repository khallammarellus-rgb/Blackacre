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

local function Build(parent)
    parent = parent or UIParent
    local embedded = parent ~= UIParent

    frame = CreateFrame("Frame", "InCharacterHardcorePanel", parent, "BackdropTemplate")
    if embedded then
        frame:SetAllPoints(parent)
    else
        frame:SetSize(440, 360)
        frame:SetPoint("CENTER")
        frame:SetFrameStrata("HIGH")
        frame:Hide()
        tinsert(UISpecialFrames, "InCharacterHardcorePanel")
        InCharacter.UI.Theme.ApplyFilledPanel(frame, 0.96, "page")
    end
    if frame.SetClipsChildren then frame:SetClipsChildren(true) end

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("TOPLEFT", 14, -12)
    frame.title:SetText("Hardcore Compact")
    InCharacter.UI.Theme.GoldTitle(frame.title)

    frame.sub = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.sub:SetPoint("TOPLEFT", 14, -36)
    frame.sub:SetPoint("TOPRIGHT", -14, -36)
    frame.sub:SetJustifyH("LEFT")
    frame.sub:SetText("An honor ledger — the game will not force these rules. The journal will remember.")
    InCharacter.UI.Theme.InkFont(frame.sub)

    frame.status = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.status:SetPoint("TOPLEFT", 16, -70)
    frame.status:SetPoint("TOPRIGHT", -16, -70)
    frame.status:SetJustifyH("LEFT")
    frame.status:SetSpacing(4)
    InCharacter.UI.Theme.InkFont(frame.status)

    local function MakeCheck(label, y, get, set)
        local cb = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", 14, y)
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

    frame.groundCheck = MakeCheck("Ground mount rite complete (IC gatekeeper)", -200, function()
        return InCharacter.CharDB.gate.ground
    end, function(v)
        InCharacter.Hardcore.SetGroundGate(v)
    end)

    frame.flyCheck = MakeCheck("Flying mount rite complete (IC gatekeeper)", -236, function()
        return InCharacter.CharDB.gate.flying
    end, function(v)
        InCharacter.Hardcore.SetFlyingGate(v)
    end)

    local openJournal = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    openJournal:SetSize(140, 24)
    openJournal:SetPoint("BOTTOMLEFT", 14, 12)
    openJournal:SetText("Open chronicle")
    openJournal:SetScript("OnClick", function()
        if InCharacter.TomeHub then InCharacter.TomeHub.Show("chronicle") end
    end)

    local refresh = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    refresh:SetSize(90, 24)
    refresh:SetPoint("BOTTOMRIGHT", -14, 12)
    refresh:SetText("Refresh")
    refresh:SetScript("OnClick", function()
        InCharacter.Hardcore.UI.Refresh()
    end)

    frame.footer = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    frame.footer:SetPoint("BOTTOM", 0, 42)
    frame.footer:SetText("Allowed worn bags: 6 slots each · Reagent bag ignored · Backpack unrestricted")
end

function InCharacter.Hardcore.UI.Mount(parent)
    if not frame then Build(parent)
    elseif parent then InCharacter.UI.Theme.MountInPage(frame, parent) end
    frame:Show()
    InCharacter.Hardcore.UI.Refresh()
end

function InCharacter.Hardcore.UI.Init()
end

function InCharacter.Hardcore.UI.Refresh()
    if not frame then return end
    frame.status:SetText(StatusLine())
    if frame.groundCheck then
        frame.groundCheck:SetChecked(InCharacter.CharDB.gate.ground)
    end
    if frame.flyCheck then
        frame.flyCheck:SetChecked(InCharacter.CharDB.gate.flying)
    end
end

function InCharacter.Hardcore.UI.Toggle()
    if InCharacter.TomeHub and InCharacter.TomeHub.Toggle then
        InCharacter.TomeHub.Toggle("honor")
        return
    end
    if not frame then Build(UIParent) end
    if frame:IsShown() then frame:Hide() else frame:Show(); InCharacter.Hardcore.UI.Refresh() end
end
