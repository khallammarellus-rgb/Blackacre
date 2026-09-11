-- Traveler's Chronicle hub — IC open book + separate OOC Backstory Menus frame.
-- DBM hygiene: locals, Theme-owned art paths, no feature logic in Theme.
Blackacre = Blackacre or {}
Blackacre.TomeHub = {}

local hub
local menu -- Backstory Menus (OOC parent)
local tabButtons = {}
local pages = {}
local activeMenuTab = "lineage"
local mounted = {}
local setupMode = false
local escGate -- Esc: sidecar first, then tome (not both at once)
local suppressEscGate = false

--- Remove a global frame name from UISpecialFrames (Esc closes all entries at once).
local function RemoveFromUISpecialFrames(name)
    if not name or not UISpecialFrames then return end
    for i = #UISpecialFrames, 1, -1 do
        if UISpecialFrames[i] == name then
            tremove(UISpecialFrames, i)
        end
    end
end

local function EnsureEscGate()
    if escGate then return escGate end
    escGate = CreateFrame("Frame", "BlackacreTomeEscGate")
    escGate:Hide()
    tinsert(UISpecialFrames, "BlackacreTomeEscGate")
    escGate:SetScript("OnHide", function(self)
        if suppressEscGate then return end
        -- First Esc: close Backstory sidecar only; re-arm gate for second Esc
        if menu and menu:IsShown() then
            menu:Hide()
            if hub and hub:IsShown() then
                C_Timer.After(0, function()
                    if hub and hub:IsShown() and escGate then
                        suppressEscGate = true
                        escGate:Show()
                        suppressEscGate = false
                    end
                end)
            end
            return
        end
        -- Second Esc (or Esc with no sidecar): close tome
        if hub and hub:IsShown() then
            hub:Hide()
        end
    end)
    return escGate
end

local function SyncEscGate()
    EnsureEscGate()
    if hub and hub:IsShown() then
        if not escGate:IsShown() then
            suppressEscGate = true
            escGate:Show()
            suppressEscGate = false
        end
    else
        suppressEscGate = true
        if escGate:IsShown() then escGate:Hide() end
        suppressEscGate = false
    end
end

-- OOC backstory modules — NOT IC journal tabs (immersion)
-- Labels are tooltip-only; tabs show icons (owner polish pack).
local MENU_TABS = {
    { id = "lineage", label = "Lineage", tip = "Birth year and longevity", icon = "spell_holy_borrowedtime" },
    { id = "honor", label = "Survival", tip = "Hardcore / survival compact", icon = "achievement_zone_tanaris_01" },
    { id = "road", label = "Paths", tip = "Expedition chart / life paths", icon = "ability_hunter_pathfinding" },
    { id = "realms", label = "Afterlife", tip = "Afterlife return rites", icon = "achievement_bg_xkills_avgraveyard" },
    { id = "voice", label = "Voice", tip = "Accent and IC voice", icon = "inv_misc_horn_03" },
    { id = "share", label = "Share", tip = "Export and peer cards", icon = "inv_10_specialization_inscription_sharedknowledge_color1" },
}

local function Theme()
    return Blackacre.UI and Blackacre.UI.Theme
end

local function EjTexturePath()
    local th = Theme()
    return (th and th.Textures and th.Textures.ejTextures)
        or "Interface\\EncounterJournal\\UI-EncounterJournalTextures"
end

local function EnsureVoiceDB()
    Blackacre.CharDB.voice = Blackacre.CharDB.voice or {
        accent = "auto",
        applyToChronicle = true,
        applyToBulletins = false,
    }
    return Blackacre.CharDB.voice
end

local function SetTabsEnabled(on)
    for _, t in ipairs(MENU_TABS) do
        local btn = tabButtons[t.id]
        if btn then
            if on then btn:Enable() else btn:Disable() end
            btn:SetAlpha(on and 1 or 0.35)
        end
    end
    if hub and hub.chronicleBookmark then
        if on then
            if hub.chronicleBookmark.Enable then hub.chronicleBookmark:Enable() end
        else
            if hub.chronicleBookmark.Disable then hub.chronicleBookmark:Disable() end
        end
        hub.chronicleBookmark:SetAlpha(on and 1 or 0.35)
    end
