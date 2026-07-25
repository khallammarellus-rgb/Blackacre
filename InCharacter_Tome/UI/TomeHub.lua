InCharacter = InCharacter or {}
InCharacter.TomeHub = {}

local hub
local tabButtons = {}
local pages = {}
local activeTab = "chronicle"

local TABS = {
    { id = "chronicle", label = "Pages", tip = "Traveler’s Chronicle" },
    { id = "lineage", label = "Lineage", tip = "Birth year and longevity" },
    { id = "honor", label = "Honor", tip = "Hardcore compact" },
    { id = "road", label = "Road", tip = "Expedition chart" },
    { id = "realms", label = "Realms", tip = "Afterlife return rites" },
    { id = "voice", label = "Voice", tip = "Accent and IC voice" },
    { id = "share", label = "Share", tip = "Export and peer cards" },
}

local function EnsureVoiceDB()
    InCharacter.CharDB.voice = InCharacter.CharDB.voice or {
        accent = "auto",
        applyToChronicle = true,
        applyToBulletins = false,
    }
    return InCharacter.CharDB.voice
end

local function SelectTab(id)
    activeTab = id
    for _, t in ipairs(TABS) do
        local btn = tabButtons[t.id]
        local page = pages[t.id]
        if btn then
            local active = t.id == id
            btn:SetNormalFontObject(active and GameFontHighlightSmall or GameFontDisableSmall)
            if active then
                local c = InCharacter.UI.Theme.Colors.tabActive
                btn.bg:SetColorTexture(c[1], c[2], c[3], 0.85)
            else
                local c = InCharacter.UI.Theme.Colors.tabIdle
                btn.bg:SetColorTexture(c[1], c[2], c[3], 0.45)
            end
        end
        if page then
            if t.id == id then page:Show() else page:Hide() end
        end
    end
    if id == "chronicle" and InCharacter.Chronicle and InCharacter.Chronicle.UI and InCharacter.Chronicle.UI.OnHubShow then
        InCharacter.Chronicle.UI.OnHubShow()
    elseif id == "lineage" and pages.lineage and pages.lineage.Refresh then
        pages.lineage:Refresh()
    elseif id == "honor" and pages.honor and pages.honor.Refresh then
        pages.honor:Refresh()
    elseif id == "road" and pages.road and pages.road.Refresh then
        pages.road:Refresh()
    elseif id == "realms" and pages.realms and pages.realms.Refresh then
        pages.realms:Refresh()
    elseif id == "voice" and pages.voice and pages.voice.Refresh then
        pages.voice:Refresh()
    end
end

local function MakeTabButton(parent, tab, index)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(72, 28)
    btn:SetPoint("TOPLEFT", 4, -12 - (index - 1) * 34)
    btn.bg = btn:CreateTexture(nil, "BACKGROUND")
    btn.bg:SetAllPoints()
    local c = InCharacter.UI.Theme.Colors.tabIdle
    btn.bg:SetColorTexture(c[1], c[2], c[3], 0.45)
    btn:SetText(tab.label)
    btn:SetNormalFontObject(GameFontDisableSmall)
    btn:SetHighlightFontObject(GameFontHighlightSmall)
    btn:SetScript("OnClick", function() SelectTab(tab.id) end)
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(tab.tip or tab.label)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    tabButtons[tab.id] = btn
    return btn
end

local function MakePage(parent, id)
    local page = CreateFrame("Frame", nil, parent)
    page:SetAllPoints(parent)
    page:Hide()
    pages[id] = page
    return page
end

local function BuildLineagePage(page)
    local title = page:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 12, -8)
    title:SetText("Lineage")
    InCharacter.UI.Theme.GoldTitle(title)

    page.summary = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    page.summary:SetPoint("TOPLEFT", 12, -40)
    page.summary:SetPoint("TOPRIGHT", -12, -40)
    page.summary:SetJustifyH("LEFT")
    page.summary:SetSpacing(3)
    InCharacter.UI.Theme.InkFont(page.summary)

    local open = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
    open:SetSize(160, 24)
    open:SetPoint("BOTTOMLEFT", 12, 12)
    open:SetText("Full lineage panel")
    open:SetScript("OnClick", function()
        if InCharacter.LineageUI and InCharacter.LineageUI.Toggle then
            InCharacter.LineageUI.Toggle()
        end
    end)

    function page:Refresh()
        if InCharacter.Birthpath and InCharacter.Birthpath.GetSummary then
            page.summary:SetText(InCharacter.Birthpath.GetSummary())
        else
            page.summary:SetText("Set a birth year to chart your path through the ages.")
        end
    end
