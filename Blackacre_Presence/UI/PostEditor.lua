Blackacre = Blackacre or {}
Blackacre.PostEditor = {}

local beaconFrame
local bulletinFrame
local loadDialog

-- Files confirmed in both Retail and Forever BlizzardInterfaceArt\Interface\QuestFrame
-- (Forever also has ProfessionFirstAid / ProfessionPoisons).
local STATIONERY = {
    { id = "parchment", label = "Parchment", atlas = "QuestBG-Parchment", file = "Interface\\QuestFrame\\QuestBackgroundParchment" },
    { id = "classic", label = "Classic", atlas = "QuestBG-Classic", file = "Interface\\QuestFrame\\QuestBackgroundClassic" },
    { id = "shadow", label = "Shadow", atlas = "QuestBG-Shadow", file = "Interface\\QuestFrame\\QuestBackgroundShadow" },
    { id = "legion", label = "Legion", atlas = "QuestBG-WoWLegion", file = "Interface\\QuestFrame\\QuestBackgroundWoWLegion" },
    { id = "pandaria", label = "Pandaria", atlas = "QuestBG-Pandaria", file = "Interface\\QuestFrame\\QuestBackgroundPandaria" },
    { id = "exiles", label = "Exile's Reach", atlas = "QuestBG-ExilesReach", file = "Interface\\QuestFrame\\QuestBackgroundExilesReach" },
    { id = "trading", label = "Trading Post", atlas = "QuestBG-TradingPost", file = "Interface\\QuestFrame\\QuestBackgroundTradingPost" },
    { id = "alchemy", label = "Alchemy", atlas = "QuestBG-Profession-Alchemy", file = "Interface\\QuestFrame\\QuestBackgroundProfessionAlchemy" },
    { id = "blacksmithing", label = "Blacksmithing", atlas = "QuestBG-Profession-Blacksmithing", file = "Interface\\QuestFrame\\QuestBackgroundProfessionBlacksmithing" },
    { id = "cooking", label = "Cooking", atlas = "QuestBG-Profession-Cooking", file = "Interface\\QuestFrame\\QuestBackgroundProfessionCooking" },
    { id = "enchanting", label = "Enchanting", atlas = "QuestBG-Profession-Enchanting", file = "Interface\\QuestFrame\\QuestBackgroundProfessionEnchanting" },
    { id = "engineering", label = "Engineering", atlas = "QuestBG-Profession-Engineering", file = "Interface\\QuestFrame\\QuestBackgroundProfessionEngineering" },
    { id = "fishing", label = "Fishing", atlas = "QuestBG-Profession-Fishing", file = "Interface\\QuestFrame\\QuestBackgroundProfessionFishing" },
    { id = "herbalism", label = "Herbalism", atlas = "QuestBG-Profession-Herbalism", file = "Interface\\QuestFrame\\QuestBackgroundProfessionHerbalism" },
    { id = "inscription", label = "Inscription", atlas = "QuestBG-Profession-Inscription", file = "Interface\\QuestFrame\\QuestBackgroundProfessionInscription" },
    { id = "jewelcrafting", label = "Jewelcrafting", atlas = "QuestBG-Profession-Jewelcrafting", file = "Interface\\QuestFrame\\QuestBackgroundProfessionJewelcrafting" },
    { id = "leatherworking", label = "Leatherworking", atlas = "QuestBG-Profession-Leatherworking", file = "Interface\\QuestFrame\\QuestBackgroundProfessionLeatherworking" },
    { id = "mining", label = "Mining", atlas = "QuestBG-Profession-Mining", file = "Interface\\QuestFrame\\QuestBackgroundProfessionMining" },
    { id = "skinning", label = "Skinning", atlas = "QuestBG-Profession-Skinning", file = "Interface\\QuestFrame\\QuestBackgroundProfessionSkinning" },
    { id = "tailoring", label = "Tailoring", atlas = "QuestBG-Profession-Tailoring", file = "Interface\\QuestFrame\\QuestBackgroundProfessionTailoring" },
    { id = "firstaid", label = "First Aid", atlas = "QuestBG-Profession-FirstAid", file = "Interface\\QuestFrame\\QuestBackgroundProfessionFirstAid" },
    { id = "poisons", label = "Poisons", atlas = "QuestBG-Profession-Poisons", file = "Interface\\QuestFrame\\QuestBackgroundProfessionPoisons" },
    { id = "sl", label = "Shadowlands", atlas = "QuestBG-Shadowlands", file = "Interface\\QuestFrame\\QuestBackgroundShadowlands" },
    { id = "ardenweald", label = "Ardenweald", atlas = "QuestBG-ShadowlandsArdenweald", file = "Interface\\QuestFrame\\QuestBackgroundShadowlandsArdenweald" },
    { id = "bastion", label = "Bastion", atlas = "QuestBG-ShadowlandsBastion", file = "Interface\\QuestFrame\\QuestBackgroundShadowlandsBastion" },
    { id = "maldraxxus", label = "Maldraxxus", atlas = "QuestBG-ShadowlandsMaldraxxus", file = "Interface\\QuestFrame\\QuestBackgroundShadowlandsMaldraxxus" },
    { id = "revendreth", label = "Revendreth", atlas = "QuestBG-ShadowlandsRevendreth", file = "Interface\\QuestFrame\\QuestBackgroundShadowlandsRevendreth" },
    { id = "oribos", label = "Oribos", atlas = "QuestBG-ShadowlandsOribos", file = "Interface\\QuestFrame\\QuestBackgroundShadowlandsOribos" },
    { id = "df", label = "Dragonflight", atlas = "QuestBG-DragonflightDragonflight", file = "Interface\\QuestFrame\\QuestBackgroundDragonflightDragonflight" },
    { id = "azure", label = "Azure Span", atlas = "QuestBG-DragonflightAzureSpan", file = "Interface\\QuestFrame\\QuestBackgroundDragonflightAzureSpan" },
    { id = "tww_flame", label = "Flame", atlas = "QuestBG-TheWarWithinFlame", file = "Interface\\QuestFrame\\QuestBackgroundTheWarWithinFlame" },
    { id = "tww_storm", label = "Storm", atlas = "QuestBG-TheWarWithinStorm", file = "Interface\\QuestFrame\\QuestBackgroundTheWarWithinStorm" },
}

