InCharacter = InCharacter or {}
InCharacter.Afterlife = InCharacter.Afterlife or {}
InCharacter.Afterlife.UI = {}

local mainFrame
local pickerFrame
local taskChecks = {}
local pathButtons = {}

local function SoftToast(msg)
    if InCharacter.UI and InCharacter.UI.Theme and InCharacter.UI.Theme.Toast then
        InCharacter.UI.Theme.Toast(msg)
    else
        InCharacter.Print(msg)
    end
end

local function BuildPicker()
    pickerFrame = CreateFrame("Frame", "InCharacterAfterlifePicker", UIParent, "BackdropTemplate")
    pickerFrame:SetSize(480, 420)
    pickerFrame:SetPoint("CENTER")
    pickerFrame:SetFrameStrata("DIALOG")
    pickerFrame:SetMovable(true)
    pickerFrame:EnableMouse(true)
    pickerFrame:RegisterForDrag("LeftButton")
    pickerFrame:SetScript("OnDragStart", pickerFrame.StartMoving)
    pickerFrame:SetScript("OnDragStop", pickerFrame.StopMovingOrSizing)
    pickerFrame:Hide()
    tinsert(UISpecialFrames, "InCharacterAfterlifePicker")
    InCharacter.UI.Theme.ApplyParchmentBackdrop(pickerFrame, 0.98)

    local title = pickerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -14)
    title:SetText("Choose a realm of death")
    InCharacter.UI.Theme.GoldTitle(title)

    local sub = pickerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sub:SetPoint("TOP", 0, -38)
    sub:SetWidth(440)
    sub:SetText("Where does your spirit walk before it returns? This is an IC rite — not a real quest.")
    InCharacter.UI.Theme.InkFont(sub)

    local close = CreateFrame("Button", nil, pickerFrame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -2, -2)

    local scroll = CreateFrame("ScrollFrame", "InCharacterAfterlifePickerScroll", pickerFrame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 16, -70)
    scroll:SetPoint("BOTTOMRIGHT", -36, 48)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(420, 40)
    scroll:SetScrollChild(content)

    local y = -4
    for i, path in ipairs(InCharacter.AfterlifePaths) do
        local btn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
        btn:SetSize(400, 36)
        btn:SetPoint("TOPLEFT", 4, y)
        btn:SetText(path.name)
        btn:SetScript("OnClick", function()
            local zone = InCharacter.GetZoneContext()
            InCharacter.Afterlife.PathTracker.Start(path.id, zone.zoneName)
            pickerFrame:Hide()
            InCharacter.Afterlife.UI.ShowMain()
        end)
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(path.name)
            GameTooltip:AddLine(path.blurb, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", GameTooltip_Hide)
        pathButtons[i] = btn
        y = y - 40
    end
    content:SetHeight(math.abs(y) + 10)

    local skip = CreateFrame("Button", nil, pickerFrame, "UIPanelButtonTemplate")
    skip:SetSize(120, 22)
    skip:SetPoint("BOTTOM", 0, 14)
    skip:SetText("Not this death")
    skip:SetScript("OnClick", function()
        pickerFrame:Hide()
        SoftToast("The pale road is left unwalked — for now.")
    end)
end

local function BuildMain()
    mainFrame = CreateFrame("Frame", "InCharacterAfterlifeMain", UIParent, "BackdropTemplate")
    mainFrame:SetSize(460, 400)
    mainFrame:SetPoint("CENTER")
    mainFrame:SetFrameStrata("HIGH")
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
    mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)
    mainFrame:Hide()
    tinsert(UISpecialFrames, "InCharacterAfterlifeMain")
    InCharacter.UI.Theme.ApplyParchmentBackdrop(mainFrame, 0.98)

    local icon = mainFrame:CreateTexture(nil, "OVERLAY")
    icon:SetSize(28, 28)
    icon:SetPoint("TOPLEFT", 14, -12)
    icon:SetTexture("Interface\\Icons\\Spell_Holy_SenseUndead")

    mainFrame.title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    mainFrame.title:SetPoint("LEFT", icon, "RIGHT", 8, 0)
    mainFrame.title:SetText("Return Rite")
    InCharacter.UI.Theme.GoldTitle(mainFrame.title)

    local close = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -2, -2)

    mainFrame.blurb = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    mainFrame.blurb:SetPoint("TOPLEFT", 16, -48)
    mainFrame.blurb:SetWidth(420)
    mainFrame.blurb:SetJustifyH("LEFT")
    InCharacter.UI.Theme.InkFont(mainFrame.blurb)

    mainFrame.progress = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainFrame.progress:SetPoint("TOPLEFT", 16, -78)
    InCharacter.UI.Theme.InkFont(mainFrame.progress, "header")

    mainFrame.taskHost = CreateFrame("Frame", nil, mainFrame)
    mainFrame.taskHost:SetPoint("TOPLEFT", 12, -100)
    mainFrame.taskHost:SetSize(430, 220)

    mainFrame.empty = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    mainFrame.empty:SetPoint("CENTER", 0, 10)
    mainFrame.empty:SetWidth(400)
    mainFrame.empty:SetText("No active return rite.\nOpen the realm picker after a death, or begin one below.")
    InCharacter.UI.Theme.InkFont(mainFrame.empty)

    local pickBtn = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    pickBtn:SetSize(130, 24)
    pickBtn:SetPoint("BOTTOMLEFT", 16, 16)
    pickBtn:SetText("Choose realm")
    pickBtn:SetScript("OnClick", function()
        InCharacter.Afterlife.UI.ShowRealmPicker()
    end)

    local abandon = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    abandon:SetSize(100, 24)
    abandon:SetPoint("LEFT", pickBtn, "RIGHT", 8, 0)
    abandon:SetText("Abandon")
    abandon:SetScript("OnClick", function()
        InCharacter.Afterlife.PathTracker.Abandon()
        SoftToast("The afterlife path is abandoned.")
        InCharacter.Afterlife.UI.Refresh()
    end)

    local journal = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    journal:SetSize(120, 24)
    journal:SetPoint("BOTTOMRIGHT", -16, 16)
    journal:SetText("Chronicle")
    journal:SetScript("OnClick", function()
        InCharacter.Chronicle.UI.Show()
    end)

    mainFrame.promptCheck = CreateFrame("CheckButton", nil, mainFrame, "UICheckButtonTemplate")
    mainFrame.promptCheck:SetPoint("BOTTOMLEFT", 14, 44)
    mainFrame.promptCheck:SetScript("OnClick", function(self)
        InCharacter.Afterlife.SetPromptOnDeath(self:GetChecked())
    end)
    local promptLabel = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    promptLabel:SetPoint("LEFT", mainFrame.promptCheck, "RIGHT", 2, 0)
    promptLabel:SetText("Prompt realm picker on death")
    InCharacter.UI.Theme.InkFont(promptLabel)
