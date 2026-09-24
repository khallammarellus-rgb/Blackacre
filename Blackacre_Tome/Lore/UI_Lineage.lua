Blackacre = Blackacre or {}
Blackacre.Lore = Blackacre.Lore or {}
Blackacre.LineageUI = {}

local frame
local eraButtons = {}
local mounted = false
local viewIndex = 1
local orbSlots = {}
local SIDE = 2 -- orbs each side of center (5 total)
local RefreshEpochs

local function SoftToast(msg)
    if Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.Toast then
        Blackacre.UI.Theme.Toast(msg)
    else
        Blackacre.Print(msg)
    end
end

local function IsForever()
    return Blackacre.Compat and Blackacre.Compat.IsForever and Blackacre.Compat.IsForever()
end

local function RefreshReadout()
    if not frame or not frame.birthBox then return end
    local id = Blackacre.YearCalendar.EnsureIdentity()
    frame.birthBox:SetText(id.birthYearADP ~= nil and tostring(id.birthYearADP) or "")
    frame.presentBox:SetText(tostring(Blackacre.YearCalendar.GetPresentADP()))
    frame.placeBox:SetText(id.birthPlace or "")
    frame.stasisBox:SetText(id.stasisUntilADP ~= nil and tostring(id.stasisUntilADP) or "")

    if frame.profileText then frame.profileText:Hide() end
    if frame.originText then frame.originText:Hide() end
    if frame.summary then frame.summary:Hide() end
    RefreshEpochs()

    if frame.suggest and not IsForever() then
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
end

local ORIGINS = { "born", "stasis", "forged", "raised", "awakened" }
local PROFILES_RETAIL = { "auto", "mortal", "long_lived", "elf", "earthen", "dracthyr", "undead" }
local PROFILES_FOREVER = { "auto", "mortal", "long_lived", "elf", "undead" }

local function LongevityChoices()
    if Blackacre.Compat and Blackacre.Compat.IsForever and Blackacre.Compat.IsForever() then
        return PROFILES_FOREVER
    end
    return PROFILES_RETAIL
end

local function ApplyMember(tex, name, flipH)
    if not tex or not name or not C_Texture or not C_Texture.GetAtlasInfo then return false end
    local info = C_Texture.GetAtlasInfo(name)
    if not info or not (info.filename or info.file) then return false end
    tex:SetTexture(info.filename or info.file)
    local l = info.leftTexCoord or info.left or 0
    local r = info.rightTexCoord or info.right or 1
    local t = info.topTexCoord or info.top or 0
    local b = info.bottomTexCoord or info.bottom or 1
    if flipH then
        tex:SetTexCoord(r, l, t, b)
    else
        tex:SetTexCoord(l, r, t, b)
    end
    if tex.SetHorizTile then tex:SetHorizTile(false) end
    if tex.SetVertTile then tex:SetVertTile(false) end
    tex:Show()
    return true
end

local FADE = { [0] = 1, [1] = 0.55, [2] = 0.22 }
local NIFFEN_ORB = "UI-niffen-HeaderOrb-Level0"
local ERA_ORB = {
    dragon_age = "UI-Expedition-HeaderOrb-Level0",
    troll_empires = "ui-rocket-headerorb-level0",
    well_of_eternity = "ui-Karesh-headerorb-level0",
    war_of_ancients = "UI-Valdrakken-HeaderOrb-Level0",
    long_vigil = "UI-Dream-Headerorb-Level0",
    highborne_exile = "ui-flame-headerorb-level0",
    pre_portal = "ui-nightfall-headerorb-level0",
    first_war = "ui-candle-headerorb-level0",
    second_war = "UI-Tuskarr-HeaderOrb-Level0",
    internment = "UI-Centaur-HeaderOrb-Level0",
    rising_darkness = "ui-Karesh-headerorb-level0",
    third_war = "UI-Tuskarr-HeaderOrb-Level0",
}
local ARROW_ATLAS = {
    idle = "CovenantSanctum-Renown-Arrow",
    hover = "CovenantSanctum-Renown-Arrow-Hover",
    down = "CovenantSanctum-Renown-Arrow-Depressed",
    off = "CovenantSanctum-Renown-Arrow-Disabled",
}

local function PaintArrow(btn, state)
    if not btn or not btn.icon then return end
    ApplyMember(btn.icon, ARROW_ATLAS[state] or ARROW_ATLAS.idle, btn.flip)
end

local function ApplyOrb(tex, era)
    local name = (era and ERA_ORB[era.id]) or NIFFEN_ORB
    if not ApplyMember(tex, name, false) then
        ApplyMember(tex, NIFFEN_ORB, false)
    end
end

