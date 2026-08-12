-- Traveler's Chronicle hub — open-book layout + Adventure Guide–style tabs.
Blackacre = Blackacre or {}
Blackacre.TomeHub = {}

local hub
local tabButtons = {}
local pages = {}
local activeTab = "chronicle"
local mounted = {}
local setupMode = false
local bookPageIndex = 1

-- Horizontal tabs (not settings list). Chronicle is the left bookmark, not a row here.
local TABS = {
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
    if hub and hub.chronicleBookmark then
        hub.chronicleBookmark:SetEnabled(on and true or false)
        hub.chronicleBookmark:SetAlpha(on and 1 or 0.35)
    end
end

--- Style a tab: active = gold outline + white text (owner request).
local function StyleTabButton(btn, active)
    if not btn then return end
    if active then
        btn:SetBackdropColor(0.25, 0.18, 0.08, 0.95)
        btn:SetBackdropBorderColor(0.95, 0.82, 0.35, 1)
        if btn.label then
            btn.label:SetTextColor(1, 1, 1, 1)
        end
        btn:SetNormalFontObject(GameFontHighlight)
    else
        btn:SetBackdropColor(0.18, 0.16, 0.14, 0.9)
        btn:SetBackdropBorderColor(0.45, 0.40, 0.32, 1)
        if btn.label then
            btn.label:SetTextColor(0.85, 0.80, 0.70, 1)
        end
        btn:SetNormalFontObject(GameFontNormal)
    end
end

local function StyleChronicleBookmark(active)
    if not hub or not hub.chronicleBookmark then return end
    if active then
        hub.chronicleBookmark:SetBackdropColor(0.55, 0.40, 0.12, 0.98)
        hub.chronicleBookmark:SetBackdropBorderColor(1, 0.9, 0.4, 1)
    else
        hub.chronicleBookmark:SetBackdropColor(0.35, 0.22, 0.12, 0.95)
        hub.chronicleBookmark:SetBackdropBorderColor(0.85, 0.70, 0.30, 1)
    end
end

local function ShowBookSpread(isChronicle)
    if not hub then return end
    if isChronicle then
        hub.leftPage:Show()
        hub.rightPage:Show()
        hub.pageHost:Hide()
        hub.prevPageBtn:Show()
        hub.nextPageBtn:Show()
    else
        hub.leftPage:Hide()
        hub.rightPage:Hide()
        hub.pageHost:Show()
        hub.prevPageBtn:Hide()
        hub.nextPageBtn:Hide()
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
    end
    mounted[id] = true
end

local function SelectTab(id)
    if setupMode and id ~= "setup" then return end
    activeTab = id

    for _, t in ipairs(TABS) do
        StyleTabButton(tabButtons[t.id], t.id == id)
        local page = pages[t.id]
        if page then
            if t.id == id then
                MountTab(t.id)
                page:Show()
            else
                page:Hide()
            end
        end
    end

    -- Chronicle uses two-page spread, not pageHost modules
    local isChron = (id == "chronicle")
    StyleChronicleBookmark(isChron)
    ShowBookSpread(isChron)
    if pages.chronicle then
        if isChron then
            MountTab("chronicle")
            pages.chronicle:Show()
        else
            pages.chronicle:Hide()
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

local function MakeHorizontalTab(parent, tab, index)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(92, 28)
    btn:SetPoint("LEFT", parent, "LEFT", 8 + (index - 1) * 96, 0)
    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 8, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    btn.label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    btn.label:SetPoint("CENTER")
    btn.label:SetText(tab.label)
    btn:SetFontString(btn.label)
    StyleTabButton(btn, false)
    btn:SetScript("OnClick", function() SelectTab(tab.id) end)
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
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
    title:SetPoint("TOPLEFT", 16, -14)
    title:SetText("Voice")
    Blackacre.UI.Theme.GoldTitle(title)

    page.hint = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    page.hint:SetPoint("TOPLEFT", 16, -44)
    page.hint:SetPoint("TOPRIGHT", -16, -44)
    page.hint:SetJustifyH("LEFT")
    page.hint:SetText("One accent profile per character — never mixed mid-entry. Auto follows your race.")
    Blackacre.UI.Theme.ApplyMailBodyFont(page.hint, 0)

    page.profile = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    page.profile:SetPoint("TOPLEFT", 16, -80)
    Blackacre.UI.Theme.ApplyMailBodyFont(page.profile, 0)

    local accents = { "auto", "none", "dwarf", "orc", "undead", "goblin", "blood_elf", "night_elf", "tauren", "draenei", "pandaren", "vulpera", "human", "afrikaans" }
    page.dropdown = CreateFrame("Frame", "BATomeVoiceAccent", page, "UIDropDownMenuTemplate")
    page.dropdown:SetPoint("TOPLEFT", 0, -110)
    UIDropDownMenu_SetWidth(page.dropdown, 180)
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
    page.chronCheck:SetPoint("TOPLEFT", 16, -160)
    local ct = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    ct:SetPoint("LEFT", page.chronCheck, "RIGHT", 4, 0)
    ct:SetText("Apply accent to new chronicle pages")
    Blackacre.UI.Theme.ApplyMailBodyFont(ct, 0)
    page.chronCheck:SetScript("OnClick", function(self)
        EnsureVoiceDB().applyToChronicle = self:GetChecked()
    end)

    page.bullCheck = CreateFrame("CheckButton", nil, page, "UICheckButtonTemplate")
    page.bullCheck:SetPoint("TOPLEFT", 16, -194)
    local bt = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    bt:SetPoint("LEFT", page.bullCheck, "RIGHT", 4, 0)
    bt:SetText("Apply accent to bulletins on post")
    Blackacre.UI.Theme.ApplyMailBodyFont(bt, 0)
    page.bullCheck:SetScript("OnClick", function(self)
        EnsureVoiceDB().applyToBulletins = self:GetChecked()
    end)

    page.sample = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    page.sample:SetPoint("TOPLEFT", 16, -240)
    page.sample:SetPoint("TOPRIGHT", -16, -240)
    page.sample:SetJustifyH("LEFT")
    Blackacre.UI.Theme.ApplyMailBodyFont(page.sample, 0)

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
    title:SetPoint("TOPLEFT", 16, -14)
    title:SetText("Share")
    Blackacre.UI.Theme.GoldTitle(title)

    page.body = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    page.body:SetPoint("TOPLEFT", 16, -48)
    page.body:SetPoint("TOPRIGHT", -16, -48)
    page.body:SetJustifyH("LEFT")
    page.body:SetText("Copy a TRP3-friendly summary to the clipboard, or whisper a peer:\n/ba share PlayerName")
    Blackacre.UI.Theme.ApplyMailBodyFont(page.body, 0)

    local exp = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
    exp:SetSize(140, 26)
    exp:SetPoint("BOTTOMLEFT", 16, 16)
    exp:SetText("Export copy")
    exp:SetScript("OnClick", function()
        if Blackacre.Share and Blackacre.Share.Export then
            Blackacre.Share.Export.CopyToClipboard()
        end
    end)
    mounted.share = true
end

local function Build()
    hub = Blackacre.UI.Theme.CreateBookShell("BlackacreTomeHub", "Traveler's Chronicle")

    for i, tab in ipairs(TABS) do
        MakeHorizontalTab(hub.tabBar, tab, i)
    end

    -- Non-chronicle modules mount on full pageHost
    for _, tab in ipairs(TABS) do
        MakePage(hub.pageHost, tab.id)
    end

    -- Chronicle marker only (hosts are leftPage/rightPage). Do not cover the book.
    pages.chronicle = CreateFrame("Frame", nil, hub.bookOpen)
    pages.chronicle:SetSize(1, 1)
    pages.chronicle:SetPoint("TOPLEFT", hub.bookOpen, "TOPLEFT", 0, 0)
    pages.chronicle:EnableMouse(false)
    pages.chronicle:Hide()
    pages.chronicle.tocHost = hub.leftPage
    pages.chronicle.pageHost = hub.rightPage

    hub.chronicleHost = pages.chronicle

    BuildVoicePage(pages.voice)
    BuildSharePage(pages.share)

    pages.setup = MakePage(hub.pageHost, "setup")

    hub._built = true
    SelectTab("chronicle")
end

function Blackacre.TomeHub.GetChronicleParent()
    if not hub then Build() end
    -- Two-page: journal embeds into right page; TOC into left
    return pages.chronicle
end

function Blackacre.TomeHub.GetChronicleTocParent()
    if not hub then Build() end
    return hub.leftPage
end

function Blackacre.TomeHub.GetChroniclePageParent()
    if not hub then Build() end
    return hub.rightPage
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
        if pages.chronicle then pages.chronicle:Hide() end
        if pages.setup then pages.setup:Show() end
        ShowBookSpread(false)
        activeTab = "setup"
    end
end

function Blackacre.TomeHub.IsSetupMode()
    return setupMode
end

function Blackacre.TomeHub.Show(tabId)
    if not hub then Build() end
    if setupMode and tabId ~= "setup" then
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

function Blackacre.TomeHub.OnJournalToggle(on)
    if Blackacre.Print then
        Blackacre.Print(on and "Journaling mode On — edit fields, then Save page." or "Journaling mode Off.")
    end
    if Blackacre.Chronicle and Blackacre.Chronicle.UI and Blackacre.Chronicle.UI.SetJournalMode then
        Blackacre.Chronicle.UI.SetJournalMode(on)
    end
end

--- Page turn within chronicle list (delta = -1 or +1).
function Blackacre.TomeHub.TurnPage(delta)
    if Blackacre.Chronicle and Blackacre.Chronicle.UI and Blackacre.Chronicle.UI.TurnPage then
        Blackacre.Chronicle.UI.TurnPage(delta)
    end
end
