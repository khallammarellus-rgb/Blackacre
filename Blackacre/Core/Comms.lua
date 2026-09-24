Blackacre = Blackacre or {}
Blackacre.Comms = {}

local AceSerializer = LibStub("AceSerializer-3.0")
-- LibDeflate registers with LibStub and returns the library from the file.
-- The addon loader discards that return, so the global stays nil.
local LibDeflate = LibStub("LibDeflate")

local CHANNEL_NAME = Blackacre.CHANNEL_NAME or "Blackacre"
local PREFIX = Blackacre.PREFIX
local SEP = Blackacre.SEP
local OLD_CHANNEL = "BA_Channel"

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

local CHANNEL_NAME_LOWER = CHANNEL_NAME:lower()

local function ChannelNameMatch(name)
    return name and name:lower() == CHANNEL_NAME_LOWER
end

local cachedChannelID
local leftLegacyChannel = false
local channelHidden = false

local function HideChannelFromChat()
    if channelHidden then return end
    local touched = false
    for i = 1, (NUM_CHAT_WINDOWS or 10) do
        local f = _G["ChatFrame" .. i]
        if f and ChatFrame_RemoveChannel then
            pcall(ChatFrame_RemoveChannel, f, CHANNEL_NAME)
            touched = true
        end
    end
    if touched then
        channelHidden = true
    end
end

local function KnownChannelID()
    if cachedChannelID and cachedChannelID > 0 then
        local _, name = GetChannelName(cachedChannelID)
        if ChannelNameMatch(name) then
            return cachedChannelID
        end
        cachedChannelID = nil
        channelHidden = false
    end
    local id = GetChannelName(CHANNEL_NAME)
    if id and id > 0 then
        cachedChannelID = id
        return id
    end
    return nil
end

local function FilterBlackacreChat(_, _, msg, sender, language, _, _, _, _, _, channelName)
    if ChannelNameMatch(channelName) then
        return true
    end
end

local chatFilterInstalled
local function InstallChatFilter()
    if chatFilterInstalled then return end
    chatFilterInstalled = true
    if ChatFrame_AddMessageEventFilter then
        ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", FilterBlackacreChat)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_NOTICE", FilterBlackacreChat)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_JOIN", FilterBlackacreChat)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_LEAVE", FilterBlackacreChat)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_NOTICE_USER", FilterBlackacreChat)
    end
end

local function EnsureChannel(retries)
    retries = retries or 3
    -- Leave the old channel name once. Doing it on every send is a server request.
    if not leftLegacyChannel then
        leftLegacyChannel = true
        pcall(LeaveChannelByName, OLD_CHANNEL)
    end
    local existing = KnownChannelID()
    if existing then
        HideChannelFromChat()
        return existing
    end

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

    JoinTemporaryChannel(CHANNEL_NAME)
    local channelID = GetChannelName(CHANNEL_NAME)
    if channelID and channelID > 0 then
        cachedChannelID = channelID
        HideChannelFromChat()
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
    if not Blackacre.addon then return false end
    Blackacre.addon:SendCommMessage(PREFIX, message, "CHANNEL", channelID, prio or "NORMAL")
    return true
end

local function SendWhisper(target, message, _logged, prio)
    -- AceComm splits long payloads and sends them through ChatThrottleLib.
    -- There is no SendAddonMessageLogged on CTL; calling it errored every full bulletin.
    if not Blackacre.addon then return end
    Blackacre.addon:SendCommMessage(PREFIX, message, "WHISPER", target, prio or "NORMAL")
end

local function CacheEntry(kind, entry)
    BlackacreDB.cache = BlackacreDB.cache or {}
    BlackacreDB.cache[kind] = BlackacreDB.cache[kind] or {}
    BlackacreDB.cache[kind][entry.id] = {
        data = entry,
        lastConfirmedAt = time(),
    }
end

local function GetCached(kind, id)
    local bucket = BlackacreDB.cache and BlackacreDB.cache[kind]
    return bucket and bucket[id] and bucket[id].data or nil
end

function Blackacre.Comms.Init(addonRef)
    local ace = addonRef or Blackacre.addon
    if not ace then return end
    ace:RegisterComm(PREFIX, Blackacre.Comms.OnCommReceived)
    InstallChatFilter()
end

