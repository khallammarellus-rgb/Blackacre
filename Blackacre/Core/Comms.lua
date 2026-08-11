Blackacre = Blackacre or {}
Blackacre.Comms = {}

local CTL = ChatThrottleLib
local AceSerializer = LibStub("AceSerializer-3.0")
local LibDeflate = LibDeflate

local addon
local CHANNEL_NAME = Blackacre.CHANNEL_NAME
local PREFIX = Blackacre.PREFIX
local SEP = Blackacre.SEP

local function EncodePayload(tbl)
    local serialized = AceSerializer:Serialize(tbl)
    local compressed = LibDeflate:CompressDeflate(serialized)
    return "Z:" .. LibDeflate:EncodeForPrint(compressed)
end

local function DecodePayload(msg)
    if not msg or msg:sub(1, 2) ~= "Z:" then
        return nil
    end
    local compressed = LibDeflate:DecodeForPrint(msg:sub(3))
    if not compressed then return nil end
    local serialized = LibDeflate:DecompressDeflate(compressed)
    if not serialized then return nil end
    local ok, data = AceSerializer:Deserialize(serialized)
    if ok then return data end
    return nil
end

local function EnsureChannel(retries)
    retries = retries or 3
    local channels = { GetChannelList() }
    local generalExists = false
    for i = 2, #channels, 3 do
        if channels[i] == "General" then
            generalExists = true
            break
        end
    end
    if not generalExists then
        C_Timer.After(2, function() EnsureChannel(retries) end)
        return nil
    end

    local channelID
    for i = 1, #channels, 3 do
        if channels[i + 1] and channels[i + 1]:lower() == CHANNEL_NAME:lower() then
            channelID = channels[i]
            local _, name = GetChannelName(channelID)
            if name == CHANNEL_NAME then
                return channelID
            end
            LeaveChannelByName(CHANNEL_NAME)
            break
        end
    end

    JoinTemporaryChannel(CHANNEL_NAME)
    channelID = select(1, GetChannelName(CHANNEL_NAME))
    if channelID and channelID > 0 then
        return channelID
    end
    if retries > 0 then
        C_Timer.After(1, function() EnsureChannel(retries - 1) end)
    end
    return nil
end

local function SendOnChannel(message, prio)
    local channelID = EnsureChannel()
    if not channelID then return false end
    Blackacre.addon:SendCommMessage(PREFIX, message, "CHANNEL", channelID, prio or "NORMAL")
    return true
end

local function SendWhisper(target, message, logged, prio)
    if logged then
        CTL:SendAddonMessageLogged(prio or "NORMAL", PREFIX, message, "WHISPER", target)
    else
        Blackacre.addon:SendCommMessage(PREFIX, message, "WHISPER", target, prio or "NORMAL")
    end
end

local function ZoneMatches(zoneId, subzone)
    local ctx = Blackacre.GetZoneContext()
    if zoneId and zoneId ~= 0 and ctx.zoneId ~= zoneId then
        return false
    end
    if subzone and subzone ~= "" and ctx.subzone ~= "" then
        return ctx.subzone:lower() == subzone:lower()
    end
    return true
end

local function CacheEntry(kind, entry)
    BlackacreDB.cache[kind] = BlackacreDB.cache[kind] or {}
    BlackacreDB.cache[kind][entry.id] = {
        data = entry,
        lastConfirmedAt = time(),
    }
end

local function GetCached(kind, id)
    local bucket = BlackacreDB.cache[kind]
    return bucket and bucket[id] and bucket[id].data or nil
end

function Blackacre.Comms.Init(addonRef)
    addon = addonRef
    addon:RegisterComm(PREFIX, "OnCommReceived")
end

function Blackacre.Comms.Enable()
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE")
    frame:SetScript("OnEvent", function(_, _, msg, channelName)
        if msg == "YOU_JOINED" and (channelName == "General" or channelName == "Trade") then
            C_Timer.After(1, EnsureChannel)
            frame:UnregisterAllEvents()
        end
    end)
    C_Timer.NewTicker(3600, EnsureChannel)