local SEALS = {
    { id = "none", label = "No seal", atlas = nil },
    { id = "alliance", label = "Alliance wax", atlas = "Quest-Alliance-WaxSeal" },
    { id = "horde", label = "Horde wax", atlas = "Quest-Horde-WaxSeal" },
    { id = "legionfall", label = "Legionfall wax", atlas = "Quest-Legionfall-WaxSeal" },
}

local FONTS = {
    { id = "quest", label = "Quest", object = "QuestFont" },
    { id = "questTitle", label = "Quest title", object = "QuestTitleFont" },
    { id = "mail", label = "Mail", object = "MailTextFontNormal" },
    { id = "chat", label = "Chat", object = "ChatFontNormal" },
    { id = "normal", label = "Game", object = "GameFontNormal" },
    { id = "highlight", label = "Highlight", object = "GameFontHighlight" },
    { id = "black", label = "Ink", object = "GameFontBlack" },
}

local function HasAtlas(name)
    return name and C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(name)
end

local function PaintNamed(tex, atlas, file)
    if not tex then return end
    if atlas and HasAtlas(atlas) then
        tex:SetAtlas(atlas, false)
        return
    end
    if atlas and HasAtlas(atlas:lower()) then
        tex:SetAtlas(atlas:lower(), false)
        return
    end
    if file then
        tex:SetTexture(file)
    end
end

function Blackacre.PostEditor.PaintStationery(tex, id)
    local spec = STATIONERY[1]
    for i = 1, #STATIONERY do
        if STATIONERY[i].id == id then spec = STATIONERY[i] break end
    end
    PaintNamed(tex, spec.atlas, spec.file)
end

function Blackacre.PostEditor.PaintSeal(tex, id)
    if not tex then return end
    if not id or id == "none" then
        tex:Hide()
        return
    end
    local atlas
    for i = 1, #SEALS do
        if SEALS[i].id == id then atlas = SEALS[i].atlas break end
    end
    if atlas and HasAtlas(atlas) then
        tex:SetAtlas(atlas, false)
        tex:Show()
    else
        tex:Hide()
    end
end

function Blackacre.PostEditor.FontObject(id)
    for i = 1, #FONTS do
        if FONTS[i].id == id then
            return FONTS[i].object
        end
    end
    return "QuestFont"
end

local function SkinBackstory(frame)
    if frame.SetBackdrop then frame:SetBackdrop(nil) end
    if Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.ApplyFactionFrameChrome then
        Blackacre.UI.Theme.ApplyFactionFrameChrome(frame)
    end
end

local function CreateShell(name, width, height)
    local f = CreateFrame("Frame", name, UIParent)
    f:SetSize(width, height)
    f:SetPoint("CENTER", 0, 20)
    f:SetFrameStrata("DIALOG")
    f:SetToplevel(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:Hide()
    tinsert(UISpecialFrames, name)
    SkinBackstory(f)
    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -18, -8)
    close:SetScript("OnClick", function() f:Hide() end)
    return f
end

local function MakeSection(parent, title, width, height, headerLarge)
    local s = CreateFrame("Frame", nil, parent)
    s:SetSize(width, height)
    s.bg = s:CreateTexture(nil, "BACKGROUND")
    s.bg:SetAllPoints()
    PaintNamed(s.bg, "Adventures-CombatLog-BG", "Interface\\Garrison\\AdventureMissionsFrame2")
    s.edge = s:CreateTexture(nil, "BORDER")
    s.edge:SetAllPoints()
    PaintNamed(s.edge, "Adventures-CombatLog-Frame", "Interface\\Garrison\\AdventureMissionsFrame2")
    s.title = s:CreateFontString(nil, "OVERLAY", headerLarge and "GameFontNormalLarge" or "GameFontNormal")
    s.title:SetPoint("TOPLEFT", 14, -8)
    s.title:SetText(title or "")
    if Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.GoldTitle then
        Blackacre.UI.Theme.GoldTitle(s.title)
    end
    return s
end

local function MakeFooter(parent)
    local bar = CreateFrame("Frame", nil, parent)
    bar:SetPoint("BOTTOMLEFT", 16, 10)
    bar:SetPoint("BOTTOMRIGHT", -16, 10)
    bar:SetHeight(28)
    return bar
end

-- UIDropDownMenu_SetWidth's frame is text width plus 25px of cap on each side.
local DD_CHROME = 50
local DD_GAP = 12

