Blackacre = Blackacre or {}
Blackacre.Afterlife = Blackacre.Afterlife or {}
Blackacre.Afterlife.UI = {}

local mainFrame
local pickerFrame
local deityFrame
local taskChecks = {}
local pathButtons = {}
local pageRoot
local deityButtons = {}

local function SoftToast(msg)
    if Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.Toast then
        Blackacre.UI.Theme.Toast(msg)
    else
        Blackacre.Print(msg)
    end
end

local function CharName()
    return (Blackacre.GetCharName and Blackacre.GetCharName()) or UnitName("player") or "Character"
end

local function BuildPicker(parent)
    pickerFrame = CreateFrame("Frame", "BlackacreAfterlifePicker", parent, "BackdropTemplate")
    pickerFrame:SetAllPoints(parent)
    if pickerFrame.SetClipsChildren then pickerFrame:SetClipsChildren(true) end
    Blackacre.UI.Theme.ApplyFilledPanel(pickerFrame, 0.96, "page")
    pickerFrame:Hide()

    local title = pickerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -14)
    title:SetText("Choose Afterlife")
    Blackacre.UI.Theme.GoldTitle(title)

    local sub = pickerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sub:SetPoint("TOPLEFT", 12, -40)
    sub:SetPoint("TOPRIGHT", -12, -40)
    sub:SetJustifyH("CENTER")
    sub:SetText("")
    Blackacre.UI.Theme.InkFont(sub)

    local scroll = CreateFrame("ScrollFrame", "BlackacreAfterlifePickerScroll", pickerFrame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 10, -64)
    scroll:SetPoint("BOTTOMRIGHT", -28, 48)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(420, 40)
    scroll:SetScrollChild(content)

    local y = -4
    local paths = (Blackacre.ListAfterlifePaths and Blackacre.ListAfterlifePaths()) or (Blackacre.AfterlifePaths or {})
    for i, path in ipairs(paths) do
        local btn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
        btn:SetSize(400, 34)
        btn:SetPoint("TOPLEFT", 4, y)
        btn:SetText(path.name)
        btn:SetScript("OnClick", function()
            Blackacre.Afterlife.Choose(path.id)
            pickerFrame:Hide()
            if mainFrame then mainFrame:Show() end
            Blackacre.Afterlife.UI.Refresh()
        end)
        btn:SetScript("OnEnter", nil)
        btn:SetScript("OnLeave", nil)
        pathButtons[i] = btn
        y = y - 38
    end
    content:SetHeight(math.abs(y) + 10)

    local back = CreateFrame("Button", nil, pickerFrame, "UIPanelButtonTemplate")
    back:SetSize(100, 22)
    back:SetPoint("BOTTOMRIGHT", -12, 12)
    back:SetText("Back")
    back:SetScript("OnClick", function()
        pickerFrame:Hide()
        if mainFrame then mainFrame:Show() end
    end)
end

local function BuildDeityPicker(parent)
    deityFrame = CreateFrame("Frame", "BlackacreDeityPicker", parent, "BackdropTemplate")
    deityFrame:SetAllPoints(parent)
    if deityFrame.SetClipsChildren then deityFrame:SetClipsChildren(true) end
    Blackacre.UI.Theme.ApplyFilledPanel(deityFrame, 0.96, "page")
    deityFrame:Hide()

    local title = deityFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -12)
    title:SetText("Deity")
    Blackacre.UI.Theme.GoldTitle(title)

    local scroll = CreateFrame("ScrollFrame", "BlackacreDeityScroll", deityFrame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 10, -40)
    scroll:SetPoint("BOTTOMRIGHT", -28, 48)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(420, 40)
    scroll:SetScrollChild(content)
    deityFrame.content = content

    local y = -2
    for i, d in ipairs(Blackacre.Deities or {}) do
        local btn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
        btn:SetSize(400, 24)
        btn:SetPoint("TOPLEFT", 4, y)
        btn:SetText(d.name)
        btn:SetScript("OnClick", function()
            Blackacre.Afterlife.SetDeity(d.id)
            deityFrame:Hide()
            if mainFrame then mainFrame:Show() end
        end)
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(d.name)
            if d.classification ~= "" then
                GameTooltip:AddLine((d.classification or "") .. " · " .. (d.sub or ""), 0.8, 0.8, 0.8)
            end
            if d.blurb ~= "" then
                GameTooltip:AddLine(d.blurb, 1, 1, 1, true)
            end
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", GameTooltip_Hide)
        deityButtons[i] = btn
        y = y - 26
    end
    content:SetHeight(math.max(40, math.abs(y) + 8))

    local back = CreateFrame("Button", nil, deityFrame, "UIPanelButtonTemplate")
    back:SetSize(100, 22)
    back:SetPoint("BOTTOMRIGHT", -12, 12)
    back:SetText("Back")
    back:SetScript("OnClick", function()
        deityFrame:Hide()
        if mainFrame then mainFrame:Show() end
    end)
