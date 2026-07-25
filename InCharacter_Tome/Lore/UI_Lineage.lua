InCharacter = InCharacter or {}
InCharacter.Lore = InCharacter.Lore or {}
InCharacter.LineageUI = {}

local frame
local eraButtons = {}

local function SoftToast(msg)
    if InCharacter.UI and InCharacter.UI.Theme and InCharacter.UI.Theme.Toast then
        InCharacter.UI.Theme.Toast(msg)
    else
        InCharacter.Print(msg)
    end
end

local function RefreshReadout()
    if not frame then return end
    local id = InCharacter.YearCalendar.EnsureIdentity()
    frame.birthBox:SetText(id.birthYearADP ~= nil and tostring(id.birthYearADP) or "")
    frame.presentBox:SetText(tostring(InCharacter.YearCalendar.GetPresentADP()))
    frame.placeBox:SetText(id.birthPlace or "")
    frame.stasisBox:SetText(id.stasisUntilADP ~= nil and tostring(id.stasisUntilADP) or "")

    local _, pid = InCharacter.GetLongevityProfile()
    frame.profileText:SetText("Longevity: " .. pid .. " (" .. (InCharacter.GetLongevityProfile().label or "") .. ")")
    frame.originText:SetText("Origin: " .. (id.originMode or "born"))
    frame.summary:SetText(InCharacter.Birthpath.GetSummary())

    local sugg = InCharacter.Birthpath.GetZoneSuggestions(5)
    local lines = {}
    for _, s in ipairs(sugg) do
        lines[#lines + 1] = string.format("· [%s %d] %s", s.fit, s.score, s.zone.name)
    end
    local presets = InCharacter.Birthpath.GetPresetSuggestions(2)
    for _, p in ipairs(presets) do
        lines[#lines + 1] = string.format("· Road: %s (%.0f)", p.preset.name, p.score)
    end
    frame.suggest:SetText(table.concat(lines, "\n"))
end

local ORIGINS = { "born", "stasis", "forged", "raised", "awakened" }
local PROFILES = { "auto", "mortal", "long_lived", "elf", "earthen", "dracthyr", "undead" }

local function Build()
    frame = CreateFrame("Frame", "InCharacterLineage", UIParent, "BackdropTemplate")
    frame:SetSize(520, 480)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("HIGH")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()
    tinsert(UISpecialFrames, "InCharacterLineage")
    InCharacter.UI.Theme.ApplyParchmentBackdrop(frame, 0.98)

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -12)
    title:SetText("Lineage")
    InCharacter.UI.Theme.GoldTitle(title)

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -2, -2)

    local help = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    help:SetPoint("TOPLEFT", 16, -36)
    help:SetWidth(480)
    help:SetJustifyH("LEFT")
    help:SetText("Years are portal-relative: 0 = Dark Portal (592 K.C.). Negative = years before the Portal (BDP). Soft RP guide only.")
    InCharacter.UI.Theme.InkFont(help)

    -- Left: era list
    frame.left = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.left:SetPoint("TOPLEFT", 14, -70)
    frame.left:SetSize(200, 280)
    frame.left:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    frame.left:SetBackdropColor(0.95, 0.90, 0.78, 0.5)
    frame.left:SetBackdropBorderColor(0.45, 0.35, 0.2, 0.9)

    local lt = frame.left:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lt:SetPoint("TOPLEFT", 8, -6)
    lt:SetText("Era quick-pick")
    InCharacter.UI.Theme.InkFont(lt, "header")

    local scroll = CreateFrame("ScrollFrame", nil, frame.left, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 4, -24)
    scroll:SetPoint("BOTTOMRIGHT", -26, 6)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(160, 40)
    scroll:SetScrollChild(content)

    local y = -2
    for i, era in ipairs(InCharacter.TimelineEras) do
        local btn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
        btn:SetSize(155, 22)
        btn:SetPoint("TOPLEFT", 2, y)
        btn:SetText(era.name:sub(1, 22))
        btn:SetScript("OnClick", function()
            local mid = math.floor((era.startADP + era.endADP) / 2)
            InCharacter.YearCalendar.SetBirthADP(mid, era.id)
            SoftToast("Birth set near " .. era.name)
            RefreshReadout()
        end)
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(era.name)
            GameTooltip:AddLine(era.blurb, 1, 1, 1, true)
            GameTooltip:AddLine(string.format("%d … %d ADP", era.startADP, era.endADP), 0.8, 0.8, 0.8)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", GameTooltip_Hide)
        eraButtons[i] = btn
        y = y - 24
    end
    content:SetHeight(math.abs(y) + 8)

    -- Right: fields
    local function Label(text, py)
        local fs = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        fs:SetPoint("TOPLEFT", 230, py)
        fs:SetText(text)
        InCharacter.UI.Theme.InkFont(fs)
        return fs
    end
    local function Box(py, w)
        local eb = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
        eb:SetSize(w or 100, 20)
        eb:SetPoint("TOPLEFT", 360, py + 2)
        eb:SetAutoFocus(false)
        return eb
    end

    Label("Birth year (ADP)", -70)
    frame.birthBox = Box(-70)
    Label("Present year (ADP)", -95)
    frame.presentBox = Box(-95)
    Label("Birthplace", -120)
    frame.placeBox = Box(-120, 140)
    Label("Stasis until (ADP)", -145)
    frame.stasisBox = Box(-145)

    frame.profileText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.profileText:SetPoint("TOPLEFT", 230, -175)
    frame.profileText:SetWidth(260)
    InCharacter.UI.Theme.InkFont(frame.profileText)

    frame.originText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.originText:SetPoint("TOPLEFT", 230, -195)
    InCharacter.UI.Theme.InkFont(frame.originText)

    -- Origin cycle
    local originBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    originBtn:SetSize(110, 22)
    originBtn:SetPoint("TOPLEFT", 230, -220)
    originBtn:SetText("Cycle origin")
    originBtn:SetScript("OnClick", function()
        local id = InCharacter.YearCalendar.EnsureIdentity()
        local cur = id.originMode or "born"
        local idx = 1
        for i, o in ipairs(ORIGINS) do if o == cur then idx = i break end end
        id.originMode = ORIGINS[(idx % #ORIGINS) + 1]
        RefreshReadout()
    end)

    local profileBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    profileBtn:SetSize(110, 22)
    profileBtn:SetPoint("LEFT", originBtn, "RIGHT", 8, 0)
    profileBtn:SetText("Cycle profile")
    profileBtn:SetScript("OnClick", function()
        local id = InCharacter.YearCalendar.EnsureIdentity()
        local cur = id.longevityProfile or "auto"
        local idx = 1
        for i, o in ipairs(PROFILES) do if o == cur then idx = i break end end
        id.longevityProfile = PROFILES[(idx % #PROFILES) + 1]
        RefreshReadout()
    end)

    frame.summary = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.summary:SetPoint("TOPLEFT", 230, -255)
    frame.summary:SetWidth(270)
    frame.summary:SetJustifyH("LEFT")
    InCharacter.UI.Theme.InkFont(frame.summary)

    local sugTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sugTitle:SetPoint("TOPLEFT", 230, -320)
    sugTitle:SetText("Suggestions")
    InCharacter.UI.Theme.InkFont(sugTitle, "header")

    frame.suggest = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.suggest:SetPoint("TOPLEFT", 230, -340)
    frame.suggest:SetWidth(270)
    frame.suggest:SetJustifyH("LEFT")
    InCharacter.UI.Theme.InkFont(frame.suggest)

    local save = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    save:SetSize(100, 24)
    save:SetPoint("BOTTOMLEFT", 16, 14)
    save:SetText("Save lineage")
    save:SetScript("OnClick", function()
        local id = InCharacter.YearCalendar.EnsureIdentity()
        local b = tonumber(frame.birthBox:GetText())
        local p = tonumber(frame.presentBox:GetText())
        local s = tonumber(frame.stasisBox:GetText())
        if b then InCharacter.YearCalendar.SetBirthADP(b) end
        if p then InCharacter.YearCalendar.SetPresentADP(p) end
        id.birthPlace = frame.placeBox:GetText() or ""
        id.stasisUntilADP = s
        InCharacter.Birthpath.OnBirthSet()
        SoftToast("Lineage saved to the chronicle.")
        RefreshReadout()
    end)

    local chart = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    chart:SetSize(130, 24)
    chart:SetPoint("LEFT", save, "RIGHT", 8, 0)
    chart:SetText("Chart from birth")
    chart:SetScript("OnClick", function()
        if not InCharacter.YearCalendar.GetBirthADP() then
            SoftToast("Set a birth year first.")
            return
        end
        InCharacter.Birthpath.ChartFromBirth()
        if InCharacter.Roadmap and InCharacter.Roadmap.UI then
            InCharacter.Roadmap.UI.Toggle()
        end
    end)

    local road = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    road:SetSize(100, 24)
    road:SetPoint("BOTTOMRIGHT", -16, 14)
    road:SetText("Expedition")
    road:SetScript("OnClick", function()
        InCharacter.Roadmap.UI.Toggle()
    end)
end

function InCharacter.LineageUI.Toggle()
    if not frame then Build() end
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
        RefreshReadout()
    end
end

function InCharacter.LineageUI.Init()
    InCharacter.YearCalendar.EnsureIdentity()
end