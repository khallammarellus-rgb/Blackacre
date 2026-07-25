InCharacter = InCharacter or {}
InCharacter.History = {}

function InCharacter.History.Init()
    InCharacterDB.history = InCharacterDB.history or {}
    -- migrate notice drafts
    if InCharacterDB.history.notice and not InCharacterDB.history.bulletin then
        InCharacterDB.history.bulletin = InCharacterDB.history.notice
    end
end

function InCharacter.History.SaveDraft(kind, entry)
    if kind == "notice" then kind = "bulletin" end
    InCharacterDB.history[kind] = InCharacterDB.history[kind] or {}
    entry.status = InCharacter.STATUS.DRAFT
    table.insert(InCharacterDB.history[kind], 1, entry)
    while #InCharacterDB.history[kind] > 20 do
        table.remove(InCharacterDB.history[kind])
    end
end

function InCharacter.History.GetDrafts(kind)
    if kind == "notice" then kind = "bulletin" end
    return InCharacterDB.history[kind] or {}
end

function InCharacter.History.RepostDraft(kind, index)
    if kind == "notice" then kind = "bulletin" end
    local drafts = InCharacter.History.GetDrafts(kind)
    local draft = drafts[index]
    if not draft then return end

    if kind == "beacon" then
        local beacon = InCharacter.Lifecycle.CreateBeacon(draft.templateId, draft.slots)
        if beacon then
            beacon.fullText = draft.fullText
            beacon.shortText = draft.shortText
            beacon.breadcrumb = draft.breadcrumb or draft.shortText
            InCharacter.Lifecycle.PostBeacon(beacon)
            InCharacter.Print("Beacon renewed (if cooldown allows).")
        end
    else
        local bulletin = InCharacter.Lifecycle.CreateBulletin(draft.title, draft.bodyText, draft.boardId, draft.scopeTier)
        if bulletin then
            InCharacter.Lifecycle.PostBulletin(bulletin)
            InCharacter.Print("Bulletin renewed.")
        end
    end
end

function InCharacter.History.Show()
    local beaconCount = #(InCharacter.History.GetDrafts("beacon"))
    local bulletinCount = #(InCharacter.History.GetDrafts("bulletin"))
    InCharacter.Print(string.format("History: %d beacon draft(s), %d bulletin draft(s).", beaconCount, bulletinCount))
end
