Blackacre = Blackacre or {}
Blackacre.ToolBox = {}

local frame
local buttons = {}

local SLOTS = {
    { id = "eat", label = "Eat", icon = { "inv_misc_food_66", "INV_Misc_Food_66" } },
    { id = "drink", label = "Drink", icon = { "inv_drink_18_color03", "INV_Drink_18" } },
    { id = "rest", label = "Recover", icon = { "spell_nature_naturesblessing", "Spell_Nature_NaturesBlessing" } },
    { id = "journal", label = "Journal", icon = { "inv_misc_book_07", "INV_Misc_Book_07" } },
    { id = "beacon", label = "Beacon", icon = { "ability_hunter_huntervswild", "Ability_Hunter_HunterVsWild" } },
    { id = "bulletin", label = "Bulletin", icon = { "inv_misc_groupneedmore", "INV_Misc_GroupNeedMore" } },
    { id = "emit", label = "Emit", toggle = true,
        iconOff = { "spell_animamaw_buff", "Spell_AnimaMaw_Buff", "spell_animamaw_orb" },
        iconOn = { "spell_animabastion_buff", "Spell_AnimaBastion_Buff", "spell_animabastion_orb" },
    },
    { id = "seeking", label = "Seeking", toggle = true,
        iconOff = { "spell_magic_lesserinvisibilty", "Spell_Magic_LesserInvisibilty" },
        iconOn = { "spell_holy_senseundead", "Spell_Holy_SenseUndead" },
    },
    { id = "survival", label = "Survival", icon = { "ability_creature_cursed_02", "Ability_Creature_Cursed_02" }, toggle = true },
}

local SIZE = 42
local GAP = 3
local COLS, ROWS = 3, 3
local INNER_PAD = 16

local function HasAtlas(name)
    return name and C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(name)
end

local function SpellTexture(spellID)
    if not spellID then return nil end
    if C_Spell and C_Spell.GetSpellTexture then
        return C_Spell.GetSpellTexture(spellID)
    end
    if GetSpellTexture then
        return GetSpellTexture(spellID)
    end
    return nil
end

local function PaintIcon(tex, names, spellID)
    if not tex then return end
    tex:SetTexCoord(0, 1, 0, 1)
    if tex.SetAtlas then
        pcall(function() tex:SetAtlas(nil) end)
    end
    tex:SetTexture(nil)
    if type(names) == "string" then names = { names } end
    names = names or {}
    for i = 1, #names do
        local n = names[i]
        if HasAtlas(n) then
            tex:SetAtlas(n, false)
            return
        end
    end
    local file = SpellTexture(spellID)
    if file then
        tex:SetTexture(file)
        tex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        return
    end
    if names[1] then
        tex:SetTexture("Interface\\Icons\\" .. names[1])
        tex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    end
end

local function PlayClick()
    if Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.PlayUISound then
        Blackacre.UI.Theme.PlayUISound("toolClick")
    end
end

local function EmitOn()
    local p = Blackacre.Lifecycle and Blackacre.Lifecycle.EnsurePresenceDB and Blackacre.Lifecycle.EnsurePresenceDB()
    if not p then return false end
    return p.emitEnabled and true or false
end

local function SeekingOn()
    local p = Blackacre.Lifecycle and Blackacre.Lifecycle.EnsurePresenceDB and Blackacre.Lifecycle.EnsurePresenceDB()
    if not p then return true end
    if p.seekingEnabled == false then return false end
    return true
end

local function SurvivalOn()
    local s = Blackacre.CharDB and Blackacre.CharDB.survival
    if s and s.enabled == false then return false end
    return true
end

local function SetPushed(btn, down)
    if btn.pushed then
        btn.pushed:SetShown(down and true or false)
    end
    if btn.icon then
        if down then
            btn.icon:SetPoint("CENTER", 1, -1)
        else
            btn.icon:SetPoint("CENTER", 0, 0)
        end
    end
end

local function PaintToggle(btn)
    if not btn.toggle then return end
    local on
    if btn.id == "emit" then
        on = EmitOn()
    elseif btn.id == "seeking" then
        on = SeekingOn()
    else
        on = SurvivalOn()
    end
    btn.isOn = on and true or false
    if btn.id == "emit" or btn.id == "seeking" then
        PaintIcon(btn.icon, on and btn.iconOn or btn.iconOff)
        btn.icon:SetDesaturated(false)
        btn.icon:SetVertexColor(1, 1, 1)
    elseif btn.icon then
        btn.icon:SetDesaturated(not on)
        btn.icon:SetVertexColor(on and 1 or 0.55, on and 1 or 0.55, on and 1 or 0.55)
    end