end

local function StyleBookmarkTab(btn, active)
    if not btn then return end
    if btn.bg then
        btn.bg:SetColorTexture(0.18, 0.14, 0.10, active and 0.95 or 0.8)
    end
    if btn.icon then
        btn.icon:ClearAllPoints()
        btn.icon:SetSize(20, 20)
        btn.icon:SetPoint("CENTER", btn, "CENTER", 0, 4)
        btn.icon:SetVertexColor(1, 1, 1, active and 1 or 0.88)
        if type(btn.icon:GetTexture()) == "string" and tostring(btn.icon:GetTexture()):find("Icons") then
            btn.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        end
    end
    if btn.glow then
        btn.glow:Hide()
    end
    if btn.label then
        btn.label:SetText(active and (btn._baTabLabel or "") or "")
        btn.label:SetTextColor(1, 0.92, 0.55, 1)
    end
end

local function ShowBookAsChronicle()
    if not hub then return end
    hub.leftPage:Show()
    hub.rightPage:Show()
    hub.pageHost:Hide()
    hub.prevPageBtn:Show()
    hub.nextPageBtn:Show()
    if hub.leftPageNum then hub.leftPageNum:Show() end
    if hub.rightPageNum then hub.rightPageNum:Show() end
    if hub.chronicleBookmark then hub.chronicleBookmark:Show() end
    if hub.toolStrip then hub.toolStrip:Show() end
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

local function SelectMenuTab(id)
    if setupMode then return end
    activeMenuTab = id or activeMenuTab or "lineage"

    for _, t in ipairs(MENU_TABS) do
        StyleBookmarkTab(tabButtons[t.id], t.id == activeMenuTab)
        local page = pages[t.id]
        if page then
            if t.id == activeMenuTab then
                MountTab(t.id)
                page:Show()
            else
                page:Hide()
            end
        end
    end

    local function SafeCall(label, fn)
        if not fn then return end
        local ok, err = pcall(fn)
        if not ok and Blackacre.Print then
            Blackacre.Print("|cffff6666Backstory " .. label .. ":|r " .. tostring(err))
        end
    end

    if activeMenuTab == "lineage" and Blackacre.LineageUI and Blackacre.LineageUI.Refresh then
        SafeCall("lineage", Blackacre.LineageUI.Refresh)
    elseif activeMenuTab == "honor" and Blackacre.Hardcore and Blackacre.Hardcore.UI then
        SafeCall("honor", Blackacre.Hardcore.UI.Refresh)
    elseif activeMenuTab == "road" and Blackacre.Roadmap and Blackacre.Roadmap.UI then
        SafeCall("road", Blackacre.Roadmap.UI.Refresh)
    elseif activeMenuTab == "realms" and Blackacre.Afterlife and Blackacre.Afterlife.UI then
        SafeCall("realms", Blackacre.Afterlife.UI.Refresh)
    elseif activeMenuTab == "voice" and pages.voice and pages.voice.Refresh then
        SafeCall("voice", function() pages.voice:Refresh() end)
    end
end

local function MakeBookmarkTab(parent, tab, index)
    -- Hit box sized to tab face (icon-centered); no red panel button
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(40, 52)
    btn:SetPoint("TOPLEFT", parent, "TOPRIGHT", -18, -32 - (index - 1) * 54)
    btn:SetFrameLevel((parent:GetFrameLevel() or 1) + 8)

    btn.bg = btn:CreateTexture(nil, "BACKGROUND")
    btn.bg:SetAllPoints(btn)
    btn.bg:SetColorTexture(0.18, 0.14, 0.10, 0.9)
    btn._baTabLabel = tab.label or ""

    btn.icon = btn:CreateTexture(nil, "ARTWORK")
    btn.icon:SetSize(20, 20)
    btn.icon:SetPoint("CENTER", 0, 3)
    btn.icon:SetTexture("Interface\\Icons\\" .. (tab.icon or "INV_Misc_QuestionMark"))
    btn.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    btn.glow = btn:CreateTexture(nil, "HIGHLIGHT")
    btn.glow:SetAllPoints(btn)
    btn.glow:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
    btn.glow:SetBlendMode("ADD")
    btn.glow:Hide()

    btn.label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    btn.label:SetPoint("BOTTOM", 0, 2)
    btn.label:SetText("")

    StyleBookmarkTab(btn, false)
    btn:SetScript("OnClick", function()
        if Theme() and Theme().PlayUISound then Theme().PlayUISound("menuTab") end
        SelectMenuTab(tab.id)
    end)
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText(tab.label)
        if tab.tip then
            GameTooltip:AddLine(tab.tip, 0.85, 0.85, 0.85, true)
        end
        GameTooltip:Show()
        if self.glow then self.glow:Show() end
    end)
    btn:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
        if self.glow then self.glow:Hide() end
        StyleBookmarkTab(self, tab.id == activeMenuTab)
    end)
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

