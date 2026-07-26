InCharacter = InCharacter or {}
InCharacter.Afterlife = InCharacter.Afterlife or {}
InCharacter.Afterlife.UI = {}

local mainFrame
local pickerFrame
local taskChecks = {}
local pathButtons = {}
local pageRoot

local function SoftToast(msg)
    if InCharacter.UI and InCharacter.UI.Theme and InCharacter.UI.Theme.Toast then
        InCharacter.UI.Theme.Toast(msg)
    else
        InCharacter.Print(msg)
    end
end

local function BuildPicker(parent)
    pickerFrame = CreateFrame("Frame", "InCharacterAfterlifePicker", parent, "BackdropTemplate")
    pickerFrame:SetAllPoints(parent)
    if pickerFrame.SetClipsChildren then pickerFrame:SetClipsChildren(true) end
    InCharacter.UI.Theme.ApplyFilledPanel(pickerFrame, 0.96, "page")
    pickerFrame:Hide()

    local title = pickerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 12, -10)
    title:SetText("Choose a realm of death")
    InCharacter.UI.Theme.GoldTitle(title)

    local sub = pickerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sub:SetPoint("TOPLEFT", 12, -34)
    sub:SetPoint("TOPRIGHT", -12, -34)
    sub:SetJustifyH("LEFT")
    sub:SetText("Where does your spirit walk before it returns? This is an IC rite — not a real quest.")
    InCharacter.UI.Theme.InkFont(sub)

    local scroll = CreateFrame("ScrollFrame", "InCharacterAfterlifePickerScroll", pickerFrame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 10, -60)
    scroll:SetPoint("BOTTOMRIGHT", -28, 48)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(420, 40)
    scroll:SetScrollChild(content)

    local y = -4
    for i, path in ipairs(InCharacter.AfterlifePaths or {}) do
        local btn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
        btn:SetSize(400, 34)
        btn:SetPoint("TOPLEFT", 4, y)
        btn:SetText(path.name)
        btn:SetScript("OnClick", function()
            local zone = InCharacter.GetZoneContext()
            InCharacter.Afterlife.PathTracker.Start(path.id, zone.zoneName)
            pickerFrame:Hide()
            if mainFrame then mainFrame:Show() end
            InCharacter.Afterlife.UI.Refresh()
        end)
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(path.name)
            GameTooltip:AddLine(path.blurb, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", GameTooltip_Hide)
        pathButtons[i] = btn
        y = y - 38
    end
    content:SetHeight(math.abs(y) + 10)

    local skip = CreateFrame("Button", nil, pickerFrame, "UIPanelButtonTemplate")
    skip:SetSize(140, 22)
    skip:SetPoint("BOTTOMLEFT", 12, 12)
    skip:SetText("Not this death")
    skip:SetScript("OnClick", function()
        pickerFrame:Hide()
        if mainFrame then mainFrame:Show() end
        SoftToast("The pale road is left unwalked — for now.")
    end)

    local back = CreateFrame("Button", nil, pickerFrame, "UIPanelButtonTemplate")
    back:SetSize(100, 22)
    back:SetPoint("BOTTOMRIGHT", -12, 12)
    back:SetText("Back")
    back:SetScript("OnClick", function()
        pickerFrame:Hide()
        if mainFrame then mainFrame:Show() end
    end)
end

local function BuildMain(parent)
    mainFrame = CreateFrame("Frame", "InCharacterAfterlifeMain", parent, "BackdropTemplate")
    mainFrame:SetAllPoints(parent)
    if mainFrame.SetClipsChildren then mainFrame:SetClipsChildren(true) end

    mainFrame.title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    mainFrame.title:SetPoint("TOPLEFT", 12, -10)
    mainFrame.title:SetText("Return Rite")
    InCharacter.UI.Theme.GoldTitle(mainFrame.title)

    mainFrame.blurb = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    mainFrame.blurb:SetPoint("TOPLEFT", 12, -36)
    mainFrame.blurb:SetPoint("TOPRIGHT", -12, -36)
    mainFrame.blurb:SetJustifyH("LEFT")
    InCharacter.UI.Theme.InkFont(mainFrame.blurb)

    mainFrame.progress = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainFrame.progress:SetPoint("TOPLEFT", 12, -64)
    InCharacter.UI.Theme.InkFont(mainFrame.progress, "header")

    mainFrame.taskHost = CreateFrame("Frame", nil, mainFrame)
    mainFrame.taskHost:SetPoint("TOPLEFT", 10, -88)
    mainFrame.taskHost:SetPoint("BOTTOMRIGHT", -10, 72)
    if mainFrame.taskHost.SetClipsChildren then mainFrame.taskHost:SetClipsChildren(true) end

    mainFrame.empty = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    mainFrame.empty:SetPoint("CENTER", 0, 20)
    mainFrame.empty:SetWidth(400)
    mainFrame.empty:SetText("No active return rite.\nChoose a realm after a death, or begin one below.")
    InCharacter.UI.Theme.InkFont(mainFrame.empty)

    local pickBtn = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    pickBtn:SetSize(130, 24)
    pickBtn:SetPoint("BOTTOMLEFT", 12, 12)
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
    journal:SetPoint("BOTTOMRIGHT", -12, 12)
    journal:SetText("Chronicle")
    journal:SetScript("OnClick", function()
        if InCharacter.TomeHub then InCharacter.TomeHub.Show("chronicle") end
    end)

    mainFrame.promptCheck = CreateFrame("CheckButton", nil, mainFrame, "UICheckButtonTemplate")
    mainFrame.promptCheck:SetPoint("BOTTOMLEFT", 10, 40)
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
    if not mainFrame then return end
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

function InCharacter.Afterlife.UI.Mount(parent)
    pageRoot = parent
    if not mainFrame then
        BuildMain(parent)
        BuildPicker(parent)
    else
        InCharacter.UI.Theme.MountInPage(mainFrame, parent)
        if pickerFrame then InCharacter.UI.Theme.MountInPage(pickerFrame, parent) end
    end
    if pickerFrame then pickerFrame:Hide() end
    mainFrame:Show()
    InCharacter.Afterlife.UI.Refresh()
end

function InCharacter.Afterlife.UI.ShowMain()
    if InCharacter.TomeHub then
        InCharacter.TomeHub.Show("realms")
        return
    end
    if not mainFrame then BuildMain(UIParent) end
    mainFrame:Show()
    InCharacter.Afterlife.UI.Refresh()
end

function InCharacter.Afterlife.UI.ShowRealmPicker()
    if InCharacter.Afterlife.GetActive() then
        SoftToast("Finish or abandon your current return rite first.")
        if mainFrame then mainFrame:Show() end
        if pickerFrame then pickerFrame:Hide() end
        InCharacter.Afterlife.UI.Refresh()
        return
    end
    if not pickerFrame then
        local p = pageRoot or (InCharacter.TomeHub and InCharacter.TomeHub.GetPageHost and InCharacter.TomeHub.GetPageHost("realms")) or UIParent
        BuildMain(p)
        BuildPicker(p)
    end
    if mainFrame then mainFrame:Hide() end
    pickerFrame:Show()
end

function InCharacter.Afterlife.UI.Toggle()
    if InCharacter.TomeHub and InCharacter.TomeHub.Toggle then
        InCharacter.TomeHub.Toggle("realms")
        return
    end
    InCharacter.Afterlife.UI.ShowMain()
end

function InCharacter.Afterlife.UI.Init()
end
