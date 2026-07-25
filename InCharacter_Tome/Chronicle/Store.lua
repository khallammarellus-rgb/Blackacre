InCharacter = InCharacter or {}
InCharacter.Chronicle = InCharacter.Chronicle or {}
InCharacter.Chronicle.Store = {}

local MAX_ENTRIES = 500

local function EnsureDB()
    InCharacter.CharDB = InCharacter.CharDB or InCharacterCharDB
    InCharacter.CharDB.chronicle = InCharacter.CharDB.chronicle or {
        entries = {},
        nextNotify = true,
    }
    return InCharacter.CharDB.chronicle
end

function InCharacter.Chronicle.Store.Init()
    EnsureDB()
end

function InCharacter.Chronicle.Store.GetAll()
    return EnsureDB().entries
end

function InCharacter.Chronicle.Store.GetById(id)
    for _, entry in ipairs(EnsureDB().entries) do
        if entry.id == id then
            return entry
        end
    end
    return nil
end

function InCharacter.Chronicle.Store.Add(entry)
    local db = EnsureDB()
    entry.id = entry.id or InCharacter.NewID()
    entry.createdAt = entry.createdAt or time()
    entry.editedAt = entry.editedAt or entry.createdAt
    entry.pinned = entry.pinned or false
    entry.tags = entry.tags or {}
    table.insert(db.entries, 1, entry)
    while #db.entries > MAX_ENTRIES do
        -- Prefer dropping unpinned oldest auto entries
        local removed = false
        for i = #db.entries, 1, -1 do
            local e = db.entries[i]
            if not e.pinned then
                table.remove(db.entries, i)
                removed = true
                break
            end
        end
        if not removed then
            table.remove(db.entries)
        end
    end
    return entry
end

function InCharacter.Chronicle.Store.Update(id, fields)
    local entry = InCharacter.Chronicle.Store.GetById(id)
    if not entry then return nil end
    for k, v in pairs(fields) do
        entry[k] = v
    end
    entry.editedAt = time()
    return entry
end

function InCharacter.Chronicle.Store.Delete(id)
    local db = EnsureDB()
    for i, entry in ipairs(db.entries) do
        if entry.id == id then
            table.remove(db.entries, i)
            return true
        end
    end
    return false
end

function InCharacter.Chronicle.Store.List(opts)
    opts = opts or {}
    local list = {}
    for _, entry in ipairs(EnsureDB().entries) do
        if opts.kind and entry.kind ~= opts.kind then
            -- skip
        elseif opts.search and opts.search ~= "" then
            local q = opts.search:lower()
            local hay = ((entry.title or "") .. " " .. (entry.body or "") .. " " .. (entry.zoneName or "")):lower()
            if hay:find(q, 1, true) then
                list[#list + 1] = entry
            end
        else
            list[#list + 1] = entry
        end
    end
    if opts.oldestFirst then
        table.sort(list, function(a, b)
            return (a.createdAt or 0) < (b.createdAt or 0)
        end)
    else
        table.sort(list, function(a, b)
            if a.pinned ~= b.pinned then
                return a.pinned
            end
            return (a.createdAt or 0) > (b.createdAt or 0)
        end)
    end
    return list
end