function Blackacre.Comms.Enable()
    InstallChatFilter()
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:SetScript("OnEvent", function(_, event, msg, channelName)
        if event == "PLAYER_ENTERING_WORLD" then
            C_Timer.After(2, function()
                local id = EnsureChannel()
                HideChannelFromChat()
                if id and Blackacre.Print then
                    Blackacre.Print("Blackacre comms joined")
                end
            end)
            return
        end
        if msg == "YOU_JOINED" and (channelName == "General" or channelName == "Trade" or ChannelNameMatch(channelName)) then
            C_Timer.After(1, function()
                EnsureChannel()
                HideChannelFromChat()
            end)
        end
    end)
    C_Timer.NewTicker(3600, function()
        -- Chat settings can put the hidden channel back. Re-hide hourly, not per message.
        channelHidden = false
        EnsureChannel()
    end)
    C_Timer.After(3, EnsureChannel)
end

function Blackacre.Comms.SendPing()
    local id = EnsureChannel()
    HideChannelFromChat()
    SendOnChannel("PING")
    if id then
        Blackacre.Print("Comms pinged")
    else
        Blackacre.Print("Attempting to join")
    end
end

function Blackacre.Comms.BroadcastBeacon(beacon)
    local payload = EncodePayload({
        opcode = "BC",
        id = beacon.id,
        ownerGUID = beacon.ownerGUID,
        charName = beacon.charName,
        zoneId = beacon.zoneId,
        zoneName = beacon.zoneName,
        subzone = beacon.subzone,
        coords = beacon.coords,
        locKind = beacon.locKind,
        rumor = beacon.rumor,
        lead = beacon.lead,
        found = beacon.found,
        shortText = beacon.shortText,
        fullText = beacon.fullText,
        expiresAt = beacon.expiresAt,
        templateId = beacon.templateId,
    })
    SendOnChannel(payload)
    CacheEntry("beacon", beacon)
    BlackacreDB.beacons = BlackacreDB.beacons or {}
    BlackacreDB.beacons[beacon.id] = beacon
end

function Blackacre.Comms.BroadcastRetract(id, kind)
    if kind == "notice" then kind = "bulletin" end
    SendOnChannel("RT" .. SEP .. kind .. SEP .. id)
end

function Blackacre.Comms.BroadcastBoardQuery(boardId)
    SendOnChannel("BQ" .. SEP .. (boardId or ""))
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
    local payload = EncodePayload({
        opcode = "NSZ",
        id = bulletin.id,
        title = bulletin.title,
        bodyText = bulletin.bodyText,
        postedZones = bulletin.postedZones,
        boardId = bulletin.boardId,
        scopeTier = bulletin.scopeTier,
        expiresAt = bulletin.expiresAt,
        charName = bulletin.charName,
        ownerGUID = bulletin.ownerGUID,
        stationary = bulletin.stationary,
        waxSeal = bulletin.waxSeal,
        font = bulletin.font,
    })
    SendOnChannel(payload)
    CacheEntry("bulletin", bulletin)
    BlackacreDB.bulletins = BlackacreDB.bulletins or {}
    BlackacreDB.bulletins[bulletin.id] = bulletin
    BlackacreDB.notices = BlackacreDB.bulletins
end

Blackacre.Comms.AnnounceNotice = Blackacre.Comms.AnnounceBulletin

local function SeekingOn()
    local p = Blackacre.CharDB and Blackacre.CharDB.presence
    if p and p.seekingEnabled == false then return false end
    if p and p.receiveBeacons == false then return false end
    return true
end

local function ZoneNameMatch(a, b)
    if not a or not b or a == "" or b == "" then return false end
    return a:lower() == b:lower()
end

local function HandleBeaconPayload(data, sender)
    if not SeekingOn() then return end
    if not data or not data.id then return end
    if data.expiresAt and data.expiresAt < time() then return end
    if Blackacre.IsMuted(sender) then return end
    local ctx = Blackacre.GetZoneContext()
    local sameId = data.zoneId and data.zoneId ~= 0 and ctx.zoneId == data.zoneId
    local sameName = ZoneNameMatch(data.zoneName, ctx.zoneName)
    if not sameId and not sameName then return end

    local beacon = {
        id = data.id,
        ownerGUID = data.ownerGUID or sender,
        charName = data.charName,
        senderName = sender,
        zoneId = data.zoneId,
        zoneName = data.zoneName,
        subzone = data.subzone,
        coords = data.coords or { x = 0, y = 0 },
        locKind = data.locKind,
        rumor = data.rumor,
        lead = data.lead,
        found = data.found,
        shortText = data.shortText,
        fullText = data.fullText,
        expiresAt = data.expiresAt,
        status = Blackacre.STATUS.ACTIVE,
        receivedAt = time(),
    }
    BlackacreDB.beacons = BlackacreDB.beacons or {}
    for bid, b in pairs(BlackacreDB.beacons) do
        if b.ownerGUID == beacon.ownerGUID and bid ~= beacon.id then
            BlackacreDB.beacons[bid] = nil
        end
    end
    BlackacreDB.beacons[beacon.id] = beacon
    CacheEntry("beacon", beacon)
    if Blackacre.Flyout and Blackacre.Flyout.OnBeaconDiscovered then
        Blackacre.Flyout.OnBeaconDiscovered(beacon)
    end
    if Blackacre.BeaconHead and Blackacre.BeaconHead.OnCacheChanged then
        Blackacre.BeaconHead.OnCacheChanged(beacon)
    end
    if Blackacre.BeaconPins and Blackacre.BeaconPins.Refresh then
        Blackacre.BeaconPins.Refresh()
    end
