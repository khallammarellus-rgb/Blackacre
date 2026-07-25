InCharacter = InCharacter or {}
InCharacter.Lifecycle = {}

local function BeaconTTL()
    return (InCharacter.BeaconConfig and InCharacter.BeaconConfig.TTL) or (24 * 60 * 60)
end

local function ReemitCooldown()
    return (InCharacter.BeaconConfig and InCharacter.BeaconConfig.REEMIT_COOLDOWN) or (15 * 60)
end

local MAX_BULLETIN_DAYS = 7

function InCharacter.Lifecycle.GetBeaconTTL()
    return BeaconTTL()
end

function InCharacter.Lifecycle.GetBulletinTTLSeconds()
    local days = InCharacter.CharDB.settings.bulletinTTLDays
        or InCharacter.CharDB.settings.noticeTTLDays
        or 3
    days = math.min(math.max(days, 1), MAX_BULLETIN_DAYS)
    return days * 24 * 60 * 60
end

InCharacter.Lifecycle.GetNoticeTTLSeconds = InCharacter.Lifecycle.GetBulletinTTLSeconds

function InCharacter.Lifecycle.EnsurePresenceDB()
    InCharacter.CharDB.presence = InCharacter.CharDB.presence or {
        receiveBeacons = true,
        lastEmitAt = nil,
        activeBeaconId = nil,
        showNameZone = true,
        showNameProximity = true,
    }
    if InCharacter.CharDB.presence.receiveBeacons == nil then
        InCharacter.CharDB.presence.receiveBeacons = true
    end
    if InCharacterDB.notices and not InCharacterDB.bulletins then
        InCharacterDB.bulletins = InCharacterDB.notices
    end
    InCharacterDB.bulletins = InCharacterDB.bulletins or {}
    InCharacterDB.notices = InCharacterDB.bulletins
    InCharacterDB.beacons = InCharacterDB.beacons or {}
    return InCharacter.CharDB.presence
end

function InCharacter.Lifecycle.Init()
    InCharacter.Lifecycle.EnsurePresenceDB()
    C_Timer.NewTicker(60, InCharacter.Lifecycle.Sweep)
end

local function StoreFor(kind)
    if kind == "beacon" then
        return InCharacterDB.beacons
    end
    return InCharacterDB.bulletins or InCharacterDB.notices
end

local function NormalizeKind(kind)
    if kind == "notice" then return "bulletin" end
    return kind
end

function InCharacter.Lifecycle.Sweep()
    local now = time()
    for id, beacon in pairs(InCharacterDB.beacons or {}) do
        if beacon.expiresAt and beacon.expiresAt < now then
            if beacon.ownerGUID == UnitGUID("player") then
                InCharacter.Lifecycle.ExpireOwned("beacon", id)
            else
                InCharacterDB.beacons[id] = nil
                if InCharacterDB.cache and InCharacterDB.cache.beacon then
                    InCharacterDB.cache.beacon[id] = nil
                end
            end
        end
    end
    for id, bulletin in pairs(InCharacterDB.bulletins or {}) do
        if bulletin.expiresAt and bulletin.expiresAt < now and bulletin.status == InCharacter.STATUS.ACTIVE then
            if bulletin.ownerGUID == UnitGUID("player") then
                InCharacter.Lifecycle.ExpireOwned("bulletin", id)
            else
                InCharacterDB.bulletins[id] = nil
            end
        end
    end
    if InCharacterDB.cache then
        for _, bucket in pairs(InCharacterDB.cache) do
            for id, wrapped in pairs(bucket) do
                local entry = wrapped.data
                if entry and entry.expiresAt and entry.expiresAt < now then
                    bucket[id] = nil
                end
            end
        end
    end
    if InCharacter.Flyout and InCharacter.Flyout.Refresh then InCharacter.Flyout.Refresh() end
    if InCharacter.BoardView and InCharacter.BoardView.Refresh then InCharacter.BoardView.Refresh() end
    if InCharacter.BeaconHead and InCharacter.BeaconHead.OnCacheChanged then
        InCharacter.BeaconHead.OnCacheChanged()
    end
    if InCharacter.BeaconPins and InCharacter.BeaconPins.Refresh then
        InCharacter.BeaconPins.Refresh()
    end