end

local function Run(id)
    if id == "eat" then
        if Blackacre.Survival and Blackacre.Survival.Engine then
            Blackacre.Survival.Engine.Recover("eat")
        end
    elseif id == "drink" then
        if Blackacre.Survival and Blackacre.Survival.Engine then
            Blackacre.Survival.Engine.Recover("drink")
        end
    elseif id == "rest" then
        if UnitAffectingCombat and UnitAffectingCombat("player") then
            if Blackacre.Print then
                Blackacre.Print("Recover is unavailable in combat")
            end
            return
        end
        if Blackacre.Survival and Blackacre.Survival.Engine then
            Blackacre.Survival.Engine.Recover("rest", 18)
        end
    elseif id == "journal" then
        if Blackacre.TomeHub and Blackacre.TomeHub.Toggle then
            Blackacre.TomeHub.Toggle()
        end
    elseif id == "beacon" then
        if Blackacre.PostEditor and Blackacre.PostEditor.ShowBeaconEditor then
            Blackacre.PostEditor.ShowBeaconEditor()
        elseif Blackacre.Print then
            Blackacre.Print("Beacons need the Presence package.")
        end
    elseif id == "bulletin" then
        if Blackacre.PostEditor and Blackacre.PostEditor.ShowBulletinEditor then
            Blackacre.PostEditor.ShowBulletinEditor()
        elseif Blackacre.Print then
            Blackacre.Print("Bulletins need the Presence package.")
        end
    elseif id == "emit" then
        local on = not EmitOn()
        local ok = true
        if Blackacre.Lifecycle and Blackacre.Lifecycle.SetEmitEnabled then
            ok = Blackacre.Lifecycle.SetEmitEnabled(on)
        end
        if ok ~= false and Blackacre.Print then
            Blackacre.Print(on and "Emit on" or "Emit Off")
        end
    elseif id == "seeking" then
        local on = not SeekingOn()
        if Blackacre.Lifecycle and Blackacre.Lifecycle.SetSeekingEnabled then
            Blackacre.Lifecycle.SetSeekingEnabled(on)
        else
            local p = Blackacre.Lifecycle and Blackacre.Lifecycle.EnsurePresenceDB and Blackacre.Lifecycle.EnsurePresenceDB()
            if p then p.seekingEnabled = on end
        end
        if Blackacre.Print then
            Blackacre.Print(on and "Seeking on" or "Seeking Off")
        end
    elseif id == "survival" then
        local on = not SurvivalOn()
        if Blackacre.Survival and Blackacre.Survival.Engine and Blackacre.Survival.Engine.SetEnabled then
            Blackacre.Survival.Engine.SetEnabled(on)
        else
            Blackacre.CharDB = Blackacre.CharDB or {}
            Blackacre.CharDB.survival = Blackacre.CharDB.survival or {}
            Blackacre.CharDB.survival.enabled = on
        end
        if Blackacre.Survival and Blackacre.Survival.UI and Blackacre.Survival.UI.Refresh then
            Blackacre.Survival.UI.Refresh()
        end
    end
    PlayClick()
    for _, b in ipairs(buttons) do
        PaintToggle(b)
    end
end

