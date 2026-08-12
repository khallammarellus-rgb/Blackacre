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
    ink = { 0.15, 0.10, 0.05 },
    inkSoft = { 0.25, 0.18, 0.10 },
    gold = { 0.85, 0.70, 0.25 },
    parchment = { 0.92, 0.86, 0.72 },
    page = { 0.97, 0.93, 0.82 },
    pageFill = { 0.94, 0.88, 0.74 },
    edge = { 0.55, 0.42, 0.22 },
    spine = { 0.22, 0.14, 0.08 },
    tabIdle = { 0.42, 0.30, 0.14 },
    tabActive = { 0.72, 0.55, 0.22 },
    cover = { 0.32, 0.20, 0.10 },
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
    bookIcon = "Interface\\Spellbook\\Spellbook-Icon",
    questBook = "Interface\\QuestFrame\\UI-QuestLog-BookIcon",
    stone = "Interface\\FrameGeneral\\UI-Background-Rock",
    white = "Interface\\Buttons\\WHITE8x8",
    -- Adventure Guide / open-book feel (Encounter Journal + Spellbook page)
    ejJournalBG = "Interface\\EncounterJournal\\UI-EJ-JournalBG",
    spellbookPage = "Interface\\Spellbook\\Spellbook-Page-1",
    spellbookPage2 = "Interface\\Spellbook\\Spellbook-Page-2",
}

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
function Blackacre.UI.Theme.CreateBookShell(name, titleText)
    local Layer = Blackacre.UI.Theme.Layer

    -- Large landscape; content fills most of the frame (less dead root margin)
    local WIDTH, HEIGHT = 960, 640
    local HEADER_H = 40
    local TAB_H = 34
    local FOOTER_H = 38
    local BOOKMARK_W = 36
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

    frame._baShellPass = "B" -- layout + open-book art language
    Blackacre.UI.Theme.ApplySkeletonPanel(frame, 0.97)
    frame:SetBackdropColor(0.12, 0.10, 0.08, 0.96)
    frame:SetBackdropBorderColor(0.55, 0.45, 0.25, 1)

    -- HEADER (compact title bar)
    frame.header = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.header:SetPoint("TOPLEFT", PAD, -PAD)
    frame.header:SetPoint("TOPRIGHT", -PAD, -PAD)
    frame.header:SetHeight(HEADER_H)
    frame.header:EnableMouse(true)
    frame.header:RegisterForDrag("LeftButton")
    frame.header:SetScript("OnDragStart", function() frame:StartMoving() end)
    frame.header:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)
    Blackacre.UI.Theme.ApplySkeletonPanel(frame.header, 0.94)
    frame.header:SetBackdropColor(0.18, 0.14, 0.10, 0.98)
    frame.header:SetBackdropBorderColor(0.70, 0.55, 0.25, 1)

    frame.title = Blackacre.UI.Theme.CreateLayeredFontString(frame.header, Layer.OVERLAY, "GameFontNormalHuge")
    frame.title:SetPoint("LEFT", 14, 0)
    frame.title:SetText(titleText or "Traveler's Chronicle")
    Blackacre.UI.Theme.GoldTitle(frame.title)

    -- Explicit large "X" close (UIPanelCloseButton + labeled backup)
    local close = CreateFrame("Button", nil, frame.header, "UIPanelCloseButton")
    close:SetPoint("RIGHT", -4, 0)
    close:SetSize(32, 32)
    frame.closeButton = close
    local closeX = CreateFrame("Button", nil, frame.header, "UIPanelButtonTemplate")
    closeX:SetSize(28, 24)
    closeX:SetPoint("RIGHT", close, "LEFT", -2, 0)
    closeX:SetText("X")
    closeX:SetScript("OnClick", function() frame:Hide() end)
    frame.closeButtonX = closeX

    -- FOOTER (journal tool)
    frame.footer = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.footer:SetPoint("BOTTOMLEFT", PAD, PAD)
    frame.footer:SetPoint("BOTTOMRIGHT", -PAD, PAD)
    frame.footer:SetHeight(FOOTER_H)
    Blackacre.UI.Theme.ApplySkeletonPanel(frame.footer, 0.94)
    frame.footer:SetBackdropColor(0.16, 0.13, 0.10, 0.95)

    frame.footerHint = Blackacre.UI.Theme.CreateLayeredFontString(frame.footer, Layer.OVERLAY, "GameFontHighlight")
    frame.footerHint:SetPoint("LEFT", 12, 0)
    frame.footerHint:SetText("Ink & edits — journaling")
    Blackacre.UI.Theme.InkFont(frame.footerHint)

    frame.journalToggle = CreateFrame("Button", nil, frame.footer, "UIPanelButtonTemplate")
    frame.journalToggle:SetSize(130, 26)
    frame.journalToggle:SetPoint("RIGHT", -10, 0)
    frame.journalToggle:SetText("Journal: Off")
    frame.journalToggle._baOn = false
    frame.journalToggle:SetScript("OnClick", function(self)
        self._baOn = not self._baOn
        self:SetText(self._baOn and "Journal: On" or "Journal: Off")
        if Blackacre.TomeHub and Blackacre.TomeHub.OnJournalToggle then
            Blackacre.TomeHub.OnJournalToggle(self._baOn)
        end
    end)

    -- HORIZONTAL TAB BAR (Adventure Guide dungeon: boss/loot/spells style)
    frame.tabBar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.tabBar:SetPoint("TOPLEFT", frame.header, "BOTTOMLEFT", 0, -GAP)
    frame.tabBar:SetPoint("TOPRIGHT", frame.header, "BOTTOMRIGHT", 0, -GAP)
    frame.tabBar:SetHeight(TAB_H)
    Blackacre.UI.Theme.ApplySkeletonPanel(frame.tabBar, 0.9)
    frame.tabBar:SetBackdropColor(0.14, 0.12, 0.10, 0.95)
    -- Legacy alias so older code looking for tabRail still finds a parent
    frame.tabRail = frame.tabBar

    -- OPEN BOOK host (fills remaining space between tabs and footer)
    frame.bookOpen = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.bookOpen:SetPoint("TOPLEFT", frame.tabBar, "BOTTOMLEFT", 0, -GAP)
    frame.bookOpen:SetPoint("BOTTOMRIGHT", frame.footer, "TOPRIGHT", 0, GAP)
    Blackacre.UI.Theme.ApplySkeletonPanel(frame.bookOpen, 0.9)
    frame.bookOpen:SetBackdropColor(0.10, 0.08, 0.06, 0.5)

    -- Chronicle bookmark (left edge of book — TOC flip target)
    frame.chronicleBookmark = CreateFrame("Button", nil, frame.bookOpen, "BackdropTemplate")
    frame.chronicleBookmark:SetWidth(BOOKMARK_W)
    frame.chronicleBookmark:SetPoint("TOPLEFT", 2, -8)
    frame.chronicleBookmark:SetPoint("BOTTOMLEFT", 2, 8)
    frame.chronicleBookmark:SetBackdrop({
        bgFile = Blackacre.UI.Theme.Textures.white,
        edgeFile = Blackacre.UI.Theme.Textures.tooltipEdge,
        tile = true, tileSize = 8, edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    frame.chronicleBookmark:SetBackdropColor(0.35, 0.22, 0.12, 0.95)
    frame.chronicleBookmark:SetBackdropBorderColor(0.85, 0.70, 0.30, 1)
    local bmLabel = frame.chronicleBookmark:CreateFontString(nil, Layer.OVERLAY, "GameFontNormal")
    bmLabel:SetPoint("CENTER", 0, 0)
    bmLabel:SetWidth(14)
    bmLabel:SetWordWrap(true)
    bmLabel:SetText("C\nh\nr\no\nn\ni\nc\nl\ne")
    bmLabel:SetTextColor(1, 1, 1, 1)
    frame.chronicleBookmark.label = bmLabel
    frame.chronicleBookmark:SetScript("OnClick", function()
        if Blackacre.TomeHub and Blackacre.TomeHub.Show then
            Blackacre.TomeHub.Show("chronicle")
        end
    end)
    frame.chronicleBookmark:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Chronology — table of contents")
        GameTooltip:Show()
    end)
    frame.chronicleBookmark:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- LEFT PAGE (TOC / left spread)
    frame.leftPage = CreateFrame("Frame", nil, frame.bookOpen, "BackdropTemplate")
    frame.leftPage:SetPoint("TOPLEFT", frame.chronicleBookmark, "TOPRIGHT", 4, 0)
    frame.leftPage:SetPoint("BOTTOMLEFT", frame.chronicleBookmark, "BOTTOMRIGHT", 4, 28)
    frame.leftPage:SetPoint("RIGHT", frame.bookOpen, "CENTER", -6, 0)
    Blackacre.UI.Theme.ApplyOpenBookPage(frame.leftPage)
    if frame.leftPage.SetClipsChildren then frame.leftPage:SetClipsChildren(true) end

    -- RIGHT PAGE (main reading / module host)
    frame.rightPage = CreateFrame("Frame", nil, frame.bookOpen, "BackdropTemplate")
    frame.rightPage:SetPoint("TOPLEFT", frame.bookOpen, "TOP", 6, -8)
    frame.rightPage:SetPoint("BOTTOMRIGHT", frame.bookOpen, "BOTTOMRIGHT", -8, 28)
    Blackacre.UI.Theme.ApplyOpenBookPage(frame.rightPage)
    if frame.rightPage.SetClipsChildren then frame.rightPage:SetClipsChildren(true) end

    -- pageHost = full book content area for non-chronicle modules (both pages under one host)
    frame.pageHost = CreateFrame("Frame", nil, frame.bookOpen)
    frame.pageHost:SetPoint("TOPLEFT", frame.chronicleBookmark, "TOPRIGHT", 4, 0)
    frame.pageHost:SetPoint("BOTTOMRIGHT", frame.bookOpen, "BOTTOMRIGHT", -8, 28)
    if frame.pageHost.SetClipsChildren then frame.pageHost:SetClipsChildren(true) end
    -- When showing two-page chronicle, hide pageHost; when showing other tabs, show pageHost over pages
    frame.pageHost:Hide()

    -- Page-turn arrows (bottom corners of each page)
    frame.prevPageBtn = CreateFrame("Button", nil, frame.bookOpen, "UIPanelButtonTemplate")
    frame.prevPageBtn:SetSize(36, 24)
    frame.prevPageBtn:SetPoint("BOTTOMLEFT", frame.leftPage, "BOTTOMLEFT", 8, -26)
    frame.prevPageBtn:SetText("<")
    frame.prevPageBtn:SetScript("OnClick", function()
        if Blackacre.TomeHub and Blackacre.TomeHub.TurnPage then
            Blackacre.TomeHub.TurnPage(-1)
        end
    end)

    frame.nextPageBtn = CreateFrame("Button", nil, frame.bookOpen, "UIPanelButtonTemplate")
    frame.nextPageBtn:SetSize(36, 24)
    frame.nextPageBtn:SetPoint("BOTTOMRIGHT", frame.rightPage, "BOTTOMRIGHT", -8, -26)
    frame.nextPageBtn:SetText(">")
    frame.nextPageBtn:SetScript("OnClick", function()
        if Blackacre.TomeHub and Blackacre.TomeHub.TurnPage then
            Blackacre.TomeHub.TurnPage(1)
        end
    end)

    return frame
end

--- Parent a feature frame into a book page (no second window).
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

--- Open-book page parchment (Adventure Guide / Spellbook language).
function Blackacre.UI.Theme.ApplyOpenBookPage(frame)
    if not frame then return end
    local Layer = Blackacre.UI.Theme.Layer
    if not frame._baBookPageTex then
        local tex = frame:CreateTexture(nil, Layer.BACKGROUND, nil, -8)
        tex:SetAllPoints()
        -- Prefer spellbook open page; fall back to achievement parchment
        tex:SetTexture(Blackacre.UI.Theme.Textures.spellbookPage)
        if not tex:GetTexture() then
            tex:SetTexture(Blackacre.UI.Theme.Textures.parchment)
        end
        tex:SetVertexColor(0.95, 0.92, 0.85, 1)
        frame._baBookPageTex = tex
    end
    if frame.SetBackdrop then
        frame:SetBackdrop(nil)
    end
end

local toastFrame
local toastTimer

function Blackacre.UI.Theme.Toast(message)
    if not toastFrame then
        toastFrame = CreateFrame("Frame", "BlackacreToast", UIParent, "BackdropTemplate")
        toastFrame:SetSize(360, 48)
        toastFrame:SetPoint("TOP", UIParent, "TOP", 0, -120)
        toastFrame:SetFrameStrata("DIALOG")
        Blackacre.UI.Theme.ApplyFilledPanel(toastFrame, 0.97, "panel")
        toastFrame.text = toastFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        toastFrame.text:SetPoint("LEFT", 16, 0)
        toastFrame.text:SetPoint("RIGHT", -16, 0)
        toastFrame.text:SetJustifyH("CENTER")
        Blackacre.UI.Theme.InkFont(toastFrame.text)
        toastFrame:Hide()
    end
    toastFrame.text:SetText(message or "")
    toastFrame:Show()
    if toastTimer then toastTimer:Cancel() end
    toastTimer = C_Timer.NewTimer(4, function() toastFrame:Hide() end)
end
