-- Blackacre UI Theme
--
-- FRAME / LAYER MODEL (Mayron Ep. 5 — use this for all Tome & Menu chrome):
--   Frame = canvas (parent + unlimited children)
--   Draw layers on a frame, back → front:
--     BACKGROUND → BORDER → ARTWORK → OVERLAY → HIGHLIGHT
--   Sublevel (-8..7) orders regions inside the same layer.
-- Full write-up: docs/FRAME-LAYERS.md

Blackacre = Blackacre or {}
Blackacre.UI = Blackacre.UI or {}
Blackacre.UI.Theme = {}

--- Canonical draw-layer names (engine strings). Prefer these constants in new code.
Blackacre.UI.Theme.Layer = {
    BACKGROUND = "BACKGROUND", -- fills, washes, paper
    BORDER = "BORDER",         -- edge art
    ARTWORK = "ARTWORK",       -- spine, ornaments, card art
    OVERLAY = "OVERLAY",       -- text, primary icons, controls chrome
    HIGHLIGHT = "HIGHLIGHT",   -- mouse hover (auto show/hide)
}

--- Create a texture on a frame at a known layer/sublevel (defaults: BACKGROUND, 0).
function Blackacre.UI.Theme.CreateLayeredTexture(frame, layer, sublevel)
    if not frame then return nil end
    layer = layer or Blackacre.UI.Theme.Layer.BACKGROUND
    return frame:CreateTexture(nil, layer, nil, sublevel)
end

--- Create a font string on OVERLAY by default (text must sit above art).
function Blackacre.UI.Theme.CreateLayeredFontString(frame, layer, inherits)
    if not frame then return nil end
    layer = layer or Blackacre.UI.Theme.Layer.OVERLAY
    return frame:CreateFontString(nil, layer, inherits or "GameFontHighlight")
end

Blackacre.UI.Theme.Colors = {
    -- Graphite pencil-lead ink (cool grey-black) for chronicle body / TOC
    ink = { 0.20, 0.21, 0.23 },
    inkSoft = { 0.32, 0.33, 0.36 },
    gold = { 0.85, 0.70, 0.25 },
    parchment = { 0.92, 0.86, 0.72 },
    page = { 0.97, 0.93, 0.82 },
    pageFill = { 0.94, 0.88, 0.74 },
    edge = { 0.55, 0.42, 0.22 },
    edgeGold = { 0.75, 0.60, 0.28 },
    spine = { 0.22, 0.14, 0.08 },
    tabIdle = { 0.42, 0.30, 0.14 },
    tabActive = { 0.72, 0.55, 0.22 },
    cover = { 0.22, 0.16, 0.10 },
    headerFill = { 0.18, 0.14, 0.10 },
    footerFill = { 0.16, 0.12, 0.09 },
}

Blackacre.UI.Theme.Seals = {
    INDIVIDUAL = { label = "Personal", color = { 0.55, 0.45, 0.30 }, short = "P" },
    GROUP = { label = "Company", color = { 0.35, 0.50, 0.65 }, short = "C" },
    GUILD = { label = "Guild", color = { 0.55, 0.35, 0.65 }, short = "G" },
    FACTION = { label = "Realm", color = { 0.70, 0.30, 0.25 }, short = "R" },
}

Blackacre.UI.Theme.Textures = {
    parchment = "Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal",
    parchmentVert = "Interface\\AchievementFrame\\UI-Achievement-Parchment",
    questBG = "Interface\\QuestFrame\\QuestBG",
    dialogEdge = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tooltipEdge = "Interface\\Tooltips\\UI-Tooltip-Border",
    goldEdge = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
    -- Owner polish pack (Interface paths; Desktop PNGs = name reference only)
    achievementBorders = "Interface\\AchievementFrame\\UI-Achievement-Borders",
    goldBorderTile = "Interface\\Common\\UI-Goldborder-_tile",
    alertBackground = "Interface\\AchievementFrame\\UI-Achievement-Alert-Background",
    rewardBackground = "Interface\\AchievementFrame\\UI-Achievement-Reward-Background",
    pageNumGlow = "Interface\\Glues\\Models\\UI_MainMenu_Legion\\UI_Warlords_SkyGLow_Left_01",
    stickyFill = "Interface\\Spellbook\\Spellbook-Page-1",
    mapPinCursor = "Interface\\Cursor\\MapPinCursor",
    mapPinCursorCross = "Interface\\Cursor\\Crosshairs\\MapPinCursor",
    commonIcons = "Interface\\Common\\CommonIcons",
    statusOffline = "Interface\\FriendsFrame\\StatusIcon-Offline",
    noteMenuIcon = "Interface\\GossipFrame\\HealerGossipIcon",
    noteLockIcon = "Interface\\ChatFrame\\UI-ChatFrame-LockIcon",
    tocBanner = "Interface\\PVPFrame\\PVP-Banner-5-Border-2",
    toastCentaur = "Interface\\CovenantRenown\\DragonflightMajorFactionsCentaur",
    frameAlliance = "Interface\\FrameGeneral\\UIFrameAlliance",
    frameHorde = "Interface\\FrameGeneral\\UIFrameHorde",
    guildBankTab = "Interface\\GuildBankFrame\\UI-GuildBankFrame-Tab",
    -- Icon chrome: Achievement icon frame wraps Interface\\Icons\\* (owner E0)
    iconFrame = "Interface\\AchievementFrame\\UI-Achievement-IconFrame",
    microSpellbook = "Interface\\Buttons\\UI-MicroButton-Spellbook-Down",
    optionsGear = "Interface\\Buttons\\UI-OptionsButton",
    bookIcon = "Interface\\Spellbook\\Spellbook-Icon",
    questBook = "Interface\\QuestFrame\\UI-QuestLog-BookIcon",
    stone = "Interface\\FrameGeneral\\UI-Background-Rock",
    white = "Interface\\Buttons\\WHITE8x8",
    -- Adventure Journal open-book (Shift+J)
    ejJournalBG = "Interface\\EncounterJournal\\UI-EJ-JournalBG",
    bookArt = "Interface\\EncounterJournal\\UI-EJ-JournalBG",
    bookArtTexCoords = { left = 0, right = 0.766601562, top = 0, bottom = 0.830078125 },
    -- EJ atlas (bookmark tabs, buttons) — name reference from owner desktop library
    ejTextures = "Interface\\EncounterJournal\\UI-EncounterJournalTextures",
    ejTexturesTile = "Interface\\EncounterJournal\\UI-EncounterJournalTextures_Tile",
    -- Map-frame chrome (Borders and Polish name family → Blizzard paths)
    ejMapFrameLeft = "Interface\\EncounterJournal\\UI-EJ-MapFrame-Cata-Left",
    ejMapFrameMid = "Interface\\EncounterJournal\\UI-EJ-MapFrame-Cata-Mid",
    -- Faction mission frame polish (OOC menu flair later)
    allianceMissionFrame = "Interface\\Garrison\\AllianceBfAMissionFrame",
    hordeMissionFrame = "Interface\\Garrison\\HordeBfAMissionFrame",
    spellbookPage = "Interface\\Spellbook\\Spellbook-Page-1",
    spellbookPage2 = "Interface\\Spellbook\\Spellbook-Page-2",
}

