Blackacre = Blackacre or {}
Blackacre.Lifecycle = {}

local function BeaconTTL()
    return (Blackacre.BeaconConfig and Blackacre.BeaconConfig.TTL) or (24 * 60 * 60)
end

local function ReemitCooldown()
    return (Blackacre.BeaconConfig and Blackacre.BeaconConfig.REEMIT_COOLDOWN) or (15 * 60)
end

local MAX_BULLETIN_DAYS = 7

function Blackacre.Lifecycle.GetBeaconTTL()
    return BeaconTTL()
end

function Blackacre.Lifecycle.GetBulletinTTLSeconds()
    local days = Blackacre.CharDB.settings.bulletinTTLDays
        or Blackacre.CharDB.settings.noticeTTLDays
        or 3
    days = math.min(math.max(days, 1), MAX_BULLETIN_DAYS)
    return days * 24 * 60 * 60
end

Blackacre.Lifecycle.GetNoticeTTLSeconds = Blackacre.Lifecycle.GetBulletinTTLSeconds

function Blackacre.Lifecycle.EnsurePresenceDB()
    Blackacre.CharDB.presence = Blackacre.CharDB.presence or {
        receiveBeacons = true,
        lastEmitAt = nil,
        activeBeaconId = nil,
        showNameZone = true,
        showNameProximity = true,
    }
    if Blackacre.CharDB.presence.receiveBeacons == nil then
        Blackacre.CharDB.presence.receiveBeacons = true
    end
    if BlackacreDB.notices and not BlackacreDB.bulletins then
        BlackacreDB.bulletins = BlackacreDB.notices
    end
    BlackacreDB.bulletins = BlackacreDB.bulletins or {}
    BlackacreDB.notices = BlackacreDB.bulletins
    BlackacreDB.beacons = BlackacreDB.beacons or {}
    return Blackacre.CharDB.presence
end

function Blackacre.Lifecycle.Init()
    Blackacre.Lifecycle.EnsurePresenceDB()
    C_Timer.NewTicker(60, Blackacre.Lifecycle.Sweep)
end

local function StoreFor(kind)
    if kind == "beacon" then
        return BlackacreDB.beacons
    end
    return BlackacreDB.bulletins or BlackacreDB.notices
end

local function NormalizeKind(kind)
    if kind == "notice" then return "bulletin" end
    return kind
end

function Blackacre.Lifecycle.Sweep()
    local now = time()
    for id, beacon in pairs(BlackacreDB.beacons or {}) do
        if beacon.expiresAt and beacon.expiresAt < now then
            if beacon.ownerGUID == UnitGUID("player") then
                Blackacre.Lifecycle.ExpireOwned("beacon", id)
            else
                BlackacreDB.beacons[id] = nil
                if BlackacreDB.cache and BlackacreDB.cache.beacon then
                    BlackacreDB.cache.beacon[id] = nil
                end
            end
        end
    end
    for id, bulletin in pairs(BlackacreDB.bulletins or {}) do
        if bulletin.expiresAt and bulletin.expiresAt < now and bulletin.status == Blackacre.STATUS.ACTIVE then
            if bulletin.ownerGUID == UnitGUID("player") then
                Blackacre.Lifecycle.ExpireOwned("bulletin", id)
            else
                BlackacreDB.bulletins[id] = nil
            end
        end
    end
    if BlackacreDB.cache then
        for _, bucket in pairs(BlackacreDB.cache) do
            for id, wrapped in pairs(bucket) do
                local entry = wrapped.data
                if entry and entry.expiresAt and entry.expiresAt < now then
                    bucket[id] = nil
                end
            end
        end
    end
    if Blackacre.Flyout and Blackacre.Flyout.Refresh then Blackacre.Flyout.Refresh() end
    if Blackacre.BoardView and Blackacre.BoardView.Refresh then Blackacre.BoardView.Refresh() end
    if Blackacre.BeaconHead and Blackacre.BeaconHead.OnCacheChanged then
        Blackacre.BeaconHead.OnCacheChanged()
    end
    if Blackacre.BeaconPins and Blackacre.BeaconPins.Refresh then
        Blackacre.BeaconPins.Refresh()
    end
end

