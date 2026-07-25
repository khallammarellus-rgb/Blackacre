InCharacter = InCharacter or {}
InCharacter.BoardView = {}

local frame
local knownFrame
local rows = {}
local knownRows = {}
local MAX_VISIBLE = 8
local MAX_KNOWN = 12
local currentBoard
local nearbyBulletins = {}

local function SealPrefix(scopeTier)
    if InCharacter.UI and InCharacter.UI.Theme and InCharacter.UI.Theme.FormatSealPrefix then
        return InCharacter.UI.Theme.FormatSealPrefix(scopeTier)
    end
    return scopeTier and ("[" .. scopeTier:sub(1, 1) .. "] ") or ""
end

local function GetBulletinsForBoard(boardId)
    local list = {}
    for _, b in pairs(nearbyBulletins) do
        if b.boardId == boardId then
            if not b.expiresAt or b.expiresAt >= time() then
                list[#list + 1] = b
            end
        end
    end
    table.sort(list, function(a, b)
        return (a.receivedAt or 0) > (b.receivedAt or 0)
    end)
    return list
end

function InCharacter.BoardView.Init()
    frame = CreateFrame("Frame", "InCharacterBoardView", UIParent, "BackdropTemplate")
    frame:SetSize(340, 260)
    frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -40, -340)
    if InCharacter.UI and InCharacter.UI.Theme and InCharacter.UI.Theme.ApplyParchmentBackdrop then
        InCharacter.UI.Theme.ApplyParchmentBackdrop(frame, 0.94)
    end
    frame:Hide()
    tinsert(UISpecialFrames, "InCharacterBoardView")

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.title:SetPoint("TOPLEFT", 12, -10)
    frame.title:SetText("Bulletin board")
    if InCharacter.UI and InCharacter.UI.Theme then
        InCharacter.UI.Theme.GoldTitle(frame.title)
    end

    frame.hint = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.hint:SetPoint("TOPLEFT", 12, -28)
    frame.hint:SetWidth(310)
    frame.hint:SetJustifyH("LEFT")
    frame.hint:SetText("Wax-sealed missives at this board")

    frame.sealLegend = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
    frame.sealLegend:SetPoint("TOPLEFT", 12, -44)
    frame.sealLegend:SetWidth(310)
    frame.sealLegend:SetJustifyH("LEFT")
    frame.sealLegend:SetText("Seals: [P]ersonal  [C]ompany  [G]uild  [R]ealm")

    for i = 1, MAX_VISIBLE do
        local row = CreateFrame("Button", nil, frame)
        row:SetSize(320, 22)
        row:SetPoint("TOPLEFT", 8, -62 - (i - 1) * 24)
        row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
        row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.text:SetPoint("LEFT", 4, 0)
        row.text:SetWidth(300)
        row.text:SetJustifyH("LEFT")
        rows[i] = row
    end

    local knownBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    knownBtn:SetSize(110, 20)
    knownBtn:SetPoint("BOTTOMLEFT", 10, 8)
    knownBtn:SetText("Known boards")
    knownBtn:SetScript("OnClick", function()
        InCharacter.BoardView.ShowKnownBoards()
    end)

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -2, -2)

    -- Known boards directory
    knownFrame = CreateFrame("Frame", "InCharacterKnownBoards", UIParent, "BackdropTemplate")
    knownFrame:SetSize(320, 340)
    knownFrame:SetPoint("CENTER")
    knownFrame:SetFrameStrata("DIALOG")
    if InCharacter.UI and InCharacter.UI.Theme and InCharacter.UI.Theme.ApplyParchmentBackdrop then
        InCharacter.UI.Theme.ApplyParchmentBackdrop(knownFrame, 0.97)
    end
    knownFrame:Hide()
    tinsert(UISpecialFrames, "InCharacterKnownBoards")

    knownFrame.title = knownFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    knownFrame.title:SetPoint("TOP", 0, -12)
    knownFrame.title:SetText("Known bulletin boards")
    if InCharacter.UI and InCharacter.UI.Theme then
        InCharacter.UI.Theme.GoldTitle(knownFrame.title)
    end

    knownFrame.hint = knownFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    knownFrame.hint:SetPoint("TOPLEFT", 14, -36)
    knownFrame.hint:SetWidth(290)
    knownFrame.hint:SetJustifyH("LEFT")
    knownFrame.hint:SetText("Stand near a board to post or read. Regions registered:")

    for i = 1, MAX_KNOWN do
        local row = knownFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row:SetPoint("TOPLEFT", 16, -58 - (i - 1) * 18)
        row:SetWidth(280)
        row:SetJustifyH("LEFT")
        knownRows[i] = row
    end

    local kclose = CreateFrame("Button", nil, knownFrame, "UIPanelCloseButton")
    kclose:SetPoint("TOPRIGHT", -2, -2)

    local ticker = CreateFrame("Frame")
    ticker:RegisterEvent("ZONE_CHANGED")
    ticker:RegisterEvent("ZONE_CHANGED_INDOORS")
    ticker:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    ticker:SetScript("OnEvent", function()
        InCharacter.BoardView.CheckProximity()
    end)
    C_Timer.NewTicker(10, InCharacter.BoardView.CheckProximity)
