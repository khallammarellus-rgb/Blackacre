# In Character

A WoW addon for in-character immersive connections rather than OOC social utility.

Traveler’s Chronicle, hardcore honor log, survival meters, afterlife rites, expedition roadmaps, PvP field reports, and TRP3-friendly export — plus discovery beacons and bulletin boards. Complements Total RP 3; never rewrites TRP3 data.

**Version:** 1.2.0 (true book Tome · first-run lineage setup)  
**Target:** Retail WoW 12.0.7+  
**Repo:** https://github.com/khallammarellus-rgb/In-Character

---

## Packages (enable all four for the full suite)

| Folder | Title | Role |
|---|---|---|
| `InCharacter` | **In Character** | Core — SavedVariables, comms, lifecycle, minimap, theme |
| `InCharacter_Presence` | In Character **Presence** | Beacons (talking-head, anti-spam) & Bulletins |
| `InCharacter_Tome` | In Character **Tome** | Traveler’s Tome hub, chronicle, hardcore, voice, share… |
| `InCharacter_Survival` | In Character **Survival** | Hunger / thirst / exposure meters |

Child packages declare `## RequiredDeps: InCharacter`. Disable a package to drop that feature set without loading its UI.

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
git clone https://github.com/khallammarellus-rgb/In-Character.git
```

Junction **all four** folders into WoW AddOns (Admin PowerShell if needed):

```powershell
$root = "C:\Users\kvebe\InCharacter"
$addons = "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns"
foreach ($p in @("InCharacter","InCharacter_Presence","InCharacter_Tome","InCharacter_Survival")) {
  New-Item -ItemType Junction -Path "$addons\$p" -Target "$root\$p" -Force
}
```

Character select → AddOns → enable **In Character**, **Presence**, **Tome**, **Survival** → `/reload`

---

## Slash commands

| Command | Description |
|---|---|
| `/ic` | Presence panel (requires Presence package) |
| `/ic beacon` | Emit / withdraw beacon (no chat text) |
| `/ic bulletin` | Post a bulletin at a board |
| `/ic beacons on` / `off` | Receive beacons (default on) |
| `/ic tome` / `/ic chronicle` | Traveler’s Tome (one book, tabs) |
| `/ic setup` | First-run character & lineage tutorial |
| `/ic voice` | Accent / IC voice settings |
| `/ic birth` | Lineage / birth year |
| `/ic roadmap` | Expedition chart |
| `/ic hardcore` | Hardcore compact / rites |
| `/ic survival` | Condition meters |
| `/ic afterlife` / `/ic realms` | Death return rites |
| `/ic export` | Copy summary for TRP3 paste |
| `/ic share PlayerName` | Peer IC summary card |
| `/ic eat` / `drink` / `rest` | Survival recovery |
| `/ic packages` | List loaded packages + version |
| `/ic ping` | Invisible comms test |

**Minimap:** Left = Presence · Right = Tome · Shift+Right = emit beacon

---

## Blackacre (next evolution)

This suite is being guided toward **Blackacre** (rename + solo RP overhaul). Phase 0 docs only so far — **no rename yet**.

| Doc | Purpose |
|-----|---------|
| [AGENTS.md](AGENTS.md) | Rules for coding agents / Grok CLI |
| [docs/BLACKACRE-BRIEF.md](docs/BLACKACRE-BRIEF.md) | Product brief & priorities |
| [docs/PRESENCE-FREEZE.md](docs/PRESENCE-FREEZE.md) | Bulletins/Beacons: do not touch until Phase 10 |
| [docs/UX-VISION.md](docs/UX-VISION.md) | Immersive UI vision |
| [docs/THEME-TOKENS.md](docs/THEME-TOKENS.md) | Colors, textures, Theme helpers |
| [docs/MEDIA-GUIDE.md](docs/MEDIA-GUIDE.md) | Your custom images in-game |

## Architecture & QA

- [docs/architecture-suite.md](docs/architecture-suite.md) — suite roadmap  
- [docs/architecture.md](docs/architecture.md) — discovery spec  
- [docs/packages.md](docs/packages.md) — multi-addon layout  
- [docs/QA-log.md](docs/QA-log.md) — **in-game checklist (check items off)**  
- [docs/testing.md](docs/testing.md) — smoke tests  

---

## Legal

World of Warcraft © Blizzard Entertainment. This is a fan addon, not affiliated with Blizzard.