end

function Blackacre.Comms.SendPing()
    SendOnChannel("PING")
    Blackacre.Print("Ping sent on " .. CHANNEL_NAME .. ".")
end

function Blackacre.Comms.BroadcastBeacon(beacon)
    -- Invisible addon CHANNEL only — never say/yell/player chat.
    local breadcrumb = beacon.breadcrumb or beacon.shortText or ""
    if #breadcrumb > 120 then breadcrumb = breadcrumb:sub(1, 117) .. "..." end
    local nameField = ""
    if beacon.showNameZone or beacon.showNameProximity then
        nameField = beacon.charName or UnitName("player") or ""
    end
    local ping = table.concat({
        "BP",
        beacon.id,
        tostring(beacon.zoneId or 0),
        string.format("%.4f", (beacon.coords and beacon.coords.x) or 0),
        string.format("%.4f", (beacon.coords and beacon.coords.y) or 0),
        breadcrumb,
        tostring(beacon.expiresAt or 0),
        beacon.showNameZone and "1" or "0",
        beacon.showNameProximity and "1" or "0",
        nameField,
        beacon.ownerGUID or UnitGUID("player") or "",
    }, SEP)
    SendOnChannel(ping)
    CacheEntry("beacon", beacon)
    BlackacreDB.beacons[beacon.id] = beacon
end

function Blackacre.Comms.BroadcastRetract(id, kind)
    if kind == "notice" then kind = "bulletin" end
    SendOnChannel("RT" .. SEP .. kind .. SEP .. id)
end

function Blackacre.Comms.BroadcastBoardQuery(boardId)
    SendOnChannel("BQ" .. SEP .. boardId)
end

function Blackacre.Comms.SendBulletinFull(target, bulletin)
    local payload = EncodePayload({ opcode = "NF", bulletin = bulletin, notice = bulletin })
    SendWhisper(target, payload, true, "BULK")
end

Blackacre.Comms.SendNoticeFull = Blackacre.Comms.SendBulletinFull

function Blackacre.Comms.RequestBulletinFull(sender, bulletinId)
    SendWhisper(sender, "FN" .. SEP .. bulletinId, false)
end

Blackacre.Comms.RequestNoticeFull = Blackacre.Comms.RequestBulletinFull

function Blackacre.Comms.AnnounceBulletin(bulletin)
    local summary = table.concat({
        "NS", bulletin.id, bulletin.boardId, bulletin.title, bulletin.scopeTier,
        tostring(bulletin.expiresAt),
    }, SEP)
    SendOnChannel(summary)
    CacheEntry("bulletin", bulletin)
    BlackacreDB.bulletins = BlackacreDB.bulletins or {}
    BlackacreDB.bulletins[bulletin.id] = bulletin
    BlackacreDB.notices = BlackacreDB.bulletins
end

Blackacre.Comms.AnnounceNotice = Blackacre.Comms.AnnounceBulletin

local function ReceiveBeaconsEnabled()
    local p = Blackacre.CharDB and Blackacre.CharDB.presence
    if p and p.receiveBeacons == false then return false end
    return true
end

