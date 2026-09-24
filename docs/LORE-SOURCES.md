# Lore sources (quest-path digest)

The Tome does **not** log every quest. It inks a **one-pager** at chain finale / meta / FoS / rep bracket / max renown.

**Working catalog (you edit):** `docs/quest-paths-v2.xlsx` (pause bookmark is on **How to use**).

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

**Depth this pass (Stratholme method: wiki graph → Wowhead IDs → short spine):**

| Path | Live spine IDs (verified Wowhead) |
|------|-----------------------------------|
| `human_stratholme_survivor` | 27383, 27387, 13149, 13151, 5282. `Human.lua`. |
| `human_7th_legion_conscript` | **12235**, **12466**, **12473**, **52654** (Alliance War Campaign — not Horde 52746), **56494** Eve of Battle. Chain end **57002** Old Soldier. |
| `dwarf_grim_batol_evacuee` | **27784** Hammer of Twilight (Alliance; 27719 is Water of Life), **27720** Goldmine (Alliance; 28885 is Horde). |
| `dwarf_explorers_league` | **2278**, **11448** (2964 A Future Task obsolete). Brann/Khaz Algar ID still 0. |
| `gnome_third_war_engineer` | **27635**, **27674**, **26208**. **25393** Operation: Gnomeregan removed from live. |
| `gnome_si7_saboteur` | **52003** Kelsey. Shaw breadcrumb still 0. |
| `orc_blackhand_veteran` | **10120**, **56494** (Saurfang names the Path of Glory). Not AU Blackhand. |
| `bloodelf_blood_knight` | **63490** (9.2.5). TBC 9681 / 11488 obsolete. Heritage **54096** is Third War recap, not founding. |

**PAUSED.** Next Path when you unpause: `nightelf_ancient_kaldorei_druid`. Lua in `_spines.lua` is source of truth; bookmark is `docs/quest-paths-v2.xlsx` → How to use. Tome does **not** log Path middles.

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