--- Piece crops (UV 0–1). Prefer Blizzard XML when found; tweak after /reload.
Blackacre.UI.Theme.TexCoords = Blackacre.UI.Theme.TexCoords or {
    commonIconsDelete = { 0.50, 0.55, 0.0, 0.10 },
    -- Guild bank side tab: trim transparent pad so face fills button (E0)
    guildBankTab = { 0.08, 0.92, 0.02, 0.98 },
}

--- EJ side-tab slices (Blizzard_EncounterJournal.xml EncounterTabTemplate family)
Blackacre.UI.Theme.EjTabCoords = {
    unselected = { 0.25585938, 0.37890625, 0.90332031, 0.95898438 },
    selected   = { 0.12890625, 0.25195313, 0.90332031, 0.95898438 },
    highlight  = { 0.00195313, 0.12500000, 0.90332031, 0.95898438 },
}

--[[
  Font library (owner request). WoW can only load fonts the game can read —
  typically TTF/OTF placed under Interface\AddOns\Blackacre\Media\Fonts\ and
  registered here. System fonts (Ink Free, Segoe Script, …) are NOT portable
  across players unless bundled.

  Drop .ttf files into Media/Fonts/ then set paths below (no extension required).
  Zips from Downloads must be extracted first (bilbo / middleearth / elven / party-business).
]]
-- Chronicle BODY + sticky notes only (not titles, headers, or Backstory menus).
-- Empty rectangles (□) = missing glyphs. WoW cannot mix two fonts inside one string
-- (so | cannot be Default while letters are Hobbiton). We sanitize symbols to safer
-- ASCII and offer full game fonts + a short decorative list.
local FONT = "Interface\\AddOns\\Blackacre\\Media\\Fonts\\"
local WOW_FRIZ = "Fonts\\FRIZQT__.TTF"
local WOW_FRIZ_CYR = "Fonts\\FRIZQT___CYR.TTF"
local WOW_MORPHEUS = "Fonts\\MORPHEUS.TTF"
local WOW_SKURRI = "Fonts\\skurri.ttf"

Blackacre.UI.Theme.Fonts = {
    catalog = {
        -- Complete / game fonts
        { key = "default",      path = nil,              name = "Default (WoW mail)", full = true },
        { key = "frizGame",     path = WOW_FRIZ,         name = "Friz (game)", full = true },
        { key = "frizCyr",      path = WOW_FRIZ_CYR,     name = "Friz Cyrillic (game)", full = true },
        { key = "friz",         path = FONT .. "friz-quadrata-tt.ttf", name = "Friz Quadrata (addon)", full = true },
        { key = "morpheusGame", path = WOW_MORPHEUS,     name = "Morpheus (game)", full = true },
        { key = "morpheus",     path = FONT .. "MORPHEUS.TTF", name = "Morpheus (addon)", full = true },
        { key = "skurri",       path = WOW_SKURRI,       name = "Skurri (game)", full = true },
        -- Decorative (may still miss some glyphs; symbols are sanitized)
        { key = "hobbiton",     path = FONT .. "HobbitonBrushhandhobbitonBrush-WygA.ttf", name = "Hobbiton Brush", full = false },
        { key = "middleEarth",  path = FONT .. "Middleearth-ao6m.ttf", name = "Middle Earth", full = false },
    },
    activeKey = "default",
    activeBody = nil,
}

function Blackacre.UI.Theme.GetBodyFontCatalog()
    return Blackacre.UI.Theme.Fonts.catalog
end

function Blackacre.UI.Theme.GetBodyFontPath()
    local fonts = Blackacre.UI.Theme.Fonts
    if fonts.activeBody and fonts.activeBody ~= "" then
        return fonts.activeBody
    end
    local key = fonts.activeKey or "default"
    for _, row in ipairs(fonts.catalog or {}) do
        if row.key == key then
            return row.path
        end
    end
    return nil
end

--- Apply body font key (tome body + sticky notes only). Persists to AceDB when available.
function Blackacre.UI.Theme.SetBodyFontKey(key, silent)
    local fonts = Blackacre.UI.Theme.Fonts
    key = key or "default"
    local path = nil
    local found = false
    for _, row in ipairs(fonts.catalog or {}) do
        if row.key == key then
            path = row.path
            found = true
            break
        end
    end
    if not found then key = "default" path = nil end
    fonts.activeKey = key
    fonts.activeBody = path
    if Blackacre.db and Blackacre.db.profile then
        Blackacre.db.profile.bodyFontKey = key
    end
    if not silent and Blackacre.Print then
        local label = key
        for _, row in ipairs(fonts.catalog or {}) do
            if row.key == key then label = row.name break end
        end
        Blackacre.Print("Chronicle body font: " .. tostring(label)
            .. (path and (" (" .. path .. ")") or " (default)"))
    end
    -- Refresh open journal so body/notes pick it up (titles stay gold/default)
    if Blackacre.Chronicle and Blackacre.Chronicle.UI and Blackacre.Chronicle.UI.Refresh then
        pcall(Blackacre.Chronicle.UI.Refresh)
    end
end

function Blackacre.UI.Theme.LoadBodyFontFromDB()
    local key = "default"
    if Blackacre.db and Blackacre.db.profile and Blackacre.db.profile.bodyFontKey then
        key = Blackacre.db.profile.bodyFontKey
    end
    Blackacre.UI.Theme.SetBodyFontKey(key, true)
end

--- Solid filled panel (no stretched quest art gaps).
function Blackacre.UI.Theme.ApplyFilledPanel(frame, alpha, style)
    alpha = alpha or 0.96
    style = style or "page"
    local bg = Blackacre.UI.Theme.Textures.white
    local edge = Blackacre.UI.Theme.Textures.tooltipEdge
    local edgeSize = 14
    local c
    if style == "book" then
        edge = Blackacre.UI.Theme.Textures.dialogEdge
        edgeSize = 24
        c = Blackacre.UI.Theme.Colors.pageFill
    elseif style == "panel" then
        c = Blackacre.UI.Theme.Colors.parchment
    else
        c = Blackacre.UI.Theme.Colors.page
    end
    frame:SetBackdrop({
        bgFile = bg,
        edgeFile = edge,
        tile = true,
        tileSize = 16,
        edgeSize = edgeSize,
        insets = { left = 5, right = 5, top = 5, bottom = 5 },
    })
    frame:SetBackdropColor(c[1], c[2], c[3], alpha)
    local e = Blackacre.UI.Theme.Colors.edge
    frame:SetBackdropBorderColor(e[1], e[2], e[3], 1)
end

function Blackacre.UI.Theme.ApplyParchmentBackdrop(frame, alpha)
    Blackacre.UI.Theme.ApplyFilledPanel(frame, alpha or 0.95, "panel")
end

