Blackacre = Blackacre or {}
Blackacre.Lore = Blackacre.Lore or {}
Blackacre.LineageUI = {}

local frame
local eraButtons = {}
local mounted = false

local function SoftToast(msg)
    if Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.Toast then
        Blackacre.UI.Theme.Toast(msg)
    else
        Blackacre.Print(msg)
    end
end

local function RefreshReadout()
    if not frame then return end
    local id = Blackacre.YearCalendar.EnsureIdentity()
    frame.birthBox:SetText(id.birthYearADP ~= nil and tostring(id.birthYearADP) or "")
    frame.presentBox:SetText(tostring(Blackacre.YearCalendar.GetPresentADP()))
    frame.placeBox:SetText(id.birthPlace or "")
    frame.stasisBox:SetText(id.stasisUntilADP ~= nil and tostring(id.stasisUntilADP) or "")

    local profile, pid = Blackacre.GetLongevityProfile()
    frame.profileText:SetText("Longevity: " .. tostring(pid) .. " (" .. (profile and profile.label or "") .. ")")
    frame.originText:SetText("Origin: " .. (id.originMode or "born"))
    frame.summary:SetText(Blackacre.Birthpath.GetSummary())

    local sugg = Blackacre.Birthpath.GetZoneSuggestions(5)
    local lines = {}
    for _, s in ipairs(sugg) do
        lines[#lines + 1] = string.format("· [%s %d] %s", s.fit, s.score, s.zone.name)
    end
    local presets = Blackacre.Birthpath.GetPresetSuggestions(2)
    for _, p in ipairs(presets) do
        lines[#lines + 1] = string.format("· Road: %s (%.0f)", p.preset.name, p.score)
    end
    frame.suggest:SetText(table.concat(lines, "\n"))
end

local ORIGINS = { "born", "stasis", "forged", "raised", "awakened" }
local PROFILES = { "auto", "mortal", "long_lived", "elf", "earthen", "dracthyr", "undead" }

local function Build(parent)
    parent = parent or UIParent
    local embedded = parent ~= UIParent

    frame = CreateFrame("Frame", "BlackacreLineage", parent, "BackdropTemplate")
    if embedded then
        frame:SetAllPoints(parent)
    else
        frame:SetSize(520, 480)
        frame:SetPoint("CENTER")
        frame:SetFrameStrata("HIGH")
        frame:Hide()
        tinsert(UISpecialFrames, "BlackacreLineage")
        Blackacre.UI.Theme.ApplyFilledPanel(frame, 0.96, "page")
    end
    if frame.SetClipsChildren then frame:SetClipsChildren(true) end

    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 12, -10)
    title:SetText("Lineage")
    Blackacre.UI.Theme.GoldTitle(title)

    local help = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    help:SetPoint("TOPLEFT", 12, -32)
    help:SetPoint("TOPRIGHT", -12, -32)
    help:SetJustifyH("LEFT")
    help:SetText("Years are portal-relative: 0 = Dark Portal (592 K.C.). Negative = years before the Portal (BDP). Soft RP guide only.")
    Blackacre.UI.Theme.InkFont(help)

    frame.left = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.left:SetPoint("TOPLEFT", 10, -56)
    frame.left:SetPoint("BOTTOMLEFT", 10, 44)
    frame.left:SetWidth(200)
    Blackacre.UI.Theme.ApplyFilledPanel(frame.left, 0.9, "panel")

    local lt = frame.left:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lt:SetPoint("TOPLEFT", 8, -6)
    lt:SetText("Era quick-pick")
    Blackacre.UI.Theme.InkFont(lt, "header")

    local scroll = CreateFrame("ScrollFrame", nil, frame.left, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 4, -24)
    scroll:SetPoint("BOTTOMRIGHT", -26, 6)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(160, 40)
    scroll:SetScrollChild(content)

    local y = -2
    for i, era in ipairs(Blackacre.TimelineEras or {}) do
        local btn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
        btn:SetSize(155, 22)
        btn:SetPoint("TOPLEFT", 2, y)
        btn:SetText(era.name:sub(1, 22))
        btn:SetScript("OnClick", function()
            local mid = math.floor((era.startADP + era.endADP) / 2)
            Blackacre.YearCalendar.SetBirthADP(mid, era.id)
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

    local right = CreateFrame("Frame", nil, frame)
    right:SetPoint("TOPLEFT", frame.left, "TOPRIGHT", 12, 0)
    right:SetPoint("BOTTOMRIGHT", -12, 44)

    local function Label(text, py)
        local fs = right:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        fs:SetPoint("TOPLEFT", 0, py)
        fs:SetText(text)
        Blackacre.UI.Theme.InkFont(fs)
        return fs
    end
    local function Box(py, w)
        local eb = CreateFrame("EditBox", nil, right, "InputBoxTemplate")
        eb:SetSize(w or 100, 20)
        eb:SetPoint("TOPLEFT", 140, py + 2)
        eb:SetAutoFocus(false)
        return eb
    end

    Label("Birth year (ADP)", 0)
    frame.birthBox = Box(0)
    Label("Present year (ADP)", -26)
    frame.presentBox = Box(-26)
    Label("Birthplace", -52)
    frame.placeBox = Box(-52, 160)
    Label("Stasis until (ADP)", -78)
    frame.stasisBox = Box(-78)

    frame.profileText = right:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.profileText:SetPoint("TOPLEFT", 0, -110)
    frame.profileText:SetWidth(320)
    Blackacre.UI.Theme.InkFont(frame.profileText)

    frame.originText = right:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.originText:SetPoint("TOPLEFT", 0, -128)
    Blackacre.UI.Theme.InkFont(frame.originText)

    local originBtn = CreateFrame("Button", nil, right, "UIPanelButtonTemplate")
    originBtn:SetSize(110, 22)
    originBtn:SetPoint("TOPLEFT", 0, -152)
    originBtn:SetText("Cycle origin")
    originBtn:SetScript("OnClick", function()
        local id = Blackacre.YearCalendar.EnsureIdentity()
        local cur = id.originMode or "born"
        local idx = 1
        for i, o in ipairs(ORIGINS) do if o == cur then idx = i break end end
        id.originMode = ORIGINS[(idx % #ORIGINS) + 1]
        RefreshReadout()
    end)

    local profileBtn = CreateFrame("Button", nil, right, "UIPanelButtonTemplate")
    profileBtn:SetSize(110, 22)
    profileBtn:SetPoint("LEFT", originBtn, "RIGHT", 8, 0)
    profileBtn:SetText("Cycle profile")
    profileBtn:SetScript("OnClick", function()
        local id = Blackacre.YearCalendar.EnsureIdentity()
        local cur = id.longevityProfile or "auto"
        local idx = 1
        for i, o in ipairs(PROFILES) do if o == cur then idx = i break end end
        id.longevityProfile = PROFILES[(idx % #PROFILES) + 1]
        RefreshReadout()
    end)

    frame.summary = right:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.summary:SetPoint("TOPLEFT", 0, -186)
    frame.summary:SetPoint("TOPRIGHT", 0, -186)
    frame.summary:SetJustifyH("LEFT")
    Blackacre.UI.Theme.InkFont(frame.summary)

    local sugTitle = right:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    sugTitle:SetPoint("TOPLEFT", 0, -250)
    sugTitle:SetText("Suggestions")
    Blackacre.UI.Theme.InkFont(sugTitle, "header")

    frame.suggest = right:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.suggest:SetPoint("TOPLEFT", 0, -270)
    frame.suggest:SetPoint("BOTTOMRIGHT", 0, 4)
    frame.suggest:SetJustifyH("LEFT")
    frame.suggest:SetJustifyV("TOP")
    Blackacre.UI.Theme.InkFont(frame.suggest)

    local save = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    save:SetSize(100, 24)
    save:SetPoint("BOTTOMLEFT", 12, 12)
    save:SetText("Save lineage")
    save:SetScript("OnClick", function()
        local id = Blackacre.YearCalendar.EnsureIdentity()
        local b = tonumber(frame.birthBox:GetText())
        local p = tonumber(frame.presentBox:GetText())
        local s = tonumber(frame.stasisBox:GetText())
        if b then Blackacre.YearCalendar.SetBirthADP(b) end
        if p then Blackacre.YearCalendar.SetPresentADP(p) end
        id.birthPlace = frame.placeBox:GetText() or ""
        id.stasisUntilADP = s
        Blackacre.Birthpath.OnBirthSet()
        SoftToast("Lineage saved to the chronicle.")
        RefreshReadout()
    end)

    local chart = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    chart:SetSize(130, 24)
    chart:SetPoint("LEFT", save, "RIGHT", 8, 0)
    chart:SetText("Chart from birth")
    chart:SetScript("OnClick", function()
        if not Blackacre.YearCalendar.GetBirthADP() then
            SoftToast("Set a birth year first.")
            return
        end
        Blackacre.Birthpath.ChartFromBirth()
        if Blackacre.TomeHub then
            Blackacre.TomeHub.Show("road")
        end
    end)

    local road = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    road:SetSize(100, 24)
    road:SetPoint("BOTTOMRIGHT", -12, 12)
    road:SetText("Expedition")
    road:SetScript("OnClick", function()
        if Blackacre.TomeHub then
            Blackacre.TomeHub.Show("road")
        end
    end)

    mounted = embedded
end

function Blackacre.LineageUI.Mount(parent)
    if not frame then
        Build(parent)
    elseif parent and frame:GetParent() ~= parent then
        Blackacre.UI.Theme.MountInPage(frame, parent)
    end
    frame:Show()
    RefreshReadout()
end

function Blackacre.LineageUI.Refresh()
    RefreshReadout()
end

function Blackacre.LineageUI.Toggle()
    if Blackacre.TomeHub and Blackacre.TomeHub.Toggle then
        Blackacre.TomeHub.Toggle("lineage")
        return
    end
    if not frame then Build(UIParent) end
    if frame:IsShown() then frame:Hide() else frame:Show(); RefreshReadout() end
end

function Blackacre.LineageUI.Init()
    Blackacre.YearCalendar.EnsureIdentity()
end
