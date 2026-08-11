Blackacre = Blackacre or {}
Blackacre.ZoneClimate = {}

-- Climate profiles drive survival meter decay. RP simulation only.
-- severity 0–1, tags influence which meters move faster.

local DEFAULT = {
    label = "temperate",
    exposure = 0.15,
    thirst = 0.25,
    hunger = 0.20,
    tags = {},
}

-- mapId -> profile overrides (seed set; expand over time)
local BY_MAP = {
    -- Cold / alpine
    [116] = { label = "frigid", exposure = 0.85, thirst = 0.15, hunger = 0.30, tags = { "cold" } }, -- Grizzly Hills-ish seed
    [117] = { label = "frigid", exposure = 0.90, thirst = 0.12, hunger = 0.28, tags = { "cold" } },
    [118] = { label = "howling", exposure = 0.95, thirst = 0.10, hunger = 0.35, tags = { "cold" } },
    [123] = { label = "frozen", exposure = 0.95, thirst = 0.10, hunger = 0.32, tags = { "cold" } },
    [127] = { label = "frozen", exposure = 0.88, thirst = 0.12, hunger = 0.30, tags = { "cold" } },
    -- Hot / arid
    [71] = { label = "desert", exposure = 0.70, thirst = 0.90, hunger = 0.25, tags = { "hot", "arid" } }, -- Tanaris
    [64] = { label = "badlands", exposure = 0.65, thirst = 0.75, hunger = 0.28, tags = { "hot", "arid" } },
    [249] = { label = "desert", exposure = 0.72, thirst = 0.88, hunger = 0.26, tags = { "hot", "arid" } },
    -- Swamp / wet
    [51] = { label = "swamp", exposure = 0.40, thirst = 0.15, hunger = 0.35, tags = { "wet" } },
    -- Stormwind / capitals — mild
    [84] = { label = "city", exposure = 0.05, thirst = 0.12, hunger = 0.12, tags = { "civilized" } },
    [85] = { label = "city", exposure = 0.05, thirst = 0.12, hunger = 0.12, tags = { "civilized" } },
    [87] = { label = "city", exposure = 0.05, thirst = 0.12, hunger = 0.12, tags = { "civilized" } },
    [89] = { label = "city", exposure = 0.05, thirst = 0.12, hunger = 0.12, tags = { "civilized" } },
    [90] = { label = "city", exposure = 0.05, thirst = 0.12, hunger = 0.12, tags = { "civilized" } },
    [103] = { label = "city", exposure = 0.05, thirst = 0.12, hunger = 0.12, tags = { "civilized" } },
    [110] = { label = "city", exposure = 0.08, thirst = 0.14, hunger = 0.14, tags = { "civilized" } },
    [627] = { label = "city", exposure = 0.08, thirst = 0.14, hunger = 0.14, tags = { "civilized" } },
    -- Teldrassil / night elf starter mild woodland
    [57] = { label = "woodland", exposure = 0.20, thirst = 0.18, hunger = 0.22, tags = { "forest" } },
}

local NAME_HINTS = {
    { match = "winter", profile = { label = "frigid", exposure = 0.85, thirst = 0.12, hunger = 0.30, tags = { "cold" } } },
    { match = "ice", profile = { label = "frozen", exposure = 0.90, thirst = 0.10, hunger = 0.32, tags = { "cold" } } },
    { match = "northrend", profile = { label = "frigid", exposure = 0.80, thirst = 0.15, hunger = 0.28, tags = { "cold" } } },
    { match = "desert", profile = { label = "desert", exposure = 0.70, thirst = 0.90, hunger = 0.25, tags = { "hot", "arid" } } },
    { match = "tanaris", profile = { label = "desert", exposure = 0.72, thirst = 0.90, hunger = 0.25, tags = { "hot", "arid" } } },
    { match = "uldum", profile = { label = "desert", exposure = 0.68, thirst = 0.85, hunger = 0.24, tags = { "hot", "arid" } } },
    { match = "swamp", profile = { label = "swamp", exposure = 0.40, thirst = 0.15, hunger = 0.35, tags = { "wet" } } },
    { match = "barrens", profile = { label = "savanna", exposure = 0.55, thirst = 0.70, hunger = 0.30, tags = { "hot" } } },
    { match = "fireland", profile = { label = "infernal", exposure = 0.95, thirst = 0.80, hunger = 0.30, tags = { "hot" } } },
    { match = "shadowland", profile = { label = "deathly", exposure = 0.60, thirst = 0.40, hunger = 0.40, tags = { "bleak" } } },
}

local function Copy(p)
    return {
        label = p.label,
        exposure = p.exposure,
        thirst = p.thirst,
        hunger = p.hunger,
        tags = p.tags or {},
    }
end

function Blackacre.ZoneClimate.GetProfile(mapId, zoneName)
    if mapId and BY_MAP[mapId] then
        return Copy(BY_MAP[mapId])
    end
    local lower = (zoneName or ""):lower()
    for _, hint in ipairs(NAME_HINTS) do
        if lower:find(hint.match, 1, true) then
            return Copy(hint.profile)
        end
    end
    return Copy(DEFAULT)
end