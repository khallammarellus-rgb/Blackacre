-- Life Path picker (not expedition roadmap).
Blackacre = Blackacre or {}
Blackacre.PathUI = {}

local frame
local rows = {}
local selectedId

local function SoftToast(msg)
    if Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.Toast then
        Blackacre.UI.Theme.Toast(msg)
    else
        Blackacre.Print(msg)
    end
end

local function EnsureDB()
    Blackacre.CharDB = Blackacre.CharDB or {}
    Blackacre.CharDB.pathId = Blackacre.CharDB.pathId
    return Blackacre.CharDB
end

local function ListPaths()
    if Blackacre.Paths and Blackacre.Paths.List then
        return Blackacre.Paths.List({})
    end
    return Blackacre.Paths and Blackacre.Paths.GetAll and Blackacre.Paths.GetAll() or {}
end

local function Build(parent)
    parent = parent or UIParent
    local embedded = parent ~= UIParent
    frame = CreateFrame("Frame", "BlackacrePathUI", parent, "BackdropTemplate")
    if embedded then
        frame:SetAllPoints(parent)
    else
        frame:SetSize(520, 460)
        frame:SetPoint("CENTER")
        frame:SetFrameStrata("HIGH")
        frame:Hide()
        tinsert(UISpecialFrames, "BlackacrePathUI")
        Blackacre.UI.Theme.ApplyFilledPanel(frame, 0.96, "page")
    end
    if frame.SetClipsChildren then frame:SetClipsChildren(true) end

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    frame.title:SetPoint("TOPLEFT", 12, -10)
    frame.title:SetText("Path")
    Blackacre.UI.Theme.GoldTitle(frame.title)

    frame.sub = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.sub:SetPoint("TOPLEFT", 12, -32)
    frame.sub:SetPoint("TOPRIGHT", -12, -32)
    frame.sub:SetJustifyH("LEFT")
    frame.sub:SetText("Choose a life path. This is not an expedition chart.")
    Blackacre.UI.Theme.InkFont(frame.sub)

    local scroll = CreateFrame("ScrollFrame", "BlackacrePathScroll", frame, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 10, -56)
    scroll:SetPoint("BOTTOMRIGHT", -28, 48)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(460, 40)
    scroll:SetScrollChild(content)
    frame.content = content

    frame.chosen = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.chosen:SetPoint("BOTTOMLEFT", 12, 16)
    frame.chosen:SetPoint("BOTTOMRIGHT", -12, 16)
    frame.chosen:SetJustifyH("LEFT")
    Blackacre.UI.Theme.InkFont(frame.chosen)
end

function Blackacre.PathUI.Refresh()
    if not frame then return end
    EnsureDB()
    selectedId = Blackacre.CharDB.pathId
    for _, row in ipairs(rows) do
        row:Hide()
        row:SetParent(nil)
    end
    wipe(rows)
    local list = ListPaths()
    local y = -2
    for i, path in ipairs(list) do
        local btn = CreateFrame("Button", nil, frame.content, "UIPanelButtonTemplate")
        btn:SetSize(430, 28)
        btn:SetPoint("TOPLEFT", 4, y)
        btn:SetText((path.name or path.id or "Path"):sub(1, 42))
        btn.pathId = path.id
        btn:SetScript("OnClick", function()
            Blackacre.CharDB.pathId = path.id
            selectedId = path.id
            SoftToast("Path set: " .. (path.name or path.id))
            Blackacre.PathUI.Refresh()
        end)
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine(path.name or path.id)
            if path.blurb then
                GameTooltip:AddLine(path.blurb, 1, 1, 1, true)
            end
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", GameTooltip_Hide)
        rows[i] = btn
        y = y - 32
    end
    frame.content:SetHeight(math.max(40, math.abs(y) + 8))
    local chosen = selectedId and Blackacre.Paths and Blackacre.Paths.Get and Blackacre.Paths.Get(selectedId)
    if chosen then
        frame.chosen:SetText("Current Path: " .. (chosen.name or selectedId))
    else
        frame.chosen:SetText("No Path chosen.")
    end
end

function Blackacre.PathUI.Mount(parent)
    if not frame then
        Build(parent)
    elseif parent then
        Blackacre.UI.Theme.MountInPage(frame, parent)
    end
    frame:Show()
    Blackacre.PathUI.Refresh()
end

function Blackacre.PathUI.Init()
end
