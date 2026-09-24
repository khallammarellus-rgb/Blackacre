Blackacre = Blackacre or {}
Blackacre.Hardcore = Blackacre.Hardcore or {}
Blackacre.Hardcore.UI = {}

local frame

local function StatusLine()
    local s = Blackacre.Hardcore.GetStatus()
    return string.format(
        "Deaths recorded: %d\nEncumbrance active: %s (events: %d)\nMount Violations: %d\nGround Rite: %s",
        s.deathCount,
        s.encumbranceActive and "yes" or "no",
        s.encumbranceViolations,
        s.mountViolations,
        s.groundGate and "Completed" or "Incomplete"
    )
end

local function Build(parent)
    parent = parent or UIParent
    local embedded = parent ~= UIParent

    frame = CreateFrame("Frame", "BlackacreHardcorePanel", parent, "BackdropTemplate")
    if embedded then
        frame:SetAllPoints(parent)
    else
        frame:SetSize(440, 360)
        frame:SetPoint("CENTER")
        frame:SetFrameStrata("HIGH")
        frame:Hide()
        tinsert(UISpecialFrames, "BlackacreHardcorePanel")
        Blackacre.UI.Theme.ApplyFilledPanel(frame, 0.96, "page")
    end
    if frame.SetClipsChildren then frame:SetClipsChildren(true) end

    local function TryAtlas(tex, name)
        if Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.TrySetAtlas then
            return Blackacre.UI.Theme.TrySetAtlas(tex, name, true)
        end
        return false
    end

    local function Category(parent, title, y, height)
        local box = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        box:SetPoint("TOPLEFT", 12, y)
        box:SetPoint("TOPRIGHT", -12, y)
        box:SetHeight(height)
        local header = box:CreateTexture(nil, "BACKGROUND")
        header:SetPoint("TOPLEFT", 0, 0)
        header:SetPoint("TOPRIGHT", 0, 0)
        header:SetHeight(24)
        if not TryAtlas(header, "UI-Character-Info-Title") then
            header:SetColorTexture(0.12, 0.10, 0.08, 0.85)
        end
        local fill = box:CreateTexture(nil, "BACKGROUND")
        fill:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0)
        fill:SetPoint("BOTTOMRIGHT", 0, 0)
        fill:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-StatBackground")
        fill:SetAlpha(0.55)
        local label = box:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("LEFT", header, "LEFT", 12, 0)
        label:SetText(title)
        Blackacre.UI.Theme.InkFont(label, "header")
        return box
    end

    local general = Category(frame, "General", -8, 88)
    frame.status = general:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.status:SetPoint("TOPLEFT", 14, -30)
    frame.status:SetPoint("TOPRIGHT", -14, -30)
    frame.status:SetJustifyH("LEFT")
    frame.status:SetSpacing(3)
    Blackacre.UI.Theme.InkFont(frame.status)

    local attrib = Category(frame, "Primary attributes", -104, 72)
    frame.attrText = attrib:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.attrText:SetPoint("TOPLEFT", 14, -30)
    frame.attrText:SetPoint("TOPRIGHT", -14, -30)
    frame.attrText:SetJustifyH("LEFT")
    Blackacre.UI.Theme.InkFont(frame.attrText)

    local weapon = Category(frame, "Weapon stats", -184, 90)
    local function MakeCheck(label, parent, y, get, set)
        local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", 8, y)
        cb:SetChecked(get())
        local text = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        text:SetPoint("LEFT", cb, "RIGHT", 4, 0)
        text:SetText(label)
        Blackacre.UI.Theme.InkFont(text)
        cb:SetScript("OnClick", function(self)
            set(self:GetChecked())
            frame.status:SetText(StatusLine())
            Blackacre.UI.Theme.Toast(self:GetChecked() and "Rite Complete" or "Rite Incomplete", "maw")
        end)
        return cb
    end

    frame.groundCheck = MakeCheck("Ground Rite: Completed/Incomplete", weapon, -28, function()
        return Blackacre.CharDB.gate.ground
    end, function(v)
        Blackacre.Hardcore.SetGroundGate(v)
    end)

    local openJournal = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    openJournal:SetSize(140, 24)
    openJournal:SetPoint("BOTTOMLEFT", 14, 12)
    openJournal:SetText("Open chronicle")
    openJournal:SetScript("OnClick", function()
        if Blackacre.TomeHub then Blackacre.TomeHub.Show("chronicle") end
    end)

    local refresh = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    refresh:SetSize(90, 24)
    refresh:SetPoint("BOTTOMRIGHT", -14, 12)
    refresh:SetText("Refresh")
    refresh:SetScript("OnClick", function()
        Blackacre.Hardcore.UI.Refresh()
    end)

    frame.footer = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    frame.footer:SetPoint("BOTTOM", 0, 42)
    frame.footer:SetText("Max bag size, 6 slots.")
end

function Blackacre.Hardcore.UI.Mount(parent)
    if not frame then Build(parent)
    elseif parent then Blackacre.UI.Theme.MountInPage(frame, parent) end
    frame:Show()
    Blackacre.Hardcore.UI.Refresh()
end

function Blackacre.Hardcore.UI.Init()
end

function Blackacre.Hardcore.UI.Refresh()
    if not frame then return end
    frame.status:SetText(StatusLine())
    if frame.attrText then
        local line = "Survival meters off"
        if Blackacre.Survival and Blackacre.Survival.GetState then
            local sv = Blackacre.Survival.GetState()
            if sv and sv.enabled ~= false then
                line = string.format(
                    "Hunger %d   Thirst %d   Exposure %d",
                    math.floor(sv.hunger or 0),
                    math.floor(sv.thirst or 0),
                    math.floor(sv.exposure or 0)
                )
            end
        end
        frame.attrText:SetText(line)
    end
    if frame.groundCheck then
        frame.groundCheck:SetChecked(Blackacre.CharDB.gate.ground)
    end
    if frame.flyCheck then
        frame.flyCheck:SetChecked(Blackacre.CharDB.gate.flying)
    end
end

function Blackacre.Hardcore.UI.Toggle()
    if Blackacre.TomeHub and Blackacre.TomeHub.Toggle then
        Blackacre.TomeHub.Toggle("honor")
        return
    end
    if not frame then Build(UIParent) end
    if frame:IsShown() then frame:Hide() else frame:Show(); Blackacre.Hardcore.UI.Refresh() end
end