local function HandleBeaconPing(fields, sender)
    if not ReceiveBeaconsEnabled() then return end
    -- BP id zoneId x y breadcrumb expiresAt showNameZone showNameProximity name guid
    local id = fields[2]
    local zoneId = tonumber(fields[3])
    local x = tonumber(fields[4])
    local y = tonumber(fields[5])
    local breadcrumb = fields[6] or "A presence stirs nearby."
    local expiresAt = tonumber(fields[7])
    local showNameZone = fields[8] == "1"
    local showNameProximity = fields[9] == "1"
    local nameField = fields[10] or ""
    local guid = fields[11] or sender
    if not id then return end
    if expiresAt and expiresAt < time() then return end
    -- Zone-only filter (no subzone required for lite beacons)
    local ctx = Blackacre.GetZoneContext()
    if zoneId and zoneId ~= 0 and ctx.zoneId ~= zoneId then return end
    if Blackacre.IsMuted(sender) then return end

    local displayName = nil
    if nameField ~= "" and (showNameZone or showNameProximity) then
        displayName = nameField
    end

    local beacon = {
        id = id,
        ownerGUID = guid,
        charName = displayName,
        senderName = sender,
        shortText = breadcrumb,
        breadcrumb = breadcrumb,
        zoneId = zoneId,
        coords = { x = x or 0, y = y or 0 },
        expiresAt = expiresAt,
        showNameZone = showNameZone,
        showNameProximity = showNameProximity,
        status = Blackacre.STATUS.ACTIVE,
        receivedAt = time(),
    }
    -- Dedupe by ownerGUID: one beacon per emitter
    BlackacreDB.beacons = BlackacreDB.beacons or {}
    for bid, b in pairs(BlackacreDB.beacons) do
        if b.ownerGUID == guid and bid ~= id then
            BlackacreDB.beacons[bid] = nil
            if BlackacreDB.cache and BlackacreDB.cache.beacon then
                BlackacreDB.cache.beacon[bid] = nil
            end
        end
    end
    BlackacreDB.beacons[id] = beacon
    CacheEntry("beacon", beacon)
    if Blackacre.Flyout and Blackacre.Flyout.OnBeaconDiscovered then
        Blackacre.Flyout.OnBeaconDiscovered(beacon)
    end
    if Blackacre.BeaconHead and Blackacre.BeaconHead.OnCacheChanged then
        Blackacre.BeaconHead.OnCacheChanged()
    end
    if Blackacre.BeaconPins and Blackacre.BeaconPins.Refresh then
        Blackacre.BeaconPins.Refresh()
    end
end

local function HandleBulletinSummary(fields, sender)
    local id, boardId, title, scopeTier, expiresAt = fields[2], fields[3], fields[4], fields[5], tonumber(fields[6])
    if not id or not boardId then return end
    if expiresAt and expiresAt < time() then return end
    if Blackacre.IsMuted(sender) then return end

    local bulletin = {
        id = id,
        ownerGUID = UnitGUID(sender) or sender,
        charName = sender,
        title = title or "Bulletin",
        scopeTier = scopeTier or Blackacre.SCOPE.INDIVIDUAL,
        boardId = boardId,
        expiresAt = expiresAt,
        status = Blackacre.STATUS.ACTIVE,
        receivedAt = time(),
    }
    CacheEntry("bulletin", bulletin)
    CacheEntry("notice", bulletin)
    if Blackacre.BoardView and Blackacre.BoardView.OnBulletinDiscovered then
        Blackacre.BoardView.OnBulletinDiscovered(bulletin)
    elseif Blackacre.BoardView and Blackacre.BoardView.OnNoticeDiscovered then
        Blackacre.BoardView.OnNoticeDiscovered(bulletin)
    end
end

