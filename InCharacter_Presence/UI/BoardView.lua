InCharacter = InCharacter or {}
InCharacter.BoardView = {}

local frame
local rows = {}
local MAX_VISIBLE = 6
local currentBoard
local nearbyBulletins = {}

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
    frame:SetSize(320, 220)
    frame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -40, -340)
    if InCharacter.UI and InCharacter.UI.Theme and InCharacter.UI.Theme.ApplyParchmentBackdrop then
        InCharacter.UI.Theme.ApplyParchmentBackdrop(frame, 0.94)
    else
        frame:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        frame:SetBackdropColor(0, 0, 0, 0.75)
    end
    frame:Hide()
    tinsert(UISpecialFrames, "InCharacterBoardView")

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.title:SetPoint("TOPLEFT", 12, -10)
    frame.title:SetText("Bulletin board")

    frame.hint = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    frame.hint:SetPoint("TOPLEFT", 12, -26)
    frame.hint:SetText("Known bulletins at this board")

    for i = 1, MAX_VISIBLE do
        local row = CreateFrame("Button", nil, frame)
        row:SetSize(300, 22)
        row:SetPoint("TOPLEFT", 8, -44 - (i - 1) * 24)
        row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        row.text:SetPoint("LEFT", 4, 0)
        row.text:SetWidth(280)
        row.text:SetJustifyH("LEFT")
        rows[i] = row
    end

    local ticker = CreateFrame("Frame")
    ticker:RegisterEvent("ZONE_CHANGED")
    ticker:RegisterEvent("ZONE_CHANGED_INDOORS")
    ticker:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    ticker:SetScript("OnEvent", function()
        InCharacter.BoardView.CheckProximity()
    end)
    C_Timer.NewTicker(10, InCharacter.BoardView.CheckProximity)
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
            local seal = bulletin.scopeTier and ("[" .. bulletin.scopeTier:sub(1, 1) .. "] ") or ""
            row.text:SetText(seal .. (bulletin.title or "Bulletin"))
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
    frame:SetHeight(60 + shown * 24)
end

function InCharacter.BoardView.Show()
    InCharacter.BoardView.CheckProximity()
    if not currentBoard then
        InCharacter.Print("No bulletin board nearby.")
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
        InCharacter.Print("|cffffffff" .. (bulletin.title or "Bulletin") .. "|r")
        InCharacter.Print(bulletin.bodyText or "")
        nearbyBulletins[bulletin.id] = bulletin
        InCharacter.BoardView.Refresh()
    end
end

InCharacter.BoardView.OnNoticeFullReceived = InCharacter.BoardView.OnBulletinFullReceived
