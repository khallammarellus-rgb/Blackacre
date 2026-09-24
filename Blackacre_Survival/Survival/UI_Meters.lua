Blackacre = Blackacre or {}
Blackacre.Survival = Blackacre.Survival or {}
Blackacre.Survival.UI = {}

local panel
local icons = {}
local collapsed = false

local ICON_SIZE = 36
local ARROW_SIZE = 22

local ICONS = {
    hunger = {
        high = { "inv_tradeskill_cooking_feastofblood", "INV_Misc_Food_15" },
        mid = { "inv_misc_food_95_grainbread", "INV_Misc_Food_95_Grainbread", "INV_Misc_Food_15" },
        low = { "spell_holy_painsupression", "Spell_Holy_PainSupression", "Spell_Holy_PainSuppression", "Spell_Shadow_ShadowWordPain" },
    },
    thirst = {
        high = { "inv_drink_waterskin_01", "INV_Drink_Waterskin_01" },
        mid = { "inv_drink_waterskin_05", "INV_Drink_Waterskin_05", "INV_Drink_Waterskin_01" },
        low = { "inv_drink_waterskin_10", "INV_Drink_Waterskin_10", "INV_Drink_Waterskin_01" },
    },
    exposure = {
        high = { "ui_embercourt-emoji-happy", "Spell_Nature_DryadDispelMagic" },
        mid = { "ui_embercourt-emoji-miserable", "Spell_Frost_FrostShock" },
        low = { "ui_embercourt-emoji-uncomfortable", "Spell_Frost_IceStorm" },
    },
}

local ARROW_ATLASES = {
    "bag-arrow",
    "Bag-arrow",
    "bags-arrow",
    "BagSlots2x-bag-arrow",
    "bagslots2x-bag-arrow",
}

local function HasAtlas(name)
    return name and C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(name)
end

local function ApplyNamedIcon(tex, names)
    if not tex or not names then return end
    if type(names) == "string" then names = { names } end
    for i = 1, #names do
        local n = names[i]
        if HasAtlas(n) then
            tex:SetAtlas(n, false)
            return
        end
    end
    tex:SetTexture("Interface\\Icons\\" .. names[1])
    tex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
end

local function BandFor(v)
    v = math.floor((v or 0) + 0.5)
    if v <= 10 then return "low" end
    if v <= 50 then return "mid" end
    return "high"
end

local function DebuffBorder(tex)
    if not tex then return end
    tex:SetTexture("Interface\\Buttons\\UI-Debuff-Border")
    tex:Show()
end

local function FaceArrow(expanded)
    if not panel or not panel.arrowTex then return end
    local tex = panel.arrowTex
    -- Native bag-arrow faces left. Flip when expanded so it points right.
    if expanded then
        tex:SetTexCoord(1, 0, 0, 1)
    else
        tex:SetTexCoord(0, 1, 0, 1)
    end
end

local function PaintArrow()
    if not panel or not panel.arrowTex then return end
    local tex = panel.arrowTex
    for i = 1, #ARROW_ATLASES do
        if HasAtlas(ARROW_ATLASES[i]) then
            tex:SetAtlas(ARROW_ATLASES[i], false)
            FaceArrow(not collapsed)
            return
        end
    end
    if not HasAtlas("bag-arrow") then
        tex:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
        tex:SetTexCoord(0, 1, 0, 1)
        -- NextPage points right; flip when collapsed so it points left.
        if collapsed then
            tex:SetTexCoord(1, 0, 0, 1)
        end
        return
    end
    FaceArrow(not collapsed)
end

local function Layout()
    if not panel then return end
    local gap = 4
    if collapsed then
        for _, b in pairs(icons) do b:Hide() end
        panel:SetSize(ARROW_SIZE + 4, ICON_SIZE)
        panel.arrow:ClearAllPoints()
        panel.arrow:SetPoint("CENTER", panel, "CENTER", 0, 0)
    else
        local prep = icons.prepared and icons.prepared:IsShown()
        local count = prep and 4 or 3
        local rowW = count * ICON_SIZE + (count - 1) * gap
        panel:SetSize(rowW + gap + ARROW_SIZE, ICON_SIZE)
        icons.hunger:Show()
        icons.thirst:Show()
        icons.exposure:Show()
        icons.hunger:ClearAllPoints()
        icons.thirst:ClearAllPoints()
        icons.exposure:ClearAllPoints()
        icons.hunger:SetPoint("LEFT", panel, "LEFT", 0, 0)
        icons.thirst:SetPoint("LEFT", icons.hunger, "RIGHT", gap, 0)
        icons.exposure:SetPoint("LEFT", icons.thirst, "RIGHT", gap, 0)
        local anchor = icons.exposure
        if prep then
            icons.prepared:ClearAllPoints()
            icons.prepared:SetPoint("LEFT", icons.exposure, "RIGHT", gap, 0)
            anchor = icons.prepared
        end
        panel.arrow:ClearAllPoints()
        panel.arrow:SetPoint("LEFT", anchor, "RIGHT", gap, 0)
    end
    PaintArrow()
end