local function ApplyMenuBodyFont(fs)
    if not fs then return end
    -- One point smaller than default highlight for denser Backstory menus
    local path, size, flags = GameFontHighlight:GetFont()
    if path then
        fs:SetFont(path, math.max(10, (size or 12) - 1), flags or "")
    end
    Blackacre.UI.Theme.ApplyMailBodyFont(fs, -1)
end

local function BuildVoicePage(page)
    local title = page:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 32, -32)
    title:SetText("Voice")
    Blackacre.UI.Theme.GoldTitle(title)
    do
        local path, size, flags = GameFontNormalLarge:GetFont()
        if path then title:SetFont(path, math.max(11, (size or 14) - 1), flags or "") end
    end

    page.profile = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    page.profile:SetPoint("TOPLEFT", 32, -72)
    ApplyMenuBodyFont(page.profile)

    local accents = { "auto", "none", "dwarf", "orc", "undead", "goblin", "blood_elf", "night_elf", "tauren", "draenei", "pandaren", "vulpera", "human", "afrikaans" }
    page.dropdown = CreateFrame("Frame", "BATomeVoiceAccent", page, "UIDropDownMenuTemplate")
    page.dropdown:SetPoint("TOPLEFT", 16, -110)
    UIDropDownMenu_SetWidth(page.dropdown, 220)
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

    -- Short labels + tooltips (no long explanatory paragraphs on the panel)
    page.chronCheck = CreateFrame("CheckButton", nil, page, "UICheckButtonTemplate")
    page.chronCheck:SetPoint("TOPLEFT", 32, -180)
    local ct = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    ct:SetPoint("LEFT", page.chronCheck, "RIGHT", 10, 0)
    ct:SetText("Chronicle")
    ApplyMenuBodyFont(ct)
    page.chronCheck:SetScript("OnClick", function(self)
        EnsureVoiceDB().applyToChronicle = self:GetChecked()
    end)
    page.chronCheck:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Apply accent to chronicle")
        GameTooltip:AddLine("When checked, new auto journal pages use this accent profile.", 0.85, 0.85, 0.85, true)
        GameTooltip:Show()
    end)
    page.chronCheck:SetScript("OnLeave", function() GameTooltip:Hide() end)

    page.bullCheck = CreateFrame("CheckButton", nil, page, "UICheckButtonTemplate")
    page.bullCheck:SetPoint("TOPLEFT", 32, -230)
    local bt = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    bt:SetPoint("LEFT", page.bullCheck, "RIGHT", 10, 0)
    bt:SetText("Bulletins")
    ApplyMenuBodyFont(bt)
    page.bullCheck:SetScript("OnClick", function(self)
        EnsureVoiceDB().applyToBulletins = self:GetChecked()
    end)
    page.bullCheck:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Apply accent to bulletins")
        GameTooltip:AddLine("When checked, bulletin posts use this accent on send.", 0.85, 0.85, 0.85, true)
        GameTooltip:Show()
    end)
    page.bullCheck:SetScript("OnLeave", function() GameTooltip:Hide() end)

    page.sample = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    page.sample:SetPoint("TOPLEFT", 32, -290)
    page.sample:SetPoint("TOPRIGHT", -32, -290)
    page.sample:SetJustifyH("LEFT")
    ApplyMenuBodyFont(page.sample)

    function page:Refresh()
        local v = EnsureVoiceDB()
        UIDropDownMenu_SetText(page.dropdown, v.accent or "auto")
        page.chronCheck:SetChecked(v.applyToChronicle ~= false)
        page.bullCheck:SetChecked(v.applyToBulletins == true)
        local resolved = Blackacre.Voice and Blackacre.Voice.ResolveProfile and Blackacre.Voice.ResolveProfile() or "none"
        page.profile:SetText("Active: " .. tostring(resolved))
        if Blackacre.Voice and Blackacre.Voice.Apply then
            page.sample:SetText("Sample: " .. Blackacre.Voice.Apply("I am looking for the thing near the mountain, yes?"))
        else
            page.sample:SetText("Voice engine not loaded.")
        end
    end
    mounted.voice = true
