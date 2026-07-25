InCharacter = InCharacter or {}
InCharacter.UI = InCharacter.UI or {}
InCharacter.UI.Theme = {}

-- Shared native-feeling colors and textures (parchment / quest log language).
InCharacter.UI.Theme.Colors = {
    ink = { 0.15, 0.10, 0.05 },
    inkSoft = { 0.25, 0.18, 0.10 },
    gold = { 0.85, 0.70, 0.25 },
    parchment = { 0.92, 0.86, 0.72 },
    edge = { 0.55, 0.42, 0.22 },
}

InCharacter.UI.Theme.Textures = {
    parchment = "Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal",
    parchmentVert = "Interface\\AchievementFrame\\UI-Achievement-Parchment",
    questBG = "Interface\\QuestFrame\\QuestBG",
    dialogEdge = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tooltipEdge = "Interface\\Tooltips\\UI-Tooltip-Border",
    bookIcon = "Interface\\Spellbook\\Spellbook-Icon",
    scrollUp = "Interface\\Buttons\\UI-ScrollBar-ScrollUpButton-Up",
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

function InCharacter.UI.Theme.InkFont(fontString, size)
    if not fontString then return end
    local c = InCharacter.UI.Theme.Colors.ink
    fontString:SetTextColor(c[1], c[2], c[3])
    if size == "title" then
        fontString:SetFontObject(GameFontNormalLarge)
    elseif size == "header" then
        fontString:SetFontObject(GameFontNormal)
    else
        fontString:SetFontObject(GameFontHighlight)
    end
    -- Re-apply ink after font object (font objects set their own color)
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