function Blackacre.UI.Theme.ApplyBookBackdrop(frame, alpha)
    alpha = alpha or 0.98
    local Layer = Blackacre.UI.Theme.Layer
    -- Backdrop = frame chrome (fill + edge). Extra art uses explicit layers (Ep. 5 model).
    -- Solid cover fill (never stretch QuestBG — that left empty corners)
    frame:SetBackdrop({
        bgFile = Blackacre.UI.Theme.Textures.white,
        edgeFile = Blackacre.UI.Theme.Textures.dialogEdge,
        tile = true,
        tileSize = 32,
        edgeSize = 28,
        insets = { left = 10, right = 10, top = 10, bottom = 10 },
    })
    local cover = Blackacre.UI.Theme.Colors.cover
    frame:SetBackdropColor(cover[1], cover[2], cover[3], alpha)
    local g = Blackacre.UI.Theme.Colors.gold
    frame:SetBackdropBorderColor(g[1] * 0.75, g[2] * 0.65, g[3] * 0.4, 1)

    if not frame._baSpine then
        -- BACKGROUND sublevel -8: spine (further back)
        local spine = Blackacre.UI.Theme.CreateLayeredTexture(frame, Layer.BACKGROUND, -8)
        spine:SetPoint("TOPLEFT", 6, -8)
        spine:SetPoint("BOTTOMLEFT", 6, 8)
        spine:SetWidth(22)
        local s = Blackacre.UI.Theme.Colors.spine
        spine:SetColorTexture(s[1], s[2], s[3], 1)
        frame._baSpine = spine

        -- BACKGROUND sublevel -6: page wash (in front of spine, still behind ARTWORK)
        local wash = Blackacre.UI.Theme.CreateLayeredTexture(frame, Layer.BACKGROUND, -6)
        wash:SetPoint("TOPLEFT", 28, -12)
        wash:SetPoint("BOTTOMRIGHT", -12, 12)
        local p = Blackacre.UI.Theme.Colors.pageFill
        wash:SetColorTexture(p[1], p[2], p[3], 0.97)
        frame._baWash = wash

        -- ARTWORK: ribbon ornament (above background washes)
        local ribbon = Blackacre.UI.Theme.CreateLayeredTexture(frame, Layer.ARTWORK, 0)
        ribbon:SetPoint("TOP", frame, "TOP", 48, 4)
        ribbon:SetSize(26, 40)
        ribbon:SetColorTexture(0.55, 0.12, 0.12, 0.9)
        frame._baRibbon = ribbon
    end
end

function Blackacre.UI.Theme.ApplyPagePanel(frame, alpha)
    Blackacre.UI.Theme.ApplyFilledPanel(frame, alpha or 0.92, "page")
end

