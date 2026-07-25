InCharacter = InCharacter or {}
InCharacter.Roadmap = InCharacter.Roadmap or {}
InCharacter.Roadmap.UI = {}

local frame
local stepLines = {}
local presetButtons = {}

local function Build()
    frame = CreateFrame("Frame", "InCharacterRoadmap", UIParent, "BackdropTemplate")
    frame:SetSize(520, 460)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("HIGH")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:Hide()
    tinsert(UISpecialFrames, "InCharacterRoadmap")
    InCharacter.UI.Theme.ApplyParchmentBackdrop(frame, 0.98)

    local icon = frame:CreateTexture(nil, "OVERLAY")
    icon:SetSize(28, 28)
    icon:SetPoint("TOPLEFT", 14, -12)
    icon:SetTexture("Interface\\Icons\\INV_Misc_Map_01")

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("LEFT", icon, "RIGHT", 8, 0)
    frame.title:SetText("Expedition Chart")
    InCharacter.UI.Theme.GoldTitle(frame.title)

    frame.sub = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.sub:SetPoint("TOPLEFT", 16, -46)
    frame.sub:SetWidth(480)
    frame.sub:SetJustifyH("LEFT")
    frame.sub:SetText("Chart a leveling road. The addon suggests when to linger — you control XP lock in game settings.")
    InCharacter.UI.Theme.InkFont(frame.sub)

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -2, -2)

    -- Left: presets
    frame.left = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.left:SetPoint("TOPLEFT", 14, -75)
    frame.left:SetSize(200, 300)
    frame.left:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    frame.left:SetBackdropColor(0.95, 0.90, 0.78, 0.5)
    frame.left:SetBackdropBorderColor(0.45, 0.35, 0.2, 0.9)

    local leftTitle = frame.left:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    leftTitle:SetPoint("TOPLEFT", 8, -8)
    leftTitle:SetText("Preset roads")
    InCharacter.UI.Theme.InkFont(leftTitle, "header")

    local y = -28
    for i, preset in ipairs(InCharacter.RoadmapPresets) do
        local btn = CreateFrame("Button", nil, frame.left, "UIPanelButtonTemplate")
        btn:SetSize(180, 28)
        btn:SetPoint("TOPLEFT", 8, y)
        btn:SetText(preset.name:sub(1, 28))
        btn:SetScript("OnClick", function()
            InCharacter.Roadmap.Store.StartPreset(preset.id)
            InCharacter.Roadmap.UI.Refresh()
            InCharacter.UI.Theme.Toast("Chart set: " .. preset.name)
        end)
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(preset.name)
            GameTooltip:AddLine(preset.blurb, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", GameTooltip_Hide)
        presetButtons[i] = btn
        y = y - 32
    end

    -- Right: active chart
    frame.right = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.right:SetPoint("TOPLEFT", frame.left, "TOPRIGHT", 12, 0)
    frame.right:SetPoint("BOTTOMRIGHT", -14, 50)
    frame.right:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    frame.right:SetBackdropColor(0.97, 0.93, 0.82, 0.65)
    frame.right:SetBackdropBorderColor(0.45, 0.35, 0.2, 0.9)

    frame.chartTitle = frame.right:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.chartTitle:SetPoint("TOPLEFT", 10, -10)
    frame.chartTitle:SetPoint("TOPRIGHT", -10, -10)
    frame.chartTitle:SetJustifyH("LEFT")
    frame.chartTitle:SetText("No active expedition")
    InCharacter.UI.Theme.InkFont(frame.chartTitle, "header")

    frame.chartBlurb = frame.right:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.chartBlurb:SetPoint("TOPLEFT", 10, -30)
    frame.chartBlurb:SetPoint("TOPRIGHT", -10, -30)
    frame.chartBlurb:SetJustifyH("LEFT")
    InCharacter.UI.Theme.InkFont(frame.chartBlurb)

    frame.stepHost = CreateFrame("Frame", nil, frame.right)
    frame.stepHost:SetPoint("TOPLEFT", 8, -55)
    frame.stepHost:SetSize(260, 250)

    frame.detail = frame.right:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.detail:SetPoint("BOTTOMLEFT", 10, 40)
    frame.detail:SetPoint("BOTTOMRIGHT", -10, 40)
    frame.detail:SetJustifyH("LEFT")
    frame.detail:SetHeight(70)
    InCharacter.UI.Theme.InkFont(frame.detail)

    local advance = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    advance:SetSize(120, 24)
    advance:SetPoint("BOTTOMRIGHT", -14, 14)
    advance:SetText("Next chapter")
    advance:SetScript("OnClick", function()
        InCharacter.Roadmap.Store.Advance()
    end)

    local abandon = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    abandon:SetSize(90, 24)
    abandon:SetPoint("RIGHT", advance, "LEFT", -8, 0)
    abandon:SetText("Abandon")
    abandon:SetScript("OnClick", function()
        InCharacter.Roadmap.Store.Abandon()
        InCharacter.UI.Theme.Toast("Expedition abandoned.")
        InCharacter.Roadmap.UI.Refresh()
    end)

    frame.promptCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    frame.promptCheck:SetPoint("BOTTOMLEFT", 12, 12)
    frame.promptCheck:SetScript("OnClick", function(self)
        InCharacter.Roadmap.SetLockPrompts(self:GetChecked())
    end)
    local pl = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    pl:SetPoint("LEFT", frame.promptCheck, "RIGHT", 2, 0)
    pl:SetText("Level-lock suggestions")
    InCharacter.UI.Theme.InkFont(pl)
end

local function ClearSteps()
    for _, line in ipairs(stepLines) do
        line:Hide()
        line:SetParent(nil)
    end
    wipe(stepLines)
end

local function StatusGlyph(status)
    if status == "done" then return "|cff2d8a2d✓|r"
    elseif status == "active" then return "|cffc9a227►|r"
    elseif status == "locked" then return "|cff6b4f2a▣|r"
    else return "|cff888888○|r"
    end
end

function InCharacter.Roadmap.UI.Refresh()
    if not frame or not frame:IsShown() then return end
    frame.promptCheck:SetChecked(InCharacter.Roadmap.LockPromptsEnabled())
    ClearSteps()

    local active = InCharacter.Roadmap.GetActive()
    if not active then
        frame.chartTitle:SetText("No active expedition")
        frame.chartBlurb:SetText("Choose a preset road on the left to begin charting.")
        frame.detail:SetText("")
        return
    end

    frame.chartTitle:SetText(active.name)
    frame.chartBlurb:SetText(active.blurb or "")
    local y = 0
    for i, step in ipairs(active.steps) do
        local line = CreateFrame("Button", nil, frame.stepHost)
        line:SetSize(250, 22)
        line:SetPoint("TOPLEFT", 0, y)
        line.text = line:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        line.text:SetAllPoints()
        line.text:SetJustifyH("LEFT")
        local lvl = string.format("%d–%d", step.levelMin or 0, step.levelMax or 0)
        line.text:SetText(string.format("%s  %s  |cff6b4f2a%s|r", StatusGlyph(step.status), step.name, lvl))
        InCharacter.UI.Theme.InkFont(line.text)
        line:SetScript("OnClick", function()
            local hubs = step.hubs and table.concat(step.hubs, ", ") or "—"
            frame.detail:SetText(string.format(
                "|cffffd100%s|r\nHubs: %s\nSuggested lock near: %s\n\n%s",
                step.name,
                hubs,
                step.lockAt and tostring(step.lockAt) or "—",
                step.lore or ""
            ))
        end)
        if step.status == "active" then
            line:GetScript("OnClick")(line)
        end
        stepLines[i] = line
        y = y - 22
    end

    local cur = active.steps[active.currentIndex]
    if cur and frame.detail:GetText() == "" then
        frame.detail:SetText(cur.lore or "")
    end
end

function InCharacter.Roadmap.UI.Toggle()
    if not frame then Build() end
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
        InCharacter.Roadmap.UI.Refresh()
    end
end

function InCharacter.Roadmap.UI.Init()
end