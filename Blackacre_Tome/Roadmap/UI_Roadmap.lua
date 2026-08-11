Blackacre = Blackacre or {}
Blackacre.Roadmap = Blackacre.Roadmap or {}
Blackacre.Roadmap.UI = {}

local frame
local stepLines = {}
local presetButtons = {}

local function Build(parent)
    parent = parent or UIParent
    local embedded = parent ~= UIParent

    frame = CreateFrame("Frame", "BlackacreRoadmap", parent, "BackdropTemplate")
    if embedded then
        frame:SetAllPoints(parent)
    else
        frame:SetSize(520, 460)
        frame:SetPoint("CENTER")
        frame:SetFrameStrata("HIGH")
        frame:Hide()
        tinsert(UISpecialFrames, "BlackacreRoadmap")
        Blackacre.UI.Theme.ApplyFilledPanel(frame, 0.96, "page")
    end
    if frame.SetClipsChildren then frame:SetClipsChildren(true) end

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("TOPLEFT", 12, -10)
    frame.title:SetText("Expedition Chart")
    Blackacre.UI.Theme.GoldTitle(frame.title)

    frame.sub = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.sub:SetPoint("TOPLEFT", 12, -32)
    frame.sub:SetPoint("TOPRIGHT", -12, -32)
    frame.sub:SetJustifyH("LEFT")
    frame.sub:SetText("Chart a leveling road. The addon suggests when to linger — you control XP lock in game settings.")
    Blackacre.UI.Theme.InkFont(frame.sub)

    frame.left = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.left:SetPoint("TOPLEFT", 10, -56)
    frame.left:SetPoint("BOTTOMLEFT", 10, 48)
    frame.left:SetWidth(190)
    Blackacre.UI.Theme.ApplyFilledPanel(frame.left, 0.9, "panel")

    local leftTitle = frame.left:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    leftTitle:SetPoint("TOPLEFT", 8, -8)
    leftTitle:SetText("Preset roads")
    Blackacre.UI.Theme.InkFont(leftTitle, "header")

    local y = -28
    for i, preset in ipairs(Blackacre.RoadmapPresets or {}) do
        local btn = CreateFrame("Button", nil, frame.left, "UIPanelButtonTemplate")
        btn:SetSize(170, 26)
        btn:SetPoint("TOPLEFT", 8, y)
        btn:SetText(preset.name:sub(1, 24))
        btn:SetScript("OnClick", function()
            Blackacre.Roadmap.Store.StartPreset(preset.id)
            Blackacre.Roadmap.UI.Refresh()
            Blackacre.UI.Theme.Toast("Chart set: " .. preset.name)
        end)
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(preset.name)
            GameTooltip:AddLine(preset.blurb, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", GameTooltip_Hide)
        presetButtons[i] = btn
        y = y - 30
    end

    frame.right = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.right:SetPoint("TOPLEFT", frame.left, "TOPRIGHT", 10, 0)
    frame.right:SetPoint("BOTTOMRIGHT", -10, 48)
    Blackacre.UI.Theme.ApplyFilledPanel(frame.right, 0.92, "page")
    if frame.right.SetClipsChildren then frame.right:SetClipsChildren(true) end

    frame.chartTitle = frame.right:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.chartTitle:SetPoint("TOPLEFT", 10, -10)
    frame.chartTitle:SetPoint("TOPRIGHT", -10, -10)
    frame.chartTitle:SetJustifyH("LEFT")
    frame.chartTitle:SetText("No active expedition")
    Blackacre.UI.Theme.InkFont(frame.chartTitle, "header")

    frame.chartBlurb = frame.right:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.chartBlurb:SetPoint("TOPLEFT", 10, -30)
    frame.chartBlurb:SetPoint("TOPRIGHT", -10, -30)
    frame.chartBlurb:SetJustifyH("LEFT")
    Blackacre.UI.Theme.InkFont(frame.chartBlurb)

    frame.stepHost = CreateFrame("Frame", nil, frame.right)
    frame.stepHost:SetPoint("TOPLEFT", 8, -55)
    frame.stepHost:SetPoint("BOTTOMRIGHT", -8, 80)

    frame.detail = frame.right:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.detail:SetPoint("BOTTOMLEFT", 10, 8)
    frame.detail:SetPoint("BOTTOMRIGHT", -10, 8)
    frame.detail:SetJustifyH("LEFT")
    frame.detail:SetHeight(70)
    Blackacre.UI.Theme.InkFont(frame.detail)

    local fromBirth = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    fromBirth:SetSize(120, 24)
    fromBirth:SetPoint("BOTTOMLEFT", 140, 12)
    fromBirth:SetText("From lineage")
    fromBirth:SetScript("OnClick", function()
        if Blackacre.Birthpath and Blackacre.Birthpath.ChartFromBirth then
            Blackacre.Birthpath.ChartFromBirth()
            Blackacre.Roadmap.UI.Refresh()
        end
    end)

    local advance = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    advance:SetSize(120, 24)
    advance:SetPoint("BOTTOMRIGHT", -12, 12)
    advance:SetText("Next chapter")
    advance:SetScript("OnClick", function()
        Blackacre.Roadmap.Store.Advance()
        Blackacre.Roadmap.UI.Refresh()
    end)

    local abandon = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    abandon:SetSize(90, 24)
    abandon:SetPoint("RIGHT", advance, "LEFT", -8, 0)
    abandon:SetText("Abandon")
    abandon:SetScript("OnClick", function()
        Blackacre.Roadmap.Store.Abandon()
        Blackacre.UI.Theme.Toast("Expedition abandoned.")
        Blackacre.Roadmap.UI.Refresh()
    end)

    frame.promptCheck = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
    frame.promptCheck:SetPoint("BOTTOMLEFT", 10, 10)
    frame.promptCheck:SetScript("OnClick", function(self)
        Blackacre.Roadmap.SetLockPrompts(self:GetChecked())
    end)
    local pl = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    pl:SetPoint("LEFT", frame.promptCheck, "RIGHT", 2, 0)
    pl:SetText("Level-lock suggestions")
    Blackacre.UI.Theme.InkFont(pl)
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

function Blackacre.Roadmap.UI.Refresh()
    if not frame then return end
    if frame.promptCheck then
        frame.promptCheck:SetChecked(Blackacre.Roadmap.LockPromptsEnabled())
    end
    ClearSteps()

    local active = Blackacre.Roadmap.GetActive()
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
        Blackacre.UI.Theme.InkFont(line.text)
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
    if cur and (frame.detail:GetText() or "") == "" then
        frame.detail:SetText(cur.lore or "")
    end
end

function Blackacre.Roadmap.UI.Mount(parent)
    if not frame then Build(parent)
    elseif parent then Blackacre.UI.Theme.MountInPage(frame, parent) end
    frame:Show()
    Blackacre.Roadmap.UI.Refresh()
end

function Blackacre.Roadmap.UI.Toggle()
    if Blackacre.TomeHub and Blackacre.TomeHub.Toggle then
        Blackacre.TomeHub.Toggle("road")
        return
    end
    if not frame then Build(UIParent) end
    if frame:IsShown() then frame:Hide() else frame:Show(); Blackacre.Roadmap.UI.Refresh() end
end

function Blackacre.Roadmap.UI.Init()
end
