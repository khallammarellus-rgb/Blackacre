Blackacre = Blackacre or {}
Blackacre.TomeHub = {}

local hub
local tabButtons = {}
local pages = {}
local activeTab = "chronicle"
local mounted = {}
local setupMode = false

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
    Blackacre.CharDB.voice = Blackacre.CharDB.voice or {
        accent = "auto",
        applyToChronicle = true,
        applyToBulletins = false,
    }
    return Blackacre.CharDB.voice
end

local function SetTabsEnabled(on)
    for _, t in ipairs(TABS) do
        local btn = tabButtons[t.id]
        if btn then
            if on then btn:Enable() else btn:Disable() end
            btn:SetAlpha(on and 1 or 0.35)
        end
    end
end

local function MountTab(id)
    if mounted[id] then return end
    local page = pages[id]
    if not page then return end

    if id == "chronicle" then
        if Blackacre.Chronicle and Blackacre.Chronicle.UI and Blackacre.Chronicle.UI.EnsureBuilt then
            Blackacre.Chronicle.UI.EnsureBuilt()
        end
    elseif id == "lineage" then
        if Blackacre.LineageUI and Blackacre.LineageUI.Mount then
            Blackacre.LineageUI.Mount(page)
        end
    elseif id == "honor" then
        if Blackacre.Hardcore and Blackacre.Hardcore.UI and Blackacre.Hardcore.UI.Mount then
            Blackacre.Hardcore.UI.Mount(page)
        end
    elseif id == "road" then
        if Blackacre.Roadmap and Blackacre.Roadmap.UI and Blackacre.Roadmap.UI.Mount then
            Blackacre.Roadmap.UI.Mount(page)
        end
    elseif id == "realms" then
        if Blackacre.Afterlife and Blackacre.Afterlife.UI and Blackacre.Afterlife.UI.Mount then
            Blackacre.Afterlife.UI.Mount(page)
        end
    elseif id == "voice" then
        -- built inline once
    elseif id == "share" then
        -- built inline once
    end
    mounted[id] = true
end

local function SelectTab(id)
    if setupMode and id ~= "setup" then return end
    activeTab = id
    for _, t in ipairs(TABS) do
        local btn = tabButtons[t.id]
        local page = pages[t.id]
        if btn then
            local active = t.id == id
            btn:SetNormalFontObject(active and GameFontHighlightSmall or GameFontDisableSmall)
            local c = active and Blackacre.UI.Theme.Colors.tabActive or Blackacre.UI.Theme.Colors.tabIdle
            btn.bg:SetColorTexture(c[1], c[2], c[3], active and 0.9 or 0.5)
        end
        if page then
            if t.id == id then
                MountTab(t.id)
                page:Show()
            else
                page:Hide()
            end
        end
    end
    if pages.setup then
        if id == "setup" then pages.setup:Show() else pages.setup:Hide() end
    end

    if id == "chronicle" and Blackacre.Chronicle and Blackacre.Chronicle.UI and Blackacre.Chronicle.UI.OnHubShow then
        Blackacre.Chronicle.UI.OnHubShow()
    elseif id == "lineage" and Blackacre.LineageUI and Blackacre.LineageUI.Refresh then
        Blackacre.LineageUI.Refresh()
    elseif id == "honor" and Blackacre.Hardcore and Blackacre.Hardcore.UI then
        Blackacre.Hardcore.UI.Refresh()
    elseif id == "road" and Blackacre.Roadmap and Blackacre.Roadmap.UI then
        Blackacre.Roadmap.UI.Refresh()
    elseif id == "realms" and Blackacre.Afterlife and Blackacre.Afterlife.UI then
        Blackacre.Afterlife.UI.Refresh()
    elseif id == "voice" and pages.voice and pages.voice.Refresh then
        pages.voice:Refresh()
    end
end

local function MakeTabButton(parent, tab, index)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(76, 30)
    btn:SetPoint("TOPLEFT", 6, -10 - (index - 1) * 36)
    btn.bg = btn:CreateTexture(nil, "BACKGROUND")
    btn.bg:SetAllPoints()
    local c = Blackacre.UI.Theme.Colors.tabIdle
    btn.bg:SetColorTexture(c[1], c[2], c[3], 0.5)
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
    if page.SetClipsChildren then page:SetClipsChildren(true) end
    page:Hide()
    pages[id] = page
    return page
end