end

local function BuildMain(parent)
    mainFrame = CreateFrame("Frame", "BlackacreAfterlifeMain", parent, "BackdropTemplate")
    mainFrame:SetAllPoints(parent)
    if mainFrame.SetClipsChildren then mainFrame:SetClipsChildren(true) end

    mainFrame.title = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    mainFrame.title:SetPoint("TOP", 0, -16)
    mainFrame.title:SetText("Rites of Return Inactive")
    Blackacre.UI.Theme.GoldTitle(mainFrame.title)

    mainFrame.chooseBtn = CreateFrame("Button", nil, mainFrame, "UIPanelButtonTemplate")
    mainFrame.chooseBtn:SetSize(160, 26)
    mainFrame.chooseBtn:SetPoint("TOP", mainFrame.title, "BOTTOM", 0, -12)
    mainFrame.chooseBtn:SetText("Choose Afterlife")
    mainFrame.chooseBtn:SetScript("OnClick", function()
        Blackacre.Afterlife.UI.ShowRealmPicker()
    end)

    mainFrame.live = CreateFrame("Frame", nil, mainFrame)
    mainFrame.live:SetPoint("TOPLEFT", 12, -56)
    mainFrame.live:SetPoint("BOTTOMRIGHT", -12, 48)
    mainFrame.live:Hide()

    mainFrame.blurb = mainFrame.live:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    mainFrame.blurb:SetPoint("TOPLEFT", 0, 0)
    mainFrame.blurb:SetPoint("TOPRIGHT", 0, 0)
    mainFrame.blurb:SetJustifyH("LEFT")
    Blackacre.UI.Theme.InkFont(mainFrame.blurb)

    mainFrame.deityIcon = mainFrame.live:CreateTexture(nil, "ARTWORK")
    mainFrame.deityIcon:SetSize(28, 28)
    mainFrame.deityIcon:SetPoint("TOPLEFT", mainFrame.blurb, "BOTTOMLEFT", 0, -10)

    mainFrame.deityBtn = CreateFrame("Button", nil, mainFrame.live, "UIPanelButtonTemplate")
    mainFrame.deityBtn:SetSize(220, 24)
    mainFrame.deityBtn:SetPoint("LEFT", mainFrame.deityIcon, "RIGHT", 8, 0)
    mainFrame.deityBtn:SetText("Choose Deity")
    mainFrame.deityBtn:SetScript("OnClick", function()
        if not deityFrame then return end
        mainFrame:Hide()
        deityFrame:Show()
    end)

    mainFrame.counts = mainFrame.live:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    mainFrame.counts:SetPoint("TOPLEFT", mainFrame.deityIcon, "BOTTOMLEFT", 0, -10)
    mainFrame.counts:SetPoint("TOPRIGHT", 0, -10)
    mainFrame.counts:SetJustifyH("LEFT")
    Blackacre.UI.Theme.InkFont(mainFrame.counts)

    local scroll = CreateFrame("ScrollFrame", "BlackacreAfterlifeTaskScroll", mainFrame.live, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", mainFrame.counts, "BOTTOMLEFT", 0, -8)
    scroll:SetPoint("BOTTOMRIGHT", -18, 28)
    local taskHost = CreateFrame("Frame", nil, scroll)
    taskHost:SetSize(400, 40)
    scroll:SetScrollChild(taskHost)
    mainFrame.taskHost = taskHost
    mainFrame.taskScroll = scroll

    mainFrame.promptCheck = CreateFrame("CheckButton", nil, mainFrame.live, "UICheckButtonTemplate")
    mainFrame.promptCheck:SetPoint("BOTTOMLEFT", 0, -4)
    mainFrame.promptCheck:SetScript("OnClick", function(self)
        Blackacre.Afterlife.SetPromptOnDeath(self:GetChecked())
    end)
    local promptLabel = mainFrame.live:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    promptLabel:SetPoint("LEFT", mainFrame.promptCheck, "RIGHT", 2, 0)
    promptLabel:SetText("Enable Rites")
    mainFrame.promptCheck:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Enable Rites")
        GameTooltip:AddLine("Rites do not record in Battlegrounds", 0.85, 0.85, 0.85, true)
        GameTooltip:Show()
    end)
    mainFrame.promptCheck:SetScript("OnLeave", GameTooltip_Hide)
    Blackacre.UI.Theme.InkFont(promptLabel)

    local abandon = CreateFrame("Button", nil, mainFrame.live, "UIPanelButtonTemplate")
    abandon:SetSize(90, 22)
    abandon:SetPoint("BOTTOMRIGHT", 0, 0)
    abandon:SetText("Abandon")
    abandon:SetScript("OnClick", function()
        Blackacre.Afterlife.PathTracker.Abandon()
        if Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.Toast then
            Blackacre.UI.Theme.Toast("You have abandoned your current afterlife Rites", "maw")
        else
            SoftToast("You have abandoned your current afterlife Rites")
        end
        Blackacre.Afterlife.UI.Refresh()
    end)
    mainFrame.abandon = abandon
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
    if not mainFrame or not mainFrame.taskHost then return end
    local y = -2
    for _, task in ipairs(path.tasks or {}) do
        local done = active.completed[task.id] ~= nil
        local cb = CreateFrame("CheckButton", nil, mainFrame.taskHost, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", 0, y)
        cb:SetChecked(done)
        cb:SetEnabled(not done)
        cb.taskId = task.id

        local label = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        label:SetPoint("LEFT", cb, "RIGHT", 4, 6)
        label:SetWidth(340)
        label:SetJustifyH("LEFT")
        label:SetText(task.title)
        Blackacre.UI.Theme.InkFont(label)

        local detail = cb:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        detail:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -2)
        detail:SetWidth(340)
        detail:SetJustifyH("LEFT")
        detail:SetText(task.body)

        cb:SetScript("OnClick", function(self)
            if self:GetChecked() then
                Blackacre.Afterlife.PathTracker.CompleteTask(self.taskId)
                SoftToast("Rite step complete: " .. task.title)
            else
                self:SetChecked(true)
            end
        end)

        taskChecks[#taskChecks + 1] = cb
        y = y - 52
    end
    mainFrame.taskHost:SetHeight(math.max(40, math.abs(y) + 8))
end

function Blackacre.Afterlife.UI.Refresh()
    if not mainFrame then return end
    local db = Blackacre.CharDB and Blackacre.CharDB.afterlife
    local chosen = Blackacre.Afterlife.GetChosenPath and Blackacre.Afterlife.GetChosenPath()
    local active = Blackacre.Afterlife.GetActive and Blackacre.Afterlife.GetActive()
    local name = CharName()
    local counts = Blackacre.Afterlife.GetCounts and Blackacre.Afterlife.GetCounts() or { deaths = 0, resurrections = 0, returns = 0 }

    if not chosen and not active then
        mainFrame.title:SetText("Rites of Return Inactive")
        Blackacre.UI.Theme.GoldTitle(mainFrame.title)
        mainFrame.title:ClearAllPoints()
        mainFrame.title:SetPoint("TOP", 0, -16)
        mainFrame.chooseBtn:ClearAllPoints()
        mainFrame.chooseBtn:SetPoint("TOP", mainFrame.title, "BOTTOM", 0, -12)
        mainFrame.chooseBtn:Show()
        mainFrame.live:Hide()
        ClearTasks()
        return
    end

    local path = chosen or (active and Blackacre.GetAfterlifePath(active.pathId))
    local realm = (active and active.pathName) or (path and path.name) or "Unknown"
    mainFrame.title:SetText("Return Rite: " .. realm)
    Blackacre.UI.Theme.GoldTitle(mainFrame.title)
    mainFrame.title:ClearAllPoints()
    mainFrame.title:SetPoint("TOPLEFT", 12, -10)
    mainFrame.chooseBtn:ClearAllPoints()
    mainFrame.chooseBtn:SetPoint("TOPRIGHT", -12, -8)
    mainFrame.chooseBtn:Show()
    mainFrame.live:Show()
    mainFrame.blurb:SetText(path and path.blurb or "")
    mainFrame.promptCheck:SetChecked(Blackacre.Afterlife.IsPromptOnDeath())

    local deity = db and Blackacre.GetDeity and Blackacre.GetDeity(db.deityId)
    if deity then
        mainFrame.deityBtn:SetText(deity.name)
        mainFrame.deityIcon:SetTexture(Blackacre.GetDeityIcon(deity))
    else
        mainFrame.deityBtn:SetText("Choose Deity")
        mainFrame.deityIcon:SetTexture("Interface\\Icons\\inv_misc_questionmark")
    end

    mainFrame.counts:SetText(string.format(
        "%s Deaths: %d\n%s Resurrections: %d\n%s Returns by Rite: %d",
        name, counts.deaths or 0,
        name, counts.resurrections or 0,
        name, counts.returns or 0
    ))

    if active and path then
        BuildTasks(path, active)
        mainFrame.abandon:Show()
        mainFrame.taskScroll:Show()
    else
        ClearTasks()
        mainFrame.abandon:Hide()
        if mainFrame.taskHost then
            mainFrame.taskHost:SetHeight(10)
        end
    end
end

function Blackacre.Afterlife.UI.Mount(parent)
    pageRoot = parent
    if not mainFrame then
        BuildMain(parent)
        BuildPicker(parent)
        BuildDeityPicker(parent)
    else
        Blackacre.UI.Theme.MountInPage(mainFrame, parent)
        if pickerFrame then Blackacre.UI.Theme.MountInPage(pickerFrame, parent) end
        if deityFrame then Blackacre.UI.Theme.MountInPage(deityFrame, parent) end
    end
    if pickerFrame then pickerFrame:Hide() end
    if deityFrame then deityFrame:Hide() end
    mainFrame:Show()
    Blackacre.Afterlife.UI.Refresh()
end

function Blackacre.Afterlife.UI.ShowMain()
    if Blackacre.TomeHub then
        Blackacre.TomeHub.Show("realms")
        return
    end
    if not mainFrame then BuildMain(UIParent) end
    mainFrame:Show()
    Blackacre.Afterlife.UI.Refresh()
end

function Blackacre.Afterlife.UI.ShowRealmPicker()
    if Blackacre.Afterlife.GetActive() then
        SoftToast("Finish or abandon your current return rite first.")
        if mainFrame then mainFrame:Show() end
        if pickerFrame then pickerFrame:Hide() end
        Blackacre.Afterlife.UI.Refresh()
        return
    end
    if not pickerFrame then
        local p = pageRoot or (Blackacre.TomeHub and Blackacre.TomeHub.GetPageHost and Blackacre.TomeHub.GetPageHost("realms")) or UIParent
        BuildMain(p)
        BuildPicker(p)
        BuildDeityPicker(p)
    end
    if mainFrame then mainFrame:Hide() end
    if deityFrame then deityFrame:Hide() end
    pickerFrame:Show()
end

function Blackacre.Afterlife.UI.Toggle()
    if Blackacre.TomeHub and Blackacre.TomeHub.Toggle then
        Blackacre.TomeHub.Toggle("realms")
        return
    end
    if not mainFrame then
        BuildMain(UIParent)
        BuildPicker(UIParent)
        BuildDeityPicker(UIParent)
    end
    if mainFrame:IsShown() then
        mainFrame:Hide()
    else
        mainFrame:Show()
        Blackacre.Afterlife.UI.Refresh()
    end
end

function Blackacre.Afterlife.UI.Init()
end
