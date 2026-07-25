InCharacter = InCharacter or {}
InCharacter.UI = InCharacter.UI or {}
InCharacter.UI.Theme = {}

-- Shared native-feeling colors and textures (parchment / quest-log / tome language).
InCharacter.UI.Theme.Colors = {
    ink = { 0.15, 0.10, 0.05 },
    inkSoft = { 0.25, 0.18, 0.10 },
    gold = { 0.85, 0.70, 0.25 },
    parchment = { 0.92, 0.86, 0.72 },
    page = { 0.97, 0.93, 0.82 },
    edge = { 0.55, 0.42, 0.22 },
    spine = { 0.28, 0.18, 0.10 },
    tabIdle = { 0.45, 0.32, 0.14 },
    tabActive = { 0.72, 0.55, 0.22 },
}

-- Wax seals for bulletin scope tiers
InCharacter.UI.Theme.Seals = {
    INDIVIDUAL = { label = "Personal", color = { 0.55, 0.45, 0.30 }, short = "P" },
    GROUP = { label = "Company", color = { 0.35, 0.50, 0.65 }, short = "C" },
    GUILD = { label = "Guild", color = { 0.55, 0.35, 0.65 }, short = "G" },
    FACTION = { label = "Realm", color = { 0.70, 0.30, 0.25 }, short = "R" },
}

InCharacter.UI.Theme.Textures = {
    parchment = "Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal",
    parchmentVert = "Interface\\AchievementFrame\\UI-Achievement-Parchment",
    questBG = "Interface\\QuestFrame\\QuestBG",
    itemText = "Interface\\ItemTextFrame\\ItemText-Bronze-TopLeft",
    dialogEdge = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tooltipEdge = "Interface\\Tooltips\\UI-Tooltip-Border",
    bookIcon = "Interface\\Spellbook\\Spellbook-Icon",
    questBook = "Interface\\QuestFrame\\UI-QuestLog-BookIcon",
    scrollUp = "Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Up",
    -- Quest log nine-slice corners (client paths)
    qTopLeft = "Interface\\QuestFrame\\UI-QuestLogTitleHighlight",
    stone = "Interface\\FrameGeneral\\UI-Background-Rock",
}

function InCharacter.UI.Theme.ApplyParchmentBackdrop(frame, alpha)
    alpha = alpha or 0.95
    frame:SetBackdrop({
        bgFile = InCharacter.UI.Theme.Textures.parchment,
        edgeFile = InCharacter.UI.Theme.Textures.tooltipEdge,
        tile = false,
        tileSize = 0,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(
        InCharacter.UI.Theme.Colors.parchment[1],
        InCharacter.UI.Theme.Colors.parchment[2],
        InCharacter.UI.Theme.Colors.parchment[3],
        alpha
    )
    frame:SetBackdropBorderColor(
        InCharacter.UI.Theme.Colors.edge[1],
        InCharacter.UI.Theme.Colors.edge[2],
        InCharacter.UI.Theme.Colors.edge[3],
        1
    )
end

--- Full traveler’s tome chrome: deep spine + parchment face + gold edge.
function InCharacter.UI.Theme.ApplyBookBackdrop(frame, alpha)
    alpha = alpha or 0.98
    frame:SetBackdrop({
        bgFile = InCharacter.UI.Theme.Textures.questBG,
        edgeFile = InCharacter.UI.Theme.Textures.dialogEdge,
        tile = false,
        tileSize = 0,
        edgeSize = 24,
        insets = { left = 8, right = 8, top = 8, bottom = 8 },
    })
    frame:SetBackdropColor(
        InCharacter.UI.Theme.Colors.parchment[1],
        InCharacter.UI.Theme.Colors.parchment[2],
        InCharacter.UI.Theme.Colors.parchment[3],
        alpha
    )
    frame:SetBackdropBorderColor(
        InCharacter.UI.Theme.Colors.gold[1] * 0.7,
        InCharacter.UI.Theme.Colors.gold[2] * 0.7,
        InCharacter.UI.Theme.Colors.gold[3] * 0.5,
        1
    )

    if not frame._icSpine then
        local spine = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
        spine:SetPoint("TOPLEFT", 4, -4)
        spine:SetPoint("BOTTOMLEFT", 4, 4)
        spine:SetWidth(18)
        local s = InCharacter.UI.Theme.Colors.spine
        spine:SetColorTexture(s[1], s[2], s[3], 0.92)
        frame._icSpine = spine

        local ribbon = frame:CreateTexture(nil, "ARTWORK")
        ribbon:SetPoint("TOP", frame, "TOP", 40, 2)
        ribbon:SetSize(28, 36)
        ribbon:SetColorTexture(0.55, 0.12, 0.12, 0.85)
        frame._icRibbon = ribbon
    end
end

function InCharacter.UI.Theme.ApplyPagePanel(frame, alpha)
    alpha = alpha or 0.72
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = InCharacter.UI.Theme.Textures.tooltipEdge,
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    local p = InCharacter.UI.Theme.Colors.page
    frame:SetBackdropColor(p[1], p[2], p[3], alpha)
    frame:SetBackdropBorderColor(0.45, 0.35, 0.2, 0.9)
end

function InCharacter.UI.Theme.SealLabel(scopeTier)
    local seal = InCharacter.UI.Theme.Seals[scopeTier or "INDIVIDUAL"]
        or InCharacter.UI.Theme.Seals.INDIVIDUAL
    return seal.label, seal.short, seal.color
end

function InCharacter.UI.Theme.FormatSealPrefix(scopeTier)
    local _, short, color = InCharacter.UI.Theme.SealLabel(scopeTier)
    return string.format("|cff%02x%02x%02x[%s]|r ",
        math.floor((color[1] or 0.5) * 255),
        math.floor((color[2] or 0.5) * 255),
        math.floor((color[3] or 0.5) * 255),
        short)
end

function InCharacter.UI.Theme.InkFont(fontString, size)
    if not fontString then return end
    local c = InCharacter.UI.Theme.Colors.ink
    if size == "title" then
        fontString:SetFontObject(GameFontNormalLarge)
    elseif size == "header" then
        fontString:SetFontObject(GameFontNormal)
    else
        fontString:SetFontObject(GameFontHighlight)
    end
    fontString:SetTextColor(c[1], c[2], c[3])
end

function InCharacter.UI.Theme.GoldTitle(fontString)
    if not fontString then return end
    fontString:SetFontObject(GameFontNormalLarge)
    local g = InCharacter.UI.Theme.Colors.gold
    fontString:SetTextColor(g[1], g[2], g[3])
end

local toastFrame
local toastTimer

function InCharacter.UI.Theme.Toast(message)
    if not toastFrame then
        toastFrame = CreateFrame("Frame", "InCharacterToast", UIParent, "BackdropTemplate")
        toastFrame:SetSize(360, 48)
        toastFrame:SetPoint("TOP", UIParent, "TOP", 0, -120)
        toastFrame:SetFrameStrata("DIALOG")
        InCharacter.UI.Theme.ApplyParchmentBackdrop(toastFrame, 0.97)
        toastFrame.text = toastFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        toastFrame.text:SetPoint("LEFT", 16, 0)
        toastFrame.text:SetPoint("RIGHT", -16, 0)
        toastFrame.text:SetJustifyH("CENTER")
        InCharacter.UI.Theme.InkFont(toastFrame.text)
        toastFrame:Hide()
    end
    toastFrame.text:SetText(message or "")
    toastFrame:Show()
    if toastTimer then
        toastTimer:Cancel()
    end
    toastTimer = C_Timer.NewTimer(4, function()
        toastFrame:Hide()
    end)
end
