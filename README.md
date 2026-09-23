# Blackacre

A WoW addon for in-character immersive connections.

**Version:** 2.0.0-dev (renamed from In Character · Blackacre identity)  
**Target:** Retail WoW 12.0.7+ (`## Interface: 120007`)  
**Repo:** https://github.com/khallammarellus-rgb/Blackacre (GitHub name may lag product name)

---

## Packages (enable all four for the full suite)

| Folder | Title | Role |
|---|---|---|
| `Blackacre` | **Blackacre** | Base |
| `Blackacre_Presence` | Blackacre **Presence** | Connections |
| `Blackacre_Tome` | Blackacre **Tome** | Journaling |
| `Blackacre_Survival` | Blackacre **Survival** | Survival Immersion|

---

## Features

| Module | Package | Status |
|---|---|---|
| **Chronicle** — Tome with skins and voice prose | Tome | 0.2+ |
| **Survival** — hunger, thirst, exposure | Survival | 0.4+ |
| **Afterlife** — IC return rites | Tome | 0.5+ |
| **Share** — Journal sharing | Tome | 0.7+ |
| **Lineage** — Character development | Tome | 0.8+ |
| **Presence** — Beacons + Bulletins | Presence | 0.9+ |
| **Setup wizard** — rough non-operable right now | Tome | **1.2.0** |

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
| `/ba export` | Copy summary for TRP3 paste |
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
| [docs/PRESENCE-FREEZE.md](docs/PRESENCE-FREEZE.md) | Bulletins/Beacons: do not touch until Phase 10 |
| [docs/UX-VISION.md](docs/UX-VISION.md) | Bethesda × Warcraft UX vision |
| [docs/THEME-TOKENS.md](docs/THEME-TOKENS.md) | Colors, textures, Theme helpers |
| [docs/FRAME-LAYERS.md](docs/FRAME-LAYERS.md) | Frame canvas + texture layers (Mayron Ep. 5) |
| [docs/MEDIA-GUIDE.md](docs/MEDIA-GUIDE.md) | Your custom images in-game |
| [docs/TOOLING.md](docs/TOOLING.md) | Phase 1 dev loop + BugSack tips |
| [docs/PHASE1-VISUAL-BASELINE.md](docs/PHASE1-VISUAL-BASELINE.md) | In-game look checklist |

## Architecture & QA

- [docs/architecture-suite.md](docs/architecture-suite.md) — suite roadmap  
- [docs/architecture.md](docs/architecture.md) — discovery spec  
- [docs/packages.md](docs/packages.md) — multi-addon layout  
- [docs/QA-log.md](docs/QA-log.md) — **in-game checklist (check items off)**  
- [docs/testing.md](docs/testing.md) — smoke tests  

---

## Legal

World of Warcraft © Blizzard Entertainment. This is a fan addon, not affiliated with Blizzard.

## Credits
Thanks to the Texture Atlas Viewer add on developer for making the visuals entirely possible