end

local function HandleBulletinPayload(data, sender)
    if not SeekingOn() then return end
    if not data or not data.id then return end
    if data.expiresAt and data.expiresAt < time() then return end
    if Blackacre.IsMuted(sender) then return end
    local bulletin = {
        id = data.id,
        ownerGUID = data.ownerGUID or sender,
        charName = data.charName or sender,
        title = data.title or "Bulletin",
        bodyText = data.bodyText,
        postedZones = data.postedZones,
        boardId = data.boardId,
        scopeTier = data.scopeTier or Blackacre.SCOPE.INDIVIDUAL,
        expiresAt = data.expiresAt,
        stationary = data.stationary,
        waxSeal = data.waxSeal,
        font = data.font,
        status = Blackacre.STATUS.ACTIVE,
        receivedAt = time(),
        senderName = sender,
    }
    CacheEntry("bulletin", bulletin)
    CacheEntry("notice", bulletin)
    if Blackacre.BoardView and Blackacre.BoardView.OnBulletinDiscovered then
        Blackacre.BoardView.OnBulletinDiscovered(bulletin)
    end
    if Blackacre.InnBoard and Blackacre.InnBoard.OnBulletinDiscovered then
        Blackacre.InnBoard.OnBulletinDiscovered(bulletin)
    end
end

function Blackacre.Comms.OnCommReceived(prefix, message, distribution, sender)
    if prefix ~= PREFIX or not message then return end
    if sender == UnitName("player") then return end
    if C_FriendList and C_FriendList.IsIgnored and C_FriendList.IsIgnored(sender) then return end

    if message == "PING" then
        SendWhisper(sender, "PONG", false)
        return
    end
    if message == "PONG" then
        Blackacre.Print("Comms ping from " .. sender)
        return
    end

    local decoded = DecodePayload(message)
    if decoded then
        if decoded.opcode == "BC" then
            HandleBeaconPayload(decoded, sender)
        elseif decoded.opcode == "NSZ" then
            HandleBulletinPayload(decoded, sender)
        elseif decoded.opcode == "NF" and (decoded.bulletin or decoded.notice) then
            local b = decoded.bulletin or decoded.notice
            CacheEntry("bulletin", b)
            CacheEntry("notice", b)
            if Blackacre.BoardView and Blackacre.BoardView.OnBulletinFullReceived then
                Blackacre.BoardView.OnBulletinFullReceived(b)
            end
            if Blackacre.InnBoard and Blackacre.InnBoard.OnBulletinFullReceived then
                Blackacre.InnBoard.OnBulletinFullReceived(b)
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
    if opcode == "RT" then
        local kind, id = fields[2], fields[3]
        if kind == "notice" then kind = "bulletin" end
        if kind and id then
            Blackacre.Lifecycle.HandleRemoteRetract(kind, id)
        end
    elseif opcode == "BQ" then
        Blackacre.Comms.RespondToBoardQuery(sender, fields[2])
    elseif opcode == "FN" then
        local bulletinId = fields[2]
        local bulletin = (BlackacreDB.bulletins and BlackacreDB.bulletins[bulletinId])
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
        local zones = bulletin.postedZones
        local match = bulletin.boardId == boardId
        if not match and type(zones) == "table" then
            for i = 1, #zones do
                if zones[i] == boardId then match = true break end
            end
        end
        if match and bulletin.status == Blackacre.STATUS.ACTIVE then
            if not bulletin.expiresAt or bulletin.expiresAt >= time() then
                Blackacre.Comms.SendBulletinFull(requester, bulletin)
            end
        end
    end
end