local function BuildVoicePage(page)
    local title = page:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 12, -10)
    title:SetText("Voice")
    Blackacre.UI.Theme.GoldTitle(title)

    page.hint = page:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    page.hint:SetPoint("TOPLEFT", 12, -36)
    page.hint:SetPoint("TOPRIGHT", -12, -36)
    page.hint:SetJustifyH("LEFT")
    page.hint:SetText("One accent profile per character — never mixed mid-entry. Auto follows your race.")
    Blackacre.UI.Theme.InkFont(page.hint)

    page.profile = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    page.profile:SetPoint("TOPLEFT", 12, -70)
    Blackacre.UI.Theme.InkFont(page.profile)

    local accents = { "auto", "none", "dwarf", "orc", "undead", "goblin", "blood_elf", "night_elf", "tauren", "draenei", "pandaren", "vulpera", "human", "afrikaans" }
    page.dropdown = CreateFrame("Frame", "BATomeVoiceAccent", page, "UIDropDownMenuTemplate")
    page.dropdown:SetPoint("TOPLEFT", 0, -100)
    UIDropDownMenu_SetWidth(page.dropdown, 160)
    UIDropDownMenu_Initialize(page.dropdown, function()
        for _, id in ipairs(accents) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = id
            info.func = function()
                EnsureVoiceDB().accent = id
                UIDropDownMenu_SetText(page.dropdown, id)
                page:Refresh()
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    page.chronCheck = CreateFrame("CheckButton", nil, page, "UICheckButtonTemplate")
    page.chronCheck:SetPoint("TOPLEFT", 16, -150)
    local ct = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    ct:SetPoint("LEFT", page.chronCheck, "RIGHT", 4, 0)
    ct:SetText("Apply accent to new chronicle pages")
    Blackacre.UI.Theme.InkFont(ct)
    page.chronCheck:SetScript("OnClick", function(self)
        EnsureVoiceDB().applyToChronicle = self:GetChecked()
    end)

    page.bullCheck = CreateFrame("CheckButton", nil, page, "UICheckButtonTemplate")
    page.bullCheck:SetPoint("TOPLEFT", 16, -180)
    local bt = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    bt:SetPoint("LEFT", page.bullCheck, "RIGHT", 4, 0)
    bt:SetText("Apply accent to bulletins on post")
    Blackacre.UI.Theme.InkFont(bt)
    page.bullCheck:SetScript("OnClick", function(self)
        EnsureVoiceDB().applyToBulletins = self:GetChecked()
    end)

    page.sample = page:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    page.sample:SetPoint("TOPLEFT", 12, -220)
    page.sample:SetPoint("TOPRIGHT", -12, -220)
    page.sample:SetJustifyH("LEFT")
    Blackacre.UI.Theme.InkFont(page.sample)

    function page:Refresh()
        local v = EnsureVoiceDB()
        UIDropDownMenu_SetText(page.dropdown, v.accent or "auto")
        page.chronCheck:SetChecked(v.applyToChronicle ~= false)
        page.bullCheck:SetChecked(v.applyToBulletins == true)
        local resolved = Blackacre.Voice and Blackacre.Voice.ResolveProfile and Blackacre.Voice.ResolveProfile() or "none"
        page.profile:SetText("Active profile: " .. tostring(resolved))
        if Blackacre.Voice and Blackacre.Voice.Apply then
            page.sample:SetText("Sample: " .. Blackacre.Voice.Apply("I am looking for the thing near the mountain, yes?"))
        else
            page.sample:SetText("Voice engine not loaded.")
        end
    end
    mounted.voice = true
end

local function BuildSharePage(page)
    local title = page:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 12, -10)
    title:SetText("Share")
    Blackacre.UI.Theme.GoldTitle(title)

    page.body = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    page.body:SetPoint("TOPLEFT", 12, -44)
    page.body:SetPoint("TOPRIGHT", -12, -44)
    page.body:SetJustifyH("LEFT")
    page.body:SetText("Copy a TRP3-friendly summary to the clipboard, or whisper a peer:\n/ic share PlayerName")
    Blackacre.UI.Theme.InkFont(page.body)

    local exp = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
    exp:SetSize(140, 24)
    exp:SetPoint("BOTTOMLEFT", 12, 12)
    exp:SetText("Export copy")
    exp:SetScript("OnClick", function()
        if Blackacre.Share and Blackacre.Share.Export then
            Blackacre.Share.Export.CopyToClipboard()
        end
    end)
    mounted.share = true
end

local function Build()
    hub = Blackacre.UI.Theme.CreateBookShell("BlackacreTomeHub", "Traveler’s Tome")

    for i, tab in ipairs(TABS) do
        MakeTabButton(hub.tabRail, tab, i)
    end

    for _, tab in ipairs(TABS) do
        MakePage(hub.pageHost, tab.id)
    end

    -- Chronicle page is host for journal embed
    hub.chronicleHost = pages.chronicle

    BuildVoicePage(pages.voice)
    BuildSharePage(pages.share)

    -- Setup page (wizard mounts here)
    pages.setup = MakePage(hub.pageHost, "setup")

    hub._built = true
    SelectTab("chronicle")
end

function Blackacre.TomeHub.GetChronicleParent()
    if not hub then Build() end
    return pages.chronicle
end

function Blackacre.TomeHub.GetPageHost(id)
    if not hub then Build() end
    return pages[id or activeTab]
end

function Blackacre.TomeHub.Init()
    if not hub then Build() end
end

function Blackacre.TomeHub.SetSetupMode(on)
    setupMode = on and true or false
    SetTabsEnabled(not setupMode)
    if setupMode then
        for _, t in ipairs(TABS) do
            if pages[t.id] then pages[t.id]:Hide() end
        end
        if pages.setup then pages.setup:Show() end
        activeTab = "setup"
    end
end

function Blackacre.TomeHub.IsSetupMode()
    return setupMode
end

function Blackacre.TomeHub.Show(tabId)
    if not hub then Build() end
    if setupMode and tabId ~= "setup" then
        -- allow wizard to finish; still show hub
        hub:Show()
        return
    end
    if tabId == "setup" then
        hub:Show()
        return
    end
    SelectTab(tabId or activeTab or "chronicle")
    hub:Show()
end

function Blackacre.TomeHub.Hide()
    if hub then hub:Hide() end
end

function Blackacre.TomeHub.Toggle(tabId)
    if not hub then Build() end
    if hub:IsShown() and (not tabId or tabId == activeTab) and not setupMode then
        hub:Hide()
    else
        Blackacre.TomeHub.Show(tabId)
    end
end

function Blackacre.TomeHub.IsShown()
    return hub and hub:IsShown()
end

function Blackacre.TomeHub.GetFrame()
    if not hub then Build() end
    return hub
end
