# Lore sources (quest-path digest)

The Tome does **not** log every quest. It inks a **one-pager** at chain finale / meta / FoS / rep bracket / max renown.

**Working catalog (you edit):** `docs/quest-paths.xlsx`

| Sheet | What |
|-------|------|
| **Meta Achievements** | Wiki [Category:Meta-achievements](https://warcraft.wiki.gg/wiki/Category:Meta-achievements) (341 pages). Sample of Tome-worthy bundles. Addon still auto-detects any meta in-game. |
| **Existing addon path stubs** | First Path crawled: `human_stratholme_survivor`. Others wait for the same BFS. |
| Chronology (ADP) | Wiki Timeline order. |
| Old expansion (consider) | Chromie Time — default off. |
| Source hubs | Pages actually opened, not a hub list of 11. |
| How to use | Path method. |

Heritage / Magic / Current-timeline tabs **removed** — those are not Paths.

**Path method (locked):** seed race + place + event on warcraft.wiki.gg → follow wikilinks and citations → then Wowhead NPCs/quests that still exist → curate a short spine.

**`human_stratholme_survivor` (this pass):** Human; Stratholme; Culling of Stratholme; Battle of Darrowshire; plus cited WC3 / Chronicle 3 / RotLK ch.12 / Dispelling Illusions (Wowhead **13149**) / A Royal Escort (**13151**). Spine is in `Paths/Alliance/Human.lua` (`status = drafting`). Next Path when you say so.

**Verified finales this pass (wiki Source lists):**

| Set / chapter | Last quest (log this) |
|---------------|------------------------|
| Lion's Heritage | Go with Honor, Friend |
| Heritage of the Kaldorei | Honor of the Goddess |
| Heritage of the Sin'dorei | The Fall of the Sunwell |
| Heritage of Lordaeron | I Am Forsaken |
| Heritage of Draenor | Aka'magosh |
| Midnight intro | Light's Last Stand |
| Rage of the Ren'dorei | Trial of Wrath |
| Haranir intro | Stranger in a New Land |

Those titles live in `Blackacre_Tome/Data/HeritageCapstones.lua` so the Tome can ink the page even if `C_QuestLine` is silent.

**Chronology (this pass):** wiki [Timeline](https://warcraft.wiki.gg/wiki/Timeline) years in **ADP** (0 = Dark Portal = 592 K.C.), same as `YearCalendar.lua`. Spreadsheet sheet **Chronology (ADP)** + `Blackacre_Tome/Data/ChronologyBeats.lua`. Present ~42–44 ADP (TWW default 42; Midnight listed as 44 on the wiki). Auto-log stays **off** until Midnight / heritage finales.

| Source | Use |
|--------|-----|
| In-game `C_QuestLine` | Live end quest (Capture.lua) |
| [Wowhead](https://www.wowhead.com/) | Quest text + `quest=` IDs |
| [warcraft.wiki.gg](https://warcraft.wiki.gg/) | Lore, kingdoms, races, storylines, magic |
| [Blizzard races](https://worldofwarcraft.blizzard.com/en-us/game/races) | Official race blurbs |
| Blizzard / Wowhead news | Current Midnight campaign names |

**Onyxia rule:** long road → one page at Katrana, player edits the digest.

Retail auto-log ignores world quests, bonus objectives, callings, and individual turn-ins.
