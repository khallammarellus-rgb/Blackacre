# Life Paths — data you edit in VS Code

**What this is:** Alternate-start style **Life Paths** (not Afterlife death rites).  
**What you do:** Fill `zones` and `quests` for each path when you scrub Wowhead / game data.  
**In-game UI:** Later (Phase 5 Menu). Data works offline anytime.

## Folders

| Folder | Content |
|--------|---------|
| `Alliance/*.lua` | Two paths per Alliance race (past + contemporary) |
| `Horde/*.lua` | Two paths per Horde race |
| `General/General.lua` | Cross-race careers (SI:7, pirate, …) |
| `Catalog.lua` | Register + query helpers |
| `_schema.lua` | Field reference + template |

## How to edit one path

1. Open e.g. `Alliance/Human.lua`.  
2. Find the path table.  
3. Set `status = "drafting"`.  
4. Add zones:

```lua
zones = {
    { zoneId = "tirisfal", note = "Memory of the north" },
    { zoneId = "eastern_plaguelands", note = "Add zone to RoadmapZones.lua if missing" },
},
```

5. Add quests (IDs from Wowhead `quest=#####`):

```lua
quests = {
    { questId = 12345, title = "Name from Wowhead", optional = false, zoneId = "tirisfal" },
},
```

6. When happy: `status = "ready"`.  
7. Save. When game is up: `/reload` loads new data (no UI picker yet).

## Zone ids

Use ids from `Data/RoadmapZones.lua` (`elwynn`, `durotar`, …).  
If you need a zone that isn’t there, add a row to `RoadmapZoneCatalog` first (or ask Grok).

## With Grok

Say: *“Scrub quests for `human_stratholme_survivor` on Wowhead — Stratholme / Third War human story.”*  
We return paste-ready `quests = { ... }` blocks.

## Free pick

Players may choose any path. `races` / `faction` only help **suggest** matches later.