end

local function BuildHonorPage(page)
    local title = page:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 12, -8)
    title:SetText("Hardcore Compact")
    InCharacter.UI.Theme.GoldTitle(title)

    page.status = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    page.status:SetPoint("TOPLEFT", 12, -44)
    page.status:SetPoint("TOPRIGHT", -12, -44)
    page.status:SetJustifyH("LEFT")
    page.status:SetSpacing(4)
    InCharacter.UI.Theme.InkFont(page.status)

    local open = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
    open:SetSize(160, 24)
    open:SetPoint("BOTTOMLEFT", 12, 12)
    open:SetText("Open gatekeeper")
    open:SetScript("OnClick", function()
        if InCharacter.Hardcore and InCharacter.Hardcore.UI then
            InCharacter.Hardcore.UI.Toggle()
        end
    end)

    function page:Refresh()
        if InCharacter.Hardcore and InCharacter.Hardcore.GetStatus then
            local s = InCharacter.Hardcore.GetStatus()
            local honor = s.clean and "Unstained" or "Stained"
            page.status:SetText(string.format(
                "Honor: %s\nDeaths: %d\nEncumbrance events: %d\nMount stains: %d · Sky stains: %d\nGround rite: %s · Flying rite: %s\n\nThe game will not force these rules. The journal remembers.",
                honor, s.deathCount, s.encumbranceViolations or 0,
                s.mountViolations or 0, s.flyViolations or 0,
                s.groundGate and "complete" or "unsworn",
                s.flyingGate and "complete" or "unsworn"
            ))
        else
            page.status:SetText("Hardcore module not ready.")
        end
    end
end

local function BuildRoadPage(page)
    local title = page:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 12, -8)
    title:SetText("Expedition")
    InCharacter.UI.Theme.GoldTitle(title)

    page.body = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    page.body:SetPoint("TOPLEFT", 12, -44)
    page.body:SetPoint("TOPRIGHT", -12, -44)
    page.body:SetJustifyH("LEFT")
    InCharacter.UI.Theme.InkFont(page.body)

    local open = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
    open:SetSize(160, 24)
    open:SetPoint("BOTTOMLEFT", 12, 12)
    open:SetText("Open full chart")
    open:SetScript("OnClick", function()
        if InCharacter.Roadmap and InCharacter.Roadmap.UI then
            InCharacter.Roadmap.UI.Toggle()
        end
    end)

    function page:Refresh()
        local rm = InCharacter.CharDB and InCharacter.CharDB.roadmap
        if rm and rm.active then
            local a = rm.active
            page.body:SetText(string.format(
                "Active road: %s\nStep focus is tracked in the full chart.\nLock prompts: %s",
                a.name or a.presetId or "Expedition",
                (rm.lockPrompts ~= false) and "on" or "off"
            ))
        else
            page.body:SetText("No active expedition. Open the full chart to choose a road.")
        end
    end
end

local function BuildRealmsPage(page)
    local title = page:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 12, -8)
    title:SetText("Realms of Death")
    InCharacter.UI.Theme.GoldTitle(title)

    page.body = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    page.body:SetPoint("TOPLEFT", 12, -44)
    page.body:SetPoint("TOPRIGHT", -12, -44)
    page.body:SetJustifyH("LEFT")
    InCharacter.UI.Theme.InkFont(page.body)

    local open = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
    open:SetSize(160, 24)
    open:SetPoint("BOTTOMLEFT", 12, 12)
    open:SetText("Open rites")
    open:SetScript("OnClick", function()
        if InCharacter.Afterlife and InCharacter.Afterlife.UI then
            InCharacter.Afterlife.UI.Toggle()
        end
    end)

    local pick = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
    pick:SetSize(140, 24)
    pick:SetPoint("LEFT", open, "RIGHT", 8, 0)
    pick:SetText("Choose realm")
    pick:SetScript("OnClick", function()
        if InCharacter.Afterlife and InCharacter.Afterlife.UI and InCharacter.Afterlife.UI.ShowRealmPicker then
            InCharacter.Afterlife.UI.ShowRealmPicker()
        end
    end)

    function page:Refresh()
        local al = InCharacter.CharDB and InCharacter.CharDB.afterlife
        if al and al.active then
            page.body:SetText(string.format(
                "Active rite: %s\nComplete the checklist in the full panel.\nPrompt on death: %s",
                al.active.pathId or al.active.name or "Unknown realm",
                (al.promptOnDeath ~= false) and "yes" or "no"
            ))
        else
            page.body:SetText("No return rite in progress. After death, choose a realm — or open rites now.")
        end
    end
