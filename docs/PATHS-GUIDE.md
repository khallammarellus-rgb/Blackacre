# Life Paths — owner guide

**Location in VS Code:** `Blackacre_Tome/Data/Paths/`  
**Not:** Afterlife death rites (`AfterlifePaths.lua`).

## Why this exists

A Path turns “Orc Veteran of Blackhand’s Horde” into **zones + quests + journal seeds** the addon can suggest later. You build the data offline; in-game path picker comes in Phase 5.

## Mental model

```
Race / setup data  →  soft suggestions
Player free will   →  any path choosable
Path record        →  zones[] + quests[] + tomeSeed
Roadmap / Tome     →  consume when UI exists
```

## Files to open first

1. `Paths/README.md` — edit workflow  
2. `Paths/_schema.lua` — field meanings  
3. One race file, e.g. `Paths/Alliance/Human.lua`  
4. `Data/Quests.lua` — optional shared chains  
5. `Data/RoadmapZones.lua` — valid `zoneId` values  

## Scrubbing quests (with Grok)

1. Pick a path `id` (e.g. `human_stratholme_survivor`).  
2. List themes: zones, expansions, factions.  
3. Ask Grok: *Scrub Wowhead for quests matching X; return paste-ready quests = { }.*  
4. Paste into that path’s `quests` table.  
5. Set `status = "drafting"` then `"ready"`.

## Status values

| status | Meaning |
|--------|---------|
| `stub` | Name/blurb only (current default for all) |
| `drafting` | You are filling zones/quests |
| `ready` | Usable for Roadmap/Tome later |

## Catalog helpers (Lua, when game loads)

```lua
Blackacre.Paths.Get("orc_blackhand_veteran")
Blackacre.Paths.List({ race = "Orc", faction = "Horde" })
Blackacre.Paths.Count()
```

## Free pick policy

`races` and `faction` do **not** hard-lock. They only help ranking later. Bethesda freedom + Warcraft content.
