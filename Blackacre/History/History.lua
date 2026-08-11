Blackacre = Blackacre or {}
Blackacre.History = {}

function Blackacre.History.Init()
    BlackacreDB.history = BlackacreDB.history or {}
    -- migrate notice drafts
    if BlackacreDB.history.notice and not BlackacreDB.history.bulletin then
        BlackacreDB.history.bulletin = BlackacreDB.history.notice
    end
end

function Blackacre.History.SaveDraft(kind, entry)
    if kind == "notice" then kind = "bulletin" end
    BlackacreDB.history[kind] = BlackacreDB.history[kind] or {}
    entry.status = Blackacre.STATUS.DRAFT
    table.insert(BlackacreDB.history[kind], 1, entry)
    while #BlackacreDB.history[kind] > 20 do
        table.remove(BlackacreDB.history[kind])
    end
end

function Blackacre.History.GetDrafts(kind)
    if kind == "notice" then kind = "bulletin" end
    return BlackacreDB.history[kind] or {}
end

function Blackacre.History.RepostDraft(kind, index)
    if kind == "notice" then kind = "bulletin" end
    local drafts = Blackacre.History.GetDrafts(kind)
    local draft = drafts[index]
    if not draft then return end

    if kind == "beacon" then
        local beacon = Blackacre.Lifecycle.CreateBeacon(draft.templateId, draft.slots)
        if beacon then
            beacon.fullText = draft.fullText
            beacon.shortText = draft.shortText
            beacon.breadcrumb = draft.breadcrumb or draft.shortText
            Blackacre.Lifecycle.PostBeacon(beacon)
            Blackacre.Print("Beacon renewed (if cooldown allows).")
        end
    else
        local bulletin = Blackacre.Lifecycle.CreateBulletin(draft.title, draft.bodyText, draft.boardId, draft.scopeTier)
        if bulletin then
            Blackacre.Lifecycle.PostBulletin(bulletin)
            Blackacre.Print("Bulletin renewed.")
        end
    end
end

function Blackacre.History.Show()
    local beaconCount = #(Blackacre.History.GetDrafts("beacon"))
    local bulletinCount = #(Blackacre.History.GetDrafts("bulletin"))
    Blackacre.Print(string.format("History: %d beacon draft(s), %d bulletin draft(s).", beaconCount, bulletinCount))
end