end

local function BuildSharePage(page)
    local title = page:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 32, -32)
    title:SetText("Share")
    Blackacre.UI.Theme.GoldTitle(title)
    do
        local path, size, flags = GameFontNormalLarge:GetFont()
        if path then title:SetFont(path, math.max(11, (size or 14) - 1), flags or "") end
    end

    local exp = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
    exp:SetSize(160, 28)
    exp:SetPoint("TOPLEFT", 32, -80)
    exp:SetText("Export copy")
    exp:SetScript("OnClick", function()
        if Blackacre.Share and Blackacre.Share.Export then
            Blackacre.Share.Export.CopyToClipboard()
        end
    end)
    exp:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Export copy")
        GameTooltip:AddLine("Copy a TRP3-friendly summary to the clipboard.", 0.85, 0.85, 0.85, true)
        GameTooltip:AddLine("Whisper: /ba share PlayerName", 0.7, 0.7, 0.7, true)
        GameTooltip:Show()
    end)
    exp:SetScript("OnLeave", function() GameTooltip:Hide() end)
    mounted.share = true
end

local function PlaceMenuAsSidecar()
    if not menu or not hub then return end
    menu:ClearAllPoints()
    -- Sidecar to the RIGHT of the open tome (not stacked on top)
    menu:SetPoint("TOPLEFT", hub, "TOPRIGHT", 8, 0)
end

--- OOC Backstory Menus parent (sidecar to the IC journal book).
local function BuildBackstoryMenu()
    if menu then return menu end
    local Layer = Blackacre.UI.Theme.Layer

    menu = CreateFrame("Frame", "BlackacreBackstoryMenu", UIParent, "BackdropTemplate")
    menu:SetSize(640, 560)
    menu:SetFrameStrata("HIGH")
    menu:SetToplevel(true)
    menu:SetMovable(true)
    menu:EnableMouse(true)
    menu:RegisterForDrag("LeftButton")
    menu:SetScript("OnDragStart", menu.StartMoving)
    menu:SetScript("OnDragStop", menu.StopMovingOrSizing)
    menu:SetClampedToScreen(true)
    menu:Hide()
    -- Not in UISpecialFrames: Esc is owned by BlackacreTomeEscGate (sidecar first, then tome)

    -- Faction FrameGeneral kits (Alliance / Horde from player data)
    if Blackacre.UI.Theme.ApplyFactionFrameChrome then
        Blackacre.UI.Theme.ApplyFactionFrameChrome(menu)
    else
        Blackacre.UI.Theme.ApplyBookShellChrome(menu)
    end

    menu.header = CreateFrame("Frame", nil, menu, "BackdropTemplate")
    menu.header:SetPoint("TOPLEFT", 14, -14)
    menu.header:SetPoint("TOPRIGHT", -14, -14)
    menu.header:SetHeight(36)
    menu.header:EnableMouse(true)
    menu.header:RegisterForDrag("LeftButton")
    menu.header:SetScript("OnDragStart", function() menu:StartMoving() end)
    menu.header:SetScript("OnDragStop", function() menu:StopMovingOrSizing() end)
    Blackacre.UI.Theme.ApplyBookChromeBar(menu.header, "header")
    menu.header:SetFrameLevel((menu:GetFrameLevel() or 1) + 5)

    menu.title = Blackacre.UI.Theme.CreateLayeredFontString(menu.header, Layer.OVERLAY, "GameFontNormal")
    menu.title:SetPoint("LEFT", 16, 0)
    menu.title:SetText("Backstory Menus")
    Blackacre.UI.Theme.GoldTitle(menu.title)
    do
        local path, size, flags = GameFontNormalLarge:GetFont()
        if path then menu.title:SetFont(path, math.max(11, (size or 14) - 1), flags or "") end
    end

    local close = CreateFrame("Button", nil, menu.header, "UIPanelButtonTemplate")
    close:SetSize(28, 22)
    close:SetPoint("RIGHT", -10, 0)
    close:SetText("X")
    close:SetScript("OnClick", function() menu:Hide() end)
    menu.closeButton = close

    -- Content host; soft page fill over faction art
    menu.content = CreateFrame("Frame", nil, menu, "BackdropTemplate")
    menu.content:SetPoint("TOPLEFT", 20, -64)
    menu.content:SetPoint("BOTTOMRIGHT", -20, 20)
    menu.content:SetFrameLevel((menu:GetFrameLevel() or 1) + 4)
    Blackacre.UI.Theme.ApplyFilledPanel(menu.content, 0.88, "page")

    for i, tab in ipairs(MENU_TABS) do
        MakeBookmarkTab(menu, tab, i) -- parent = outer shell so tabs hang past edge
        MakePage(menu.content, tab.id)
    end

    BuildVoicePage(pages.voice)
    BuildSharePage(pages.share)

    menu._built = true
    return menu
