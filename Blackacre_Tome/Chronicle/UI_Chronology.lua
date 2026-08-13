-- Traveler's Chronicle: true book navigation.
-- Spreads: TOC pages first, then one spread per entry. Flip with < > ; TOC bookmark jumps to page 1.
Blackacre = Blackacre or {}
Blackacre.Chronicle = Blackacre.Chronicle or {}
Blackacre.Chronicle.UI = {}

local journal
local selectedId
local oldestFirst = true -- chronological order default
local filterKind = nil
local searchText = ""
local presentationMode = false
local journalMode = false

-- Book model
local spreads = {} -- { type="toc"|"entry", ... }
local spreadIndex = 1
local TOC_LINES_PER_PAGE = 11 -- per leaf; two leaves per TOC spread

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

local function White(fs)
    if fs and fs.SetTextColor then fs:SetTextColor(1, 1, 1, 1) end
end

local function FormatEntryYear(entry)
    local y = entry and (entry.yearKC or entry.yearADP)
    if Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.FormatFactionYear then
        return Blackacre.UI.Theme.FormatFactionYear(y)
    end
    return tostring(y or "")
end

local function GetEntryList()
    return Blackacre.Chronicle.Store.List({
        kind = filterKind,
        search = searchText,
        oldestFirst = oldestFirst,
    })
end

