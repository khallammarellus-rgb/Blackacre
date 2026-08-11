-- Life Path catalog (Alternate Start). Not Afterlife/death rites.
-- Race files call Blackacre.Paths.Register(pathTable).

Blackacre = Blackacre or {}
Blackacre.Paths = Blackacre.Paths or {}

local byId = {}
local all = {}

--- Register one path. Safe to call multiple times with same id (last wins).
function Blackacre.Paths.Register(path)
    if type(path) ~= "table" or not path.id then
        return
    end
    path.status = path.status or "stub"
    path.zones = path.zones or {}
    path.quests = path.quests or {}
    path.levelLockHints = path.levelLockHints or {}
    path.tags = path.tags or {}
    path.races = path.races or {}
    path.tomeSeed = path.tomeSeed or { title = path.name or path.id, body = path.blurb or "" }

    if not byId[path.id] then
        all[#all + 1] = path
    else
        -- replace in all list
        for i = 1, #all do
            if all[i].id == path.id then
                all[i] = path
                break
            end
        end
    end
    byId[path.id] = path
end

function Blackacre.Paths.Get(id)
    return id and byId[id] or nil
end

function Blackacre.Paths.GetAll()
    return all
end

--- filter = { race = "Orc", faction = "Horde", era = "past", status = "ready", tag = "scourge" }
--- Free pick: empty filter returns everything. Soft match helpers for UI later.
function Blackacre.Paths.List(filter)
    filter = filter or {}
    local out = {}
    for i = 1, #all do
        local p = all[i]
        local ok = true
        if filter.status and p.status ~= filter.status then
            ok = false
        end
        if ok and filter.era and p.era ~= filter.era then
            ok = false
        end
        if ok and filter.faction and p.faction and p.faction ~= "Any" and p.faction ~= filter.faction then
            ok = false
        end
        if ok and filter.race and p.races and #p.races > 0 then
            local hit = false
            for _, r in ipairs(p.races) do
                if r == filter.race then
                    hit = true
                    break
                end
            end
            if not hit then
                ok = false
            end
        end
        if ok and filter.tag and p.tags then
            local hit = false
            for _, t in ipairs(p.tags) do
                if t == filter.tag then
                    hit = true
                    break
                end
            end
            if not hit then
                ok = false
            end
        end
        if ok then
            out[#out + 1] = p
        end
    end
    return out
end

function Blackacre.Paths.Count()
    return #all
end