end

local function BuildVoicePage(page)
    local title = page:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 12, -8)
    title:SetText("Voice")
    InCharacter.UI.Theme.GoldTitle(title)

    page.hint = page:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    page.hint:SetPoint("TOPLEFT", 12, -36)
    page.hint:SetPoint("TOPRIGHT", -12, -36)
    page.hint:SetJustifyH("LEFT")
    page.hint:SetText("One accent profile per character — never mixed mid-entry. Auto follows your race.")
    InCharacter.UI.Theme.InkFont(page.hint)

    page.profile = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    page.profile:SetPoint("TOPLEFT", 12, -70)
    page.profile:SetJustifyH("LEFT")
    InCharacter.UI.Theme.InkFont(page.profile)

    local accents = { "auto", "none", "dwarf", "orc", "undead", "goblin", "blood_elf", "night_elf", "tauren", "draenei", "pandaren", "vulpera", "human", "afrikaans" }
    page.dropdown = CreateFrame("Frame", "ICTomeVoiceAccent", page, "UIDropDownMenuTemplate")
    page.dropdown:SetPoint("TOPLEFT", 0, -100)
    UIDropDownMenu_SetWidth(page.dropdown, 160)
    UIDropDownMenu_Initialize(page.dropdown, function(self, level)
        for _, id in ipairs(accents) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = id
            info.func = function()
                EnsureVoiceDB().accent = id
                UIDropDownMenu_SetText(page.dropdown, id)
                page:Refresh()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    page.chronCheck = CreateFrame("CheckButton", nil, page, "UICheckButtonTemplate")
    page.chronCheck:SetPoint("TOPLEFT", 20, -150)
    local ct = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    ct:SetPoint("LEFT", page.chronCheck, "RIGHT", 4, 0)
    ct:SetText("Apply accent to new chronicle pages")
    InCharacter.UI.Theme.InkFont(ct)
    page.chronCheck:SetScript("OnClick", function(self)
        EnsureVoiceDB().applyToChronicle = self:GetChecked()
    end)

    page.bullCheck = CreateFrame("CheckButton", nil, page, "UICheckButtonTemplate")
    page.bullCheck:SetPoint("TOPLEFT", 20, -180)
    local bt = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    bt:SetPoint("LEFT", page.bullCheck, "RIGHT", 4, 0)
    bt:SetText("Apply accent to bulletins on post")
    InCharacter.UI.Theme.InkFont(bt)
    page.bullCheck:SetScript("OnClick", function(self)
        EnsureVoiceDB().applyToBulletins = self:GetChecked()
    end)

    page.sample = page:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    page.sample:SetPoint("TOPLEFT", 12, -220)
    page.sample:SetPoint("TOPRIGHT", -12, -220)
    page.sample:SetJustifyH("LEFT")
    InCharacter.UI.Theme.InkFont(page.sample)

    function page:Refresh()
        local v = EnsureVoiceDB()
        UIDropDownMenu_SetText(page.dropdown, v.accent or "auto")
        page.chronCheck:SetChecked(v.applyToChronicle ~= false)
        page.bullCheck:SetChecked(v.applyToBulletins == true)
        local resolved = InCharacter.Voice and InCharacter.Voice.ResolveProfile and InCharacter.Voice.ResolveProfile() or "none"
        page.profile:SetText("Active profile: " .. tostring(resolved))
        if InCharacter.Voice and InCharacter.Voice.Apply then
            local demo = "I am looking for the thing near the mountain, yes?"
            page.sample:SetText("Sample: " .. InCharacter.Voice.Apply(demo))
        else
            page.sample:SetText("Voice engine not loaded.")
        end
    end
end

local function BuildSharePage(page)
    local title = page:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 12, -8)
    title:SetText("Share")
    InCharacter.UI.Theme.GoldTitle(title)

    page.body = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    page.body:SetPoint("TOPLEFT", 12, -44)
    page.body:SetPoint("TOPRIGHT", -12, -44)
    page.body:SetJustifyH("LEFT")
    page.body:SetText("Copy a TRP3-friendly summary to the clipboard, or whisper a peer for their card.")
    InCharacter.UI.Theme.InkFont(page.body)

    local exp = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
    exp:SetSize(140, 24)
    exp:SetPoint("BOTTOMLEFT", 12, 12)
    exp:SetText("Export copy")
    exp:SetScript("OnClick", function()
        if InCharacter.Share and InCharacter.Share.Export then
            InCharacter.Share.Export.CopyToClipboard()
        end
    end)