local function CreateDropdown(parent, name, items, width)
    local dropdown = CreateFrame("Frame", name, parent, "UIDropDownMenuTemplate")
    UIDropDownMenu_SetWidth(dropdown, width or 140)
    dropdown.items = items
    dropdown.textWidth = width or 140
    UIDropDownMenu_Initialize(dropdown, function(self)
        local selected = UIDropDownMenu_GetSelectedID(dropdown) or 1
        for i, item in ipairs(self.items) do
            -- Fresh info each row. AddButton writes checked=1 onto the table it
            -- is given and never clears it, so a reused table paints every later
            -- row as selected.
            local info = UIDropDownMenu_CreateInfo()
            info.text = item
            info.value = item
            info.checked = (i == selected)
            info.func = function()
                UIDropDownMenu_SetSelectedID(dropdown, i)
                UIDropDownMenu_SetText(dropdown, item)
                if dropdown.onChanged then dropdown.onChanged(i) end
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetSelectedID(dropdown, 1)
    if items and items[1] then
        UIDropDownMenu_SetText(dropdown, items[1])
    end
    return dropdown
end

local function DropdownRowWidth(textWidths)
    local w = 22
    for i = 1, #textWidths do
        w = w + textWidths[i] + DD_CHROME
        if i > 1 then w = w + DD_GAP end
    end
    return w
end

local function PlaceDropdowns(parent, specs, y)
    local x = 8
    for i = 1, #specs do
        local spec = specs[i]
        spec.dropdown:ClearAllPoints()
        spec.dropdown:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
        if spec.label then
            spec.label:ClearAllPoints()
            spec.label:SetPoint("BOTTOMLEFT", spec.dropdown, "TOPLEFT", 20, 3)
        end
        x = x + (spec.textWidth or spec.dropdown.textWidth or 140) + DD_CHROME + DD_GAP
    end
end

local BEACON_DD_WIDTHS = { 156, 112, 124, 164 }
local SECTION_W = math.max(DropdownRowWidth(BEACON_DD_WIDTHS), DropdownRowWidth({ 164, 150, 136, 118 }))
local SHELL_W = SECTION_W + 88

local function GetDropdownValue(dropdown)
    local id = UIDropDownMenu_GetSelectedID(dropdown)
    return dropdown.items and dropdown.items[id] or dropdown.items[1], id
end

local function MacroBox(parent, w, h, maxLetters)
    local holder = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    holder:SetSize(w, h)
    holder:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    holder:SetBackdropColor(0, 0, 0, 0.35)
    holder:SetBackdropBorderColor(0.6, 0.5, 0.3, 0.9)
    local scroll = CreateFrame("ScrollFrame", nil, holder, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 8, -8)
    scroll:SetPoint("BOTTOMRIGHT", -28, 8)
    local edit = CreateFrame("EditBox", nil, scroll)
    edit:SetMultiLine(true)
    edit:SetAutoFocus(false)
    edit:SetFontObject(ChatFontNormal)
    edit:SetWidth(w - 44)
    edit:SetMaxLetters(maxLetters or 250)
    edit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    scroll:SetScrollChild(edit)
    holder.edit = edit
    holder.scroll = scroll
    return holder
end

local function PlayerGrid()
    local ctx = Blackacre.GetZoneContext()
    local x = (ctx.coords and ctx.coords.x or 0) * 100
    local y = (ctx.coords and ctx.coords.y or 0) * 100
    return x, y, ctx
end

local function BuildBeaconEditor()
    beaconFrame = CreateShell("BlackacreBeaconEditor", SHELL_W, 720)
    local heading = beaconFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    heading:SetPoint("TOP", 0, -22)
    heading:SetText("Set a beacon")
    if Blackacre.UI and Blackacre.UI.Theme then Blackacre.UI.Theme.GoldTitle(heading) end

    local scroll = CreateFrame("ScrollFrame", "BlackacreBeaconScroll", beaconFrame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 28, -48)
    scroll:SetPoint("BOTTOMRIGHT", -52, 44)
    local child = CreateFrame("Frame", nil, scroll)
    child:SetSize(SECTION_W, 400)
    scroll:SetScrollChild(child)
    beaconFrame.scroll = scroll
    beaconFrame.scrollChild = child

    local templates = Blackacre.SentenceTemplates.GetTemplates()
    local templateNames = {}
    for _, t in ipairs(templates) do
        templateNames[#templateNames + 1] = t.label
    end

    local status = MakeSection(child, "Status", SECTION_W, 112)
    status:SetPoint("TOPLEFT", child, "TOPLEFT", 0, 0)
    beaconFrame.templateDropdown = CreateDropdown(status, "BABeaconTemplate", templateNames, BEACON_DD_WIDTHS[1])
    local tLab = status:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    tLab:SetText("Status")

    beaconFrame.slotDropdowns = {}
    local slotNames = { "disposition", "role", "intent" }
    local row = {
        { dropdown = beaconFrame.templateDropdown, label = tLab, textWidth = BEACON_DD_WIDTHS[1] },
    }
    for i, slot in ipairs(slotNames) do
        local dd = CreateDropdown(status, "BABeacon" .. slot, Blackacre.SentenceTemplates.GetSlotOptions(slot), BEACON_DD_WIDTHS[i + 1])
        beaconFrame.slotDropdowns[slot] = dd
        local lab = status:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        lab:SetText(slot:sub(1, 1):upper() .. slot:sub(2))
        row[#row + 1] = { dropdown = dd, label = lab, textWidth = BEACON_DD_WIDTHS[i + 1] }
    end
    PlaceDropdowns(status, row, -46)

    local loc = MakeSection(child, "Location", SECTION_W, 64)
    loc:SetPoint("TOPLEFT", status, "BOTTOMLEFT", 0, -8)
    local xLab = loc:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    xLab:SetPoint("LEFT", 16, -8)
    xLab:SetText("X")
    beaconFrame.gridX = CreateFrame("EditBox", nil, loc, "InputBoxTemplate")
    beaconFrame.gridX:SetSize(64, 20)
    beaconFrame.gridX:SetPoint("LEFT", xLab, "RIGHT", 8, 0)
    beaconFrame.gridX:SetAutoFocus(false)
    local yLab = loc:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    yLab:SetPoint("LEFT", beaconFrame.gridX, "RIGHT", 10, 0)
    yLab:SetText("Y")
    beaconFrame.gridY = CreateFrame("EditBox", nil, loc, "InputBoxTemplate")
    beaconFrame.gridY:SetSize(64, 20)
    beaconFrame.gridY:SetPoint("LEFT", yLab, "RIGHT", 8, 0)
    beaconFrame.gridY:SetAutoFocus(false)
    beaconFrame.locKind = "present"

    local present = CreateFrame("Button", nil, loc, "UIPanelButtonTemplate")
    present:SetSize(130, 22)
    present:SetPoint("LEFT", beaconFrame.gridY, "RIGHT", 12, 0)
    present:SetText("Present location")
    beaconFrame.presentBtn = present
    present:SetScript("OnClick", function()
        if beaconFrame.locKind == "roving" then return end
        beaconFrame._filling = true
        local gx, gy = PlayerGrid()
        beaconFrame.gridX:SetText(string.format("%.2f", gx))
        beaconFrame.gridY:SetText(string.format("%.2f", gy))
        beaconFrame.locKind = "present"
        beaconFrame._filling = false
    end)

    local roving = CreateFrame("Button", nil, loc, "UIPanelButtonTemplate")
    roving:SetSize(90, 22)
    roving:SetPoint("LEFT", present, "RIGHT", 8, 0)
    roving:SetText("Roving")
    beaconFrame.rovingBtn = roving

    local function SetRoving(on)
        if on then
            beaconFrame.locKind = "roving"
            roving:SetText("Roving •")
            present:Disable()
            present:SetAlpha(0.45)
            beaconFrame._filling = true
            beaconFrame.gridX:SetText("")
            beaconFrame.gridY:SetText("")
            beaconFrame._filling = false
            beaconFrame.gridX:Disable()
            beaconFrame.gridY:Disable()
            beaconFrame.gridX:SetAlpha(0.4)
            beaconFrame.gridY:SetAlpha(0.4)
        else
            beaconFrame.locKind = "grid"
            roving:SetText("Roving")
            present:Enable()
            present:SetAlpha(1)
            beaconFrame.gridX:Enable()
            beaconFrame.gridY:Enable()
            beaconFrame.gridX:SetAlpha(1)
            beaconFrame.gridY:SetAlpha(1)
        end
    end
    beaconFrame.SetRoving = SetRoving
    roving:SetScript("OnClick", function()
        SetRoving(beaconFrame.locKind ~= "roving")
    end)
    beaconFrame.gridX:SetScript("OnTextChanged", function()
        if not beaconFrame._filling and beaconFrame.locKind ~= "roving" then
            beaconFrame.locKind = "grid"
        end
    end)
    beaconFrame.gridY:SetScript("OnTextChanged", function()
        if not beaconFrame._filling and beaconFrame.locKind ~= "roving" then
            beaconFrame.locKind = "grid"
        end
    end)

    local crumbs = MakeSection(child, "Breadcrumbs", SECTION_W, 360, true)
    crumbs:SetPoint("TOPLEFT", loc, "BOTTOMLEFT", 0, -8)

    local function Crumb(label, instruction, yOff)
        local lab = crumbs:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        lab:SetPoint("TOPLEFT", 16, yOff)
        lab:SetText(label)
        local inst = crumbs:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
        inst:SetPoint("TOPLEFT", 90, yOff)
        inst:SetWidth(SECTION_W - 110)
        inst:SetJustifyH("LEFT")
        inst:SetText(instruction)
        local box = MacroBox(crumbs, SECTION_W - 32, 86, 250)
        box:SetPoint("TOPLEFT", 16, yOff - 16)
        return box
    end
    beaconFrame.rumorBox = Crumb("Rumor", "Use a rumor crumb for those to hear about you around the region.", -28)
    beaconFrame.leadBox = Crumb("Lead", "Give the seeker a lead as if they hear of locals talk about you.", -132)
    beaconFrame.foundBox = Crumb("Found", "Give a short description of the scene they stumble upon as they find you.", -236)

    local preview = MakeSection(child, "Emitted", SECTION_W, 220, true)
    preview:SetPoint("TOPLEFT", crumbs, "BOTTOMLEFT", 0, -8)
    beaconFrame.preview = preview
    local previewHeads, previewBodies = {}, {}
    for i = 1, 5 do
        local head = preview:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        head:SetWidth(SECTION_W - 36)
        head:SetJustifyH("LEFT")
        previewHeads[i] = head
        local body = preview:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        body:SetWidth(SECTION_W - 36)
        body:SetJustifyH("LEFT")
        body:SetJustifyV("TOP")
        previewBodies[i] = body
    end

    local footer = MakeFooter(beaconFrame)
    local save = CreateFrame("Button", nil, footer, "UIPanelButtonTemplate")
    save:SetSize(96, 24)
    save:SetPoint("RIGHT", 0, 0)
    save:SetText("Save")
    local load = CreateFrame("Button", nil, footer, "UIPanelButtonTemplate")
    load:SetSize(96, 24)
    load:SetPoint("RIGHT", save, "LEFT", -8, 0)
    load:SetText("Load")

    local function CurrentSlots(template)
        local slots = {}
        for _, slot in ipairs(template.slots) do
            if slot ~= "location" then
                local dd = beaconFrame.slotDropdowns[slot]
                if dd then slots[slot] = GetDropdownValue(dd) end
            end
        end
        return slots
    end

    local function BuildBeaconFromForm()
        local ti = UIDropDownMenu_GetSelectedID(beaconFrame.templateDropdown) or 1
        local template = templates[ti]
        local gx = tonumber(beaconFrame.gridX:GetText()) or 0
        local gy = tonumber(beaconFrame.gridY:GetText()) or 0
        local ctx = Blackacre.GetZoneContext()
        local locKind = beaconFrame.locKind or "grid"
        local coords
        if locKind == "roving" then
            coords = ctx.coords
        else
            coords = { x = gx / 100, y = gy / 100 }
        end
        return Blackacre.Lifecycle.CreateBeacon(template.id, CurrentSlots(template), {
            locKind = locKind,
            coords = coords,
            zoneId = ctx.zoneId,
            zoneName = ctx.zoneName,
            subzone = ctx.subzone,
            rumor = beaconFrame.rumorBox.edit:GetText() or "",
            lead = beaconFrame.leadBox.edit:GetText() or "",
            found = beaconFrame.foundBox.edit:GetText() or "",
        })
    end
    beaconFrame.BuildBeaconFromForm = BuildBeaconFromForm

    local function ShownText(text)
        if text and text ~= "" then return text end
        return "(none)"
    end

    local function RefreshBeaconPreview()
        local ti = UIDropDownMenu_GetSelectedID(beaconFrame.templateDropdown) or 1
        local template = templates[ti]
        if not template then return end
        local resolved = Blackacre.SentenceTemplates.Resolve(template.id, CurrentSlots(template), Blackacre.CharDB and Blackacre.CharDB.residence)
        local ctx = Blackacre.GetZoneContext()
        local locText
        if beaconFrame.locKind == "roving" then
            locText = "Roving with you through " .. ((ctx.subzone ~= "" and ctx.subzone) or ctx.zoneName or "this region")
        else
            locText = string.format("%s, %s  (%.2f, %.2f)", ctx.zoneName or "", ctx.subzone or "", tonumber(beaconFrame.gridX:GetText()) or 0, tonumber(beaconFrame.gridY:GetText()) or 0)
        end
        local blocks = {
            { "Status", (resolved and resolved.fullText) or "" },
            { "Heard nearby", (resolved and resolved.shortText) or "" },
            { "Location", locText },
            { "Rumor", ShownText(beaconFrame.rumorBox.edit:GetText()) },
            { "Lead", ShownText(beaconFrame.leadBox.edit:GetText()) },
            { "Found", ShownText(beaconFrame.foundBox.edit:GetText()) },
        }
        local y = -28
        for i = 1, #blocks do
            local head = previewHeads[i]
            local body = previewBodies[i]
            if not head then
                head = preview:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                head:SetWidth(SECTION_W - 36)
                head:SetJustifyH("LEFT")
                previewHeads[i] = head
                body = preview:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
                body:SetWidth(SECTION_W - 36)
                body:SetJustifyH("LEFT")
                body:SetJustifyV("TOP")
                previewBodies[i] = body
            end
            head:ClearAllPoints()
            head:SetPoint("TOPLEFT", 16, y)
            head:SetText(blocks[i][1])
            if Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.GoldTitle then
                Blackacre.UI.Theme.GoldTitle(head)
            end
            local headH = head:GetStringHeight()
            if headH < 1 then headH = 14 end
            y = y - headH - 2
            body:ClearAllPoints()
            body:SetPoint("TOPLEFT", 16, y)
            body:SetText(blocks[i][2])
            local bodyH = body:GetStringHeight()
            if bodyH < 1 then
                bodyH = 16 * math.max(1, math.ceil(#(blocks[i][2] or "") / 80))
            end
            y = y - bodyH - 10
        end
        preview:SetHeight(-y + 8)
        child:SetHeight(112 + 8 + 64 + 8 + 360 + 8 + preview:GetHeight() + 12)
        if scroll.UpdateScrollChildRect then
            scroll:UpdateScrollChildRect()
        end
    end
    beaconFrame.RefreshBeaconPreview = RefreshBeaconPreview
    beaconFrame.templateDropdown.onChanged = RefreshBeaconPreview
    for _, dd in pairs(beaconFrame.slotDropdowns) do
        dd.onChanged = RefreshBeaconPreview
    end
    local function WatchEdit(edit)
        edit:HookScript("OnTextChanged", function()
            if not beaconFrame._filling then RefreshBeaconPreview() end
        end)
    end
    WatchEdit(beaconFrame.rumorBox.edit)
    WatchEdit(beaconFrame.leadBox.edit)
    WatchEdit(beaconFrame.foundBox.edit)
    WatchEdit(beaconFrame.gridX)
    WatchEdit(beaconFrame.gridY)
    present:HookScript("OnClick", RefreshBeaconPreview)
    roving:HookScript("OnClick", RefreshBeaconPreview)
    RefreshBeaconPreview()

    save:SetScript("OnClick", function()
        StaticPopup_Show("BLACKACRE_BEACON_SAVE")
    end)
    load:SetScript("OnClick", function()
        Blackacre.PostEditor.ShowLoadDialog()
    end)
end

StaticPopupDialogs["BLACKACRE_BEACON_SAVE"] = {
    text = "Name this beacon:",
    button1 = SAVE,
    button2 = CANCEL,
    hasEditBox = true,
    maxLetters = 32,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
    OnShow = function(self)
        local box = self.editBox or self.EditBox or (self.GetEditBox and self:GetEditBox())
        if box then box:SetText("Beacon") box:HighlightText() end
    end,
    OnAccept = function(self)
        if not beaconFrame then return end
        local box = self.editBox or self.EditBox or (self.GetEditBox and self:GetEditBox())
        local name = box and box:GetText() or "Beacon"
        local beacon = beaconFrame.BuildBeaconFromForm and beaconFrame.BuildBeaconFromForm()
        if not beacon then return end
        local p = Blackacre.Lifecycle.EnsurePresenceDB()
        local slot = 1
        for i = 1, 5 do
            if not (p.savedBeacons[i] and p.savedBeacons[i].beacon) then
                slot = i
                break
            end
            slot = i
        end
        Blackacre.Lifecycle.SaveNamedBeacon(slot, name, beacon)
        Blackacre.Print("Saved \"" .. name .. "\" in slot " .. slot .. ". Turn Emit on to send crumbs.")
        beaconFrame:Hide()
    end,
}

local function ApplyBeaconToForm(beacon)
    if not beacon or not beaconFrame then return end
    beaconFrame.rumorBox.edit:SetText(beacon.rumor or "")
    beaconFrame.leadBox.edit:SetText(beacon.lead or "")
    beaconFrame.foundBox.edit:SetText(beacon.found or "")
    if beacon.locKind == "roving" then
        beaconFrame.SetRoving(true)
    else
        beaconFrame.SetRoving(false)
        beaconFrame.locKind = beacon.locKind or "present"
        if beacon.coords then
            beaconFrame._filling = true
            beaconFrame.gridX:SetText(string.format("%.2f", (beacon.coords.x or 0) * 100))
            beaconFrame.gridY:SetText(string.format("%.2f", (beacon.coords.y or 0) * 100))
            beaconFrame._filling = false
        end
    end
    if beaconFrame.RefreshBeaconPreview then
        beaconFrame.RefreshBeaconPreview()
    end
end

function Blackacre.PostEditor.ShowLoadDialog()
    if not loadDialog then
        loadDialog = CreateFrame("Frame", "BlackacreBeaconLoad", UIParent, "BackdropTemplate")
        loadDialog:SetSize(320, 140)
        loadDialog:SetPoint("CENTER")
        loadDialog:SetFrameStrata("FULLSCREEN_DIALOG")
        loadDialog:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 32,
            insets = { left = 8, right = 8, top = 8, bottom = 8 },
        })
        local t = loadDialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        t:SetPoint("TOP", 0, -16)
        t:SetText("Load a saved beacon")
        loadDialog.drop = CreateDropdown(loadDialog, "BABeaconLoadDrop", { "1" }, 200)
        loadDialog.drop:SetPoint("TOP", 0, -40)
        local ok = CreateFrame("Button", nil, loadDialog, "UIPanelButtonTemplate")
        ok:SetSize(80, 22)
        ok:SetPoint("BOTTOMLEFT", 40, 16)
        ok:SetText("Load")
        ok:SetScript("OnClick", function()
            local _, id = GetDropdownValue(loadDialog.drop)
            local beacon, name = Blackacre.Lifecycle.LoadNamedBeacon(id or 1)
            if not beacon then
                Blackacre.Print("That slot is empty.")
                return
            end
            ApplyBeaconToForm(beacon)
            Blackacre.Print("Loaded " .. (name or "beacon") .. ".")
            loadDialog:Hide()
        end)
        local cancel = CreateFrame("Button", nil, loadDialog, "UIPanelButtonTemplate")
        cancel:SetSize(80, 22)
        cancel:SetPoint("BOTTOMRIGHT", -40, 16)
        cancel:SetText("Cancel")
        cancel:SetScript("OnClick", function() loadDialog:Hide() end)
        tinsert(UISpecialFrames, "BlackacreBeaconLoad")
    end
    local names = {}
    local p = Blackacre.Lifecycle.EnsurePresenceDB()
    for i = 1, 5 do
        local row = p.savedBeacons[i]
        names[i] = i .. ": " .. ((row and row.name) or "(empty)")
    end
    loadDialog.drop.items = names
    UIDropDownMenu_Initialize(loadDialog.drop, function(self)
        local selected = UIDropDownMenu_GetSelectedID(loadDialog.drop) or 1
        for i, item in ipairs(self.items) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = item
            info.checked = (i == selected)
            info.func = function()
                UIDropDownMenu_SetSelectedID(loadDialog.drop, i)
                UIDropDownMenu_SetText(loadDialog.drop, item)
            end
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetSelectedID(loadDialog.drop, 1)
    UIDropDownMenu_SetText(loadDialog.drop, names[1])
    loadDialog:Show()
end

local function SelectedZones()
    local out = {}
    if not bulletinFrame or not bulletinFrame.zoneOn then return out end
    for id, on in pairs(bulletinFrame.zoneOn) do
        if on then out[#out + 1] = id end
    end
    return out
end

local function RefreshZoneDropText()
    if not bulletinFrame or not bulletinFrame.zoneDrop then return end
    local n = #SelectedZones()
    local zones = Blackacre.Boards.GetMajorZones()
    local label = "Posted Location"
    if n == 0 then
        label = "Posted Location (none)"
    elseif n == #zones then
        label = "Posted Location (all)"
    elseif n == 1 then
        for _, z in ipairs(zones) do
            if bulletinFrame.zoneOn[z.id] then label = z.name break end
        end
    else
        label = n .. " locations"
    end
    UIDropDownMenu_SetText(bulletinFrame.zoneDrop, label)
end

local PAPER_NAT_W, PAPER_NAT_H = 299, 407
local BULLETIN_DD_WIDTHS = { 130, 96, 108, 90 }
local BULLETIN_SECTION_W = DropdownRowWidth(BULLETIN_DD_WIDTHS)
local BULLETIN_SHELL_W = math.floor(SHELL_W * 0.81)
local BULLETIN_H = math.floor((48 + 58 + 8 + 108 + 8 + math.floor(540 + 44) + 12 + 46) * 0.81)
local TITLE_H, OPT_H, GAP = 52, 96, 6
local PAPER_FIT_H = BULLETIN_H - (42 + TITLE_H + GAP + OPT_H + GAP + 44) - 28
local paperScale = math.min((BULLETIN_SECTION_W - 36) / PAPER_NAT_W, PAPER_FIT_H / PAPER_NAT_H)
local PAPER_FIT_W = PAPER_NAT_W * paperScale
local PREVIEW_W = math.floor(PAPER_FIT_W + 16)
local PREVIEW_H = math.floor(PAPER_FIT_H + 28)

local function StationeryNativeSize(id)
    local spec = STATIONERY[1]
    for i = 1, #STATIONERY do
        if STATIONERY[i].id == id then spec = STATIONERY[i] break end
    end
    if spec.atlas and C_Texture and C_Texture.GetAtlasInfo then
        local info = C_Texture.GetAtlasInfo(spec.atlas)
        if info and info.width and info.height and info.width > 0 and info.height > 0 then
            return info.width, info.height
        end
    end
    return PAPER_NAT_W, PAPER_NAT_H
end

local function BuildBulletinEditor()
    bulletinFrame = CreateShell("BlackacreBulletinEditor", BULLETIN_SHELL_W, BULLETIN_H)
    local heading = bulletinFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    heading:SetPoint("TOP", 0, -18)
    heading:SetText("Post a bulletin")
    if Blackacre.UI and Blackacre.UI.Theme then Blackacre.UI.Theme.GoldTitle(heading) end

    local titleSec = MakeSection(bulletinFrame, "Title", BULLETIN_SECTION_W, TITLE_H)
    titleSec:SetPoint("TOP", 0, -42)
    bulletinFrame.titleEdit = CreateFrame("EditBox", nil, titleSec, "InputBoxTemplate")
    bulletinFrame.titleEdit:SetSize(BULLETIN_SECTION_W - 48, 22)
    bulletinFrame.titleEdit:SetPoint("LEFT", 24, -8)
    bulletinFrame.titleEdit:SetAutoFocus(false)
    bulletinFrame.titleEdit:SetMaxLetters(80)

    local opt = MakeSection(bulletinFrame, "Posted Location", BULLETIN_SECTION_W, OPT_H)
    opt:SetPoint("TOP", titleSec, "BOTTOM", 0, -GAP)
    bulletinFrame.zoneOn = {}
    bulletinFrame.zoneDrop = CreateFrame("Frame", "BABulletinZoneDrop", opt, "UIDropDownMenuTemplate")
    UIDropDownMenu_SetWidth(bulletinFrame.zoneDrop, BULLETIN_DD_WIDTHS[1])
    bulletinFrame.zoneDrop.textWidth = BULLETIN_DD_WIDTHS[1]
    UIDropDownMenu_Initialize(bulletinFrame.zoneDrop, function()
        local zones = Blackacre.Boards.GetMajorZones()
        for _, z in ipairs(zones) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = z.name
            info.keepShownOnClick = true
            info.isNotRadio = true
            info.checked = bulletinFrame.zoneOn[z.id] and true or false
            info.func = function()
                bulletinFrame.zoneOn[z.id] = not bulletinFrame.zoneOn[z.id]
                RefreshZoneDropText()
            end
            UIDropDownMenu_AddButton(info)
        end
        local allInfo = UIDropDownMenu_CreateInfo()
        allInfo.text = "Select all"
        allInfo.notCheckable = true
        allInfo.keepShownOnClick = true
        allInfo.func = function()
            for _, z in ipairs(zones) do bulletinFrame.zoneOn[z.id] = true end
            RefreshZoneDropText()
        end
        UIDropDownMenu_AddButton(allInfo)
        local clearInfo = UIDropDownMenu_CreateInfo()
        clearInfo.text = "Clear all"
        clearInfo.notCheckable = true
        clearInfo.keepShownOnClick = true
        clearInfo.func = function()
            wipe(bulletinFrame.zoneOn)
            RefreshZoneDropText()
        end
        UIDropDownMenu_AddButton(clearInfo)
    end)
    RefreshZoneDropText()

    -- Only the default parchment is offered. The other quest backgrounds still
    -- disagree with this page fit, so they stay out of the menu for now.
    local paperNames = { STATIONERY[1].label }
    bulletinFrame.paperDrop = CreateDropdown(opt, "BABulletinPaper", paperNames, BULLETIN_DD_WIDTHS[2])
    local pLab = opt:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    pLab:SetText("Stationery")

    local sealNames = {}
    for _, s in ipairs(SEALS) do sealNames[#sealNames + 1] = s.label end
    bulletinFrame.sealDrop = CreateDropdown(opt, "BABulletinSeal", sealNames, BULLETIN_DD_WIDTHS[3])
    local sLab = opt:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    sLab:SetText("Wax seal")

    local fontNames = {}
    for _, f in ipairs(FONTS) do fontNames[#fontNames + 1] = f.label end
    bulletinFrame.fontDrop = CreateDropdown(opt, "BABulletinFont", fontNames, BULLETIN_DD_WIDTHS[4])
    local fLab = opt:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    fLab:SetText("Font")
    PlaceDropdowns(opt, {
        { dropdown = bulletinFrame.zoneDrop, textWidth = BULLETIN_DD_WIDTHS[1] },
        { dropdown = bulletinFrame.paperDrop, label = pLab, textWidth = BULLETIN_DD_WIDTHS[2] },
        { dropdown = bulletinFrame.sealDrop, label = sLab, textWidth = BULLETIN_DD_WIDTHS[3] },
        { dropdown = bulletinFrame.fontDrop, label = fLab, textWidth = BULLETIN_DD_WIDTHS[4] },
    }, -46)

    local preview = MakeSection(bulletinFrame, "", PREVIEW_W, PREVIEW_H, true)
    preview:SetPoint("TOP", opt, "BOTTOM", 0, -GAP)
    preview.title:SetText("")
    bulletinFrame.paper = preview:CreateTexture(nil, "ARTWORK")
    bulletinFrame.paper:SetSize(PAPER_FIT_W, PAPER_FIT_H)
    bulletinFrame.paper:SetPoint("CENTER", preview, "CENTER", 0, 0)
    Blackacre.PostEditor.PaintStationery(bulletinFrame.paper, "parchment")

    local letter = CreateFrame("EditBox", nil, preview)
    letter:SetMultiLine(true)
    letter:SetAutoFocus(false)
    letter:SetMaxLetters(500)
    letter:SetFontObject(QuestFont)
    letter:SetTextInsets(6, 6, 6, 6)
    letter:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    bulletinFrame.bodyEdit = letter

    bulletinFrame.seal = preview:CreateTexture(nil, "OVERLAY")
    bulletinFrame.seal:SetSize(56, 56)
    bulletinFrame.seal:Hide()

    local function FitPaper(natW, natH)
        local scale = math.min(PAPER_FIT_W / natW, PAPER_FIT_H / natH)
        local w, h = natW * scale, natH * scale
        local tex = bulletinFrame.paper
        tex:ClearAllPoints()
        tex:SetSize(w, h)
        tex:SetPoint("CENTER", preview, "CENTER", 0, 0)
        local insetX = math.floor(w * 0.1)
        local insetTop = math.floor(h * 0.11)
        local insetBot = math.floor(h * 0.09)
        letter:ClearAllPoints()
        letter:SetPoint("TOPLEFT", tex, "TOPLEFT", insetX, -insetTop)
        letter:SetPoint("BOTTOMRIGHT", tex, "BOTTOMRIGHT", -insetX, insetBot)
        bulletinFrame.seal:ClearAllPoints()
        bulletinFrame.seal:SetPoint("BOTTOMRIGHT", tex, "BOTTOMRIGHT", -math.floor(w * 0.04), math.floor(h * 0.05))
    end

    local function RefreshPreview()
        local _, pi = GetDropdownValue(bulletinFrame.paperDrop)
        local paper = STATIONERY[pi or 1]
        Blackacre.PostEditor.PaintStationery(bulletinFrame.paper, paper and paper.id)
        local natW, natH = StationeryNativeSize(paper and paper.id)
        FitPaper(natW, natH)
        local _, si = GetDropdownValue(bulletinFrame.sealDrop)
        local seal = SEALS[si or 1]
        Blackacre.PostEditor.PaintSeal(bulletinFrame.seal, seal and seal.id)
        local _, fi = GetDropdownValue(bulletinFrame.fontDrop)
        local font = FONTS[fi or 1]
        if font then
            letter:SetFontObject(font.object)
        end
    end
    bulletinFrame.paperDrop.onChanged = RefreshPreview
    bulletinFrame.sealDrop.onChanged = RefreshPreview
    bulletinFrame.fontDrop.onChanged = RefreshPreview
    bulletinFrame.RefreshPreview = RefreshPreview

    local footer = MakeFooter(bulletinFrame)
    local post = CreateFrame("Button", nil, footer, "UIPanelButtonTemplate")
    post:SetSize(100, 24)
    post:SetPoint("RIGHT", 0, 0)
    post:SetText("Post")
    post:SetScript("OnClick", function()
        local posted = SelectedZones()
        if #posted == 0 then
            Blackacre.Print("Pick at least one Posted Location.")
            return
        end
        local titleText = bulletinFrame.titleEdit:GetText() or ""
        local bodyText = bulletinFrame.bodyEdit:GetText() or ""
        if bodyText == "" then
            Blackacre.Print("Write a notice first.")
            return
        end
        local _, pi = GetDropdownValue(bulletinFrame.paperDrop)
        local _, si = GetDropdownValue(bulletinFrame.sealDrop)
        local _, fi = GetDropdownValue(bulletinFrame.fontDrop)
        local paper = STATIONERY[pi or 1]
        local seal = SEALS[si or 1]
        local font = FONTS[fi or 1]
        local function doPost()
            if Blackacre.Voice and Blackacre.Voice.MaybeApplyBulletin then
                bodyText = Blackacre.Voice.MaybeApplyBulletin(bodyText)
                titleText = Blackacre.Voice.MaybeApplyBulletin(titleText)
            end
            local bulletin = Blackacre.Lifecycle.CreateBulletin(titleText, bodyText, "inn:" .. posted[1], Blackacre.SCOPE.INDIVIDUAL, {
                postedZones = posted,
                stationary = paper and paper.id or "parchment",
                waxSeal = seal and seal.id ~= "none" and seal.id or nil,
                font = font and font.id or "quest",
            })
            Blackacre.Lifecycle.PostBulletin(bulletin)
            Blackacre.Print("Bulletin posted to " .. #posted .. " inn board(s).")
            bulletinFrame:Hide()
        end
        if Blackacre.ProfanityFilter and Blackacre.ProfanityFilter.ValidateBulletin then
            if Blackacre.ProfanityFilter.ValidateBulletin(titleText, bodyText, doPost) then
                doPost()
            end
        else
            doPost()
        end
    end)
end

function Blackacre.PostEditor.Init()
    BuildBeaconEditor()
    BuildBulletinEditor()
end

function Blackacre.PostEditor.ShowBeaconEditor()
    if not beaconFrame then BuildBeaconEditor() end
    if beaconFrame.locKind ~= "roving" then
        local gx, gy = PlayerGrid()
        if (beaconFrame.gridX:GetText() or "") == "" then
            beaconFrame._filling = true
            beaconFrame.gridX:SetText(string.format("%.2f", gx))
            beaconFrame.gridY:SetText(string.format("%.2f", gy))
            beaconFrame._filling = false
            beaconFrame.locKind = "present"
        end
    end
    local p = Blackacre.Lifecycle.EnsurePresenceDB()
    if p.draftBeacon then
        ApplyBeaconToForm(p.draftBeacon)
    end
    beaconFrame:Show()
    if beaconFrame.RefreshBeaconPreview then
        beaconFrame.RefreshBeaconPreview()
    end
end

function Blackacre.PostEditor.ShowBulletinEditor()
    if not bulletinFrame then BuildBulletinEditor() end
    local key = Blackacre.Boards.CurrentZoneKey()
    if key then bulletinFrame.zoneOn[key] = true end
    RefreshZoneDropText()
    if bulletinFrame.RefreshPreview then bulletinFrame.RefreshPreview() end
    bulletinFrame:Show()
end

Blackacre.PostEditor.ShowNoticeEditor = Blackacre.PostEditor.ShowBulletinEditor
Blackacre.PostEditor.STATIONERY = STATIONERY
Blackacre.PostEditor.SEALS = SEALS
Blackacre.PostEditor.FONTS = FONTS