--- Pass A skeleton chrome: plain box + border only (no spine/ribbon/parchment art).
--- Use until owner approves layout; Pass B swaps to Achievement-frame art.
function Blackacre.UI.Theme.ApplySkeletonPanel(frame, alpha)
    alpha = alpha or 0.95
    frame:SetBackdrop({
        bgFile = Blackacre.UI.Theme.Textures.white,
        edgeFile = Blackacre.UI.Theme.Textures.tooltipEdge,
        tile = true,
        tileSize = 16,
        edgeSize = 14,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    -- Neutral gray fill so regions read as structure, not final art
    frame:SetBackdropColor(0.18, 0.18, 0.20, alpha)
    frame:SetBackdropBorderColor(0.55, 0.55, 0.58, 1)
end

local function SkeletonRegionLabel(parent, text)
    local fs = Blackacre.UI.Theme.CreateLayeredFontString(parent, Blackacre.UI.Theme.Layer.OVERLAY, "GameFontDisableSmall")
    fs:SetPoint("TOPRIGHT", -6, -4)
    fs:SetText(text)
    fs:SetTextColor(0.65, 0.65, 0.7, 0.85)
    return fs
end

--- Outer Tome: Adventure Guide–inspired open book.
--- Returns: .header, .tabBar (horizontal EJ-style), .chronicleBookmark,
---          .bookOpen, .leftPage, .rightPage, .pageHost (alias rightPage for mounts),
---          .prevPageBtn, .nextPageBtn, .footer, .title, .closeButton
--- Outer Tome shell: single centered book art, bottom tabs, parent footer tools, one close X.
--- Returns: header, tabBar, bookOpen, leftPage, rightPage, pageHost, chronicleBookmark,
---          prevPageBtn, nextPageBtn, pageLabel, footer, toolStrip, title, closeButton
function Blackacre.UI.Theme.CreateBookShell(name, titleText)
    local Layer = Blackacre.UI.Theme.Layer

    local WIDTH, HEIGHT = 980, 660
    local HEADER_H = 36
    local TAB_H = 32
    local FOOTER_H = 44
    local PAD = 6
    local GAP = 4

    local frame = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
    frame:SetSize(WIDTH, HEIGHT)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("HIGH")
    frame:SetToplevel(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetClampedToScreen(true)
    frame:Hide()
    tinsert(UISpecialFrames, name)

    frame._baShellPass = "B"
    Blackacre.UI.Theme.ApplyBookShellChrome(frame)

    -- HEADER
    frame.header = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.header:SetPoint("TOPLEFT", PAD, -PAD)
    frame.header:SetPoint("TOPRIGHT", -PAD, -PAD)
    frame.header:SetHeight(HEADER_H)
    frame.header:EnableMouse(true)
    frame.header:RegisterForDrag("LeftButton")
    frame.header:SetScript("OnDragStart", function() frame:StartMoving() end)
    frame.header:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)
    Blackacre.UI.Theme.ApplyBookChromeBar(frame.header, "header")
    frame.header:SetFrameLevel((frame:GetFrameLevel() or 1) + 30)

    frame.title = Blackacre.UI.Theme.CreateLayeredFontString(frame.header, Layer.OVERLAY, "GameFontNormalHuge")
    frame.title:SetPoint("LEFT", 14, 0)
    frame.title:SetText(titleText or "Traveler's Chronicle")
    Blackacre.UI.Theme.GoldTitle(frame.title)

    -- Stock labeled close (no experimental icon BLP)
    local close = CreateFrame("Button", nil, frame.header, "UIPanelButtonTemplate")
    close:SetSize(32, 26)
    close:SetPoint("RIGHT", -8, 0)
    close:SetFrameLevel((frame.header:GetFrameLevel() or 1) + 5)
    close:SetText("X")
    close:SetScript("OnClick", function() frame:Hide() end)
    frame.closeButton = close
    close:Show()

    -- FOOTER — raised above book art so tools never disappear
    frame.footer = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.footer:SetPoint("BOTTOMLEFT", PAD, PAD)
    frame.footer:SetPoint("BOTTOMRIGHT", -PAD, PAD)
    frame.footer:SetHeight(FOOTER_H)
    Blackacre.UI.Theme.ApplyBookChromeBar(frame.footer, "footer")
    frame.footer:SetFrameLevel((frame:GetFrameLevel() or 1) + 30)

    -- Labeled stock buttons (same layout/function as E0; no framed BLP icons)
    local fl = (frame.footer:GetFrameLevel() or 1) + 5
    local function Tip(btn, title, body)
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(title)
            if body then GameTooltip:AddLine(body, 0.85, 0.85, 0.85, true) end
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end

    frame.journalToggle = CreateFrame("Button", nil, frame.footer, "UIPanelButtonTemplate")
    frame.journalToggle:SetSize(110, 26)
    frame.journalToggle:SetPoint("LEFT", 12, 0)
    frame.journalToggle:SetFrameLevel(fl)
    frame.journalToggle:SetText("Journal: Off")
    frame.journalToggle._baOn = false
    Tip(frame.journalToggle, "Edit Journal", "Toggle edit mode. Turning off also saves the open page.")
    frame.journalToggle:SetScript("OnClick", function(self)
        local wasOn = self._baOn
        self._baOn = not self._baOn
        self:SetText(self._baOn and "Journal: On" or "Journal: Off")
        if wasOn and not self._baOn then
            if Blackacre.Chronicle and Blackacre.Chronicle.UI and Blackacre.Chronicle.UI.SaveSelected then
                Blackacre.Chronicle.UI.SaveSelected()
            end
        end
        Blackacre.UI.Theme.PlayUISound("journalToggle")
        if Blackacre.TomeHub and Blackacre.TomeHub.OnJournalToggle then
            Blackacre.TomeHub.OnJournalToggle(self._baOn)
        end
    end)

    frame.backstoryBtn = CreateFrame("Button", nil, frame.footer, "UIPanelButtonTemplate")
    frame.backstoryBtn:SetSize(90, 26)
    frame.backstoryBtn:SetPoint("RIGHT", -10, 0)
    frame.backstoryBtn:SetFrameLevel(fl)
    frame.backstoryBtn:SetText("Backstory")
    Tip(frame.backstoryBtn, "Backstory Menus", "Lineage, Survival, Paths, Afterlife, Voice, Share — OOC tools.")
    frame.backstoryBtn:SetScript("OnClick", function()
        Blackacre.UI.Theme.PlayUISound("toolClick")
        if Blackacre.TomeHub and Blackacre.TomeHub.ToggleBackstoryMenu then
            Blackacre.TomeHub.ToggleBackstoryMenu()
        end
    end)

    frame.pageJump = CreateFrame("EditBox", nil, frame.footer, "InputBoxTemplate")
    frame.pageJump:SetSize(36, 20)
    frame.pageJump:SetPoint("RIGHT", frame.backstoryBtn, "LEFT", -44, 0)
    frame.pageJump:SetAutoFocus(false)
    frame.pageJump:SetNumeric(true)
    frame.pageJump:SetMaxLetters(4)
    frame.pageJump:SetText("1")
    frame.pageJump:SetFrameLevel(fl)
    frame.pageJump:SetScript("OnEnterPressed", function(self)
        local n = tonumber(self:GetText())
        if Blackacre.Chronicle and Blackacre.Chronicle.UI and Blackacre.Chronicle.UI.GoToPage then
            Blackacre.Chronicle.UI.GoToPage(n)
        end
        self:ClearFocus()
    end)

    frame.pageJumpBtn = CreateFrame("Button", nil, frame.footer, "UIPanelButtonTemplate")
    frame.pageJumpBtn:SetSize(36, 24)
    frame.pageJumpBtn:SetPoint("LEFT", frame.pageJump, "RIGHT", 2, 0)
    frame.pageJumpBtn:SetFrameLevel(fl)
    frame.pageJumpBtn:SetText("Go")
    Tip(frame.pageJumpBtn, "Jump to page", "Type a leaf number, then click or press Enter.")
    frame.pageJumpBtn:SetScript("OnClick", function()
        Blackacre.UI.Theme.PlayUISound("toolClick")
        local n = tonumber(frame.pageJump:GetText())
        if Blackacre.Chronicle and Blackacre.Chronicle.UI and Blackacre.Chronicle.UI.GoToPage then
            Blackacre.Chronicle.UI.GoToPage(n)
        end
    end)

    frame.addNoteBtn = CreateFrame("Button", nil, frame.footer, "UIPanelButtonTemplate")
    frame.addNoteBtn:SetSize(80, 26)
    frame.addNoteBtn:SetPoint("RIGHT", frame.pageJump, "LEFT", -8, 0)
    frame.addNoteBtn:SetFrameLevel(fl)
    frame.addNoteBtn:SetText("Add note")
    Tip(frame.addNoteBtn, "Add note", "Click, then click a page leaf to place a scrap note.")
    frame.addNoteBtn:SetScript("OnClick", function()
        Blackacre.UI.Theme.PlayUISound("toolClick")
        if Blackacre.Chronicle and Blackacre.Chronicle.UI and Blackacre.Chronicle.UI.BeginPinMode then
            Blackacre.Chronicle.UI.BeginPinMode()
        end
    end)
    frame.pinHereBtn = nil

    frame.toolStrip = CreateFrame("Frame", nil, frame.footer)
    frame.toolStrip:SetPoint("LEFT", frame.journalToggle, "RIGHT", 8, 0)
    frame.toolStrip:SetPoint("RIGHT", frame.addNoteBtn, "LEFT", -8, 0)
    frame.toolStrip:SetHeight(30)
    frame.toolStrip:SetFrameLevel((frame.footer:GetFrameLevel() or 1) + 2)

    -- Slim rail above footer (no IC feature tabs — reserved for page tools strip spacing)
    frame.tabBar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.tabBar:SetPoint("BOTTOMLEFT", frame.footer, "TOPLEFT", 0, GAP)
    frame.tabBar:SetPoint("BOTTOMRIGHT", frame.footer, "TOPRIGHT", 0, GAP)
    frame.tabBar:SetHeight(math.max(8, TAB_H - 18))
    frame.tabBar:SetBackdrop({
        bgFile = Blackacre.UI.Theme.Textures.white,
        edgeFile = nil,
        tile = true, tileSize = 8, edgeSize = 0,
        insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    frame.tabBar:SetBackdropColor(0.12, 0.09, 0.06, 0.5)
    frame.tabRail = frame.tabBar

    -- BOOK OPEN between header and tabs (fills middle of shell)
    frame.bookOpen = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.bookOpen:SetPoint("TOPLEFT", frame.header, "BOTTOMLEFT", 0, -GAP)
    frame.bookOpen:SetPoint("BOTTOMRIGHT", frame.tabBar, "TOPRIGHT", 0, GAP)
    frame.bookOpen:SetScript("OnSizeChanged", function(self)
        Blackacre.UI.Theme.FitBookArtToFrame(self)
    end)
    frame.bookOpen:SetScript("OnShow", function(self)
        Blackacre.UI.Theme.FitBookArtToFrame(self)
    end)
    Blackacre.UI.Theme.FitBookArtToFrame(frame.bookOpen)

    -- TOC bookmark: stock tooltip edge (no guild-bank BLP sheet)
    frame.chronicleBookmark = CreateFrame("Button", nil, frame.bookOpen, "BackdropTemplate")
    frame.chronicleBookmark:SetSize(28, 72)
    frame.chronicleBookmark:SetPoint("TOPLEFT", frame.bookOpen, "TOPLEFT", -10, -40)
    frame.chronicleBookmark:SetFrameLevel((frame.bookOpen:GetFrameLevel() or 1) + 2)
    frame.chronicleBookmark:SetBackdrop({
        bgFile = Blackacre.UI.Theme.Textures.white,
        edgeFile = Blackacre.UI.Theme.Textures.tooltipEdge,
        tile = true, tileSize = 8, edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    frame.chronicleBookmark:SetBackdropColor(0.45, 0.28, 0.12, 0.98)
    frame.chronicleBookmark:SetBackdropBorderColor(0.95, 0.80, 0.35, 1)
    local bmLabel = frame.chronicleBookmark:CreateFontString(nil, Layer.OVERLAY, "GameFontNormalSmall")
    bmLabel:SetPoint("CENTER", 0, 0)
    bmLabel:SetWidth(12)
    bmLabel:SetWordWrap(true)
    bmLabel:SetText("TOC")
    bmLabel:SetTextColor(1, 1, 1, 1)
    frame.chronicleBookmark.label = bmLabel
    frame.chronicleBookmark:SetScript("OnClick", function()
        Blackacre.UI.Theme.PlayUISound("pageTurn")
        if Blackacre.TomeHub and Blackacre.TomeHub.Show then
            Blackacre.TomeHub.Show("chronicle")
        end
        if Blackacre.Chronicle and Blackacre.Chronicle.UI and Blackacre.Chronicle.UI.GoToToc then
            Blackacre.Chronicle.UI.GoToToc()
        end
    end)
    frame.chronicleBookmark:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Jump to Table of Contents")
        GameTooltip:Show()
    end)
    frame.chronicleBookmark:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Gutter buffer ~50px each side so graphite text stays clear of the spine
    local GUTTER_PAD = 50

    -- Two equal leaves — above bookmark chrome so TOC rows receive clicks
    frame.leftPage = CreateFrame("Frame", nil, frame.bookOpen)
    frame.leftPage:SetPoint("TOPLEFT", frame.bookOpen, "TOPLEFT", 28, -20)
    frame.leftPage:SetPoint("BOTTOMRIGHT", frame.bookOpen, "BOTTOM", -GUTTER_PAD, 48)
    if frame.leftPage.SetClipsChildren then frame.leftPage:SetClipsChildren(true) end
    frame.leftPage:SetFrameLevel((frame.bookOpen:GetFrameLevel() or 1) + 10)
    frame.leftPage:EnableMouse(false)

    frame.rightPage = CreateFrame("Frame", nil, frame.bookOpen)
    frame.rightPage:SetPoint("TOPLEFT", frame.bookOpen, "TOP", GUTTER_PAD, -20)
    frame.rightPage:SetPoint("BOTTOMRIGHT", frame.bookOpen, "BOTTOMRIGHT", -28, 48)
    if frame.rightPage.SetClipsChildren then frame.rightPage:SetClipsChildren(true) end
    frame.rightPage:SetFrameLevel((frame.bookOpen:GetFrameLevel() or 1) + 10)
    frame.rightPage:EnableMouse(false)

    -- Soft center gutter
    frame.gutter = frame.bookOpen:CreateTexture(nil, Layer.ARTWORK)
    frame.gutter:SetColorTexture(0.05, 0.04, 0.03, 0.35)
    frame.gutter:SetWidth(6)
    frame.gutter:SetPoint("TOP", frame.bookOpen, "TOP", 0, -24)
    frame.gutter:SetPoint("BOTTOM", frame.bookOpen, "BOTTOM", 0, 52)

    frame.pageHost = CreateFrame("Frame", nil, frame.bookOpen)
    frame.pageHost:SetPoint("TOPLEFT", 28, -20)
    frame.pageHost:SetPoint("BOTTOMRIGHT", -28, 48)
    if frame.pageHost.SetClipsChildren then frame.pageHost:SetClipsChildren(true) end
    frame.pageHost:SetFrameLevel((frame.bookOpen:GetFrameLevel() or 1) + 3)
    frame.pageHost:Hide()

    -- Nav: < leftNum ..... rightNum >
    frame.prevPageBtn = CreateFrame("Button", nil, frame.bookOpen, "UIPanelButtonTemplate")
    frame.prevPageBtn:SetSize(36, 24)
    frame.prevPageBtn:SetPoint("BOTTOMLEFT", frame.leftPage, "BOTTOMLEFT", 8, -36)
    frame.prevPageBtn:SetFrameLevel((frame.bookOpen:GetFrameLevel() or 1) + 20)
    frame.prevPageBtn:SetText("<")
    frame.prevPageBtn:Show()
    frame.prevPageBtn:SetScript("OnClick", function()
        if Blackacre.TomeHub and Blackacre.TomeHub.TurnPage then
            Blackacre.TomeHub.TurnPage(-1)
        end
    end)

    -- Page numbers with subtle sky-glow underlay (owner: Warlords sky glow as soft mask)
    local function MakePageNum(anchorPoint, relTo, relPoint, ox, oy)
        local holder = CreateFrame("Frame", nil, frame.bookOpen)
        holder:SetSize(36, 22)
        holder:SetPoint(anchorPoint, relTo, relPoint, ox, oy)
        holder:SetFrameLevel((frame.bookOpen:GetFrameLevel() or 1) + 7)
        local fs = holder:CreateFontString(nil, Layer.OVERLAY, "GameFontNormal")
        fs:SetPoint("CENTER", 0, 0)
        local ink = Blackacre.UI.Theme.Colors.ink
        fs:SetTextColor(ink[1], ink[2], ink[3], 1)
        holder.text = fs
        return holder, fs
    end

    local leftHold, leftFs = MakePageNum("LEFT", frame.prevPageBtn, "RIGHT", 6, 0)
    leftFs:SetText("1")
    frame.leftPageNumHolder = leftHold
    frame.leftPageNum = leftFs

    frame.nextPageBtn = CreateFrame("Button", nil, frame.bookOpen, "UIPanelButtonTemplate")
    frame.nextPageBtn:SetSize(36, 24)
    frame.nextPageBtn:SetPoint("BOTTOMRIGHT", frame.rightPage, "BOTTOMRIGHT", -8, -36)
    frame.nextPageBtn:SetFrameLevel((frame.bookOpen:GetFrameLevel() or 1) + 20)
    frame.nextPageBtn:SetText(">")
    frame.nextPageBtn:Show()
    frame.nextPageBtn:SetScript("OnClick", function()
        if Blackacre.TomeHub and Blackacre.TomeHub.TurnPage then
            Blackacre.TomeHub.TurnPage(1)
        end
    end)

    local rightHold, rightFs = MakePageNum("RIGHT", frame.nextPageBtn, "LEFT", -6, 0)
    rightFs:SetText("2")
    frame.rightPageNumHolder = rightHold
    frame.rightPageNum = rightFs

    -- Legacy aliases (jump lives on footer now; no center book label)
    frame.pageLabel = nil

    return frame
end

function Blackacre.UI.Theme.MountInPage(frame, parent)
    if not frame or not parent then return end
    frame:SetParent(parent)
    frame:ClearAllPoints()
    frame:SetAllPoints(parent)
    frame:SetMovable(false)
    frame:EnableMouse(true)
    frame:SetFrameStrata(parent:GetFrameStrata() or "HIGH")
    if frame.SetClipsChildren then
        frame:SetClipsChildren(true)
    end
    -- Strip freestanding chrome if present
    if frame.closeButton then frame.closeButton:Hide() end
    for _, child in ipairs({ frame:GetChildren() }) do
        if child.GetObjectType and child:GetObjectType() == "Button" then
            local n = child:GetName() or ""
            if n:find("Close") or (child.GetNormalTexture and child:GetWidth() <= 32 and child:GetHeight() <= 32
                and child:GetPoint(1) and select(1, child:GetPoint(1)) == "TOPRIGHT") then
                -- leave generic small buttons; hide UIPanelCloseButton-like
            end
        end
    end
end

function Blackacre.UI.Theme.SealLabel(scopeTier)
    local seal = Blackacre.UI.Theme.Seals[scopeTier or "INDIVIDUAL"]
        or Blackacre.UI.Theme.Seals.INDIVIDUAL
    return seal.label, seal.short, seal.color
end

function Blackacre.UI.Theme.FormatSealPrefix(scopeTier)
    local _, short, color = Blackacre.UI.Theme.SealLabel(scopeTier)
    return string.format("|cff%02x%02x%02x[%s]|r ",
        math.floor((color[1] or 0.5) * 255),
        math.floor((color[2] or 0.5) * 255),
        math.floor((color[3] or 0.5) * 255),
        short)
end

function Blackacre.UI.Theme.InkFont(fontString, size)
    if not fontString then return end
    local c = Blackacre.UI.Theme.Colors.ink
    if size == "title" then
        fontString:SetFontObject(GameFontNormalHuge or GameFontNormalLarge)
    elseif size == "header" then
        fontString:SetFontObject(GameFontNormalLarge)
    else
        fontString:SetFontObject(GameFontHighlightLarge or GameFontHighlight)
    end
    fontString:SetTextColor(c[1], c[2], c[3])
end

function Blackacre.UI.Theme.GoldTitle(fontString)
    if not fontString then return end
    fontString:SetFontObject(GameFontNormalHuge or GameFontNormalLarge)
    local g = Blackacre.UI.Theme.Colors.gold
    fontString:SetTextColor(g[1], g[2], g[3])
end

--- In-game letter / mail style body text (larger, readable).
function Blackacre.UI.Theme.ApplyMailBodyFont(region, extraSize)
    if not region then return end
    extraSize = extraSize or 2
    local fontPath, fontSize, fontFlags
    if MailTextFontNormal and MailTextFontNormal.GetFont then
        fontPath, fontSize, fontFlags = MailTextFontNormal:GetFont()
    elseif QuestFontNormalLarge and QuestFontNormalLarge.GetFont then
        fontPath, fontSize, fontFlags = QuestFontNormalLarge:GetFont()
    elseif QuestFont and QuestFont.GetFont then
        fontPath, fontSize, fontFlags = QuestFont:GetFont()
    else
        fontPath, fontSize, fontFlags = GameFontHighlight:GetFont()
    end
    if fontPath then
        region:SetFont(fontPath, (fontSize or 14) + extraSize, fontFlags or "")
    end
    local c = Blackacre.UI.Theme.Colors.ink
    if region.SetTextColor then
        region:SetTextColor(c[1], c[2], c[3])
    end
end


--- Active book-art path for inspection (/ba bookart also prints this).
function Blackacre.UI.Theme.GetBookArtPath()
    return Blackacre.UI.Theme.Textures.bookArt
        or Blackacre.UI.Theme.Textures.ejJournalBG
        or "Interface\\EncounterJournal\\UI-EJ-JournalBG"
end

--- Fit Adventure Journal texture to bookOpen.
--- File: Interface\EncounterJournal\UI-EJ-JournalBG
---
--- Blizzard does NOT use the full BLP: they SetTexCoord to crop packing grey.
--- From Gethe/wow-ui-source Blizzard_EncounterJournal.xml (Mainline):
---   <Texture file="Interface\EncounterJournal\UI-EJ-JournalBG">
---     <TexCoords left="0" right="0.766601562" top="0" bottom="0.830078125"/>
--- That is ~23% off the right and ~17% off the bottom of the source image.
--- We use the same coords, then stretch that region to fill bookOpen.
function Blackacre.UI.Theme.FitBookArtToFrame(host)
    if not host then return end
    local path = Blackacre.UI.Theme.GetBookArtPath()
    local tc = Blackacre.UI.Theme.Textures.bookArtTexCoords or {
        left = 0, right = 0.766601562, top = 0, bottom = 0.830078125,
    }

    if host._baBookArtFrame then
        host._baBookArtFrame:Hide()
        host._baBookArtFrame:SetParent(nil)
        host._baBookArtFrame = nil
    end
    host._baFixedBookW = nil
    host._baFixedBookH = nil

    if host.SetBackdrop then
        host:SetBackdrop(nil)
    end

    local Layer = Blackacre.UI.Theme.Layer
    local tex = host._baBookArt
    if not tex then
        tex = host:CreateTexture(nil, Layer.ARTWORK, nil, -8)
        host._baBookArt = tex
    end
    if tex.SetDrawLayer then
        tex:SetDrawLayer(Layer.ARTWORK, -8)
    end
    tex:SetTexture(path)
    tex:SetVertexColor(1, 1, 1, 1)
    tex:SetAlpha(1)
    if tex.SetHorizTile then tex:SetHorizTile(false) end
    if tex.SetVertTile then tex:SetVertTile(false) end

    -- Blizzard official crop (not full 0–1 of the BLP)
    tex:SetTexCoord(tc.left or 0, tc.right or 1, tc.top or 0, tc.bottom or 1)

    tex:ClearAllPoints()
    tex:SetAllPoints(host)
    tex:Show()
end

--- Back-compat name used by older call sites / OnSizeChanged.
function Blackacre.UI.Theme.ApplyCenteredBookArt(host)
    Blackacre.UI.Theme.FitBookArtToFrame(host)
end

--- Map symbols fancy fonts often lack to plain ASCII letters/spaces.
--- (Cannot use Default font for | only — WoW draws each string in ONE font.)
function Blackacre.UI.Theme.SanitizeBodyText(text)
    if not text or text == "" then return text end
    if not Blackacre.UI.Theme.GetBodyFontPath or not Blackacre.UI.Theme.GetBodyFontPath() then
        return text
    end
    -- Unicode / fancy punctuation
    text = text:gsub("–", "-")
    text = text:gsub("—", "-")
    text = text:gsub("…", "...")
    text = text:gsub("·", " - ")
    text = text:gsub("•", "*")
    text = text:gsub("“", "\"")
    text = text:gsub("”", "\"")
    text = text:gsub("‘", "'")
    text = text:gsub("’", "'")
    -- ASCII symbols that often become □ in script fonts → word-safe substitutes
    text = text:gsub("|", " / ")
    text = text:gsub("\\", "/")
    text = text:gsub("%[", "(")
    text = text:gsub("%]", ")")
    text = text:gsub("%{", "(")
    text = text:gsub("%}", ")")
    text = text:gsub("<", "(")
    text = text:gsub(">", ")")
    text = text:gsub("~", "-")
    text = text:gsub("`", "'")
    text = text:gsub("@", " at ")
    text = text:gsub("#", " no.")
    text = text:gsub("%^", " ")
    text = text:gsub("_", " ")
    return text
end

local function TrySetFont(region, path, size)
    if not region or not path or path == "" or not region.SetFont then return false end
    local ok = pcall(function() region:SetFont(path, size, "") end)
    if ok then return true end
    -- Retry without extension
    local bare = path:gsub("%.[tT][tT][fF]$", ""):gsub("%.[oO][tT][fF]$", "")
    if bare ~= path then
        ok = pcall(function() region:SetFont(bare, size, "") end)
    end
    return ok and true or false
end

function Blackacre.UI.Theme.ApplyReadableBodyFont(region, extraSize)
    if not region then return end
    extraSize = extraSize or 1
    local size = 14 + extraSize
    local custom = Blackacre.UI.Theme.GetBodyFontPath and Blackacre.UI.Theme.GetBodyFontPath()
    local applied = false
    if custom then
        applied = TrySetFont(region, custom, size)
        -- If fancy font failed to load entirely, fall back to game Friz (full charset)
        if not applied then
            applied = TrySetFont(region, WOW_FRIZ, size)
        end
    end
    if not applied then
        Blackacre.UI.Theme.ApplyMailBodyFont(region, extraSize)
    end
    -- Graphite pencil-lead (titles use GoldTitle separately — not this)
    local c = Blackacre.UI.Theme.Colors.ink
    if region.SetTextColor then
        region:SetTextColor(c[1], c[2], c[3], 1)
    end
    if region.SetShadowColor then
        region:SetShadowColor(1, 1, 1, 0.15)
    end
end

--- Book parent shell chrome — proven dialog/gold *edgeFile* only (no raw multi-piece sheet).
--- Achievement-Borders pieces come later as TexCoord/NineSlice (E1), not full-bleed.
function Blackacre.UI.Theme.ApplyBookShellChrome(frame)
    if not frame or not frame.SetBackdrop then return end
    local T = Blackacre.UI.Theme.Textures
    -- Prefer classic dialog edge (known edgeFile layout). Gold tile only if it behaves as edge.
    local edge = T.dialogEdge or T.goldEdge
    frame:SetBackdrop({
        bgFile = T.white,
        edgeFile = edge,
        tile = true,
        tileSize = 32,
        edgeSize = 28,
        insets = { left = 10, right = 10, top = 10, bottom = 10 },
    })
    local cover = Blackacre.UI.Theme.Colors.cover
    frame:SetBackdropColor(cover[1], cover[2], cover[3], 0.97)
    local eg = Blackacre.UI.Theme.Colors.edgeGold
    frame:SetBackdropBorderColor(eg[1], eg[2], eg[3], 1)
    -- Hide any leftover raw full-sheet border from earlier experiment
    if frame._baAchBorder then
        frame._baAchBorder:Hide()
    end
end

--- Faction OOC chrome — dialog edge only (no Alliance/Horde kit BLP sheets).
function Blackacre.UI.Theme.ApplyFactionFrameChrome(frame)
    if frame and frame._baFactionBG then
        frame._baFactionBG:Hide()
    end
    Blackacre.UI.Theme.ApplyBookShellChrome(frame)
end

function Blackacre.UI.Theme.ApplyBookChromeBar(frame, which)
    if not frame or not frame.SetBackdrop then return end
    frame:SetBackdrop({
        bgFile = Blackacre.UI.Theme.Textures.parchment,
        edgeFile = Blackacre.UI.Theme.Textures.tooltipEdge,
        tile = false,
        tileSize = 0,
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    local fill = (which == "footer") and Blackacre.UI.Theme.Colors.footerFill or Blackacre.UI.Theme.Colors.headerFill
    frame:SetBackdropColor(fill[1], fill[2], fill[3], 0.98)
    local eg = Blackacre.UI.Theme.Colors.edgeGold
    frame:SetBackdropBorderColor(eg[1] * 0.85, eg[2] * 0.85, eg[3] * 0.85, 1)
end

--- Style a tool button for the book footer (still uses panel template for clickability).
function Blackacre.UI.Theme.ApplyBookToolButton(btn)
    if not btn then return end
    if btn.SetNormalFontObject then btn:SetNormalFontObject(GameFontNormal) end
    if btn.SetHighlightFontObject then btn:SetHighlightFontObject(GameFontHighlight) end
end

--- Small floating menus (sticky pin, add-note confirm) — one Theme path for edges.
function Blackacre.UI.Theme.ApplyChromeMenuFrame(frame)
    if not frame or not frame.SetBackdrop then return end
    local T = Blackacre.UI.Theme.Textures
    frame:SetBackdrop({
        bgFile = T.white,
        edgeFile = T.tooltipEdge,
        tile = true,
        tileSize = 8,
        edgeSize = 10,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    frame:SetBackdropColor(0.12, 0.10, 0.08, 0.97)
    frame:SetBackdropBorderColor(0.85, 0.70, 0.30, 1)
end

function Blackacre.UI.Theme.GetParchmentPath()
    return Blackacre.UI.Theme.Textures.parchment
        or "Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal"
end

--- Local UI sounds only (PlaySound = this client; never broadcasts).
Blackacre.UI.Theme.Sounds = {
    pageTurn = (SOUNDKIT and SOUNDKIT.IG_ABILITY_PAGE_TURN) or 836,
    -- Soft adventure flourish when opening the tome (local)
    bookOpen = (SOUNDKIT and SOUNDKIT.UI_70_BOOST_THANKSFORPLAYING_SMALLER)
        or (SOUNDKIT and SOUNDKIT.UI_PERSONAL_LOOT_BANNER)
        or (SOUNDKIT and SOUNDKIT.IG_QUEST_LOG_OPEN)
        or 829,
    bookClose = (SOUNDKIT and SOUNDKIT.IG_SPELLBOOK_CLOSE) or 830,
    writeQuill = (SOUNDKIT and SOUNDKIT.IG_WRITE_QUILL) or 839,
    checkbox = (SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON) or 856,
    toolClick = (SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION) or 852,
    menuTab = (SOUNDKIT and SOUNDKIT.IG_CHARACTER_INFO_TAB) or 841,
    menuOpen = (SOUNDKIT and SOUNDKIT.IG_CHARACTER_INFO_OPEN) or 850,
    -- Soft neutral flourish (sidecar open)
    softFlourish = (SOUNDKIT and SOUNDKIT.UI_70_BOOST_THANKSFORPLAYING_SMALLER)
        or (SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPEN)
        or 850,
    -- Soft pin / paper (no dedicated paper-tear kit — closest UI paper)
    pinSoft = (SOUNDKIT and SOUNDKIT.IG_ABILITY_PAGE_TURN) or 836,
    paperTear = (SOUNDKIT and SOUNDKIT.IG_MAINMENU_CLOSE) or 799,
    journalToggle = (SOUNDKIT and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON) or 856,
}

function Blackacre.UI.Theme.PlayUISound(which)
    local sounds = Blackacre.UI.Theme.Sounds
    local kit = sounds and sounds[which]
    if not kit or not PlaySound then return end
    pcall(PlaySound, kit, "SFX", true)
end

--- Icon helper: atlas name or Interface\\Icons\\ path.
function Blackacre.UI.Theme.SetIconTexture(tex, iconRef, size)
    if not tex then return end
    size = size or 25
    if not iconRef or iconRef == "" then return end
    if not iconRef:find("\\") and not iconRef:find("/") then
        if tex.SetAtlas then
            local ok = pcall(function() tex:SetAtlas(iconRef, true) end)
            if ok then return end
        end
        tex:SetTexture("Interface\\Icons\\" .. iconRef)
        return
    end
    tex:SetTexture(iconRef)
end

--- Apply path or atlas to a texture; returns true if something stuck.
function Blackacre.UI.Theme.ApplyTextureOrAtlas(tex, ref)
    if not tex or not ref then return false end
    if type(ref) == "table" then
        if ref.atlas and tex.SetAtlas then
            local ok = pcall(function() tex:SetAtlas(ref.atlas, true) end)
            if ok then return true end
        end
        if ref.path then
            tex:SetTexture(ref.path)
            if ref.coords then
                tex:SetTexCoord(ref.coords[1], ref.coords[2], ref.coords[3], ref.coords[4])
            end
            return true
        end
        return false
    end
    -- bare atlas name (no backslash)
    if not tostring(ref):find("\\") and not tostring(ref):find("/") and tex.SetAtlas then
        local ok = pcall(function() tex:SetAtlas(ref, true) end)
        if ok then return true end
        tex:SetTexture("Interface\\Icons\\" .. ref)
        return true
    end
    tex:SetTexture(ref)
    return true
end

--- Icon button: Achievement IconFrame border with icon BLP nested inside (owner E0).
--- outerSize = full button including frame; icon sits inset. opts: { noFrame=true, w=, h= }
function Blackacre.UI.Theme.CreateIconButton(parent, outerSize, ref, tooltipTitle, tooltipBody, opts)
    opts = opts or {}
    local ow = opts.w or outerSize or 36
    local oh = opts.h or outerSize or ow
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(ow, oh)
    b:EnableMouse(true)
    b:RegisterForClicks("LeftButtonUp")

    local useFrame = not opts.noFrame
    local T = Blackacre.UI.Theme.Textures
    local inset = useFrame and 6 or 0
    local iconW = math.max(12, ow - inset * 2)
    local iconH = math.max(12, oh - inset * 2)

    -- ARTWORK: icon face (nested inside frame)
    local normal = b:CreateTexture(nil, "ARTWORK")
    normal:SetSize(iconW, iconH)
    normal:SetPoint("CENTER", 0, 0)
    Blackacre.UI.Theme.ApplyTextureOrAtlas(normal, ref)
    if type(ref) == "string" and ref:find("Interface\\Icons\\") then
        normal:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    end
    b.icon = normal

    -- OVERLAY: Achievement icon frame around any Interface\\Icons style face
    if useFrame and T.iconFrame then
        local frameTex = b:CreateTexture(nil, "OVERLAY")
        frameTex:SetAllPoints(b)
        frameTex:SetTexture(T.iconFrame)
        -- IconFrame sheet often has usable ring in full UV; leave 0–1 unless XML crop needed
        frameTex:SetTexCoord(0, 1, 0, 1)
        b.iconFrame = frameTex
    end

    local pushed = b:CreateTexture(nil, "ARTWORK")
    pushed:SetSize(iconW, iconH)
    pushed:SetPoint("CENTER", 1, -1)
    Blackacre.UI.Theme.ApplyTextureOrAtlas(pushed, ref)
    if type(ref) == "string" and ref:find("Interface\\Icons\\") then
        pushed:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    end
    pushed:SetVertexColor(0.8, 0.8, 0.8, 1)
    b:SetPushedTexture(pushed)
    -- Keep normal as child art (SetNormalTexture can fight with custom layout)
    b:SetScript("OnMouseDown", function()
        normal:SetPoint("CENTER", 1, -1)
        normal:SetVertexColor(0.85, 0.85, 0.85, 1)
    end)
    b:SetScript("OnMouseUp", function()
        normal:SetPoint("CENTER", 0, 0)
        normal:SetVertexColor(1, 1, 1, 1)
    end)

    local hi = b:CreateTexture(nil, "HIGHLIGHT")
    hi:SetPoint("CENTER", 0, 0)
    hi:SetSize(iconW + 2, iconH + 2)
    hi:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
    hi:SetBlendMode("ADD")
    b:SetHighlightTexture(hi)

    if tooltipTitle then
        b:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(tooltipTitle)
            if tooltipBody then
                GameTooltip:AddLine(tooltipBody, 0.85, 0.85, 0.85, true)
            end
            GameTooltip:Show()
        end)
        b:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end
    return b
end

--- Minimap / map pin face for Pin Here (atlas first, path fallbacks).
function Blackacre.UI.Theme.GetMapPinIconRef()
    return {
        -- try modern waypoint pin, then classic minimap-style paths
        atlas = "Waypoint-MapPin-Tracked",
        path = "Interface\\MINIMAP\\UI-Minimap-Pin",
        fallbackPath = "Interface\\Cursor\\MapPinCursor",
        fallbackIcon = "Interface\\Icons\\INV_Misc_Map_01",
    }
end

function Blackacre.UI.Theme.ApplyMapPinIcon(tex)
    if not tex then return end
    local r = Blackacre.UI.Theme.GetMapPinIconRef()
    if tex.SetAtlas and r.atlas then
        local ok = pcall(function() tex:SetAtlas(r.atlas, true) end)
        if ok then return end
    end
    for _, path in ipairs({ r.path, r.fallbackPath, r.fallbackIcon }) do
        if path then
            tex:SetTexture(path)
            if path:find("Icons\\") then
                tex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            else
                tex:SetTexCoord(0, 1, 0, 1)
            end
            return
        end
    end
end

--- Alliance = K.C. only; Horde = ADP only (never both for the player).
function Blackacre.UI.Theme.FormatFactionYear(yearValue)
    local faction = UnitFactionGroup and UnitFactionGroup("player") or "Alliance"
    local adp = yearValue
    if yearValue and yearValue > 200 and Blackacre.YearCalendar and Blackacre.YearCalendar.FromKC then
        adp = Blackacre.YearCalendar.FromKC(yearValue)
    end
    if not Blackacre.YearCalendar then
        return tostring(yearValue or "?")
    end
    adp = adp or Blackacre.YearCalendar.GetPresentADP()
    if faction == "Horde" then
        return Blackacre.YearCalendar.FormatYearADP(adp, "ADP")
    end
    local kc = Blackacre.YearCalendar.ToKC(adp)
    if kc then
        return string.format("%d K.C.", kc)
    end
    return Blackacre.YearCalendar.FormatYearADP(adp, "KC")
end

--- Keep for callers that still paint a single leaf; uses parchment only (no dual images).
function Blackacre.UI.Theme.ApplyOpenBookPage(frame)
    if not frame then return end
    if frame.SetBackdrop then frame:SetBackdrop(nil) end
    -- Leaves stay transparent; parent bookOpen owns the single art texture.
end

local toastFrame
local toastTimer

function Blackacre.UI.Theme.Toast(message)
    if not toastFrame then
        toastFrame = CreateFrame("Frame", "BlackacreToast", UIParent)
        toastFrame:SetSize(400, 72)
        toastFrame:SetPoint("TOP", UIParent, "TOP", 0, -100)
        toastFrame:SetFrameStrata("DIALOG")
        toastFrame.bg = toastFrame:CreateTexture(nil, "BACKGROUND")
        toastFrame.bg:SetAllPoints(toastFrame)
        toastFrame.bg:SetColorTexture(0.15, 0.12, 0.08, 0.95)
        toastFrame.text = toastFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        toastFrame.text:SetPoint("LEFT", 28, 0)
        toastFrame.text:SetPoint("RIGHT", -28, 0)
        toastFrame.text:SetJustifyH("CENTER")
        Blackacre.UI.Theme.InkFont(toastFrame.text)
        toastFrame.text:SetTextColor(1, 0.95, 0.85, 1)
        toastFrame:Hide()
    end
    toastFrame.text:SetText(message or "")
    toastFrame:Show()
    if toastTimer then toastTimer:Cancel() end
    toastTimer = C_Timer.NewTimer(4, function() toastFrame:Hide() end)
end