function addon:OnCommReceived(prefix, message, distribution, sender)
    if prefix ~= PREFIX or not message then return end
    if sender == UnitName("player") then return end
    if C_FriendList.IsIgnored(sender) then return end

    if message == "PING" then
        SendWhisper(sender, "PONG", false)
        Blackacre.Print("Comms pong from " .. sender)
        return
    end
    if message == "PONG" then
        Blackacre.Print("Comms pong from " .. sender)
        return
    end

    local decoded = DecodePayload(message)
    if decoded then
        if decoded.opcode == "NF" and (decoded.bulletin or decoded.notice) then
            local b = decoded.bulletin or decoded.notice
            CacheEntry("bulletin", b)
            CacheEntry("notice", b)
            if Blackacre.BoardView and Blackacre.BoardView.OnBulletinFullReceived then
                Blackacre.BoardView.OnBulletinFullReceived(b)
            elseif Blackacre.BoardView and Blackacre.BoardView.OnNoticeFullReceived then
                Blackacre.BoardView.OnNoticeFullReceived(b)
            end
        elseif decoded.opcode == "IC_SUM" then
            if Blackacre.Share and Blackacre.Share.OnPeerSummary then
                Blackacre.Share.OnPeerSummary(sender, decoded)
            end
        end
        return
    end

    local fields = { strsplit(SEP, message) }
    local opcode = fields[1]

    if opcode == "BP" then
        HandleBeaconPing(fields, sender)
    elseif opcode == "RT" then
        local kind, id = fields[2], fields[3]
        if kind == "notice" then kind = "bulletin" end
        if kind and id then
            Blackacre.Lifecycle.HandleRemoteRetract(kind, id)
        end
    elseif opcode == "BQ" then
        local boardId = fields[2]
        Blackacre.Comms.RespondToBoardQuery(sender, boardId)
    elseif opcode == "BR" then
        HandleBulletinSummary(fields, sender)
    elseif opcode == "NS" then
        HandleBulletinSummary(fields, sender)
    elseif opcode == "FN" then
        local bulletinId = fields[2]
        local bulletin = (BlackacreDB.bulletins and BlackacreDB.bulletins[bulletinId])
            or (BlackacreDB.notices and BlackacreDB.notices[bulletinId])
            or GetCached("bulletin", bulletinId)
            or GetCached("notice", bulletinId)
        if bulletin then
            Blackacre.Comms.SendBulletinFull(sender, bulletin)
        end
    elseif opcode == "SQ" then
        Blackacre.Comms.SendSummaryTo(sender)
    end
end

function Blackacre.Comms.SendSummaryTo(target)
    if not target or target == "" then return end
    if not Blackacre.Share or not Blackacre.Share.Export then return end
    local payload = Blackacre.Share.Export.BuildPeerPayload()
    local encoded = EncodePayload(payload)
    SendWhisper(target, encoded, false, "NORMAL")
end

function Blackacre.Comms.RequestSummary(target)
    if not target or target == "" then
        Blackacre.Print("Usage: /ic share PlayerName")
        return
    end
    SendWhisper(target, "SQ", false, "NORMAL")
    Blackacre.Print("Requested Blackacre summary from " .. target .. ".")
end

function Blackacre.Comms.RespondToBoardQuery(requester, boardId)
    if not boardId then return end
    local store = BlackacreDB.bulletins or BlackacreDB.notices or {}
    for _, bulletin in pairs(store) do
        if bulletin.boardId == boardId and bulletin.status == Blackacre.STATUS.ACTIVE then
            if not bulletin.expiresAt or bulletin.expiresAt >= time() then
                local summary = table.concat({
                    "BR", bulletin.id, bulletin.boardId, bulletin.title, bulletin.scopeTier,
                    tostring(bulletin.expiresAt or 0),
                }, SEP)
                SendWhisper(requester, summary, false)
            end
        end
    end
    local cache = (BlackacreDB.cache and (BlackacreDB.cache.bulletin or BlackacreDB.cache.notice))
    if cache then
        for _, wrapped in pairs(cache) do
            local bulletin = wrapped.data
            if bulletin.boardId == boardId and bulletin.status == Blackacre.STATUS.ACTIVE then
                if not bulletin.expiresAt or bulletin.expiresAt >= time() then
                    local summary = table.concat({
                        "BR", bulletin.id, bulletin.boardId, bulletin.title, bulletin.scopeTier,
                        tostring(bulletin.expiresAt or 0), tostring(wrapped.lastConfirmedAt or time()),
                    }, SEP)
                    SendWhisper(requester, summary, false)
                end
            end
        end
    end
end