end

local function Build()
    hub = CreateFrame("Frame", "InCharacterTomeHub", UIParent, "BackdropTemplate")
    hub:SetSize(820, 560)
    hub:SetPoint("CENTER")
    hub:SetFrameStrata("HIGH")
    hub:SetToplevel(true)
    hub:SetMovable(true)
    hub:EnableMouse(true)
    hub:RegisterForDrag("LeftButton")
    hub:SetScript("OnDragStart", hub.StartMoving)
    hub:SetScript("OnDragStop", hub.StopMovingOrSizing)
    hub:SetClampedToScreen(true)
    hub:Hide()
    tinsert(UISpecialFrames, "InCharacterTomeHub")
    InCharacter.UI.Theme.ApplyBookBackdrop(hub, 0.98)

    local icon = hub:CreateTexture(nil, "OVERLAY")
    icon:SetSize(30, 30)
    icon:SetPoint("TOPLEFT", 28, -12)
    icon:SetTexture(InCharacter.UI.Theme.Textures.questBook or "Interface\\Icons\\INV_Misc_Book_09")

    hub.title = hub:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    hub.title:SetPoint("LEFT", icon, "RIGHT", 8, 0)
    hub.title:SetText("Traveler’s Tome")
    InCharacter.UI.Theme.GoldTitle(hub.title)

    hub.subtitle = hub:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hub.subtitle:SetPoint("TOPLEFT", icon, "BOTTOMLEFT", 0, -4)
    hub.subtitle:SetText("Private pages of the road — chronicle, honor, lineage, and rites")
    InCharacter.UI.Theme.InkFont(hub.subtitle)

    local close = CreateFrame("Button", nil, hub, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)

    -- Tab rail
    hub.tabRail = CreateFrame("Frame", nil, hub, "BackdropTemplate")
    hub.tabRail:SetPoint("TOPLEFT", 24, -58)
    hub.tabRail:SetPoint("BOTTOMLEFT", 12, 16)
    hub.tabRail:SetWidth(80)
    InCharacter.UI.Theme.ApplyPagePanel(hub.tabRail, 0.4)

    for i, tab in ipairs(TABS) do
        MakeTabButton(hub.tabRail, tab, i)
    end

    -- Content host
    hub.content = CreateFrame("Frame", nil, hub, "BackdropTemplate")
    hub.content:SetPoint("TOPLEFT", hub.tabRail, "TOPRIGHT", 8, 0)
    hub.content:SetPoint("BOTTOMRIGHT", -16, 16)
    InCharacter.UI.Theme.ApplyPagePanel(hub.content, 0.35)

    -- Chronicle embeds journal shell
    local chron = MakePage(hub.content, "chronicle")
    chron:Show()
    hub.chronicleHost = chron

    local lineage = MakePage(hub.content, "lineage")
    BuildLineagePage(lineage)

    local honor = MakePage(hub.content, "honor")
    BuildHonorPage(honor)

    local road = MakePage(hub.content, "road")
    BuildRoadPage(road)

    local realms = MakePage(hub.content, "realms")
    BuildRealmsPage(realms)

    local voice = MakePage(hub.content, "voice")
    BuildVoicePage(voice)

    local share = MakePage(hub.content, "share")
    BuildSharePage(share)

    hub._built = true
    SelectTab("chronicle")
end

function InCharacter.TomeHub.GetChronicleParent()
    if not hub then Build() end
    return hub.chronicleHost
end

function InCharacter.TomeHub.Init()
    if not hub then Build() end
end

function InCharacter.TomeHub.Show(tabId)
    if not hub then Build() end
    if InCharacter.Chronicle and InCharacter.Chronicle.UI and InCharacter.Chronicle.UI.EnsureBuilt then
        InCharacter.Chronicle.UI.EnsureBuilt()
    end
    SelectTab(tabId or activeTab or "chronicle")
    hub:Show()
end

function InCharacter.TomeHub.Hide()
    if hub then hub:Hide() end
end

function InCharacter.TomeHub.Toggle(tabId)
    if not hub then Build() end
    if hub:IsShown() and (not tabId or tabId == activeTab) then
        hub:Hide()
    else
        InCharacter.TomeHub.Show(tabId)
    end
end

function InCharacter.TomeHub.IsShown()
    return hub and hub:IsShown()
end
