# In Character

A WoW addon for in-character immersive connections rather than OOC social utility.

Traveler’s Chronicle, hardcore honor log, survival meters, afterlife rites, expedition roadmaps, PvP field reports, and TRP3-friendly export — plus discovery beacons and notice boards. Complements Total RP 3; never rewrites TRP3 data.

**Version:** 0.7.0 (Phases A–G MVP suite)  
**Target:** Retail WoW 12.0.7+  
**Repo:** https://github.com/khallammarellus-rgb/In-Character

---

## Features

| Module | Status |
|---|---|
| **Chronicle** — auto log + editable IC prose + parchment journal | 0.2.0 |
| **Hardcore honor log** — 6-slot bags, mount/fly rites, deaths | 0.3.0 |
| **Survival** — hunger, thirst, exposure by zone climate | 0.4.0 |
| **Afterlife** — IC return rites by realm of death | 0.5.0 |
| **Roadmap** — leveling expedition chart + lock prompts | 0.6.0 |
| **PvP** — battleground/arena after-action field reports | **0.7.0** |
| **Share** — clipboard export + peer summary cards | **0.7.0** |
| Discovery — beacons & notice boards | Shipped |

---

## Install (development)

```powershell
git clone https://github.com/khallammarellus-rgb/In-Character.git
```

Junction into WoW AddOns (Admin PowerShell):

```powershell
New-Item -ItemType Junction `
  -Path "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\InCharacter" `
  -Target "C:\Users\kvebe\InCharacter\InCharacter"
```

Enable **In Character** → `/reload`

---

## Slash commands

| Command | Description |
|---|---|
| `/ic chronicle` | Traveler’s journal |
| `/ic roadmap` | Expedition chart |
| `/ic hardcore` | Hardcore compact / rites |
| `/ic survival` | Condition meters |
| `/ic afterlife` / `/ic realms` | Death return rites |
| `/ic export` | Copy summary for TRP3 About/Notes |
| `/ic share PlayerName` | Request peer IC summary card |
| `/ic pvpsample` | Sample field report (dev) |
| `/ic pvp on` / `off` | Toggle auto PvP reports |
| `/ic eat` / `drink` / `rest` | Survival recovery |
| `/ic beacon` / `/ic notice` | Discovery |
| `/ic ping` | Comms test |

**Minimap:** Left = flyout · Right = chronicle · Shift+Right = beacon

---

## Architecture & QA

- [docs/architecture-suite.md](docs/architecture-suite.md) — suite roadmap  
- [docs/architecture.md](docs/architecture.md) — discovery spec  
- [docs/QA-log.md](docs/QA-log.md) — **in-game checklist (check items off)**  
- [docs/testing.md](docs/testing.md) — smoke tests  

---

## Legal

World of Warcraft is a trademark of Blizzard Entertainment. Fan addon; not affiliated with Blizzard.