end

local function Build()
    local ok, err = pcall(function()
        if not Blackacre.UI or not Blackacre.UI.Theme or not Blackacre.UI.Theme.CreateBookShell then
            error("Theme.CreateBookShell missing — core UI failed to load")
        end
        hub = Blackacre.UI.Theme.CreateBookShell("BlackacreTomeHub", "Traveler's Chronicle")
        -- Esc hierarchy via BlackacreTomeEscGate (not raw hub name — that closed sidecar+tome together)
        RemoveFromUISpecialFrames("BlackacreTomeHub")
        EnsureEscGate()
        hub:HookScript("OnShow", function()
            SyncEscGate()
            if Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.PlayUISound then
                Blackacre.UI.Theme.PlayUISound("bookOpen") -- adventure flourish (local)
            end
        end)
        hub:HookScript("OnHide", function()
            if menu then menu:Hide() end
            SyncEscGate()
            if Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.PlayUISound then
                Blackacre.UI.Theme.PlayUISound("bookClose") -- local only (Wowhead igSpellBookClose / 830)
            end
        end)

        -- IC book only: chronicle hosts (no feature tabs on the book)
        pages.chronicle = CreateFrame("Frame", nil, hub.bookOpen)
        pages.chronicle:SetSize(1, 1)
        pages.chronicle:SetPoint("TOPLEFT", hub.bookOpen, "TOPLEFT", 0, 0)
        pages.chronicle:EnableMouse(false)
        pages.chronicle:Hide()
        pages.chronicle.tocHost = hub.leftPage
        pages.chronicle.pageHost = hub.rightPage
        hub.chronicleHost = pages.chronicle

        -- pageHost still used for setup wizard embedding if needed
        pages.setup = CreateFrame("Frame", nil, hub.pageHost)
        pages.setup:SetAllPoints(hub.pageHost)
        pages.setup:Hide()

        BuildBackstoryMenu()

        hub._built = true
        ShowBookAsChronicle()
        MountTab("chronicle")
        if pages.chronicle then pages.chronicle:Show() end
        if Blackacre.Chronicle and Blackacre.Chronicle.UI and Blackacre.Chronicle.UI.OnHubShow then
            pcall(Blackacre.Chronicle.UI.OnHubShow)
        end
    end)
    if not ok then
        hub = nil
        if Blackacre.Print then
            Blackacre.Print("|cffff6666Tome failed to build:|r " .. tostring(err))
        else
            print("|cffff6666Blackacre Tome failed to build:|r " .. tostring(err))
        end
    end
end

function Blackacre.TomeHub.GetChronicleParent()
    if not hub then Build() end
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
    BuildBackstoryMenu()
    return pages[id or activeMenuTab]
end

function Blackacre.TomeHub.Init()
end