end

local function ClearTasks()
    for _, cb in ipairs(taskChecks) do
        cb:Hide()
        cb:SetParent(nil)
    end
    wipe(taskChecks)
end

local function BuildTasks(path, active)
    ClearTasks()
    if not mainFrame then return end
    local y = 0
    for _, task in ipairs(path.tasks) do
        local done = active.completed[task.id] ~= nil
        local cb = CreateFrame("CheckButton", nil, mainFrame.taskHost, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", 0, y)
        cb:SetChecked(done)
        cb:SetEnabled(not done)
        cb.taskId = task.id

        local label = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        label:SetPoint("LEFT", cb, "RIGHT", 4, 6)
        label:SetWidth(380)
        label:SetJustifyH("LEFT")
        label:SetText(task.title)
        InCharacter.UI.Theme.InkFont(label)

        local detail = cb:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        detail:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -2)
        detail:SetWidth(380)
        detail:SetJustifyH("LEFT")
        detail:SetText(task.body)

        cb:SetScript("OnClick", function(self)
            if self:GetChecked() then
                InCharacter.Afterlife.PathTracker.CompleteTask(self.taskId)
                SoftToast("Rite step complete: " .. task.title)
            else
                self:SetChecked(true)
            end
        end)

        taskChecks[#taskChecks + 1] = cb
        y = y - 48
    end
end

function InCharacter.Afterlife.UI.Refresh()
    if not mainFrame or not mainFrame:IsShown() then return end
    local active = InCharacter.Afterlife.GetActive()
    mainFrame.promptCheck:SetChecked(InCharacter.Afterlife.IsPromptOnDeath())

    if not active then
        mainFrame.title:SetText("Return Rite")
        mainFrame.blurb:SetText("No soul-path is active. When you die — or when you choose — select a realm of death.")
        mainFrame.progress:SetText("")
        mainFrame.empty:Show()
        ClearTasks()
        return
    end

    local path = InCharacter.GetAfterlifePath(active.pathId)
    mainFrame.empty:Hide()
    mainFrame.title:SetText(active.pathName or "Return Rite")
    mainFrame.blurb:SetText(path and path.blurb or "")
    local done, total = InCharacter.Afterlife.PathTracker.Progress()
    local zoneBit = active.deathZone and active.deathZone ~= "" and (" · fell in " .. active.deathZone) or ""
    mainFrame.progress:SetText(string.format("Progress: %d / %d%s", done, total, zoneBit))
    if path then
        BuildTasks(path, active)
    end
end

function InCharacter.Afterlife.UI.ShowMain()
    if not mainFrame then BuildMain() end
    mainFrame:Show()
    InCharacter.Afterlife.UI.Refresh()
end

function InCharacter.Afterlife.UI.ShowRealmPicker()
    if InCharacter.Afterlife.GetActive() then
        SoftToast("Finish or abandon your current return rite first.")
        InCharacter.Afterlife.UI.ShowMain()
        return
    end
    if not pickerFrame then BuildPicker() end
    pickerFrame:Show()
end

function InCharacter.Afterlife.UI.Toggle()
    if mainFrame and mainFrame:IsShown() then
        mainFrame:Hide()
    else
        InCharacter.Afterlife.UI.ShowMain()
    end
end

function InCharacter.Afterlife.UI.Init()
    -- lazy-built on first open
end