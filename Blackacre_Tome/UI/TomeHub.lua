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
        -- Esc closes the Tome only. Backstory sidecar stays until its own X.
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
    { id = "lineage", label = "Lineage", icon = "spell_holy_borrowedtime" },
    { id = "honor", label = "Survival", icon = "achievement_zone_tanaris_01" },
    { id = "road", label = "Path", icon = "ability_hunter_pathfinding", retailOnly = true },
    { id = "realms", label = "Afterlife", icon = "achievement_bg_xkills_avgraveyard" },
    { id = "voice", label = "Voice", icon = "inv_misc_horn_03" },
    { id = "share", label = "Character Sheet", icon = "inv_10_specialization_inscription_sharedknowledge_color1" },
}

local function VisibleMenuTabs()
    local forever = Blackacre.Compat and Blackacre.Compat.IsForever and Blackacre.Compat.IsForever()
    local list = {}
    for i = 1, #MENU_TABS do
        local tab = MENU_TABS[i]
        if not (forever and tab.retailOnly) then
            list[#list + 1] = tab
        end
    end
    return list
end

local function Theme()
    return Blackacre.UI and Blackacre.UI.Theme
end

local function EjTexturePath()
    local th = Theme()
    return (th and th.Textures and th.Textures.ejTextures)
        or "Interface\\EncounterJournal\\UI-EncounterJournalTextures"
end

local function EnsureVoiceDB()
    if Blackacre.Voice and Blackacre.Voice.GetSettings then
        return Blackacre.Voice.GetSettings()
    end
    Blackacre.CharDB = Blackacre.CharDB or {}
    Blackacre.CharDB.voice = Blackacre.CharDB.voice or {
        language = "auto",
        accent = "auto",
        applyToChronicle = true,
        applyToBulletins = false,
    }
    return Blackacre.CharDB.voice
end

local function SetTabsEnabled(on)
    for _, t in ipairs(VisibleMenuTabs()) do
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
        btn.bg:SetVertexColor(1, 1, 1, active and 1 or 0.72)
    end
    if btn.icon then
        btn.icon:ClearAllPoints()
        btn.icon:SetSize(38, 38)
        btn.icon:SetPoint("CENTER", btn, "CENTER", -14, 5)
        btn.icon:SetVertexColor(1, 1, 1, active and 1 or 0.72)
        if type(btn.icon:GetTexture()) == "string" and tostring(btn.icon:GetTexture()):find("Icons") then
            btn.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        end
    end
    if btn.glow then
        btn.glow:Hide()
    end
    if btn.label then
        btn.label:SetText("")
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
        if Blackacre.PathUI and Blackacre.PathUI.Mount then
            Blackacre.PathUI.Mount(page)
        elseif Blackacre.Roadmap and Blackacre.Roadmap.UI and Blackacre.Roadmap.UI.Mount then
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

    for _, t in ipairs(VisibleMenuTabs()) do
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

    if menu and menu.title then
        local label = "Backstory"
        for _, t in ipairs(VisibleMenuTabs()) do
            if t.id == activeMenuTab then
                label = t.label or label
                break
            end
        end
        menu.title:SetText(label)
        if Blackacre.UI.Theme.GoldTitle then
            Blackacre.UI.Theme.GoldTitle(menu.title)
        end
    end

    if activeMenuTab == "lineage" and Blackacre.LineageUI and Blackacre.LineageUI.Refresh then
        SafeCall("lineage", Blackacre.LineageUI.Refresh)
    elseif activeMenuTab == "honor" and Blackacre.Hardcore and Blackacre.Hardcore.UI then
        SafeCall("honor", Blackacre.Hardcore.UI.Refresh)
    elseif activeMenuTab == "road" and Blackacre.PathUI and Blackacre.PathUI.Refresh then
        SafeCall("road", Blackacre.PathUI.Refresh)
    elseif activeMenuTab == "road" and Blackacre.Roadmap and Blackacre.Roadmap.UI then
        SafeCall("road", Blackacre.Roadmap.UI.Refresh)
    elseif activeMenuTab == "realms" and Blackacre.Afterlife and Blackacre.Afterlife.UI then
        SafeCall("realms", Blackacre.Afterlife.UI.Refresh)
    elseif activeMenuTab == "voice" and pages.voice and pages.voice.Refresh then
        SafeCall("voice", function() pages.voice:Refresh() end)
    elseif activeMenuTab == "share" and pages.share and pages.share.Refresh then
        SafeCall("sheet", function() pages.share:Refresh() end)
    end
end

local function MakeBookmarkTab(parent, tab, index)
    -- Spellbook tab face; hang sits on the shell, not in empty UI.
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(72, 72)
    btn:SetPoint("TOPLEFT", parent, "TOPRIGHT", -4, -48 - (index - 1) * 76)
    -- Above B1 nineslice (host is parent+45).
    btn:SetFrameLevel((parent:GetFrameLevel() or 1) + 52)

    btn.bg = btn:CreateTexture(nil, "BACKGROUND")
    btn.bg:SetAllPoints(btn)
    local tabFile = (Theme() and Theme().Textures and Theme().Textures.backstoryTab)
        or "Interface\\Spellbook\\UIFrameTabsSpellbook"
    btn.bg:SetTexture(tabFile)
    btn._baTabLabel = tab.label or ""

    btn.icon = btn:CreateTexture(nil, "ARTWORK")
    btn.icon:SetSize(38, 38)
    btn.icon:SetPoint("CENTER", -14, 5)
    btn.icon:SetTexture("Interface\\Icons\\" .. (tab.icon or "INV_Misc_QuestionMark"))
    btn.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    local maskPath = (Theme() and Theme().Textures and Theme().Textures.backstoryIconMask)
        or "Interface\\Spellbook\\SpellbookElementsIconMask"
    -- CreateMaskTexture clips the square spell icon to the round spellbook mask.
    if btn.CreateMaskTexture then
        local mask = btn:CreateMaskTexture()
        mask:SetAllPoints(btn.icon)
        mask:SetTexture(maskPath, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        btn.icon:AddMaskTexture(mask)
        btn.iconMask = mask
    elseif btn.icon.SetMask then
        pcall(btn.icon.SetMask, btn.icon, maskPath)
    end

    -- OVERLAY above the icon; not masked (the autocast ring lives outside the circle).
    btn.glow = btn:CreateTexture(nil, "OVERLAY", nil, 6)
    btn.glow:ClearAllPoints()
    btn.glow:SetSize(35, 35)
    btn.glow:SetPoint("CENTER", btn.icon, "CENTER", 0, 0)
    local hoverPath = (Theme() and Theme().Textures and Theme().Textures.backstoryTabHover)
        or "Interface\\Spellbook\\SpellbookElementsAutoCastMask"
    btn.glow:SetTexture(hoverPath)
    if btn.glow.SetBlendMode then btn.glow:SetBlendMode("ADD") end
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
    title:SetText("")
    title:Hide()
    Blackacre.UI.Theme.GoldTitle(title)
    do
        local path, size, flags = GameFontNormalLarge:GetFont()
        if path then title:SetFont(path, math.max(11, (size or 14) - 1), flags or "") end
    end

    page.profile = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    page.profile:SetPoint("TOPLEFT", 32, -72)
    ApplyMenuBodyFont(page.profile)

    local function Voice()
        return Blackacre.Voice
    end

    local langLabel = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    langLabel:SetPoint("TOPLEFT", 32, -100)
    langLabel:SetText("Language")
    ApplyMenuBodyFont(langLabel)

    page.langDrop = CreateFrame("Frame", "BATomeVoiceLanguage", page, "UIDropDownMenuTemplate")
    page.langDrop:SetPoint("TOPLEFT", 16, -118)
    UIDropDownMenu_SetWidth(page.langDrop, 220)
    UIDropDownMenu_Initialize(page.langDrop, function()
        local ids = Voice() and Voice().ListLanguages and Voice().ListLanguages() or { "auto", "none" }
        for _, id in ipairs(ids) do
            local captured = id
            local info = UIDropDownMenu_CreateInfo()
            info.text = Voice() and Voice().LanguageLabel and Voice().LanguageLabel(captured) or captured
            info.func = function()
                EnsureVoiceDB().language = captured
                page:Refresh()
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    local accLabel = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    accLabel:SetPoint("TOPLEFT", 32, -158)
    accLabel:SetText("Accent")
    ApplyMenuBodyFont(accLabel)

    page.dropdown = CreateFrame("Frame", "BATomeVoiceAccent", page, "UIDropDownMenuTemplate")
    page.dropdown:SetPoint("TOPLEFT", 16, -176)
    UIDropDownMenu_SetWidth(page.dropdown, 220)
    UIDropDownMenu_Initialize(page.dropdown, function()
        local ids = Voice() and Voice().ListAccents and Voice().ListAccents() or { "auto", "none" }
        for _, id in ipairs(ids) do
            local captured = id
            local info = UIDropDownMenu_CreateInfo()
            info.text = Voice() and Voice().AccentLabel and Voice().AccentLabel(captured) or captured
            info.func = function()
                EnsureVoiceDB().accent = captured
                page:Refresh()
            end
            UIDropDownMenu_AddButton(info)
        end
    end)

    page.chronCheck = CreateFrame("CheckButton", nil, page, "UICheckButtonTemplate")
    page.chronCheck:SetPoint("TOPLEFT", 32, -220)
    local ct = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    ct:SetPoint("LEFT", page.chronCheck, "RIGHT", 10, 0)
    ct:SetText("Chronicle")
    ApplyMenuBodyFont(ct)
    page.chronCheck:SetScript("OnClick", function(self)
        EnsureVoiceDB().applyToChronicle = self:GetChecked()
    end)
    page.chronCheck:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Apply voice to chronicle")
        GameTooltip:Show()
    end)
    page.chronCheck:SetScript("OnLeave", function() GameTooltip:Hide() end)

    page.bullCheck = CreateFrame("CheckButton", nil, page, "UICheckButtonTemplate")
    page.bullCheck:SetPoint("TOPLEFT", 32, -258)
    local bt = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    bt:SetPoint("LEFT", page.bullCheck, "RIGHT", 10, 0)
    bt:SetText("Bulletins")
    ApplyMenuBodyFont(bt)
    page.bullCheck:SetScript("OnClick", function(self)
        EnsureVoiceDB().applyToBulletins = self:GetChecked()
    end)
    page.bullCheck:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Apply voice to bulletins")
        GameTooltip:Show()
    end)
    page.bullCheck:SetScript("OnLeave", function() GameTooltip:Hide() end)

    page.sample = page:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    page.sample:SetPoint("TOPLEFT", 32, -304)
    page.sample:SetPoint("TOPRIGHT", -32, -304)
    page.sample:SetJustifyH("LEFT")
    page.sample:SetSpacing(4)
    ApplyMenuBodyFont(page.sample)

    function page:Refresh()
        local v = EnsureVoiceDB()
        local V = Voice()
        local langId = v.language or "auto"
        local accId = v.accent or "auto"
        UIDropDownMenu_SetText(page.langDrop, V and V.LanguageLabel and V.LanguageLabel(langId) or langId)
        UIDropDownMenu_SetText(page.dropdown, V and V.AccentLabel and V.AccentLabel(accId) or accId)
        page.chronCheck:SetChecked(v.applyToChronicle ~= false)
        page.bullCheck:SetChecked(v.applyToBulletins == true)
        local language, accent = "none", "none"
        if V and V.Resolve then
            language, accent = V.Resolve()
        end
        page.profile:SetText("Active: " .. (V and V.LanguageLabel and V.LanguageLabel(language) or language)
            .. "  +  " .. (V and V.AccentLabel and V.AccentLabel(accent) or accent))
        if V and V.Apply then
            page.sample:SetText(
                "Sample: " .. V.Apply("I am looking for the thing near the mountain, yes?")
                .. "\nGreeting: " .. V.Apply("Hello, I am looking for the thing, yes?")
                .. "\nSlang: " .. V.Apply("I'm gonna look for the thing, yeah?")
            )
        else
            page.sample:SetText("Voice engine not loaded.")
        end
    end
    mounted.voice = true
end

local function SheetLine(label, value)
    return label .. ": " .. (value and value ~= "" and value or "Not set")
end

local function BuildSharePage(page)
    local title = page:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 32, -24)
    title:SetText("Character Sheet")
    Blackacre.UI.Theme.GoldTitle(title)
    do
        local path, size, flags = GameFontNormalLarge:GetFont()
        if path then title:SetFont(path, math.max(11, (size or 14) - 1), flags or "") end
    end

    local shareBtn = CreateFrame("Button", nil, page, "UIPanelButtonTemplate")
    shareBtn:SetSize(90, 24)
    shareBtn:SetPoint("TOPRIGHT", -32, -22)
    shareBtn:SetText("Share")
    shareBtn:SetScript("OnClick", function()
        if Blackacre.Share and Blackacre.Share.Export and Blackacre.Share.Export.CopyToClipboard then
            Blackacre.Share.Export.CopyToClipboard()
        end
    end)
    shareBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Share")
        GameTooltip:AddLine("Whisper: /ba share PlayerName", 0.7, 0.7, 0.7, true)
        GameTooltip:Show()
    end)
    shareBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    local scroll = CreateFrame("ScrollFrame", "BATomeCharacterSheetScroll", page, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 24, -56)
    scroll:SetPoint("BOTTOMRIGHT", -44, 16)

    local body = CreateFrame("Frame", nil, scroll)
    body:SetSize(520, 40)
    scroll:SetScrollChild(body)

    page.bodyText = body:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    page.bodyText:SetPoint("TOPLEFT", 8, -4)
    page.bodyText:SetPoint("TOPRIGHT", -8, -4)
    page.bodyText:SetJustifyH("LEFT")
    page.bodyText:SetJustifyV("TOP")
    page.bodyText:SetSpacing(5)
    if page.bodyText.SetWordWrap then page.bodyText:SetWordWrap(true) end
    ApplyMenuBodyFont(page.bodyText)

    function page:Refresh()
        local name = (Blackacre.GetCharName and Blackacre.GetCharName()) or UnitName("player") or "Unknown"
        local race = UnitRace("player") or ""
        local class = UnitClass("player") or ""
        local level = UnitLevel("player") or 0

        local lineage = "Not set"
        if Blackacre.Birthpath and Blackacre.Birthpath.GetFlavor then
            lineage = Blackacre.Birthpath.GetFlavor() or lineage
        elseif Blackacre.YearCalendar and Blackacre.YearCalendar.GetBirthADP and Blackacre.YearCalendar.GetBirthADP()
            and Blackacre.Birthpath and Blackacre.Birthpath.GetSummary then
            lineage = Blackacre.Birthpath.GetSummary()
        end

        local pathLine = "Not set"
        local pathId = Blackacre.CharDB and Blackacre.CharDB.pathId
        if pathId and Blackacre.Paths and Blackacre.Paths.Get then
            local p = Blackacre.Paths.Get(pathId)
            if p then pathLine = p.name or pathId end
        end

        local riteLine = "Rites of Return Inactive"
        local chosen = Blackacre.Afterlife and Blackacre.Afterlife.GetChosenPath and Blackacre.Afterlife.GetChosenPath()
        local active = Blackacre.Afterlife and Blackacre.Afterlife.GetActive and Blackacre.Afterlife.GetActive()
        if active then
            riteLine = "Return Rite: " .. (active.pathName or (chosen and chosen.name) or "Active")
        elseif chosen then
            riteLine = "Return Rite: " .. (chosen.name or "Set")
        end

        local voiceLine = "None"
        if Blackacre.Voice and Blackacre.Voice.Resolve then
            local language, accent = Blackacre.Voice.Resolve()
            voiceLine = (Blackacre.Voice.LanguageLabel and Blackacre.Voice.LanguageLabel(language) or language)
                .. "  +  "
                .. (Blackacre.Voice.AccentLabel and Blackacre.Voice.AccentLabel(accent) or accent)
        end

        local survivalLine = "Not loaded"
        if Blackacre.Hardcore and Blackacre.Hardcore.GetStatus then
            local s = Blackacre.Hardcore.GetStatus()
            survivalLine = string.format(
                "%s  ·  deaths %d",
                s.clean and "unstained" or "stained",
                s.deathCount or 0
            )
        end
        if Blackacre.Survival and Blackacre.Survival.GetState then
            local sv = Blackacre.Survival.GetState()
            if sv and sv.enabled then
                survivalLine = (survivalLine ~= "Not loaded" and (survivalLine .. "  ·  ") or "")
                    .. string.format(
                        "hunger %d  thirst %d  exposure %d",
                        math.floor(sv.hunger or 0),
                        math.floor(sv.thirst or 0),
                        math.floor(sv.exposure or 0)
                    )
            end
        end

        local pages = {}
        local entries = Blackacre.Chronicle and Blackacre.Chronicle.Store and Blackacre.Chronicle.Store.List({}) or {}
        for i = 1, math.min(5, #entries) do
            pages[#pages + 1] = "  " .. (entries[i].title or entries[i].kind or "Untitled")
        end
        if #pages == 0 then
            pages[1] = "  (no pages yet)"
        end

        local text = table.concat({
            SheetLine("Name", name),
            SheetLine("Race / class / level", string.format("%s %s  ·  %d", race, class, level)),
            SheetLine("Lineage", lineage),
            SheetLine("Path", pathLine),
            riteLine,
            SheetLine("Voice", voiceLine),
            SheetLine("Survival", survivalLine),
            "",
            "Recent chronicle:",
            table.concat(pages, "\n"),
        }, "\n")
        page.bodyText:SetText(text)
        local h = page.bodyText:GetStringHeight() or 80
        body:SetHeight(math.max(80, h + 16))
    end
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
    -- Height matches the Tome so the sidecar is not a stub.
    menu:SetSize(640, 720)
    menu:SetFrameStrata("HIGH")
    menu:SetToplevel(true)
    menu:SetMovable(true)
    menu:EnableMouse(true)
    menu:RegisterForDrag("LeftButton")
    menu:SetScript("OnDragStart", menu.StartMoving)
    menu:SetScript("OnDragStop", menu.StopMovingOrSizing)
    menu:SetClampedToScreen(true)
    menu:Hide()
    menu:HookScript("OnShow", function(self)
        if Blackacre.UI.Theme.ApplyFactionFrameChrome then
            Blackacre.UI.Theme.ApplyFactionFrameChrome(self)
        end
    end)
    -- Not in UISpecialFrames: Esc is owned by BlackacreTomeEscGate (sidecar first, then tome)

    -- Faction FrameGeneral kits (Alliance / Horde from player data)
    if Blackacre.UI.Theme.ApplyFactionFrameChrome then
        Blackacre.UI.Theme.ApplyFactionFrameChrome(menu)
    else
        Blackacre.UI.Theme.ApplyBookShellChrome(menu)
    end

    menu.header = CreateFrame("Frame", nil, menu, "BackdropTemplate")
    menu.header:SetPoint("TOPLEFT", 33, -36)
    menu.header:SetPoint("TOPRIGHT", -33, -36)
    menu.header:SetHeight(34)
    menu.header:EnableMouse(true)
    menu.header:RegisterForDrag("LeftButton")
    menu.header:SetScript("OnDragStart", function() menu:StartMoving() end)
    menu.header:SetScript("OnDragStop", function() menu:StopMovingOrSizing() end)
    Blackacre.UI.Theme.ApplyNeutralTitleBar(menu.header)
    -- Above B1 garrison landing art.
    menu.header:SetFrameLevel((menu:GetFrameLevel() or 1) + 50)

    menu.title = Blackacre.UI.Theme.CreateLayeredFontString(menu.header, Layer.OVERLAY, "GameFontNormalHuge")
    menu.title:SetPoint("LEFT", 14, 0)
    menu.title:SetJustifyH("LEFT")
    if menu.title.SetWordWrap then menu.title:SetWordWrap(false) end
    menu.title:SetText("Lineage")
    Blackacre.UI.Theme.GoldTitle(menu.title)

    local close = CreateFrame("Button", nil, menu.header, "UIPanelButtonTemplate")
    close:SetSize(30, 24)
    close:SetPoint("RIGHT", -8, 0)
    close:SetFrameLevel((menu:GetFrameLevel() or 1) + 52)
    close:SetText("X")
    close:SetScript("OnClick", function() menu:Hide() end)
    menu.closeButton = close
    menu.title:SetPoint("RIGHT", close, "LEFT", -8, 0)

    -- Content inset so type sits inside ClassTrial-End-Frame, not under the ornament.
    menu.content = CreateFrame("Frame", nil, menu, "BackdropTemplate")
    menu.content:SetPoint("TOPLEFT", 28, -58)
    menu.content:SetPoint("BOTTOMRIGHT", -28, 28)
    menu.content:SetFrameLevel((menu:GetFrameLevel() or 1) + 16)
    if menu.content.SetBackdrop then menu.content:SetBackdrop(nil) end

    menu.sideTabs = {}
    for i, tab in ipairs(VisibleMenuTabs()) do
        MakeBookmarkTab(menu, tab, i)
        menu.sideTabs[i] = tabButtons[tab.id]
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
            -- Commit any active Chronicle editor before the book disappears.
            -- Text is also persisted as it changes, but this covers a final
            -- paste or focus change immediately before closing the Tome.
            if Blackacre.Chronicle and Blackacre.Chronicle.UI
                and Blackacre.Chronicle.UI.SaveSelected then
                pcall(Blackacre.Chronicle.UI.SaveSelected)
            end
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
            Blackacre.Print("Tome is not available, see system messages for errors to diagnose")
        end
        return
    end
    local ok, err = pcall(function()
        if Blackacre.SetupWizard and Blackacre.SetupWizard.PAUSED then
            setupMode = false
        end
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
        for _, t in ipairs(VisibleMenuTabs()) do
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
            Blackacre.Print("Tome is not available, see system messages for errors to diagnose")
        end
        return
    end
    local isMenu = false
    for _, t in ipairs(VisibleMenuTabs()) do
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
        Blackacre.Print(on and "Journaling is On — edits save automatically" or "Journaling is Off")
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
