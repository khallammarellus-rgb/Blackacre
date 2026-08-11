Blackacre = Blackacre or {}
Blackacre.SetupWizard = {}

local step = 1
local MAX_STEP = 6
local root
local widgets = {}

local function EnsureSetupDB()
    Blackacre.CharDB.setup = Blackacre.CharDB.setup or {
        completed = false,
        version = 1,
    }
    return Blackacre.CharDB.setup
end

--- Soft migrate: veterans with data skip auto-wizard.
function Blackacre.SetupWizard.ShouldAutoShow()
    local s = EnsureSetupDB()
    if s.completed then return false end
    local id = Blackacre.CharDB.identity
    if id and id.birthYearADP ~= nil then
        s.completed = true
        return false
    end
    local entries = Blackacre.CharDB.chronicle and Blackacre.CharDB.chronicle.entries
    if entries and #entries > 0 then
        s.completed = true
        return false
    end
    return true
end

local function SetStepVisible(n)
    for i = 1, MAX_STEP do
        if widgets.panels[i] then
            if i == n then widgets.panels[i]:Show() else widgets.panels[i]:Hide() end
        end
    end
    widgets.progress:SetText(string.format("Step %d of %d", n, MAX_STEP))
    widgets.back:SetEnabled(n > 1)
    if n >= MAX_STEP then
        widgets.next:SetText("Open your Tome")
    else
        widgets.next:SetText("Continue")
    end
end

local function Finish(skipped)
    local s = EnsureSetupDB()
    s.completed = true
    s.skipped = skipped and true or false
    s.completedAt = time()
    if Blackacre.TomeHub then
        Blackacre.TomeHub.SetSetupMode(false)
        Blackacre.TomeHub.Show("chronicle")
    end
    if Blackacre.UI and Blackacre.UI.Theme then
        Blackacre.UI.Theme.Toast(skipped and "Setup skipped — you can run /ic setup anytime."
            or "Your lineage is inscribed. Welcome to the road.")
    end
end

