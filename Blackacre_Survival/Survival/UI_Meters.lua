Blackacre = Blackacre or {}
Blackacre.Survival = Blackacre.Survival or {}
Blackacre.Survival.UI = {}

local panel
local bars = {}

local BAR_W = 140
local BAR_H = 12

local function ColorFor(value)
    if value <= 15 then
        return 0.75, 0.15, 0.12
    elseif value <= 40 then
        return 0.85, 0.55, 0.15
    end
    return 0.35, 0.55, 0.28
end

local function MakeBar(parent, label, y)
    local row = CreateFrame("Frame", nil, parent)
    row:SetSize(BAR_W + 70, 28)
    row:SetPoint("TOPLEFT", 12, y)

    row.name = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    row.name:SetPoint("LEFT", 0, 0)
    row.name:SetWidth(62)
    row.name:SetJustifyH("LEFT")
    row.name:SetText(label)
    Blackacre.UI.Theme.InkFont(row.name)

    row.bg = row:CreateTexture(nil, "BACKGROUND")
    row.bg:SetPoint("LEFT", 64, 0)
    row.bg:SetSize(BAR_W, BAR_H)
    row.bg:SetColorTexture(0.2, 0.15, 0.1, 0.55)

    row.fill = row:CreateTexture(nil, "ARTWORK")
    row.fill:SetPoint("LEFT", row.bg, "LEFT", 0, 0)
    row.fill:SetSize(BAR_W, BAR_H)
    row.fill:SetColorTexture(0.35, 0.55, 0.28, 0.95)

    row.border = CreateFrame("Frame", nil, row, "BackdropTemplate")
    row.border:SetPoint("TOPLEFT", row.bg, "TOPLEFT", -2, 2)
    row.border:SetPoint("BOTTOMRIGHT", row.bg, "BOTTOMRIGHT", 2, -2)
    row.border:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    row.border:SetBackdropBorderColor(0.45, 0.35, 0.2, 0.9)

    row.value = row:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    row.value:SetPoint("LEFT", row.bg, "RIGHT", 6, 0)

    function row:SetValue(v)
        v = math.max(0, math.min(100, v or 0))
        local w = math.max(1, (BAR_W * v) / 100)
        self.fill:SetWidth(w)
        local r, g, b = ColorFor(v)
        self.fill:SetColorTexture(r, g, b, 0.95)
        self.value:SetText(string.format("%d", math.floor(v + 0.5)))
    end

    return row
end

local function Build()
    panel = CreateFrame("Frame", "BlackacreSurvivalMeters", UIParent, "BackdropTemplate")
    panel:SetSize(250, 168)
    -- Near objective tracker region (top-right)
    panel:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -40, -180)
    panel:SetFrameStrata("MEDIUM")
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
    panel:SetClampedToScreen(true)
    Blackacre.UI.Theme.ApplyParchmentBackdrop(panel, 0.94)

    panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    panel.title:SetPoint("TOPLEFT", 12, -10)
    panel.title:SetText("Condition")
    Blackacre.UI.Theme.GoldTitle(panel.title)

    panel.climate = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    panel.climate:SetPoint("TOPRIGHT", -12, -12)
    panel.climate:SetText("")

    bars.hunger = MakeBar(panel, "Hunger", -36)
    bars.thirst = MakeBar(panel, "Thirst", -64)
    bars.exposure = MakeBar(panel, "Exposure", -92)

    local function ActionBtn(text, x, onClick)
        local b = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
        b:SetSize(70, 20)
        b:SetPoint("BOTTOMLEFT", x, 10)
        b:SetText(text)
        b:SetScript("OnClick", onClick)
        return b
    end

    ActionBtn("Eat", 10, function()
        Blackacre.Survival.Engine.Recover("eat", 22)
    end)
    ActionBtn("Drink", 84, function()
        Blackacre.Survival.Engine.Recover("drink", 22)
    end)
    ActionBtn("Rest", 158, function()
        if UnitAffectingCombat and UnitAffectingCombat("player") then
            Blackacre.UI.Theme.Toast("You cannot truly rest in combat.")
            return
        end
        Blackacre.Survival.Engine.Recover("rest", 18)
    end)

    panel:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("Blackacre — Survival")
        GameTooltip:AddLine("Honor-system meters. Eat / Drink / Rest are IC actions.", 1, 1, 1, true)
        GameTooltip:AddLine("Well Fed / resting in an inn slows decay.", 0.8, 0.8, 0.8, true)
        GameTooltip:AddLine("/ic survival  ·  drag to move", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    panel:SetScript("OnLeave", GameTooltip_Hide)
end

function Blackacre.Survival.UI.Init()
    Build()
    Blackacre.Survival.UI.Refresh()
end

function Blackacre.Survival.UI.Refresh()
    if not panel then return end
    local state = Blackacre.Survival.GetState()
    if not state.enabled or state.hideMeters then
        panel:Hide()
        return
    end
    panel:Show()
    bars.hunger:SetValue(state.hunger)
    bars.thirst:SetValue(state.thirst)
    bars.exposure:SetValue(state.exposure)
    local c = state.climate
    local flag = state.indoors and "indoors" or "outdoors"
    if state.resting then flag = flag .. ", resting" end
    panel.climate:SetText(string.format("%s (%s)", c.label or "temperate", flag))
end

function Blackacre.Survival.UI.Toggle()
    if not panel then Build() end
    local s = Blackacre.CharDB.survival
    if panel:IsShown() then
        s.hideMeters = true
        panel:Hide()
    else
        s.hideMeters = false
        Blackacre.Survival.UI.Refresh()
        panel:Show()
    end
end

function Blackacre.Survival.UI.ShowPanel()
    if not panel then Build() end
    Blackacre.CharDB.survival.hideMeters = false
    Blackacre.Survival.UI.Refresh()
    panel:Show()
end