function Blackacre.TomeHub.SetSetupMode(on)
    setupMode = on and true or false
    SetTabsEnabled(not setupMode)
    if setupMode then
        if pages.chronicle then pages.chronicle:Hide() end
        if pages.setup then
            pages.setup:Show()
            hub.pageHost:Show()
            hub.leftPage:Hide()
            hub.rightPage:Hide()
        end
    else
        ShowBookAsChronicle()
        if pages.setup then pages.setup:Hide() end
        if pages.chronicle then pages.chronicle:Show() end
    end
end

function Blackacre.TomeHub.IsSetupMode()
    return setupMode
end

function Blackacre.TomeHub.ShowBackstoryMenu(tabId)
    if not hub or not hub._built then Build() end
    BuildBackstoryMenu()
    if not menu then return end
    if not hub:IsShown() then hub:Show() end
    PlaceMenuAsSidecar()
    SelectMenuTab(tabId or activeMenuTab or "lineage")
    if not menu:IsShown() and Theme() and Theme().PlayUISound then
        Theme().PlayUISound("softFlourish")
    end
    menu:Show()
    SyncEscGate()
end

function Blackacre.TomeHub.HideBackstoryMenu()
    if menu then menu:Hide() end
    SyncEscGate()
end

function Blackacre.TomeHub.ToggleBackstoryMenu(tabId)
    if not menu or not menu._built then
        Blackacre.TomeHub.ShowBackstoryMenu(tabId)
        return
    end
    if menu:IsShown() and (not tabId or tabId == activeMenuTab) then
        menu:Hide()
    else
        Blackacre.TomeHub.ShowBackstoryMenu(tabId)
    end
end

function Blackacre.TomeHub.Show(tabId)
    if not hub or not hub._built then Build() end
    if not hub then
        if Blackacre.Print then
            Blackacre.Print("Tome is not available (build failed). Check chat for red errors.")
        end
        return
    end
    local ok, err = pcall(function()
        if setupMode and tabId ~= "setup" then
            hub:Show()
            return
        end
        if tabId == "setup" then
            hub:Show()
            return
        end
        -- Known OOC menu tabs open Backstory frame; chronicle/default opens the book
        local isMenu = false
        for _, t in ipairs(MENU_TABS) do
            if t.id == tabId then isMenu = true break end
        end
        if isMenu then
            hub:Show()
            ShowBookAsChronicle()
            MountTab("chronicle")
            if pages.chronicle then pages.chronicle:Show() end
            if Blackacre.Chronicle and Blackacre.Chronicle.UI and Blackacre.Chronicle.UI.OnHubShow then
                pcall(Blackacre.Chronicle.UI.OnHubShow)
            end
            Blackacre.TomeHub.ShowBackstoryMenu(tabId)
        else
            ShowBookAsChronicle()
            MountTab("chronicle")
            if pages.chronicle then pages.chronicle:Show() end
            if Blackacre.Chronicle and Blackacre.Chronicle.UI and Blackacre.Chronicle.UI.OnHubShow then
                pcall(Blackacre.Chronicle.UI.OnHubShow)
            end
            hub:Show()
        end
    end)
    if not ok then
        if Blackacre.Print then
            Blackacre.Print("|cffff6666Tome open failed:|r " .. tostring(err))
        else
            print("|cffff6666Blackacre Tome open failed:|r " .. tostring(err))
        end
    end
end

function Blackacre.TomeHub.Hide()
    if hub then hub:Hide() end
    if menu then menu:Hide() end
end

function Blackacre.TomeHub.Toggle(tabId)
    if not hub or not hub._built then Build() end
    if not hub then
        if Blackacre.Print then
            Blackacre.Print("Tome is not available (build failed). Check chat for red errors.")
        end
        return
    end
    local isMenu = false
    for _, t in ipairs(MENU_TABS) do
        if t.id == tabId then isMenu = true break end
    end
    if isMenu then
        Blackacre.TomeHub.ToggleBackstoryMenu(tabId)
        if not hub:IsShown() then hub:Show() end
        return
    end
    if hub:IsShown() and not setupMode then
        hub:Hide()
        if menu then menu:Hide() end
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

function Blackacre.TomeHub.TurnPage(delta)
    if Blackacre.Chronicle and Blackacre.Chronicle.UI and Blackacre.Chronicle.UI.TurnPage then
        Blackacre.Chronicle.UI.TurnPage(delta)
    end
end