end

function InCharacter.BoardView.ShowKnownBoards()
    if not knownFrame then return end
    local all = InCharacter.Boards.GetAll()
    local lines = {}
    local seen = {}
    for _, b in ipairs(all) do
        local key = b.region or b.displayName
        if not seen[key] then
            seen[key] = true
            lines[#lines + 1] = string.format("· %s — %s", key, b.displayName)
        end
    end
    table.sort(lines)
    for i = 1, MAX_KNOWN do
        if lines[i] then
            knownRows[i]:SetText(lines[i])
            knownRows[i]:Show()
        else
            knownRows[i]:Hide()
        end
    end
    knownFrame:SetHeight(70 + math.min(#lines, MAX_KNOWN) * 18 + 20)
    knownFrame:Show()
end

function InCharacter.BoardView.CheckProximity()
    local board = InCharacter.Boards.GetNearbyBoard()
    if board and board.id ~= (currentBoard and currentBoard.id) then
        currentBoard = board
        wipe(nearbyBulletins)
        InCharacter.Comms.BroadcastBoardQuery(board.id)
        if frame then
            frame.title:SetText(board.displayName)
        end
    elseif not board then
        currentBoard = nil
    end
end

function InCharacter.BoardView.Refresh()
    if not frame or not frame:IsShown() or not currentBoard then return end
    InCharacter.BoardView.Populate(currentBoard.id)
end

function InCharacter.BoardView.Populate(boardId)
    local bulletins = GetBulletinsForBoard(boardId)
    local shown = math.min(#bulletins, MAX_VISIBLE)
    for i = 1, MAX_VISIBLE do
        local row = rows[i]
        if i <= shown then
            local bulletin = bulletins[i]
            row.text:SetText(SealPrefix(bulletin.scopeTier) .. (bulletin.title or "Bulletin"))
            row:Show()
            row:SetScript("OnClick", function()
                if bulletin.charName then
                    InCharacter.Comms.RequestBulletinFull(bulletin.charName, bulletin.id)
                end
            end)
        else
            row:Hide()
        end
    end
    frame:SetHeight(90 + shown * 24)
end

function InCharacter.BoardView.Show()
    InCharacter.BoardView.CheckProximity()
    if not currentBoard then
        InCharacter.Print("No bulletin board nearby. Opening known boards list.")
        InCharacter.BoardView.ShowKnownBoards()
        return
    end
    frame.title:SetText(currentBoard.displayName)
    InCharacter.BoardView.Populate(currentBoard.id)
    frame:Show()
end

function InCharacter.BoardView.OnBulletinDiscovered(bulletin)
    nearbyBulletins[bulletin.id] = bulletin
    if currentBoard and bulletin.boardId == currentBoard.id then
        InCharacter.BoardView.Refresh()
        if not frame:IsShown() then
            InCharacter.Print("New bulletin at " .. (currentBoard.displayName or "nearby board") .. ".")
        end
    end
end

InCharacter.BoardView.OnNoticeDiscovered = InCharacter.BoardView.OnBulletinDiscovered

function InCharacter.BoardView.OnBulletinFullReceived(bulletin)
    if bulletin then
        local seal = SealPrefix(bulletin.scopeTier)
        InCharacter.Print("|cffffffff" .. seal .. (bulletin.title or "Bulletin") .. "|r")
        InCharacter.Print(bulletin.bodyText or "")
        nearbyBulletins[bulletin.id] = bulletin
        InCharacter.BoardView.Refresh()
    end
end

InCharacter.BoardView.OnNoticeFullReceived = InCharacter.BoardView.OnBulletinFullReceived