local function Build(parent)
    root = CreateFrame("Frame", "BlackacreSetupWizard", parent)
    root:SetAllPoints(parent)
    if root.SetClipsChildren then root:SetClipsChildren(true) end

    local title = root:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 14, -12)
    title:SetText("First steps on the road")
    Blackacre.UI.Theme.GoldTitle(title)

    widgets.progress = root:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    widgets.progress:SetPoint("TOPRIGHT", -14, -16)
    Blackacre.UI.Theme.InkFont(widgets.progress)

    widgets.panels = {}

    local function Panel(i)
        local p = CreateFrame("Frame", nil, root)
        p:SetPoint("TOPLEFT", 14, -48)
        p:SetPoint("BOTTOMRIGHT", -14, 52)
        p:Hide()
        widgets.panels[i] = p
        return p
    end

    -- 1 Welcome
    local p1 = Panel(1)
    local w1 = p1:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    w1:SetPoint("TOPLEFT", 0, 0)
    w1:SetPoint("TOPRIGHT", 0, 0)
    w1:SetJustifyH("LEFT")
    w1:SetSpacing(4)
    w1:SetText(
        "Welcome, traveler.\n\n" ..
        "|cffc9a227Blackacre|r is a private tome and presence suite — not OOC group finder.\n\n" ..
        "• The |cffffd100Tome|r holds your chronicle, lineage, honor, and rites in |cffc9a227one book|r.\n" ..
        "• |cffffd100Presence|r (minimap left-click) is beacons and bulletin boards.\n" ..
        "• Complements Total RP 3; never overwrites TRP3 data.\n\n" ..
        "This short guide helps you set who you are in the world."
    )
    Blackacre.UI.Theme.InkFont(w1)

    -- 2 Who you are
    local p2 = Panel(2)
    local w2 = p2:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    w2:SetPoint("TOPLEFT", 0, 0)
    w2:SetJustifyH("LEFT")
    w2:SetText("How others may know you (editable defaults):")
    Blackacre.UI.Theme.InkFont(w2)

    widgets.nameLabel = p2:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    widgets.nameLabel:SetPoint("TOPLEFT", 0, -36)
    Blackacre.UI.Theme.InkFont(widgets.nameLabel, "header")

    local resL = p2:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    resL:SetPoint("TOPLEFT", 0, -70)
    resL:SetText("Residence (remembered on this character)")
    Blackacre.UI.Theme.InkFont(resL)

    widgets.residence = CreateFrame("EditBox", nil, p2, "InputBoxTemplate")
    widgets.residence:SetSize(280, 24)
    widgets.residence:SetPoint("TOPLEFT", 0, -92)
    widgets.residence:SetAutoFocus(false)

    -- 3 Lineage (core)
    local p3 = Panel(3)
    local w3 = p3:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    w3:SetPoint("TOPLEFT", 0, 0)
    w3:SetPoint("TOPRIGHT", 0, 0)
    w3:SetJustifyH("LEFT")
    w3:SetText("When were you born? Years are portal-relative: 0 = Dark Portal. Negative = before the Portal (BDP).")
    Blackacre.UI.Theme.InkFont(w3)

    local bl = p3:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    bl:SetPoint("TOPLEFT", 0, -40)
    bl:SetText("Birth year (ADP)")
    Blackacre.UI.Theme.InkFont(bl)

    widgets.birth = CreateFrame("EditBox", nil, p3, "InputBoxTemplate")
    widgets.birth:SetSize(100, 22)
    widgets.birth:SetPoint("TOPLEFT", 140, -38)
    widgets.birth:SetAutoFocus(false)

    local pl = p3:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    pl:SetPoint("TOPLEFT", 0, -70)
    pl:SetText("Present year (ADP)")
    Blackacre.UI.Theme.InkFont(pl)

    widgets.present = CreateFrame("EditBox", nil, p3, "InputBoxTemplate")
    widgets.present:SetSize(100, 22)
    widgets.present:SetPoint("TOPLEFT", 140, -68)
    widgets.present:SetAutoFocus(false)

    local eraTitle = p3:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    eraTitle:SetPoint("TOPLEFT", 0, -105)
    eraTitle:SetText("Quick era (sets a mid-era birth)")
    Blackacre.UI.Theme.InkFont(eraTitle, "header")

    local eraHost = CreateFrame("Frame", nil, p3)
    eraHost:SetPoint("TOPLEFT", 0, -128)
    eraHost:SetSize(500, 120)
    local ex, ey, col = 0, 0, 0
    for i, era in ipairs(Blackacre.TimelineEras or {}) do
        if i > 8 then break end
        local btn = CreateFrame("Button", nil, eraHost, "UIPanelButtonTemplate")
        btn:SetSize(150, 24)
        btn:SetPoint("TOPLEFT", col * 158, ey)
        btn:SetText(era.name:sub(1, 18))
        btn:SetScript("OnClick", function()
            local mid = math.floor((era.startADP + era.endADP) / 2)
            widgets.birth:SetText(tostring(mid))
            Blackacre.YearCalendar.SetBirthADP(mid, era.id)
            widgets.summary:SetText(Blackacre.Birthpath.GetSummary())
        end)
        col = col + 1
        if col >= 3 then col = 0; ey = ey - 28 end
    end

    widgets.summary = p3:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    widgets.summary:SetPoint("TOPLEFT", 0, -260)
    widgets.summary:SetPoint("TOPRIGHT", 0, -260)
    widgets.summary:SetJustifyH("LEFT")
    Blackacre.UI.Theme.InkFont(widgets.summary)

    -- 4 Voice
    local p4 = Panel(4)
    local w4 = p4:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    w4:SetPoint("TOPLEFT", 0, 0)
    w4:SetJustifyH("LEFT")
    w4:SetText("How should new chronicle ink sound? One accent only — never mixed.")
    Blackacre.UI.Theme.InkFont(w4)

    widgets.accentDrop = CreateFrame("Frame", "BASetupVoiceAccent", p4, "UIDropDownMenuTemplate")
    widgets.accentDrop:SetPoint("TOPLEFT", -12, -40)
    UIDropDownMenu_SetWidth(widgets.accentDrop, 160)
    local accents = { "auto", "none", "dwarf", "orc", "undead", "goblin", "blood_elf", "night_elf", "human", "afrikaans" }
    UIDropDownMenu_Initialize(widgets.accentDrop, function()
        for _, id in ipairs(accents) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = id
            info.func = function()
                Blackacre.CharDB.voice = Blackacre.CharDB.voice or {}
                Blackacre.CharDB.voice.accent = id
                UIDropDownMenu_SetText(widgets.accentDrop, id)
                if Blackacre.Voice and Blackacre.Voice.Apply then
                    widgets.voiceSample:SetText("Sample: " .. Blackacre.Voice.Apply("I am looking for the thing, yes?"))
                end
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    widgets.voiceSample = p4:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    widgets.voiceSample:SetPoint("TOPLEFT", 0, -90)
    widgets.voiceSample:SetPoint("TOPRIGHT", 0, -90)
    widgets.voiceSample:SetJustifyH("LEFT")
    Blackacre.UI.Theme.InkFont(widgets.voiceSample)

    -- 5 Optional toggles
    local p5 = Panel(5)
    local w5 = p5:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    w5:SetPoint("TOPLEFT", 0, 0)
    w5:SetText("Optional — you can change these later.")
    Blackacre.UI.Theme.InkFont(w5)

    widgets.beaconCheck = CreateFrame("CheckButton", nil, p5, "UICheckButtonTemplate")
    widgets.beaconCheck:SetPoint("TOPLEFT", 0, -40)
    local bt = p5:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    bt:SetPoint("LEFT", widgets.beaconCheck, "RIGHT", 4, 0)
    bt:SetText("Receive presence beacons (talking-head)")
    Blackacre.UI.Theme.InkFont(bt)

    widgets.survCheck = CreateFrame("CheckButton", nil, p5, "UICheckButtonTemplate")
    widgets.survCheck:SetPoint("TOPLEFT", 0, -80)
    local st = p5:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    st:SetPoint("LEFT", widgets.survCheck, "RIGHT", 4, 0)
    st:SetText("Survival meters (hunger / thirst / exposure)")
    Blackacre.UI.Theme.InkFont(st)

    -- 6 Done
    local p6 = Panel(6)
    local w6 = p6:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    w6:SetPoint("TOPLEFT", 0, 0)
    w6:SetPoint("TOPRIGHT", 0, 0)
    w6:SetJustifyH("LEFT")
    w6:SetSpacing(4)
    w6:SetText(
        "Your tome is ready.\n\n" ..
        "• Right-click minimap: open this book\n" ..
        "• Left-click minimap: presence (beacons & boards)\n" ..
        "• /ic setup — run this guide again\n" ..
        "• /ic packages — which modules are loaded\n\n" ..
        "Turn the page when you are ready."
    )
    Blackacre.UI.Theme.InkFont(w6)

    -- Footer
    widgets.skip = CreateFrame("Button", nil, root, "UIPanelButtonTemplate")
    widgets.skip:SetSize(100, 24)
    widgets.skip:SetPoint("BOTTOMLEFT", 14, 12)
    widgets.skip:SetText("Skip setup")
    widgets.skip:SetScript("OnClick", function() Finish(true) end)

    widgets.back = CreateFrame("Button", nil, root, "UIPanelButtonTemplate")
    widgets.back:SetSize(90, 24)
    widgets.back:SetPoint("BOTTOMRIGHT", -120, 12)
    widgets.back:SetText("Back")
    widgets.back:SetScript("OnClick", function()
        if step > 1 then
            step = step - 1
            SetStepVisible(step)
        end
    end)

    widgets.next = CreateFrame("Button", nil, root, "UIPanelButtonTemplate")
    widgets.next:SetSize(120, 24)
    widgets.next:SetPoint("BOTTOMRIGHT", -14, 12)
    widgets.next:SetText("Continue")
    widgets.next:SetScript("OnClick", function()
        if step == 2 then
            local res = widgets.residence:GetText() or ""
            Blackacre.CharDB.residence = res
            if Blackacre.TRP3Bridge and Blackacre.TRP3Bridge.RememberResidence then
                Blackacre.TRP3Bridge.RememberResidence(res)
            end
        elseif step == 3 then
            local b = tonumber(widgets.birth:GetText())
            local p = tonumber(widgets.present:GetText())
            if b then Blackacre.YearCalendar.SetBirthADP(b) end
            if p then Blackacre.YearCalendar.SetPresentADP(p) end
            if Blackacre.Birthpath and Blackacre.Birthpath.OnBirthSet and b then
                Blackacre.Birthpath.OnBirthSet()
            end
        elseif step == 5 then
            local pres = Blackacre.Lifecycle and Blackacre.Lifecycle.EnsurePresenceDB and Blackacre.Lifecycle.EnsurePresenceDB()
            if pres then
                pres.receiveBeacons = widgets.beaconCheck:GetChecked()
            end
            if Blackacre.CharDB.survival then
                Blackacre.CharDB.survival.enabled = widgets.survCheck:GetChecked()
            end
            if Blackacre.Survival and Blackacre.Survival.Engine and Blackacre.Survival.Engine.SetEnabled then
                Blackacre.Survival.Engine.SetEnabled(widgets.survCheck:GetChecked())
            end
        end

        if step >= MAX_STEP then
            Finish(false)
        else
            step = step + 1
            if step == 3 then
                local id = Blackacre.YearCalendar.EnsureIdentity()
                widgets.birth:SetText(id.birthYearADP ~= nil and tostring(id.birthYearADP) or "")
                widgets.present:SetText(tostring(Blackacre.YearCalendar.GetPresentADP()))
                widgets.summary:SetText(Blackacre.Birthpath and Blackacre.Birthpath.GetSummary() or "")
            elseif step == 4 then
                local v = Blackacre.CharDB.voice or {}
                UIDropDownMenu_SetText(widgets.accentDrop, v.accent or "auto")
                if Blackacre.Voice and Blackacre.Voice.Apply then
                    widgets.voiceSample:SetText("Sample: " .. Blackacre.Voice.Apply("I am looking for the thing, yes?"))
                end
            elseif step == 5 then
                local pres = Blackacre.CharDB.presence or {}
                widgets.beaconCheck:SetChecked(pres.receiveBeacons ~= false)
                widgets.survCheck:SetChecked(not Blackacre.CharDB.survival or Blackacre.CharDB.survival.enabled ~= false)
            end
            SetStepVisible(step)
        end
    end)
end

local function RefreshIdentity()
    if not widgets.nameLabel then return end
    widgets.nameLabel:SetText("Name: " .. (Blackacre.GetCharName() or UnitName("player") or "?"))
    widgets.residence:SetText(Blackacre.CharDB.residence or "")
end

function Blackacre.SetupWizard.Show()
    if not Blackacre.TomeHub then return end
    local hub = Blackacre.TomeHub.GetFrame()
    local page = Blackacre.TomeHub.GetPageHost("setup")
    if not page then return end
    if not root then
        Build(page)
    else
        root:SetParent(page)
        root:ClearAllPoints()
        root:SetAllPoints(page)
    end
    step = 1
    RefreshIdentity()
    SetStepVisible(1)
    Blackacre.TomeHub.SetSetupMode(true)
    hub:Show()
    root:Show()
end

function Blackacre.SetupWizard.TryAutoShow()
    if Blackacre.SetupWizard.ShouldAutoShow() then
        C_Timer.After(1.5, function()
            if Blackacre.SetupWizard.ShouldAutoShow() then
                Blackacre.SetupWizard.Show()
            end
        end)
    end
end

function Blackacre.SetupWizard.Init()
    EnsureSetupDB()
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_LOGIN")
    f:SetScript("OnEvent", function()
        Blackacre.SetupWizard.TryAutoShow()
    end)
end
