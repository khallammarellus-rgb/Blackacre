# Blackacre

A WoW addon for in-character immersive connections rather than OOC social utility.

Traveler’s Chronicle, hardcore honor log, survival meters, afterlife rites, expedition roadmaps, PvP field reports, and clipboard export — plus discovery beacons and bulletin boards. On Retail, complements Total RP 3 and never rewrites TRP3 data. On WoW Forever, TRP3 is not read (no Forever port yet).

**Version:** 2.0.0-dev (renamed from In Character · Blackacre identity)  
**Target:** Retail WoW 12.0.7+ (`120007`) and WoW Forever beta (`16001` / Camelot)  
**Repo:** https://github.com/khallammarellus-rgb/Blackacre (GitHub name may lag product name)

---

## Packages (enable all four for the full suite)

| Folder | Title | Role |
|---|---|---|
| `Blackacre` | **Blackacre** | Core — SavedVariables, comms, lifecycle, minimap, theme |
| `Blackacre_Presence` | Blackacre **Presence** | Beacons (talking-head, anti-spam) & Bulletins |
| `Blackacre_Tome` | Blackacre **Tome** | Traveler’s Tome hub, chronicle, hardcore, voice, share… |
| `Blackacre_Survival` | Blackacre **Survival** | Hunger / thirst / exposure meters |

Child packages declare `## RequiredDeps: Blackacre`. Disable a package to drop that feature set without loading its UI.

---

## Features

| Module | Package | Status |
|---|---|---|
| **Chronicle** — auto log + editable IC prose | Tome | 0.2+ |
| **Hardcore honor log** — 6-slot bags, mount/fly rites | Tome | 0.3+ |
| **Survival** — hunger, thirst, exposure | Survival | 0.4+ |
| **Afterlife** — IC return rites | Tome | 0.5+ |
| **Roadmap** — expedition chart | Tome | 0.6+ |
| **PvP** — field reports | Tome | 0.7+ |
| **Share** — export + peer cards | Tome | 0.7+ |
| **Lineage** — birth year (ADP/BDP) | Tome | 0.8+ |
| **Presence** — Beacons lite + Bulletins | Presence | 0.9+ |
| **Multi-package layout** | all | 1.0.0 |
| **Tome Theme 2.0** — book hub + tabs | Tome | 1.1.0 |
| **Voice** — race accents (one profile, never mixed) | Tome | 1.1.0 |
| **Bulletin polish** — more boards, wax seals, OOC lint | Presence | 1.1.0 |
| **True book** — all Tome modules in one window | Tome | **1.2.0** |
| **Setup wizard** — first-run character & lineage | Tome | **1.2.0** |

---

## Install (development)

```powershell
git clone https://github.com/khallammarellus-rgb/Blackacre.git
```

Junction **all four** folders into WoW AddOns (Admin PowerShell if needed).

Retail:

```powershell
$root = "C:\Users\kvebe\InCharacter"
$addons = "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns"
foreach ($p in @("Blackacre","Blackacre_Presence","Blackacre_Tome","Blackacre_Survival")) {
  New-Item -ItemType Junction -Path "$addons\$p" -Target "$root\$p" -Force
}
```

WoW Forever (beta lives in `_classic_beta_`):

```powershell
$root = "C:\Users\kvebe\InCharacter"
$addons = "C:\Program Files (x86)\World of Warcraft\_classic_beta_\Interface\AddOns"
foreach ($p in @("Blackacre","Blackacre_Presence","Blackacre_Tome","Blackacre_Survival")) {
  New-Item -ItemType Junction -Path "$addons\$p" -Target "$root\$p" -Force
}
```

Character select → AddOns → enable **Blackacre**, **Presence**, **Tome**, **Survival** → `/reload`  

Slash aliases: **`/ba`**, **`/blackacre`**, and legacy **`/ic`**.

---

## Slash commands

| Command | Description |
|---|---|
| `/ba` or `/blackacre` or `/ic` | Presence panel (requires Presence package) |
| `/ba beacon` | Emit / withdraw beacon (no chat text) |
| `/ba bulletin` | Post a bulletin at a board |
| `/ba beacons on` / `off` | Receive beacons (default on) |
| `/ba tome` / `/ba chronicle` | Traveler’s Tome (one book, tabs) |
| `/ba setup` | First-run character & lineage tutorial |
| `/ba voice` | Accent / IC voice settings |
| `/ba birth` | Lineage / birth year |
| `/ba roadmap` | Expedition chart |
| `/ba hardcore` | Hardcore compact / rites |
| `/ba survival` | Condition meters |
| `/ba afterlife` / `/ba realms` | Death return rites |
| `/ba export` | Copy summary (Retail: TRP3 paste; Forever: notes / whispers) |
| `/ba share PlayerName` | Peer IC summary card |
| `/ba eat` / `drink` / `rest` | Survival recovery |
| `/ba packages` | List loaded packages + version |
| `/ba ping` | Invisible comms test |

**Minimap:** Left = Presence · Right = Tome · Shift+Right = emit beacon

---

## Project docs (Blackacre)

| Doc | Purpose |
|-----|---------|
| [AGENTS.md](AGENTS.md) | Rules for coding agents / Grok CLI |
| [docs/BLACKACRE-BRIEF.md](docs/BLACKACRE-BRIEF.md) | Product brief & priorities |
| [docs/HANDOFF-WOW-FOREVER.md](docs/HANDOFF-WOW-FOREVER.md) | Active handoff note, performance rules & copy review |
| [docs/PRESENCE-FREEZE.md](docs/PRESENCE-FREEZE.md) | Bulletins/Beacons: do not touch until Phase 10 |
| [docs/UX-VISION.md](docs/UX-VISION.md) | Bethesda × Warcraft UX vision |
| [docs/SKIN-AND-CHROME-GUIDE.md](docs/SKIN-AND-CHROME-GUIDE.md) | Canvas hierarchy, draw layers, BLP UV cropping, nine-slice & regions |
| [docs/THEME-TOKENS.md](docs/THEME-TOKENS.md) | Colors, textures, Theme helpers |
| [docs/DBM-HYGIENE.md](docs/DBM-HYGIENE.md) | DBM-Core code standards & diagnostic checklist |
| [docs/UI-ELEMENT-WORKFLOW.md](docs/UI-ELEMENT-WORKFLOW.md) | Pass A skeleton → B art → C combine → D DBM hard pass |
| [docs/QA-TESTING-GUIDE.md](docs/QA-TESTING-GUIDE.md) | Modular in-game testing & pass/fail checklists |
| [docs/MEDIA-GUIDE.md](docs/MEDIA-GUIDE.md) | Custom images & TGA pipeline |
| [docs/TOOLING.md](docs/TOOLING.md) | Dev loop, junctions & BugSack tips |
| [docs/PATHS-GUIDE.md](docs/PATHS-GUIDE.md) | Offline Life Paths authoring guide |
| [docs/LORE-SOURCES.md](docs/LORE-SOURCES.md) | Quest-path digest & heritage finales |  

---

## Legal

World of Warcraft © Blizzard Entertainment. This is a fan addon, not affiliated with Blizzard.
