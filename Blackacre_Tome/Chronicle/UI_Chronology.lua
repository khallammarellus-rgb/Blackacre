Blackacre = Blackacre or {}
Blackacre.Chronicle = Blackacre.Chronicle or {}
Blackacre.Chronicle.UI = {}

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
    DEATH = "Death",
    HC_ENCUMBRANCE = "Burden",
    HC_MOUNT = "Mount",
    HC_FLY = "Sky",
    SURVIVAL = "Survival",
    AFTERLIFE = "Afterlife",
    ROADMAP = "Road",
    PVP = "Field",
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
    local list = Blackacre.Chronicle.Store.List({
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
    -- Single title line on right page (avoid double/fuzzy stack)
    if journal.rightTitle then
        journal.rightTitle:SetText(entry.title or "Untitled")
        journal.rightTitle:Show()
    end
    if journal.meta then
        journal.meta:SetText(string.format(
            "%s · %s · %s · %s",
            KindLabel(entry.kind),
            FormatDate(entry.createdAt),
            entry.zoneName or "Unknown lands",
            Blackacre.YearCalendar and Blackacre.YearCalendar.FormatYear and Blackacre.YearCalendar.FormatYear(entry.yearKC) or ""
        ))
    end
    if journal.titleEdit then
        journal.titleEdit:SetText(entry.title or "")
        -- Hide title edit under the display title unless journaling mode
        if journal._baJournalMode then
            journal.titleEdit:Show()
            journal.rightTitle:Hide()
        else
            journal.titleEdit:Hide()
            journal.rightTitle:Show()
        end
    end
    if journal.bodyEdit then
        journal.bodyEdit:SetText(entry.body or "")
        -- Prevent "doubled" look: no shadow layer, solid ink only
        journal.bodyEdit:SetTextColor(0.15, 0.10, 0.05, 1)
        if journal.bodyEdit.SetShadowColor then
            journal.bodyEdit:SetShadowColor(0, 0, 0, 0)
        end
    end
    if presentationMode then
        if journal.bodyEdit then journal.bodyEdit:Disable() end
        if journal.titleEdit then journal.titleEdit:Disable() end
        if journal.editHint then journal.editHint:SetText("Presentation — reading the open page") end
    else
        if journal.bodyEdit then
            if journal._baJournalMode then journal.bodyEdit:Enable() else journal.bodyEdit:Disable() end
        end
        if journal.titleEdit then
            if journal._baJournalMode then journal.titleEdit:Enable() else journal.titleEdit:Disable() end
        end
        if journal.editHint then
            journal.editHint:SetText(journal._baJournalMode and "Edit, then press Save page" or "Turn Journal: On in the footer to edit")
        end
    end
    RefreshList()
end

local function SaveSelected()
    if not journal then return end
    if not selectedId then
        if Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.Toast then
            Blackacre.UI.Theme.Toast("Select a page in the contents first.")
        elseif Blackacre.Print then
            Blackacre.Print("Select a page in the contents first.")
        end
        return
    end
    if journal.bodyEdit then journal.bodyEdit:ClearFocus() end
    if journal.titleEdit then journal.titleEdit:ClearFocus() end
    local titleText = journal.titleEdit and journal.titleEdit:GetText() or ""
    local bodyText = journal.bodyEdit and journal.bodyEdit:GetText() or ""
    local entry = Blackacre.Chronicle.Store.Update(selectedId, {
        title = titleText,
        body = bodyText,
    })
    if entry then
        ShowEntry(entry)
        if Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.Toast then
            Blackacre.UI.Theme.Toast("Page saved to the journal.")
        elseif Blackacre.Print then
            Blackacre.Print("Page saved.")
        end
    else
        if Blackacre.Print then
            Blackacre.Print("Could not save — entry missing.")
        end
    end
end

local function BuildManualDialog()
    local f = CreateFrame("Frame", "BlackacreManualEntry", UIParent, "BackdropTemplate")
    f:SetSize(420, 260)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    Blackacre.UI.Theme.ApplyParchmentBackdrop(f, 0.98)
    f:Hide()
    tinsert(UISpecialFrames, "BlackacreManualEntry")

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -16)
    title:SetText("New journal note")
    Blackacre.UI.Theme.GoldTitle(title)

    local tl = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    tl:SetPoint("TOPLEFT", 20, -48)
    tl:SetText("Heading")
    Blackacre.UI.Theme.InkFont(tl)

    f.titleBox = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
    f.titleBox:SetSize(360, 24)
    f.titleBox:SetPoint("TOPLEFT", 24, -68)
    f.titleBox:SetAutoFocus(false)

    local bl = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    bl:SetPoint("TOPLEFT", 20, -100)
    bl:SetText("What happened (in-character)")
    Blackacre.UI.Theme.InkFont(bl)

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
        local entry = Blackacre.Chronicle.Capture.AddManual(t, b, "MANUAL")
        -- For manual, prefer player's body over template if they wrote one
        if b ~= "" then
            Blackacre.Chronicle.Store.Update(entry.id, { title = t, body = b })
        end
        f:Hide()
        Blackacre.Chronicle.UI.Refresh()
        if entry then
            ShowEntry(Blackacre.Chronicle.Store.GetById(entry.id) or entry)
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
    local parent, tocParent, pageParent
    local embedded = false
    if Blackacre.TomeHub then
        if Blackacre.TomeHub.GetChronicleParent then
            parent = Blackacre.TomeHub.GetChronicleParent()
            embedded = parent ~= nil
        end
        if Blackacre.TomeHub.GetChronicleTocParent then
            tocParent = Blackacre.TomeHub.GetChronicleTocParent()
        end
        if Blackacre.TomeHub.GetChroniclePageParent then
            pageParent = Blackacre.TomeHub.GetChroniclePageParent()
        end
    end
    journal = Blackacre.UI.JournalFrame.Create("BlackacreJournal", "Table of Contents", {
        parent = parent or UIParent,
        embedded = embedded,
        tocParent = tocParent,
        pageParent = pageParent,
    })
    journal:SetSubtitle("Search or choose a page — read on the right leaf.")
    journal:Show()
    journal._baJournalMode = false

    -- Search (TOC)
    journal.searchBox = CreateFrame("EditBox", nil, journal.leftHost, "InputBoxTemplate")
    journal.searchBox:SetSize(150, 22)
    journal.searchBox:SetPoint("TOPLEFT", 14, -58)
    journal.searchBox:SetAutoFocus(false)
    journal.searchBox:SetScript("OnTextChanged", function(self)
        searchText = self:GetText() or ""
        RefreshList()
    end)

    journal.listCount = journal.leftHost:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    journal.listCount:SetPoint("LEFT", journal.searchBox, "RIGHT", 8, 0)
    journal.listCount:SetText("0 entries")
    Blackacre.UI.Theme.ApplyMailBodyFont(journal.listCount, -1)

    -- Sort toggle
    local sortBtn = CreateFrame("Button", nil, journal.leftHost, "UIPanelButtonTemplate")
    sortBtn:SetSize(72, 22)
    sortBtn:SetPoint("TOPRIGHT", -12, -58)
    sortBtn:SetText("Newest")
    sortBtn:SetScript("OnClick", function(self)
        oldestFirst = not oldestFirst
        self:SetText(oldestFirst and "Oldest" or "Newest")
        RefreshList()
    end)

    -- TOC rows (table of contents on left page)
    local listTop = -90
    for i = 1, MAX_ROWS do
        local btn = CreateFrame("Button", nil, journal.leftHost)
        btn:SetSize(220, 30)
        btn:SetPoint("TOPLEFT", 12, listTop - (i - 1) * 32)
        btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")

        btn.label = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        btn.label:SetPoint("TOPLEFT", 4, -2)
        btn.label:SetPoint("TOPRIGHT", -4, -2)
        btn.label:SetJustifyH("LEFT")
        Blackacre.UI.Theme.ApplyMailBodyFont(btn.label, 0)

        btn.sub = btn:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        btn.sub:SetPoint("TOPLEFT", 4, -16)
        btn.sub:SetJustifyH("LEFT")

        btn:SetScript("OnClick", function(self)
            if self.entryId then
                local entry = Blackacre.Chronicle.Store.GetById(self.entryId)
                if entry then ShowEntry(entry) end
            end
        end)
        entryButtons[i] = btn
    end

    -- Right page content (single display title; edit boxes when journaling)
    journal.meta = journal.rightHost:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    journal.meta:SetPoint("TOPLEFT", 16, -36)
    journal.meta:SetPoint("TOPRIGHT", -16, -36)
    journal.meta:SetJustifyH("LEFT")
    journal.meta:SetText("")
    Blackacre.UI.Theme.ApplyMailBodyFont(journal.meta, -1)

    journal.titleEdit = CreateFrame("EditBox", nil, journal.rightHost, "InputBoxTemplate")
    journal.titleEdit:SetPoint("TOPLEFT", 16, -12)
    journal.titleEdit:SetPoint("TOPRIGHT", -16, -12)
    journal.titleEdit:SetHeight(24)
    journal.titleEdit:SetAutoFocus(false)
    journal.titleEdit:Hide()

    journal.editHint = journal.rightHost:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    journal.editHint:SetPoint("TOPLEFT", 16, -56)
    journal.editHint:SetText("Turn Journal: On in the footer to edit")
    Blackacre.UI.Theme.ApplyMailBodyFont(journal.editHint, -1)

    -- Multiline body — mail-like font; no double draw
    local bodyScroll = CreateFrame("ScrollFrame", "BlackacreJournalBodyScroll", journal.rightHost, "UIPanelScrollFrameTemplate")
    bodyScroll:SetPoint("TOPLEFT", 14, -78)
    bodyScroll:SetPoint("BOTTOMRIGHT", -28, 44)

    journal.bodyEdit = CreateFrame("EditBox", nil, bodyScroll)
    journal.bodyEdit:SetMultiLine(true)
    journal.bodyEdit:SetAutoFocus(false)
    journal.bodyEdit:SetTextInsets(6, 6, 6, 6)
    journal.bodyEdit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    journal.bodyEdit:SetScript("OnCursorChanged", function(self, x, y, w, h)
        -- Keep caret visible in scroll frame
        local offset = bodyScroll:GetVerticalScroll()
        local height = bodyScroll:GetHeight()
        if y > 0 then
            bodyScroll:SetVerticalScroll(offset - y)
        elseif (-y + h) > height then
            bodyScroll:SetVerticalScroll(offset + ((-y + h) - height))
        end
    end)
    Blackacre.UI.Theme.ApplyMailBodyFont(journal.bodyEdit, 2)
    journal.bodyEdit:SetTextColor(0.15, 0.10, 0.05, 1)
    if journal.bodyEdit.SetShadowColor then
        journal.bodyEdit:SetShadowColor(0, 0, 0, 0)
    end
    bodyScroll:SetScrollChild(journal.bodyEdit)
    local function SizeBody()
        local w = bodyScroll:GetWidth()
        if w and w > 50 then
            journal.bodyEdit:SetWidth(w - 8)
        else
            journal.bodyEdit:SetWidth(360)
        end
        journal.bodyEdit:SetHeight(math.max(400, bodyScroll:GetHeight() or 400))
    end
    bodyScroll:SetScript("OnSizeChanged", SizeBody)
    SizeBody()
    journal.bodyEdit:Disable()
    journal.bodyScroll = bodyScroll

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
        local entry = Blackacre.Chronicle.Store.GetById(selectedId)
        if entry then
            Blackacre.Chronicle.Hooks.Regenerate(entry)
            ShowEntry(entry)
            Blackacre.UI.Theme.Toast("The page was rewritten from the template.")
        end
    end)
    FooterButton("Pin", -192, function()
        if not selectedId then return end
        local entry = Blackacre.Chronicle.Store.GetById(selectedId)
        if entry then
            entry.pinned = not entry.pinned
            RefreshList()
            ShowEntry(entry)
        end
    end)
    FooterButton("Delete", -288, function()
        if not selectedId then return end
        StaticPopup_Show("Blackacre_DELETE_ENTRY", nil, nil, selectedId)
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
            local entry = Blackacre.Chronicle.Store.GetById(selectedId)
            if entry then ShowEntry(entry) end
        end
        local sp = journal._icSidePad or 10
        local tp = journal._icTopPad or 22
        local bp = journal._icBottomPad or 40
        if presentationMode then
            journal.leftHost:Hide()
            journal.rightHost:ClearAllPoints()
            journal.rightHost:SetPoint("TOPLEFT", sp, -tp)
            journal.rightHost:SetPoint("BOTTOMRIGHT", -sp, bp)
        else
            journal.leftHost:Show()
            journal.rightHost:ClearAllPoints()
            journal.rightHost:SetPoint("TOPLEFT", journal.leftHost, "TOPRIGHT", 10, 0)
            journal.rightHost:SetPoint("BOTTOMRIGHT", -sp, bp)
        end
    end)

    BuildManualDialog()

    StaticPopupDialogs["Blackacre_DELETE_ENTRY"] = {
        text = "Tear this page from the chronicle?",
        button1 = "Tear out",
        button2 = "Keep",
        OnAccept = function(_, id)
            Blackacre.Chronicle.Store.Delete(id)
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

function Blackacre.Chronicle.UI.EnsureBuilt()
    if not journal then
        BuildUI()
    end
    return journal
end

function Blackacre.Chronicle.UI.Init()
    -- Built on first hub open so TomeHub host exists first.
end

function Blackacre.Chronicle.UI.OnHubShow()
    Blackacre.Chronicle.UI.EnsureBuilt()
    RefreshList()
    local list = Blackacre.Chronicle.Store.List({ oldestFirst = oldestFirst })
    if #list > 0 and not selectedId then
        ShowEntry(list[1])
    elseif selectedId then
        local e = Blackacre.Chronicle.Store.GetById(selectedId)
        if e then ShowEntry(e) end
    end
end

function Blackacre.Chronicle.UI.Refresh()
    if journal then
        RefreshList()
    end
end

function Blackacre.Chronicle.UI.Toggle()
    if Blackacre.TomeHub and Blackacre.TomeHub.Toggle then
        Blackacre.TomeHub.Toggle("chronicle")
        return
    end
    Blackacre.Chronicle.UI.EnsureBuilt()
    if journal:IsShown() then
        journal:Hide()
    else
        Blackacre.Chronicle.UI.OnHubShow()
        journal:Show()
    end
end

function Blackacre.Chronicle.UI.Show()
    if Blackacre.TomeHub and Blackacre.TomeHub.Show then
        Blackacre.TomeHub.Show("chronicle")
        return
    end
    Blackacre.Chronicle.UI.EnsureBuilt()
    Blackacre.Chronicle.UI.OnHubShow()
    journal:Show()
end

function Blackacre.Chronicle.UI.OnNewEntry(entry)
    if journal then
        RefreshList()
        if entry and Blackacre.TomeHub and Blackacre.TomeHub.IsShown and Blackacre.TomeHub.IsShown() then
            ShowEntry(entry)
        end
    end
end

function Blackacre.Chronicle.UI.SetJournalMode(on)
    if not journal then
        Blackacre.Chronicle.UI.EnsureBuilt()
    end
    journal._baJournalMode = on and true or false
    if selectedId then
        local e = Blackacre.Chronicle.Store.GetById(selectedId)
        if e then ShowEntry(e) end
    else
        if journal.editHint then
            journal.editHint:SetText(on and "Select a page, edit, then Save" or "Turn Journal: On in the footer to edit")
        end
        if journal.titleEdit then
            if on then journal.titleEdit:Show() else journal.titleEdit:Hide() end
        end
        if journal.rightTitle then
            if on then journal.rightTitle:Hide() else journal.rightTitle:Show() end
        end
        if journal.bodyEdit then
            if on then journal.bodyEdit:Enable() else journal.bodyEdit:Disable() end
        end
    end
end

--- Flip to previous/next entry in the current TOC list (book page arrows).
function Blackacre.Chronicle.UI.TurnPage(delta)
    delta = delta or 1
    Blackacre.Chronicle.UI.EnsureBuilt()
    local list = Blackacre.Chronicle.Store.List({
        kind = filterKind,
        search = searchText,
        oldestFirst = oldestFirst,
    })
    if #list == 0 then return end
    local idx = 1
    if selectedId then
        for i = 1, #list do
            if list[i].id == selectedId then
                idx = i
                break
            end
        end
    end
    idx = idx + delta
    if idx < 1 then idx = 1 end
    if idx > #list then idx = #list end
    ShowEntry(list[idx])
end