local function MakeAura(parent, key, label)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(ICON_SIZE, ICON_SIZE)
    btn.key = key
    btn.label = label

    btn.icon = btn:CreateTexture(nil, "ARTWORK")
    btn.icon:SetPoint("TOPLEFT", 2, -2)
    btn.icon:SetPoint("BOTTOMRIGHT", -2, 2)
    ApplyNamedIcon(btn.icon, ICONS[key].high)

    btn.border = btn:CreateTexture(nil, "OVERLAY")
    btn.border:SetAllPoints(btn)
    btn.border:Hide()

    btn.count = btn:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
    btn.count:SetPoint("BOTTOMRIGHT", 1, 0)

    function btn:SetMeter(v)
        v = math.max(0, math.min(100, v or 0))
        local stacks = math.floor(v + 0.5)
        if self._stacks == stacks then return end
        local band = BandFor(stacks)
        local bandChanged = self._band ~= band
        self._stacks = stacks
        self._band = band
        self.count:SetText(tostring(stacks))
        if bandChanged then
            ApplyNamedIcon(self.icon, ICONS[self.key][band])
            self.icon:SetVertexColor(1, 1, 1)
        end
        if stacks <= 10 then
            if not self._debuff then
                DebuffBorder(self.border)
                self._debuff = true
            end
        elseif self._debuff then
            self.border:Hide()
            self._debuff = false
        end
    end

    btn:RegisterForDrag("LeftButton")
    btn:SetScript("OnDragStart", function()
        if panel then panel:StartMoving() end
    end)
    btn:SetScript("OnDragStop", function()
        if panel then panel:StopMovingOrSizing() end
    end)
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:SetText(label)
        local state = Blackacre.Survival.GetState and Blackacre.Survival.GetState()
        if state then
            local n = math.floor((state[key] or 0) + 0.5)
            GameTooltip:AddLine(n .. " stacks", 0.9, 0.9, 0.9)
            if state.climate and state.climate.title then
                GameTooltip:AddLine(state.climate.title .. " climate", 0.85, 0.75, 0.45)
            end
        end
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", GameTooltip_Hide)
    return btn
end

local function Build()
    panel = CreateFrame("Frame", "BlackacreSurvivalMeters", UIParent)
    panel:SetSize(3 * ICON_SIZE + 2 * 4 + 4 + ARROW_SIZE, ICON_SIZE)
    panel:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -40, -180)
    panel:SetFrameStrata("MEDIUM")
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop", panel.StopMovingOrSizing)
    panel:SetClampedToScreen(true)

    panel.arrow = CreateFrame("Button", nil, panel)
    panel.arrow:SetSize(ARROW_SIZE, ARROW_SIZE)
    panel.arrowTex = panel.arrow:CreateTexture(nil, "ARTWORK")
    panel.arrowTex:SetAllPoints()
    panel.arrow:RegisterForDrag("LeftButton")
    panel.arrow:SetScript("OnDragStart", function()
        panel:StartMoving()
    end)
    panel.arrow:SetScript("OnDragStop", function()
        panel:StopMovingOrSizing()
    end)
    panel.arrow:SetScript("OnClick", function()
        collapsed = not collapsed
        Layout()
    end)
    panel.arrow:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:SetText(collapsed and "Expand" or "Collapse")
        GameTooltip:Show()
    end)
    panel.arrow:SetScript("OnLeave", GameTooltip_Hide)

    icons.hunger = MakeAura(panel, "hunger", "Hunger")
    icons.thirst = MakeAura(panel, "thirst", "Thirst")
    icons.exposure = MakeAura(panel, "exposure", "Exposure")

    local prep = CreateFrame("Button", nil, panel)
    prep:SetSize(ICON_SIZE, ICON_SIZE)
    prep.icon = prep:CreateTexture(nil, "ARTWORK")
    prep.icon:SetPoint("TOPLEFT", 2, -2)
    prep.icon:SetPoint("BOTTOMRIGHT", -2, 2)
    ApplyNamedIcon(prep.icon, { "inv_misc_food_15", "INV_Misc_Food_15" })
    prep:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
        GameTooltip:SetText("Prepared")
        GameTooltip:AddLine("Your preparation keeps you sated.", 0.9, 0.9, 0.9, true)
        GameTooltip:Show()
    end)
    prep:SetScript("OnLeave", GameTooltip_Hide)
    prep:Hide()
    icons.prepared = prep
    Layout()
end

function Blackacre.Survival.UI.Init()
    Build()
    Blackacre.Survival.UI.Refresh()
end

function Blackacre.Survival.UI.Refresh()
    if not panel then return end
    local s = Blackacre.CharDB and Blackacre.CharDB.survival
    if not s or s.enabled == false or s.hideMeters then
        panel:Hide()
        return
    end
    local state = Blackacre.Survival.GetState()
    panel:Show()
    if icons.prepared then
        if state.hasFood or state.hasWater then
            icons.prepared:Show()
        else
            icons.prepared:Hide()
        end
    end
    Layout()
    icons.hunger:SetMeter(state.hunger)
    icons.thirst:SetMeter(state.thirst)
    icons.exposure:SetMeter(state.exposure)
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