local function MakeSlot(parent, spec, col, row, originX, originY)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(SIZE, SIZE)
    local x = originX + (col - 1) * (SIZE + GAP)
    local y = originY - (row - 1) * (SIZE + GAP)
    btn:SetPoint("TOPLEFT", x, y)
    btn.id = spec.id
    btn.toggle = spec.toggle
    btn.baseLabel = spec.label
    btn.iconOn = spec.iconOn
    btn.iconOff = spec.iconOff
    btn.spellID = spec.spellID

    btn.slot = btn:CreateTexture(nil, "BACKGROUND")
    btn.slot:SetAllPoints()
    btn.slot:SetTexture("Interface\\Buttons\\UI-Quickslot2")
    btn.slot:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    btn.icon = btn:CreateTexture(nil, "ARTWORK", nil, 1)
    btn.icon:SetSize(28, 28)
    btn.icon:SetPoint("CENTER", 0, 0)
    PaintIcon(btn.icon, spec.icon or spec.iconOff, spec.spellID)

    btn.pushed = btn:CreateTexture(nil, "ARTWORK", nil, 1)
    btn.pushed:SetAllPoints()
    btn.pushed:SetTexture("Interface\\Buttons\\UI-Quickslot-Depress")
    btn.pushed:Hide()

    btn.glow = btn:CreateTexture(nil, "OVERLAY")
    btn.glow:SetSize(32, 32)
    btn.glow:SetPoint("CENTER", btn.icon, "CENTER", 0, 0)
    btn.glow:SetTexture("Interface\\Spellbook\\SpellbookElementsAutoCastMask")
    if btn.glow.SetBlendMode then btn.glow:SetBlendMode("ADD") end
    btn.glow:Hide()

    btn:SetScript("OnEnter", function(self)
        self.glow:Show()
        local tip = spec.label
        if self.toggle then
            tip = spec.label .. ((self.isOn and " On") or " Off")
        end
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(tip)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function(self)
        self.glow:Hide()
        SetPushed(self, false)
        GameTooltip:Hide()
    end)
    btn:SetScript("OnMouseDown", function(self)
        SetPushed(self, true)
    end)
    btn:SetScript("OnMouseUp", function(self)
        SetPushed(self, false)
    end)
    btn:SetScript("OnClick", function()
        Run(spec.id)
    end)

    PaintToggle(btn)
    return btn
end

local function SizeForShell()
    local gridW = COLS * SIZE + (COLS - 1) * GAP
    local gridH = ROWS * SIZE + (ROWS - 1) * GAP
    local needW = gridW + INNER_PAD * 2
    local needH = gridH + INNER_PAD * 2
    local aw, ah = 512, 512
    local info = HasAtlas("ClassTrial-End-Frame") and C_Texture.GetAtlasInfo("ClassTrial-End-Frame")
    if info then
        aw = info.width or aw
        ah = info.height or ah
    end
    local scale = math.max(needW / aw, needH / ah)
    return aw * scale, ah * scale, gridW, gridH
end

local function Build()
    local fw, fh, gridW, gridH = SizeForShell()
    frame = CreateFrame("Frame", "BlackacreToolBox", UIParent)
    frame:SetSize(fw, fh)
    frame:SetPoint("CENTER", 0, 80)
    frame:SetFrameStrata("HIGH")
    frame:SetToplevel(true)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetClampedToScreen(true)
    frame:Hide()
    tinsert(UISpecialFrames, "BlackacreToolBox")

    local base = frame:GetFrameLevel() or 1
    frame.shellHost = CreateFrame("Frame", nil, frame)
    frame.shellHost:SetAllPoints()
    frame.shellHost:EnableMouse(false)
    frame.shellHost:SetFrameLevel(base)
    frame.shell = frame.shellHost:CreateTexture(nil, "BACKGROUND")
    frame.shell:SetAllPoints()
    if HasAtlas("ClassTrial-End-Frame") then
        frame.shell:SetAtlas("ClassTrial-End-Frame", false)
    else
        frame.shell:SetTexture("Interface\\Glues\\AccountUpgrade\\ClassTrialThanksFrame")
    end

    frame.content = CreateFrame("Frame", nil, frame)
    frame.content:SetAllPoints()
    frame.content:EnableMouse(false)
    frame.content:SetFrameLevel(base + 40)

    local close = CreateFrame("Button", nil, frame.content, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -22, -4)
    close:SetFrameLevel(base + 50)
    close:SetScript("OnClick", function() frame:Hide() end)

    local originX = (fw - gridW) / 2
    local originY = -((fh - gridH) / 2)
    wipe(buttons)
    for i, spec in ipairs(SLOTS) do
        local col = ((i - 1) % COLS) + 1
        local row = math.floor((i - 1) / COLS) + 1
        local btn = MakeSlot(frame.content, spec, col, row, originX, originY)
        btn:SetFrameLevel(base + 45)
        buttons[#buttons + 1] = btn
    end
end

function Blackacre.ToolBox.Toggle()
    if not frame then Build() end
    if frame:IsShown() then
        frame:Hide()
    else
        for _, b in ipairs(buttons) do PaintToggle(b) end
        frame:Show()
    end
end

function Blackacre.ToolBox.Show()
    if not frame then Build() end
    for _, b in ipairs(buttons) do PaintToggle(b) end
    frame:Show()
end
