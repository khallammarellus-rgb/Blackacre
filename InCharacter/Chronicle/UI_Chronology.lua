InCharacter = InCharacter or {}
InCharacter.Chronicle = InCharacter.Chronicle or {}
InCharacter.Chronicle.UI = {}

local journal
local entryButtons = {}
local selectedId
local oldestFirst = false
local filterKind = nil
local searchText = ""
local presentationMode = false
local MAX_ROWS = 14

local KIND_LABELS = {
    QUEST = "Quest",
    ACHIEVEMENT = "Feat",
    TITLE = "Title",
    PROFESSION = "Craft",
    MANUAL = "Note",
}

local function KindLabel(kind)
    return KIND_LABELS[kind] or kind or "?"
end

local function FormatDate(ts)
    if not ts then return "" end
    return date("%Y-%m-%d", ts)
end

local function RefreshList()
    if not journal then return end
    local list = InCharacter.Chronicle.Store.List({
        kind = filterKind,
        search = searchText,
        oldestFirst = oldestFirst,
    })
    journal.listCount:SetText(#list .. " entries")
    for i = 1, MAX_ROWS do
        local btn = entryButtons[i]
        local entry = list[i]
        if entry then
            btn.entryId = entry.id
            local pin = entry.pinned and "|TInterface\\Buttons\\UI-GuildButton-PublicNote-Up:12|t " or ""
            btn.label:SetText(string.format("%s|cff6b4f2a%s|r  %s", pin, KindLabel(entry.kind), entry.title or "Untitled"))
            btn.sub:SetText(string.format("%s · %s", FormatDate(entry.createdAt), entry.zoneName or ""))
            if entry.id == selectedId then
                btn:LockHighlight()
            else
                btn:UnlockHighlight()
            end
            btn:Show()
        else
            btn.entryId = nil
            btn:Hide()
        end
    end
end

local function ShowEntry(entry)
    if not journal or not entry then return end
    selectedId = entry.id
    journal.rightTitle:SetText(entry.title or "Untitled")
    journal.meta:SetText(string.format(
        "%s · %s · %s · %s",
        KindLabel(entry.kind),
        FormatDate(entry.createdAt),
        entry.zoneName or "Unknown lands",
        InCharacter.YearCalendar.FormatYear(entry.yearKC)
    ))
    journal.bodyEdit:SetText(entry.body or "")
    journal.titleEdit:SetText(entry.title or "")
    if presentationMode then
        journal.bodyEdit:SetTextColor(0.15, 0.10, 0.05)
        journal.bodyEdit:Disable()
        journal.titleEdit:Disable()
        journal.editHint:SetText("Presentation — reading the open page")
    else
        journal.bodyEdit:Enable()
        journal.titleEdit:Enable()
        journal.editHint:SetText("Edit the ink, then press Save page")
    end
    RefreshList()
end

local function SaveSelected()
    if not selectedId then return end
    InCharacter.Chronicle.Store.Update(selectedId, {
        title = journal.titleEdit:GetText() or "",
        body = journal.bodyEdit:GetText() or "",
    })
    local entry = InCharacter.Chronicle.Store.GetById(selectedId)
    if entry then
        ShowEntry(entry)
        InCharacter.UI.Theme.Toast("Page saved to the journal.")
    end
end

local function BuildManualDialog()
    local f = CreateFrame("Frame", "InCharacterManualEntry", UIParent, "BackdropTemplate")
    f:SetSize(420, 260)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    InCharacter.UI.Theme.ApplyParchmentBackdrop(f, 0.98)
    f:Hide()
    tinsert(UISpecialFrames, "InCharacterManualEntry")

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -16)
    title:SetText("New journal note")
    InCharacter.UI.Theme.GoldTitle(title)

    local tl = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    tl:SetPoint("TOPLEFT", 20, -48)
    tl:SetText("Heading")
    InCharacter.UI.Theme.InkFont(tl)

    f.titleBox = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
    f.titleBox:SetSize(360, 24)
    f.titleBox:SetPoint("TOPLEFT", 24, -68)
    f.titleBox:SetAutoFocus(false)

    local bl = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    bl:SetPoint("TOPLEFT", 20, -100)
    bl:SetText("What happened (in-character)")
    InCharacter.UI.Theme.InkFont(bl)

    f.bodyBox = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
    f.bodyBox:SetSize(360, 70)
    f.bodyBox:SetMultiLine(true)
    f.bodyBox:SetPoint("TOPLEFT", 24, -120)
    f.bodyBox:SetAutoFocus(false)

    local save = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    save:SetSize(100, 24)
    save:SetPoint("BOTTOMRIGHT", -20, 16)
    save:SetText("Inscribe")
    save:SetScript("OnClick", function()
        local t = f.titleBox:GetText() or "Note"
        local b = f.bodyBox:GetText() or ""
        local entry = InCharacter.Chronicle.Capture.AddManual(t, b, "MANUAL")
        -- For manual, prefer player's body over template if they wrote one
        if b ~= "" then
            InCharacter.Chronicle.Store.Update(entry.id, { title = t, body = b })
        end
        f:Hide()
        InCharacter.Chronicle.UI.Refresh()
        if entry then
            ShowEntry(InCharacter.Chronicle.Store.GetById(entry.id) or entry)
        end
    end)

    local cancel = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    cancel:SetSize(80, 24)
    cancel:SetPoint("RIGHT", save, "LEFT", -8, 0)
    cancel:SetText("Close")
    cancel:SetScript("OnClick", function() f:Hide() end)

    journal.manualDialog = f