function RefreshEpochs()
    local eras = (Blackacre.ListEras and Blackacre.ListEras()) or Blackacre.TimelineEras or {}
    local n = #eras
    if n < 1 then return end
    if viewIndex < 1 then viewIndex = 1 end
    if viewIndex > n then viewIndex = n end
    for _, slot in ipairs(orbSlots) do
        local eraI = viewIndex + slot.offset
        local era = eras[eraI]
        if era then
            slot:Show()
            slot.era = era
            ApplyOrb(slot.orb, era)
            local a = FADE[math.abs(slot.offset)] or 0.15
            slot:SetAlpha(a)
            if slot.offset == 0 then
                slot:SetScale(1)
            elseif math.abs(slot.offset) == 1 then
                slot:SetScale(0.88)
            else
                slot:SetScale(0.76)
            end
        else
            slot.era = nil
            slot:Hide()
        end
    end
    if frame and frame.leftArr then
        frame.leftArr:SetNavEnabled(viewIndex > 1)
        frame.rightArr:SetNavEnabled(viewIndex < n)
    end
end

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

    -- Timeline carousel. Sidecar header already says Lineage.
    frame.left = CreateFrame("Frame", nil, frame)
    frame.left:SetPoint("TOPLEFT", 8, -6)
    frame.left:SetPoint("TOPRIGHT", -8, -6)
    frame.left:SetHeight(132)

    local function MakeArrow(flip)
        local btn = CreateFrame("Button", nil, frame.left)
        btn:SetSize(32, 32)
        btn.flip = flip and true or false
        local tex = btn:CreateTexture(nil, "ARTWORK")
        tex:SetAllPoints()
        btn.icon = tex
        PaintArrow(btn, "idle")
        function btn:SetNavEnabled(on)
            self._disabled = not on
            PaintArrow(self, on and "idle" or "off")
        end
        btn:SetScript("OnEnter", function(self)
            if self._disabled then return end
            PaintArrow(self, "hover")
        end)
        btn:SetScript("OnLeave", function(self)
            PaintArrow(self, self._disabled and "off" or "idle")
        end)
        btn:SetScript("OnMouseDown", function(self)
            if self._disabled then return end
            PaintArrow(self, "down")
        end)
        btn:SetScript("OnMouseUp", function(self)
            if self._disabled then return end
            PaintArrow(self, self:IsMouseOver() and "hover" or "idle")
        end)
        return btn
    end
    local leftArr = MakeArrow(false)
    leftArr:SetPoint("LEFT", 18, -8)
    leftArr:SetScript("OnClick", function()
        if leftArr._disabled then return end
        viewIndex = viewIndex - 1
        RefreshEpochs()
    end)
    local rightArr = MakeArrow(true)
    rightArr:SetPoint("RIGHT", -18, -8)
    rightArr:SetScript("OnClick", function()
        if rightArr._disabled then return end
        viewIndex = viewIndex + 1
        RefreshEpochs()
    end)
    frame.leftArr = leftArr
    frame.rightArr = rightArr

    local track = CreateFrame("Frame", nil, frame.left)
    track:SetPoint("LEFT", leftArr, "RIGHT", 4, -8)
    track:SetPoint("RIGHT", rightArr, "LEFT", -4, -8)
    track:SetHeight(72)
    if track.SetClipsChildren then track:SetClipsChildren(true) end

    local ORB = 74
    local GAP = 6
    for i = -SIDE, SIDE do
        local slot = CreateFrame("Frame", nil, track)
        slot:SetSize(ORB, ORB)
        slot:SetPoint("CENTER", track, "CENTER", i * (ORB + GAP), 0)
        slot.offset = i

        local mid = slot:CreateTexture(nil, "BACKGROUND")
        mid:SetAllPoints()
        ApplyMember(mid, "UI-niffen-Highlight-Middle", false)
        slot.mid = mid

        local orb = slot:CreateTexture(nil, "ARTWORK")
        orb:SetSize(50, 50)
        orb:SetPoint("CENTER", 0, 0)
        ApplyMember(orb, "UI-niffen-HeaderOrb-Level0", false)
        slot.orb = orb

        local topH = slot:CreateTexture(nil, "OVERLAY")
        topH:SetPoint("TOPLEFT", mid, "TOPLEFT", 0, 0)
        topH:SetPoint("TOPRIGHT", mid, "TOPRIGHT", 0, 0)
        topH:SetHeight(18)
        if not ApplyMember(topH, "UI-niffen-Highlight-Top", false) then
            ApplyMember(topH, "UI-Niffen-Highlight-Top", false)
        end

        local botH = slot:CreateTexture(nil, "OVERLAY")
        botH:SetPoint("BOTTOMLEFT", mid, "BOTTOMLEFT", 0, 0)
        botH:SetPoint("BOTTOMRIGHT", mid, "BOTTOMRIGHT", 0, 0)
        botH:SetHeight(18)
        if not ApplyMember(botH, "UI-Niffen-Highlight-Bottom", false) then
            ApplyMember(botH, "UI-niffen-Highlight-Bottom", false)
        end

        slot:EnableMouse(true)
        slot:SetScript("OnEnter", function(self)
            local era = self.era
            if not era then return end
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
            GameTooltip:AddLine(era.name)
            GameTooltip:AddLine(era.blurb, 1, 1, 1, true)
            GameTooltip:AddLine(string.format("%d … %d ADP", era.startADP, era.endADP), 0.8, 0.8, 0.8)
            GameTooltip:Show()
        end)
        slot:SetScript("OnLeave", GameTooltip_Hide)
        orbSlots[#orbSlots + 1] = slot
    end

    local selectBtn = CreateFrame("Button", nil, frame.left, "UIPanelButtonTemplate")
    selectBtn:SetSize(130, 22)
    selectBtn:SetPoint("BOTTOM", 0, -4)
    selectBtn:SetText("Set Birth Era")
    selectBtn:SetScript("OnClick", function()
        local eras = (Blackacre.ListEras and Blackacre.ListEras()) or Blackacre.TimelineEras or {}
        local era = eras[viewIndex]
        if not era then return end
        local midY = math.floor((era.startADP + era.endADP) / 2)
        if era.id == "third_war" and Blackacre.MinAdultBirthADP then
            local adult = Blackacre.MinAdultBirthADP()
            if adult >= era.startADP and adult <= era.endADP then
                midY = adult
            end
        end
        Blackacre.YearCalendar.SetBirthADP(midY, era.id)
        if Blackacre.Birthpath and Blackacre.Birthpath.RefreshFlavor then
            Blackacre.Birthpath.RefreshFlavor()
        end
        SoftToast("Birth set in the era of " .. era.name)
        RefreshReadout()
    end)

    local id = Blackacre.YearCalendar.EnsureIdentity()
    viewIndex = 1
    local erasForIndex = (Blackacre.ListEras and Blackacre.ListEras()) or Blackacre.TimelineEras or {}
    if id and id.birthEraId then
        for i, e in ipairs(erasForIndex) do
            if e.id == id.birthEraId then viewIndex = i break end
        end
    else
        for i, e in ipairs(erasForIndex) do
            if e.id == "first_war" then viewIndex = i break end
        end
    end
    RefreshEpochs()

    local right = CreateFrame("Frame", nil, frame)
    right:SetPoint("TOPLEFT", 12, -148)
    right:SetPoint("BOTTOMRIGHT", -12, 44)
    frame.right = right

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

    local function YearUnit()
        local faction = UnitFactionGroup and UnitFactionGroup("player")
        if faction == "Horde" then return "ADP" end
        return "KC"
    end
    Label("Birth Year (" .. YearUnit() .. ")", 0)
    frame.birthBox = Box(0)
    Label("Present Year (" .. YearUnit() .. ")", -26)
    frame.presentBox = Box(-26)
    Label("Birthplace", -52)
    frame.placeBox = Box(-52, 160)
    local stasisLabel = Label("Stasis until (ADP)", -78)
    frame.stasisBox = Box(-78)
    stasisLabel:Hide()
    frame.stasisBox:Hide()

    frame.profileText = right:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.profileText:SetPoint("TOPLEFT", 0, -110)
    frame.profileText:SetWidth(320)
    Blackacre.UI.Theme.InkFont(frame.profileText)

    frame.originText = right:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.originText:SetPoint("TOPLEFT", 0, -128)
    Blackacre.UI.Theme.InkFont(frame.originText)

    if not IsForever() then
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
            local profiles = LongevityChoices()
            for i, o in ipairs(profiles) do if o == cur then idx = i break end end
            id.longevityProfile = profiles[(idx % #profiles) + 1]
            RefreshReadout()
        end)
    end

    frame.summary = right:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.summary:SetPoint("TOPLEFT", 0, IsForever() and -152 or -186)
    frame.summary:SetPoint("TOPRIGHT", 0, -186)
    frame.summary:SetJustifyH("LEFT")
    frame.summary:Hide()
    Blackacre.UI.Theme.InkFont(frame.summary)

    if not IsForever() then
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
    end

    local save = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    frame.saveBtn = save
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
        if Blackacre.Birthpath and Blackacre.Birthpath.RefreshFlavor then
            Blackacre.Birthpath.RefreshFlavor()
        end
        SoftToast("Character Sheet Successfully Updated")
        RefreshReadout()
    end)

    if not IsForever() then
        local chart = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
        chart:SetSize(130, 24)
        chart:SetPoint("LEFT", save, "RIGHT", 8, 0)
        chart:SetText("Chart from birth")
        chart:SetScript("OnClick", function()
            if not Blackacre.YearCalendar.GetBirthADP() then
                if Blackacre.Print then
                    Blackacre.Print("Set a birth year first")
                end
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
    end

    mounted = embedded
end

function Blackacre.LineageUI.Mount(parent)
    if frame and not frame.birthBox then
        frame:Hide()
        frame = nil
        orbSlots = {}
    end
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
