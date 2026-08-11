Blackacre = Blackacre or {}
Blackacre.Boards = {}

-- Landmark bulletin boards (coords are map fractions 0–1; proximity is radius in those units).
local boards = {
    -- Eastern Kingdoms / Kalimdor capitals
    {
        id = "sw_heroes_call",
        zoneId = 84,
        coords = { x = 0.62, y = 0.72 },
        displayName = "Stormwind Hero's Call Bulletin Board",
        proximityRadius = 0.04,
        region = "Stormwind",
    },
    {
        id = "sw_trade_board",
        zoneId = 84,
        coords = { x = 0.61, y = 0.74 },
        displayName = "Stormwind Trade District Bulletin Board",
        proximityRadius = 0.03,
        region = "Stormwind",
    },
    {
        id = "if_board",
        zoneId = 87,
        coords = { x = 0.55, y = 0.47 },
        displayName = "Ironforge Military Ward Board",
        proximityRadius = 0.04,
        region = "Ironforge",
    },
    {
        id = "darn_board",
        zoneId = 89,
        coords = { x = 0.55, y = 0.52 },
        displayName = "Darnassus Craftsmen's Terrace Board",
        proximityRadius = 0.04,
        region = "Darnassus",
    },
    {
        id = "org_warchief",
        zoneId = 85,
        coords = { x = 0.49, y = 0.76 },
        displayName = "Orgrimmar Warchief's Command Bulletin Board",
        proximityRadius = 0.04,
        region = "Orgrimmar",
    },
    {
        id = "org_valley_board",
        zoneId = 85,
        coords = { x = 0.52, y = 0.88 },
        displayName = "Valley of Strength Bulletin Board",
        proximityRadius = 0.03,
        region = "Orgrimmar",
    },
    {
        id = "tb_board",
        zoneId = 88,
        coords = { x = 0.47, y = 0.50 },
        displayName = "Thunder Bluff Central Rise Board",
        proximityRadius = 0.04,
        region = "Thunder Bluff",
    },
    {
        id = "sm_board",
        zoneId = 110,
        coords = { x = 0.54, y = 0.50 },
        displayName = "Silvermoon Court of the Sun Board",
        proximityRadius = 0.04,
        region = "Silvermoon",
    },
    -- Outland / Northrend / Broken Isles
    {
        id = "shattrath_board",
        zoneId = 111,
        coords = { x = 0.53, y = 0.50 },
        displayName = "Shattrath Terrace of Light Board",
        proximityRadius = 0.04,
        region = "Shattrath",
    },
    {
        id = "dalaran_board",
        zoneId = 627,
        coords = { x = 0.48, y = 0.42 },
        displayName = "Dalaran Commission Bulletin Board",
        proximityRadius = 0.04,
        region = "Dalaran",
    },
    {
        id = "dalaran_northrend",
        zoneId = 125,
        coords = { x = 0.48, y = 0.42 },
        displayName = "Dalaran (Northrend) Notice Board",
        proximityRadius = 0.04,
        region = "Dalaran",
    },
    -- BfA capitals
    {
        id = "boralus_board",
        zoneId = 1161,
        coords = { x = 0.48, y = 0.62 },
        displayName = "Boralus Harbor Commission Board",
        proximityRadius = 0.04,
        region = "Boralus",
    },
    {
        id = "dazaralor_board",
        zoneId = 1165,
        coords = { x = 0.50, y = 0.45 },
        displayName = "Dazar'alor Great Seal Board",
        proximityRadius = 0.04,
        region = "Dazar'alor",
    },
    -- Shadowlands / Dragonflight / TWW
    {
        id = "oribos_board",
        zoneId = 1670,
        coords = { x = 0.50, y = 0.52 },
        displayName = "Oribos Ring of Fates Board",
        proximityRadius = 0.04,
        region = "Oribos",
    },
    {
        id = "valdrakken_board",
        zoneId = 2112,
        coords = { x = 0.48, y = 0.58 },
        displayName = "Valdrakken Seat of the Aspects Board",
        proximityRadius = 0.04,
        region = "Valdrakken",
    },
    {
        id = "dornogal_board",
        zoneId = 2339,
        coords = { x = 0.48, y = 0.52 },
        displayName = "Dornogal Foundation Hall Board",
        proximityRadius = 0.04,
        region = "Dornogal",
    },
}

function Blackacre.Boards.GetAll()
    return boards
end

function Blackacre.Boards.GetById(boardId)
    for _, board in ipairs(boards) do
        if board.id == boardId then
            return board
        end
    end
    return nil
end

function Blackacre.Boards.GetByRegion(region)
    local list = {}
    for _, board in ipairs(boards) do
        if board.region == region then
            list[#list + 1] = board
        end
    end
    return list
end

function Blackacre.Boards.GetKnownListText()
    local lines = {}
    local seen = {}
    for _, board in ipairs(boards) do
        local r = board.region or board.displayName
        if not seen[r] then
            seen[r] = true
            lines[#lines + 1] = "· " .. r
        end
    end
    table.sort(lines)
    return table.concat(lines, "\n")
end

function Blackacre.Boards.GetNearbyBoard()
    local zone = Blackacre.GetZoneContext()
    if not zone.zoneId or zone.zoneId == 0 then
        return nil
    end
    local best, bestDist
    for _, board in ipairs(boards) do
        if board.zoneId == zone.zoneId then
            local dx = (zone.coords.x or 0) - board.coords.x
            local dy = (zone.coords.y or 0) - board.coords.y
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist <= (board.proximityRadius or 0.04) then
                if not bestDist or dist < bestDist then
                    best, bestDist = board, dist
                end
            end
        end
    end
    return best
end

function Blackacre.Boards.GetBoardsInZone(zoneId)
    local list = {}
    zoneId = zoneId or (Blackacre.GetZoneContext().zoneId)
    for _, board in ipairs(boards) do
        if board.zoneId == zoneId then
            list[#list + 1] = board
        end
    end
    return list
end