end

local function BuildUI()
    journal = InCharacter.UI.JournalFrame.Create("InCharacterJournal", "Traveler's Chronicle")
    journal:SetSubtitle("Quests, feats, titles, craft — a story told in order")

    -- Search
    journal.searchBox = CreateFrame("EditBox", nil, journal.leftHost, "InputBoxTemplate")
    journal.searchBox:SetSize(160, 20)
    journal.searchBox:SetPoint("TOPLEFT", 10, -28)
    journal.searchBox:SetAutoFocus(false)
    journal.searchBox:SetScript("OnTextChanged", function(self)
        searchText = self:GetText() or ""
        RefreshList()
    end)

    journal.listCount = journal.leftHost:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    journal.listCount:SetPoint("LEFT", journal.searchBox, "RIGHT", 8, 0)
    journal.listCount:SetText("0 entries")

    -- Sort toggle
    local sortBtn = CreateFrame("Button", nil, journal.leftHost, "UIPanelButtonTemplate")
    sortBtn:SetSize(70, 20)
    sortBtn:SetPoint("TOPRIGHT", -8, -28)
    sortBtn:SetText("Newest")
    sortBtn:SetScript("OnClick", function(self)
        oldestFirst = not oldestFirst
        self:SetText(oldestFirst and "Oldest" or "Newest")
        RefreshList()
    end)

    -- Scrollable-looking list of rows
    local listTop = -54
    for i = 1, MAX_ROWS do
        local btn = CreateFrame("Button", nil, journal.leftHost)
        btn:SetSize(240, 28)
        btn:SetPoint("TOPLEFT", 8, listTop - (i - 1) * 28)
        btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")

        btn.label = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        btn.label:SetPoint("TOPLEFT", 4, -2)
        btn.label:SetPoint("TOPRIGHT", -4, -2)
        btn.label:SetJustifyH("LEFT")
        InCharacter.UI.Theme.InkFont(btn.label)

        btn.sub = btn:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        btn.sub:SetPoint("TOPLEFT", 4, -14)
        btn.sub:SetJustifyH("LEFT")

        btn:SetScript("OnClick", function(self)
            if self.entryId then
                local entry = InCharacter.Chronicle.Store.GetById(self.entryId)
                if entry then ShowEntry(entry) end
            end
        end)
        entryButtons[i] = btn
    end

    -- Right page content
    journal.meta = journal.rightHost:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    journal.meta:SetPoint("TOPLEFT", 12, -28)
    journal.meta:SetPoint("TOPRIGHT", -12, -28)
    journal.meta:SetJustifyH("LEFT")
    journal.meta:SetText("")

    journal.titleEdit = CreateFrame("EditBox", nil, journal.rightHost, "InputBoxTemplate")
    journal.titleEdit:SetPoint("TOPLEFT", 16, -50)
    journal.titleEdit:SetPoint("TOPRIGHT", -16, -50)
    journal.titleEdit:SetHeight(22)
    journal.titleEdit:SetAutoFocus(false)

    journal.editHint = journal.rightHost:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    journal.editHint:SetPoint("TOPLEFT", 16, -76)
    journal.editHint:SetText("Edit the ink, then press Save page")

    -- Multiline body
    local bodyScroll = CreateFrame("ScrollFrame", "InCharacterJournalBodyScroll", journal.rightHost, "UIPanelScrollFrameTemplate")
    bodyScroll:SetPoint("TOPLEFT", 12, -96)
    bodyScroll:SetPoint("BOTTOMRIGHT", -32, 48)

    journal.bodyEdit = CreateFrame("EditBox", nil, bodyScroll)
    journal.bodyEdit:SetMultiLine(true)
    journal.bodyEdit:SetFontObject(GameFontHighlight)
    journal.bodyEdit:SetWidth(420)
    journal.bodyEdit:SetAutoFocus(false)
    journal.bodyEdit:SetTextInsets(4, 4, 4, 4)
    journal.bodyEdit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    InCharacter.UI.Theme.InkFont(journal.bodyEdit)
    bodyScroll:SetScrollChild(journal.bodyEdit)
    journal.bodyEdit:SetHeight(400)

    -- Footer buttons
    local function FooterButton(text, xOff, onClick)
        local b = CreateFrame("Button", nil, journal.footer, "UIPanelButtonTemplate")
        b:SetSize(90, 24)
        b:SetPoint("RIGHT", journal.footer, "RIGHT", xOff, 0)
        b:SetText(text)
        b:SetScript("OnClick", onClick)
        return b
    end

    FooterButton("Save page", 0, SaveSelected)
    FooterButton("Regenerate", -96, function()
        if not selectedId then return end
        local entry = InCharacter.Chronicle.Store.GetById(selectedId)
        if entry then
            InCharacter.Chronicle.Hooks.Regenerate(entry)
            ShowEntry(entry)
            InCharacter.UI.Theme.Toast("The page was rewritten from the template.")
        end
    end)
    FooterButton("Pin", -192, function()
        if not selectedId then return end
        local entry = InCharacter.Chronicle.Store.GetById(selectedId)
        if entry then
            entry.pinned = not entry.pinned
            RefreshList()
            ShowEntry(entry)
        end
    end)
    FooterButton("Delete", -288, function()
        if not selectedId then return end
        StaticPopup_Show("INCHARACTER_DELETE_ENTRY", nil, nil, selectedId)
    end)
    FooterButton("Add note", -384, function()
        if journal.manualDialog then
            journal.manualDialog.titleBox:SetText("")
            journal.manualDialog.bodyBox:SetText("")
            journal.manualDialog:Show()
        end
    end)

    local presentBtn = CreateFrame("Button", nil, journal.footer, "UIPanelButtonTemplate")
    presentBtn:SetSize(110, 24)
    presentBtn:SetPoint("LEFT", journal.footer, "LEFT", 0, 0)
    presentBtn:SetText("Presentation")
    presentBtn:SetScript("OnClick", function(self)
        presentationMode = not presentationMode
        self:SetText(presentationMode and "Edit mode" or "Presentation")
        if selectedId then
            local entry = InCharacter.Chronicle.Store.GetById(selectedId)
            if entry then ShowEntry(entry) end
        end
        if presentationMode then
            journal.leftHost:Hide()
            journal.rightHost:ClearAllPoints()
            journal.rightHost:SetPoint("TOPLEFT", 16, -60)
            journal.rightHost:SetPoint("BOTTOMRIGHT", -16, 48)
        else
            journal.leftHost:Show()
            journal.rightHost:ClearAllPoints()
            journal.rightHost:SetPoint("TOPLEFT", journal.leftHost, "TOPRIGHT", 12, 0)
            journal.rightHost:SetPoint("BOTTOMRIGHT", -16, 48)
        end
    end)

    BuildManualDialog()

    StaticPopupDialogs["INCHARACTER_DELETE_ENTRY"] = {
        text = "Tear this page from the chronicle?",
        button1 = "Tear out",
        button2 = "Keep",
        OnAccept = function(_, id)
            InCharacter.Chronicle.Store.Delete(id)
            selectedId = nil
            journal.rightTitle:SetText("Select an entry")
            journal.meta:SetText("")
            journal.bodyEdit:SetText("")
            journal.titleEdit:SetText("")
            RefreshList()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
end

function InCharacter.Chronicle.UI.Init()
    BuildUI()
end

function InCharacter.Chronicle.UI.Refresh()
    if journal and journal:IsShown() then
        RefreshList()
    end
end

function InCharacter.Chronicle.UI.Toggle()
    if not journal then
        BuildUI()
    end
    if journal:IsShown() then
        journal:Hide()
    else
        RefreshList()
        local list = InCharacter.Chronicle.Store.List({ oldestFirst = oldestFirst })
        if #list > 0 and not selectedId then
            ShowEntry(list[1])
        elseif selectedId then
            local e = InCharacter.Chronicle.Store.GetById(selectedId)
            if e then ShowEntry(e) end
        end
        journal:Show()
    end
end

function InCharacter.Chronicle.UI.Show()
    if not journal then BuildUI() end
    RefreshList()
    journal:Show()
end

function InCharacter.Chronicle.UI.OnNewEntry(entry)
    if journal and journal:IsShown() then
        RefreshList()
        if entry then ShowEntry(entry) end
    end
end