--- Build spreads: TOC pages then entry pages. Page numbers are 1-based spreads.
local function RebuildSpreads()
    spreads = {}
    local list = GetEntryList()
    local perSpread = TOC_LINES_PER_PAGE * 2
    if #list == 0 then
        spreads[1] = { type = "toc", startIndex = 1, entries = {} }
    else
        local i = 1
        while i <= #list do
            local chunk = {}
            for j = i, math.min(i + perSpread - 1, #list) do
                chunk[#chunk + 1] = { entry = list[j], listIndex = j }
            end
            spreads[#spreads + 1] = { type = "toc", startIndex = i, entries = chunk }
            i = i + perSpread
        end
        for j = 1, #list do
            spreads[#spreads + 1] = { type = "entry", entry = list[j], listIndex = j }
        end
    end
    -- Map entry id -> first entry spread index for TOC jumps
    for si = 1, #spreads do
        local s = spreads[si]
        if s.type == "entry" and s.entry then
            s.entry._baSpreadIndex = si
        end
    end
end

local function ClearLeaf(leaf)
    if not leaf then return end
    if leaf._baKids then
        for _, k in ipairs(leaf._baKids) do
            if k.Hide then k:Hide() end
            if k.SetParent then k:SetParent(nil) end
        end
    end
    leaf._baKids = {}
end

local function AddKid(leaf, kid)
    leaf._baKids = leaf._baKids or {}
    leaf._baKids[#leaf._baKids + 1] = kid
    return kid
end

local function SetPageLabel()
    local hub = Blackacre.TomeHub and Blackacre.TomeHub.GetFrame and Blackacre.TomeHub.GetFrame()
    if hub and hub.pageLabel then
        hub.pageLabel:SetText(string.format("%d / %d", spreadIndex, math.max(1, #spreads)))
        White(hub.pageLabel)
    end
end

local function JumpToEntrySpread(entryId)
    RebuildSpreads()
    for i = 1, #spreads do
        local s = spreads[i]
        if s.type == "entry" and s.entry and s.entry.id == entryId then
            spreadIndex = i
            Blackacre.Chronicle.UI.RenderSpread()
            return
        end
    end
end

local function RenderTocLeaf(leaf, items, pageSideLabel)
    ClearLeaf(leaf)
    local title = leaf:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -14)
    title:SetText("Table of Contents")
    title:SetTextColor(1, 0.9, 0.55, 1)
    AddKid(leaf, title)

    local sub = leaf:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    sub:SetPoint("TOPLEFT", 16, -38)
    sub:SetText(pageSideLabel or "")
    White(sub)
    Blackacre.UI.Theme.ApplyReadableBodyFont(sub, -1)
    AddKid(leaf, sub)

    local y = -64
    for _, row in ipairs(items) do
        local e = row.entry
        local btn = CreateFrame("Button", nil, leaf)
        btn:SetSize(math.max(120, (leaf:GetWidth() or 300) - 28), 28)
        btn:SetPoint("TOPLEFT", 14, y)
        btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
        local label = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        label:SetPoint("LEFT", 4, 0)
        label:SetPoint("RIGHT", -4, 0)
        label:SetJustifyH("LEFT")
        -- TOC line: page number (entry spread) · year · title
        local pageNum = e._baSpreadIndex or "?"
        local yearStr = FormatEntryYear(e)
        label:SetText(string.format("%s.  %s  ·  %s", tostring(pageNum), yearStr, e.title or "Untitled"))
        White(label)
        Blackacre.UI.Theme.ApplyReadableBodyFont(label, 0)
        btn:SetScript("OnClick", function()
            selectedId = e.id
            JumpToEntrySpread(e.id)
        end)
        AddKid(leaf, btn)
        y = y - 30
    end
end

local function RenderEntrySpread(left, right, entry)
    ClearLeaf(left)
    ClearLeaf(right)
    selectedId = entry.id

    local title = left:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetPoint("TOPRIGHT", -16, -16)
    title:SetJustifyH("LEFT")
    title:SetText(entry.title or "Untitled")
    title:SetTextColor(1, 0.9, 0.55, 1)
    AddKid(left, title)

    local meta = left:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    meta:SetPoint("TOPLEFT", 16, -48)
    meta:SetPoint("TOPRIGHT", -16, -48)
    meta:SetJustifyH("LEFT")
    meta:SetText(string.format(
        "%s\n%s\n%s",
        KindLabel(entry.kind),
        entry.zoneName or "Unknown lands",
        FormatEntryYear(entry)
    ))
    White(meta)
    Blackacre.UI.Theme.ApplyReadableBodyFont(meta, 0)
    AddKid(left, meta)

    -- Title edit (journal mode)
    local titleEdit = CreateFrame("EditBox", nil, left, "InputBoxTemplate")
    titleEdit:SetPoint("TOPLEFT", 16, -16)
    titleEdit:SetPoint("TOPRIGHT", -16, -16)
    titleEdit:SetHeight(24)
    titleEdit:SetAutoFocus(false)
    titleEdit:SetText(entry.title or "")
    titleEdit:Hide()
    AddKid(left, titleEdit)
    journal.titleEdit = titleEdit

    if journalMode and not presentationMode then
        title:Hide()
        titleEdit:Show()
        titleEdit:Enable()
    end

    -- Right: body
    local hint = right:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    hint:SetPoint("TOPLEFT", 16, -12)
    hint:SetText(journalMode and "Edit ink, then Save in the tools bar below." or "Turn Journal: On below to edit this page.")
    White(hint)
    Blackacre.UI.Theme.ApplyReadableBodyFont(hint, -1)
    AddKid(right, hint)
    journal.editHint = hint

    local bodyScroll = CreateFrame("ScrollFrame", nil, right, "UIPanelScrollFrameTemplate")
    bodyScroll:SetPoint("TOPLEFT", 12, -36)
    bodyScroll:SetPoint("BOTTOMRIGHT", -28, 12)
    AddKid(right, bodyScroll)

    local bodyEdit = CreateFrame("EditBox", nil, bodyScroll)
    bodyEdit:SetMultiLine(true)
    bodyEdit:SetAutoFocus(false)
    bodyEdit:SetTextInsets(6, 6, 6, 6)
    bodyEdit:SetText(entry.body or "")
    bodyEdit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    Blackacre.UI.Theme.ApplyReadableBodyFont(bodyEdit, 2)
    White(bodyEdit)
    if bodyEdit.SetShadowColor then bodyEdit:SetShadowColor(0, 0, 0, 0.4) end
    bodyScroll:SetScrollChild(bodyEdit)
    local w = bodyScroll:GetWidth()
    bodyEdit:SetWidth((w and w > 40) and (w - 8) or 340)
    bodyEdit:SetHeight(420)
    if journalMode and not presentationMode then
        bodyEdit:Enable()
    else
        bodyEdit:Disable()
    end
    journal.bodyEdit = bodyEdit
    journal.bodyScroll = bodyScroll
    journal.rightTitle = title
end

function Blackacre.Chronicle.UI.RenderSpread()
    if not journal then return end
    RebuildSpreads()
    if spreadIndex < 1 then spreadIndex = 1 end
    if spreadIndex > #spreads then spreadIndex = #spreads end
    local s = spreads[spreadIndex] or { type = "toc", entries = {} }

    local left = journal.leftHost
    local right = journal.rightHost
    if not left or not right then return end

    if s.type == "toc" then
        local leftItems, rightItems = {}, {}
        for i, row in ipairs(s.entries or {}) do
            if i <= TOC_LINES_PER_PAGE then
                leftItems[#leftItems + 1] = row
            else
                rightItems[#rightItems + 1] = row
            end
        end
        RenderTocLeaf(left, leftItems, "Contents")
        RenderTocLeaf(right, rightItems, (#rightItems > 0) and "Contents (cont.)" or "")
        journal.bodyEdit = nil
        journal.titleEdit = nil
    else
        RenderEntrySpread(left, right, s.entry)
    end
    SetPageLabel()
end

local function SaveSelected()
    if not journal then return end
    local s = spreads[spreadIndex]
    if not s or s.type ~= "entry" or not s.entry then
        if Blackacre.UI and Blackacre.UI.Theme then
            Blackacre.UI.Theme.Toast("Open an entry page to save (not the TOC).")
        end
        return
    end
    if journal.bodyEdit then journal.bodyEdit:ClearFocus() end
    if journal.titleEdit then journal.titleEdit:ClearFocus() end
    local titleText = (journal.titleEdit and journal.titleEdit:IsShown()) and (journal.titleEdit:GetText() or "") or (s.entry.title or "")
    local bodyText = journal.bodyEdit and journal.bodyEdit:GetText() or (s.entry.body or "")
    local entry = Blackacre.Chronicle.Store.Update(s.entry.id, {
        title = titleText,
        body = bodyText,
    })
    if entry then
        if Blackacre.UI and Blackacre.UI.Theme then
            Blackacre.UI.Theme.Toast("Page saved to the journal.")
        end
        Blackacre.Chronicle.UI.RenderSpread()
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

    f.titleBox = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
    f.titleBox:SetSize(360, 24)
    f.titleBox:SetPoint("TOPLEFT", 24, -68)
    f.titleBox:SetAutoFocus(false)

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
        if entry and b ~= "" then
            Blackacre.Chronicle.Store.Update(entry.id, { title = t, body = b })
        end
        f:Hide()
        Blackacre.Chronicle.UI.Refresh()
        if entry then
            JumpToEntrySpread(entry.id)
        end
    end)

    local cancel = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    cancel:SetSize(80, 24)
    cancel:SetPoint("RIGHT", save, "LEFT", -8, 0)
    cancel:SetText("Close")
    cancel:SetScript("OnClick", function() f:Hide() end)

    journal.manualDialog = f
end

local function MountToolsOnParentFooter()
    local hub = Blackacre.TomeHub and Blackacre.TomeHub.GetFrame and Blackacre.TomeHub.GetFrame()
    if not hub or not hub.toolStrip then return end
    local strip = hub.toolStrip
    -- Clear previous
    if strip._baBuilt then return end
    strip._baBuilt = true

    local function ToolBtn(text, x, onClick)
        local b = CreateFrame("Button", nil, strip, "UIPanelButtonTemplate")
        b:SetSize(88, 24)
        b:SetPoint("LEFT", strip, "LEFT", x, 0)
        b:SetText(text)
        b:SetScript("OnClick", onClick)
        return b
    end

    ToolBtn("Save", 0, SaveSelected)
    ToolBtn("Add note", 96, function()
        if journal.manualDialog then
            journal.manualDialog.titleBox:SetText("")
            journal.manualDialog.bodyBox:SetText("")
            journal.manualDialog:Show()
        end
    end)
    ToolBtn("Pin", 192, function()
        local s = spreads[spreadIndex]
        if not s or s.type ~= "entry" or not s.entry then return end
        s.entry.pinned = not s.entry.pinned
        Blackacre.Chronicle.UI.RenderSpread()
    end)
    ToolBtn("Delete", 288, function()
        local s = spreads[spreadIndex]
        if not s or s.type ~= "entry" or not s.entry then return end
        StaticPopup_Show("Blackacre_DELETE_ENTRY", nil, nil, s.entry.id)
    end)
end

local function BuildUI()
    local tocParent = Blackacre.TomeHub and Blackacre.TomeHub.GetChronicleTocParent and Blackacre.TomeHub.GetChronicleTocParent()
    local pageParent = Blackacre.TomeHub and Blackacre.TomeHub.GetChroniclePageParent and Blackacre.TomeHub.GetChroniclePageParent()
    local parent = Blackacre.TomeHub and Blackacre.TomeHub.GetChronicleParent and Blackacre.TomeHub.GetChronicleParent()

    journal = {
        leftHost = tocParent,
        rightHost = pageParent,
        _baJournalMode = false,
    }

    -- If hosts missing (standalone), create fallback
    if not journal.leftHost or not journal.rightHost then
        local f = CreateFrame("Frame", "BlackacreJournalFallback", UIParent, "BackdropTemplate")
        f:SetSize(800, 500)
        f:SetPoint("CENTER")
        f:Hide()
        journal.leftHost = CreateFrame("Frame", nil, f)
        journal.leftHost:SetPoint("TOPLEFT", 10, -10)
        journal.leftHost:SetPoint("BOTTOMRIGHT", f, "BOTTOM", -10, 10)
        journal.rightHost = CreateFrame("Frame", nil, f)
        journal.rightHost:SetPoint("TOPLEFT", f, "TOP", 10, -10)
        journal.rightHost:SetPoint("BOTTOMRIGHT", -10, 10)
        journal._fallback = f
    end

    BuildManualDialog()
    MountToolsOnParentFooter()

    StaticPopupDialogs["Blackacre_DELETE_ENTRY"] = {
        text = "Tear this page from the chronicle?",
        button1 = "Tear out",
        button2 = "Keep",
        OnAccept = function(_, id)
            Blackacre.Chronicle.Store.Delete(id)
            selectedId = nil
            Blackacre.Chronicle.UI.GoToToc()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
end

function Blackacre.Chronicle.UI.EnsureBuilt()
    if not journal then BuildUI() end
    return journal
end

function Blackacre.Chronicle.UI.Init()
end

function Blackacre.Chronicle.UI.OnHubShow()
    Blackacre.Chronicle.UI.EnsureBuilt()
    MountToolsOnParentFooter()
    RebuildSpreads()
    if spreadIndex < 1 or spreadIndex > #spreads then
        spreadIndex = 1
    end
    Blackacre.Chronicle.UI.RenderSpread()
end

function Blackacre.Chronicle.UI.Refresh()
    if journal then
        Blackacre.Chronicle.UI.RenderSpread()
    end
end

function Blackacre.Chronicle.UI.GoToToc()
    Blackacre.Chronicle.UI.EnsureBuilt()
    RebuildSpreads()
    spreadIndex = 1
    Blackacre.Chronicle.UI.RenderSpread()
end

function Blackacre.Chronicle.UI.TurnPage(delta)
    Blackacre.Chronicle.UI.EnsureBuilt()
    RebuildSpreads()
    spreadIndex = spreadIndex + (delta or 1)
    if spreadIndex < 1 then spreadIndex = 1 end
    if spreadIndex > #spreads then spreadIndex = #spreads end
    Blackacre.Chronicle.UI.RenderSpread()
end

function Blackacre.Chronicle.UI.SetJournalMode(on)
    journalMode = on and true or false
    if journal then
        journal._baJournalMode = journalMode
        Blackacre.Chronicle.UI.RenderSpread()
    end
end

function Blackacre.Chronicle.UI.Toggle()
    if Blackacre.TomeHub and Blackacre.TomeHub.Toggle then
        Blackacre.TomeHub.Toggle("chronicle")
        return
    end
end

function Blackacre.Chronicle.UI.Show()
    if Blackacre.TomeHub and Blackacre.TomeHub.Show then
        Blackacre.TomeHub.Show("chronicle")
    end
end

function Blackacre.Chronicle.UI.OnNewEntry(entry)
    if entry then
        JumpToEntrySpread(entry.id)
    elseif journal then
        Blackacre.Chronicle.UI.RenderSpread()
    end
end
