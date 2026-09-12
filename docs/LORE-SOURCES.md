# Lore sources (quest-path digest)

The Tome does **not** log every quest. It inks a **one-pager** at chain finale / meta / FoS / rep bracket / max renown.

**Working catalog (you edit):** `docs/quest-paths.xlsx`

| Sheet | What |
|-------|------|
| Heritage (auto-log) | Every playable-race heritage set from [Heritage armor](https://warcraft.wiki.gg/wiki/Heritage_armor). Log **finale only** (Human capstone: *Go with Honor, Friend*). Dracthyr: no set yet. |
| Current timeline finales | Midnight zone/campaign storylines from [Zone storyline](https://warcraft.wiki.gg/wiki/Zone_storyline). |
| Magic (IC paths) | Six cosmic forces + derived branches from [Magic](https://warcraft.wiki.gg/wiki/Magic). |
| Existing addon path stubs | Every `id` already in `Blackacre_Tome/Data/Paths/`. |
| Old expansion (consider) | Chromie Time campaigns — default **off** for auto-log. |
| Source hubs | Wiki / Wowhead / Blizzard / in-game API. |

Cannot ingest all **641** pages in [Category:Lore](https://warcraft.wiki.gg/wiki/Category:Lore). Hubs first, then one wiki article per path you mark `include=yes`.

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