function Blackacre.Lifecycle.ExpireOwned(kind, id)
    kind = NormalizeKind(kind)
    local store = StoreFor(kind)
    local entry = store[id]
    if not entry then return end
    entry.status = Blackacre.STATUS.EXPIRED
    store[id] = nil
    if kind == "beacon" then
        local p = Blackacre.Lifecycle.EnsurePresenceDB()
        if p.activeBeaconId == id then p.activeBeaconId = nil end
    end
    Blackacre.History.SaveDraft(kind, entry)
end

function Blackacre.Lifecycle.DeleteOwned(kind, id)
    kind = NormalizeKind(kind)
    local store = StoreFor(kind)
    local entry = store[id]
    if entry then
        entry.status = Blackacre.STATUS.DRAFT
        store[id] = nil
        Blackacre.History.SaveDraft(kind, entry)
    end
    if kind == "beacon" then
        local p = Blackacre.Lifecycle.EnsurePresenceDB()
        if p.activeBeaconId == id then p.activeBeaconId = nil end
    end
    Blackacre.Comms.BroadcastRetract(id, kind)
    if BlackacreDB.cache then
        if BlackacreDB.cache[kind] then BlackacreDB.cache[kind][id] = nil end
        if kind == "bulletin" and BlackacreDB.cache.notice then
            BlackacreDB.cache.notice[id] = nil
        end
    end
    if Blackacre.Flyout and Blackacre.Flyout.Refresh then Blackacre.Flyout.Refresh() end
    if Blackacre.BoardView and Blackacre.BoardView.Refresh then Blackacre.BoardView.Refresh() end
    if Blackacre.BeaconHead and Blackacre.BeaconHead.OnCacheChanged then
        Blackacre.BeaconHead.OnCacheChanged()
    end
    if Blackacre.BeaconPins and Blackacre.BeaconPins.Refresh then
        Blackacre.BeaconPins.Refresh()
    end
end

function Blackacre.Lifecycle.HandleRemoteRetract(kind, id)
    kind = NormalizeKind(kind)
    if BlackacreDB.cache then
        if BlackacreDB.cache[kind] then BlackacreDB.cache[kind][id] = nil end
        if kind == "bulletin" and BlackacreDB.cache.notice then
            BlackacreDB.cache.notice[id] = nil
        end
    end
    if BlackacreDB.beacons then BlackacreDB.beacons[id] = nil end
    if kind == "beacon" then
        if Blackacre.Flyout and Blackacre.Flyout.Refresh then Blackacre.Flyout.Refresh() end
        if Blackacre.BeaconHead and Blackacre.BeaconHead.OnCacheChanged then
            Blackacre.BeaconHead.OnCacheChanged()
        end
        if Blackacre.BeaconPins and Blackacre.BeaconPins.Refresh then
            Blackacre.BeaconPins.Refresh()
        end
    else
        if Blackacre.BoardView and Blackacre.BoardView.Refresh then
            Blackacre.BoardView.Refresh()
        end
    end
end

function Blackacre.Lifecycle.CanEmitBeacon()
    local p = Blackacre.Lifecycle.EnsurePresenceDB()
    local now = time()
    if p.activeBeaconId and BlackacreDB.beacons[p.activeBeaconId] then
        local b = BlackacreDB.beacons[p.activeBeaconId]
        if b.expiresAt and b.expiresAt > now then
            return false, "You already have an active beacon. Delete it before emitting another."
        end
        p.activeBeaconId = nil
    end
    if p.lastEmitAt and (now - p.lastEmitAt) < ReemitCooldown() then
        local left = ReemitCooldown() - (now - p.lastEmitAt)
        local m = math.floor(left / 60)
        local s = left % 60
        return false, string.format("You must wait %d:%02d before emitting another beacon.", m, s)
    end
    return true
end