end

function InCharacter.Lifecycle.ExpireOwned(kind, id)
    kind = NormalizeKind(kind)
    local store = StoreFor(kind)
    local entry = store[id]
    if not entry then return end
    entry.status = InCharacter.STATUS.EXPIRED
    store[id] = nil
    if kind == "beacon" then
        local p = InCharacter.Lifecycle.EnsurePresenceDB()
        if p.activeBeaconId == id then p.activeBeaconId = nil end
    end
    InCharacter.History.SaveDraft(kind, entry)
end

function InCharacter.Lifecycle.DeleteOwned(kind, id)
    kind = NormalizeKind(kind)
    local store = StoreFor(kind)
    local entry = store[id]
    if entry then
        entry.status = InCharacter.STATUS.DRAFT
        store[id] = nil
        InCharacter.History.SaveDraft(kind, entry)
    end
    if kind == "beacon" then
        local p = InCharacter.Lifecycle.EnsurePresenceDB()
        if p.activeBeaconId == id then p.activeBeaconId = nil end
    end
    InCharacter.Comms.BroadcastRetract(id, kind)
    if InCharacterDB.cache then
        if InCharacterDB.cache[kind] then InCharacterDB.cache[kind][id] = nil end
        if kind == "bulletin" and InCharacterDB.cache.notice then
            InCharacterDB.cache.notice[id] = nil
        end
    end
    if InCharacter.Flyout and InCharacter.Flyout.Refresh then InCharacter.Flyout.Refresh() end
    if InCharacter.BoardView and InCharacter.BoardView.Refresh then InCharacter.BoardView.Refresh() end
    if InCharacter.BeaconHead and InCharacter.BeaconHead.OnCacheChanged then
        InCharacter.BeaconHead.OnCacheChanged()
    end
    if InCharacter.BeaconPins and InCharacter.BeaconPins.Refresh then
        InCharacter.BeaconPins.Refresh()
    end
end

function InCharacter.Lifecycle.HandleRemoteRetract(kind, id)
    kind = NormalizeKind(kind)
    if InCharacterDB.cache then
        if InCharacterDB.cache[kind] then InCharacterDB.cache[kind][id] = nil end
        if kind == "bulletin" and InCharacterDB.cache.notice then
            InCharacterDB.cache.notice[id] = nil
        end
    end
    if InCharacterDB.beacons then InCharacterDB.beacons[id] = nil end
    if kind == "beacon" then
        if InCharacter.Flyout and InCharacter.Flyout.Refresh then InCharacter.Flyout.Refresh() end
        if InCharacter.BeaconHead and InCharacter.BeaconHead.OnCacheChanged then
            InCharacter.BeaconHead.OnCacheChanged()
        end
        if InCharacter.BeaconPins and InCharacter.BeaconPins.Refresh then
            InCharacter.BeaconPins.Refresh()
        end
    else
        if InCharacter.BoardView and InCharacter.BoardView.Refresh then
            InCharacter.BoardView.Refresh()
        end
    end
end

function InCharacter.Lifecycle.CanEmitBeacon()
    local p = InCharacter.Lifecycle.EnsurePresenceDB()
    local now = time()
    if p.activeBeaconId and InCharacterDB.beacons[p.activeBeaconId] then
        local b = InCharacterDB.beacons[p.activeBeaconId]
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

