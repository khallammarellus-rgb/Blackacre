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

--- Outer Tome window — Pass A skeleton (Achievement-frame scale).
--- Returns frame with: .header, .tabRail, .pageHost, .footer, .title, .subtitle, .closeButton
--- Parent/child tree + layers only; no final Achievement parchment art yet.
function Blackacre.UI.Theme.CreateBookShell(name, titleText)
    local Layer = Blackacre.UI.Theme.Layer

    -- Achievement-frame-ish landscape footprint (large readable journal)
    local WIDTH, HEIGHT = 900, 620
    local HEADER_H = 58
    local FOOTER_H = 42
    local TAB_W = 100
    local PAD = 12
    local GAP = 8

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

    -- Root: plain box (Pass A). Pass B will call ApplyBookBackdrop / Achievement textures.
    frame._baShellPass = "A" -- "A" skeleton | "B" art
    Blackacre.UI.Theme.ApplySkeletonPanel(frame, 0.96)
    SkeletonRegionLabel(frame, "TOME ROOT")

    -- HEADER (child canvas)
    frame.header = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.header:SetPoint("TOPLEFT", PAD, -PAD)
    frame.header:SetPoint("TOPRIGHT", -PAD, -PAD)
    frame.header:SetHeight(HEADER_H)
    Blackacre.UI.Theme.ApplySkeletonPanel(frame.header, 0.92)
    frame.header:SetBackdropColor(0.22, 0.22, 0.26, 0.95)
    SkeletonRegionLabel(frame.header, "HEADER")

    frame.title = Blackacre.UI.Theme.CreateLayeredFontString(frame.header, Layer.OVERLAY, "GameFontNormalLarge")
    frame.title:SetPoint("TOPLEFT", 12, -10)
    frame.title:SetText(titleText or "Traveler’s Tome")
    frame.title:SetTextColor(0.95, 0.90, 0.70) -- readable gold-ish, not final Theme gold pass

    frame.subtitle = Blackacre.UI.Theme.CreateLayeredFontString(frame.header, Layer.OVERLAY, "GameFontHighlightSmall")
    frame.subtitle:SetPoint("TOPLEFT", frame.title, "BOTTOMLEFT", 0, -4)
    frame.subtitle:SetPoint("RIGHT", frame.header, "RIGHT", -40, 0)
    frame.subtitle:SetJustifyH("LEFT")
    frame.subtitle:SetText("Skeleton Pass A — layout only (Achievement-frame scale)")
    frame.subtitle:SetTextColor(0.75, 0.75, 0.78)

    local close = CreateFrame("Button", nil, frame.header, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", 2, 2)
    frame.closeButton = close

    -- FOOTER (parchment tool / journaling strip — skeleton placeholder)
    frame.footer = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.footer:SetPoint("BOTTOMLEFT", PAD, PAD)
    frame.footer:SetPoint("BOTTOMRIGHT", -PAD, PAD)
    frame.footer:SetHeight(FOOTER_H)
    Blackacre.UI.Theme.ApplySkeletonPanel(frame.footer, 0.92)
    frame.footer:SetBackdropColor(0.20, 0.22, 0.24, 0.95)
    SkeletonRegionLabel(frame.footer, "FOOTER / JOURNAL TOOL")

    frame.footerHint = Blackacre.UI.Theme.CreateLayeredFontString(frame.footer, Layer.OVERLAY, "GameFontHighlightSmall")
    frame.footerHint:SetPoint("LEFT", 12, 0)
    frame.footerHint:SetText("Journaling tool (placeholder) — edit mode later")
    frame.footerHint:SetTextColor(0.7, 0.7, 0.72)

    frame.journalToggle = CreateFrame("Button", nil, frame.footer, "UIPanelButtonTemplate")
    frame.journalToggle:SetSize(120, 24)
    frame.journalToggle:SetPoint("RIGHT", -12, 0)
    frame.journalToggle:SetText("Journal: Off")
    frame.journalToggle._baOn = false
    frame.journalToggle:SetScript("OnClick", function(self)
        self._baOn = not self._baOn
        self:SetText(self._baOn and "Journal: On" or "Journal: Off")
        if Blackacre.TomeHub and Blackacre.TomeHub.OnJournalToggle then
            Blackacre.TomeHub.OnJournalToggle(self._baOn)
        end
    end)

    -- TAB RAIL (left)
    frame.tabRail = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.tabRail:SetPoint("TOPLEFT", frame.header, "BOTTOMLEFT", 0, -GAP)
    frame.tabRail:SetPoint("BOTTOMLEFT", frame.footer, "TOPLEFT", 0, GAP)
    frame.tabRail:SetWidth(TAB_W)
    Blackacre.UI.Theme.ApplySkeletonPanel(frame.tabRail, 0.92)
    frame.tabRail:SetBackdropColor(0.16, 0.17, 0.20, 0.95)
    SkeletonRegionLabel(frame.tabRail, "TABS")
    if frame.tabRail.SetClipsChildren then
        frame.tabRail:SetClipsChildren(true)
    end

    -- PAGE HOST (main content — modules mount here)
    frame.pageHost = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.pageHost:SetPoint("TOPLEFT", frame.tabRail, "TOPRIGHT", GAP, 0)
    frame.pageHost:SetPoint("BOTTOMRIGHT", frame.footer, "TOPRIGHT", 0, GAP)
    Blackacre.UI.Theme.ApplySkeletonPanel(frame.pageHost, 0.92)
    frame.pageHost:SetBackdropColor(0.14, 0.14, 0.16, 0.97)
    SkeletonRegionLabel(frame.pageHost, "PAGE HOST")
    if frame.pageHost.SetClipsChildren then
        frame.pageHost:SetClipsChildren(true)
    end

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
        fontString:SetFontObject(GameFontNormalLarge)
    elseif size == "header" then
        fontString:SetFontObject(GameFontNormal)
    else
        fontString:SetFontObject(GameFontHighlight)
    end
    fontString:SetTextColor(c[1], c[2], c[3])
end

function Blackacre.UI.Theme.GoldTitle(fontString)
    if not fontString then return end
    fontString:SetFontObject(GameFontNormalLarge)
    local g = Blackacre.UI.Theme.Colors.gold
    fontString:SetTextColor(g[1], g[2], g[3])
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