function Blackacre.Lifecycle.CreateBeacon(templateId, slotValues, opts)
    opts = opts or {}
    if not (Blackacre.SentenceTemplates and Blackacre.SentenceTemplates.Resolve) then
        Blackacre.Print("Beacons require the Blackacre Presence package.")
        return nil
    end
    local resolved = Blackacre.SentenceTemplates.Resolve(templateId, slotValues, Blackacre.CharDB.residence)
    if not resolved then return nil end
    local ctx = Blackacre.GetZoneContext()
    local now = time()
    local p = Blackacre.Lifecycle.EnsurePresenceDB()
    return {
        id = Blackacre.NewID(),
        ownerGUID = UnitGUID("player"),
        charName = Blackacre.GetCharName(),
        templateId = templateId,
        slots = resolved.slots,
        fullText = resolved.fullText,
        shortText = resolved.shortText,
        breadcrumb = resolved.shortText,
        zoneId = ctx.zoneId,
        subzone = ctx.subzone,
        coords = ctx.coords,
        createdAt = now,
        expiresAt = now + BeaconTTL(),
        status = Blackacre.STATUS.ACTIVE,
        showNameZone = opts.showNameZone,
        showNameProximity = opts.showNameProximity,
    }
end

function Blackacre.Lifecycle.CreateBulletin(title, bodyText, boardId, scopeTier)
    local now = time()
    return {
        id = Blackacre.NewID(),
        ownerGUID = UnitGUID("player"),
        charName = Blackacre.GetCharName(),
        title = title,
        bodyText = bodyText,
        scopeTier = scopeTier or Blackacre.SCOPE.INDIVIDUAL,
        boardId = boardId,
        createdAt = now,
        expiresAt = now + Blackacre.Lifecycle.GetBulletinTTLSeconds(),
        editCount = 0,
        status = Blackacre.STATUS.ACTIVE,
    }
end

Blackacre.Lifecycle.CreateNotice = Blackacre.Lifecycle.CreateBulletin

function Blackacre.Lifecycle.PostBeacon(beacon)
    local ok, err = Blackacre.Lifecycle.CanEmitBeacon()
    if not ok then
        Blackacre.Print(err)
        return false
    end
    local guid = UnitGUID("player")
    for id, b in pairs(BlackacreDB.beacons) do
        if b.ownerGUID == guid then
            BlackacreDB.beacons[id] = nil
        end
    end
    local p = Blackacre.Lifecycle.EnsurePresenceDB()
    if beacon.showNameZone == nil then beacon.showNameZone = p.showNameZone ~= false end
    if beacon.showNameProximity == nil then beacon.showNameProximity = p.showNameProximity ~= false end
    BlackacreDB.beacons[beacon.id] = beacon
    p.activeBeaconId = beacon.id
    p.lastEmitAt = time()
    Blackacre.Comms.BroadcastBeacon(beacon)
    if Blackacre.Flyout and Blackacre.Flyout.Refresh then Blackacre.Flyout.Refresh() end
    if Blackacre.BeaconPins and Blackacre.BeaconPins.Refresh then Blackacre.BeaconPins.Refresh() end
    if Blackacre.BeaconHead and Blackacre.BeaconHead.OnCacheChanged then
        Blackacre.BeaconHead.OnCacheChanged()
    end
    return true
end

function Blackacre.Lifecycle.StopBeacon()
    local p = Blackacre.Lifecycle.EnsurePresenceDB()
    local id = p.activeBeaconId
    if not id or not BlackacreDB.beacons[id] then
        Blackacre.Print("You have no active beacon.")
        return
    end
    Blackacre.Lifecycle.DeleteOwned("beacon", id)
    Blackacre.Print("Beacon withdrawn.")
end

function Blackacre.Lifecycle.PostBulletin(bulletin)
    BlackacreDB.bulletins = BlackacreDB.bulletins or {}
    BlackacreDB.bulletins[bulletin.id] = bulletin
    BlackacreDB.notices = BlackacreDB.bulletins
    Blackacre.Comms.AnnounceBulletin(bulletin)
    if Blackacre.BoardView and Blackacre.BoardView.Refresh then
        Blackacre.BoardView.Refresh()
    end
end

Blackacre.Lifecycle.PostNotice = Blackacre.Lifecycle.PostBulletin

function Blackacre.Lifecycle.GetActiveOwnedBeacon()
    local p = Blackacre.Lifecycle.EnsurePresenceDB()
    if not p.activeBeaconId then return nil end
    return BlackacreDB.beacons[p.activeBeaconId]
end