function InCharacter.Lifecycle.CreateBeacon(templateId, slotValues, opts)
    opts = opts or {}
    if not (InCharacter.SentenceTemplates and InCharacter.SentenceTemplates.Resolve) then
        InCharacter.Print("Beacons require the In Character Presence package.")
        return nil
    end
    local resolved = InCharacter.SentenceTemplates.Resolve(templateId, slotValues, InCharacter.CharDB.residence)
    if not resolved then return nil end
    local ctx = InCharacter.GetZoneContext()
    local now = time()
    local p = InCharacter.Lifecycle.EnsurePresenceDB()
    return {
        id = InCharacter.NewID(),
        ownerGUID = UnitGUID("player"),
        charName = InCharacter.GetCharName(),
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
        status = InCharacter.STATUS.ACTIVE,
        showNameZone = opts.showNameZone,
        showNameProximity = opts.showNameProximity,
    }
end

function InCharacter.Lifecycle.CreateBulletin(title, bodyText, boardId, scopeTier)
    local now = time()
    return {
        id = InCharacter.NewID(),
        ownerGUID = UnitGUID("player"),
        charName = InCharacter.GetCharName(),
        title = title,
        bodyText = bodyText,
        scopeTier = scopeTier or InCharacter.SCOPE.INDIVIDUAL,
        boardId = boardId,
        createdAt = now,
        expiresAt = now + InCharacter.Lifecycle.GetBulletinTTLSeconds(),
        editCount = 0,
        status = InCharacter.STATUS.ACTIVE,
    }
end

InCharacter.Lifecycle.CreateNotice = InCharacter.Lifecycle.CreateBulletin

function InCharacter.Lifecycle.PostBeacon(beacon)
    local ok, err = InCharacter.Lifecycle.CanEmitBeacon()
    if not ok then
        InCharacter.Print(err)
        return false
    end
    local guid = UnitGUID("player")
    for id, b in pairs(InCharacterDB.beacons) do
        if b.ownerGUID == guid then
            InCharacterDB.beacons[id] = nil
        end
    end
    local p = InCharacter.Lifecycle.EnsurePresenceDB()
    if beacon.showNameZone == nil then beacon.showNameZone = p.showNameZone ~= false end
    if beacon.showNameProximity == nil then beacon.showNameProximity = p.showNameProximity ~= false end
    InCharacterDB.beacons[beacon.id] = beacon
    p.activeBeaconId = beacon.id
    p.lastEmitAt = time()
    InCharacter.Comms.BroadcastBeacon(beacon)
    if InCharacter.Flyout and InCharacter.Flyout.Refresh then InCharacter.Flyout.Refresh() end
    if InCharacter.BeaconPins and InCharacter.BeaconPins.Refresh then InCharacter.BeaconPins.Refresh() end
    if InCharacter.BeaconHead and InCharacter.BeaconHead.OnCacheChanged then
        InCharacter.BeaconHead.OnCacheChanged()
    end
    return true
end

function InCharacter.Lifecycle.StopBeacon()
    local p = InCharacter.Lifecycle.EnsurePresenceDB()
    local id = p.activeBeaconId
    if not id or not InCharacterDB.beacons[id] then
        InCharacter.Print("You have no active beacon.")
        return
    end
    InCharacter.Lifecycle.DeleteOwned("beacon", id)
    InCharacter.Print("Beacon withdrawn.")
end

function InCharacter.Lifecycle.PostBulletin(bulletin)
    InCharacterDB.bulletins = InCharacterDB.bulletins or {}
    InCharacterDB.bulletins[bulletin.id] = bulletin
    InCharacterDB.notices = InCharacterDB.bulletins
    InCharacter.Comms.AnnounceBulletin(bulletin)
    if InCharacter.BoardView and InCharacter.BoardView.Refresh then
        InCharacter.BoardView.Refresh()
    end
end

InCharacter.Lifecycle.PostNotice = InCharacter.Lifecycle.PostBulletin

function InCharacter.Lifecycle.GetActiveOwnedBeacon()
    local p = InCharacter.Lifecycle.EnsurePresenceDB()
    if not p.activeBeaconId then return nil end
    return InCharacterDB.beacons[p.activeBeaconId]
end
