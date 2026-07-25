# In Character

A WoW addon for in-character immersive connections rather than OOC social utility.

**Traveler’s Chronicle** (journal of quests, feats, titles, craft, and handwritten notes), plus RP discovery beacons and notice boards. Complements Total RP 3 — never replaces it.

**Version:** 0.4.0 (Phase C — Survival meters)  
**Target:** Retail WoW 12.0.7+  
**Repo:** https://github.com/khallammarellus-rgb/In-Character

---

## Features

| Module | Status |
|---|---|
| **Chronicle** — auto log + editable IC prose + parchment journal UI | 0.2.0 |
| **Hardcore honor log** — 6-slot bags, mount/fly rites, deaths | 0.3.0 |
| **Survival** — hunger, thirst, exposure by zone climate | **0.4.0** |
| Discovery — beacons & notice boards | Shipped |
| Afterlife return paths | Planned |
| Leveling roadmap | Planned |
| PvP after-action reports | Planned |
| Peer share / TRP3-friendly export | Planned |

---

## Install (development)

1. Clone this repo:

```powershell
git clone https://github.com/khallammarellus-rgb/In-Character.git
```

2. Junction into WoW AddOns (PowerShell **as Administrator**):

```powershell
New-Item -ItemType Junction `
  -Path "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\InCharacter" `
  -Target "C:\Users\kvebe\InCharacter\InCharacter"
```

3. Enable **In Character** on the character select AddOns screen  
4. `/reload` in-game

---

## Slash commands

| Command | Description |
|---|---|
| `/ic chronicle` | Open the traveler’s journal (`/ic log`, `/ic journal`) |
| `/ic hardcore` | Hardcore compact / gatekeeper rites (`/ic gates`, `/ic hc`) |
| `/ic survival` | Toggle condition meters (`/ic meters`) |
| `/ic eat` / `/ic drink` / `/ic rest` | IC recovery actions |
| `/ic survival on` / `off` | Enable or disable survival for this character |
| `/ic sample` | Add a sample chronicle entry (dev) |
| `/ic` | Discovery flyout |
| `/ic beacon` | Broadcast beacon editor |
| `/ic notice` | Notice board editor |
| `/ic ping` | Comms test |
| `/ic history` | Discovery draft counts |

**Minimap:** Left-click flyout · Right-click chronicle · Shift+Right-click beacon

---

## Chronicle quick start

1. `/ic chronicle` — open the parchment journal  
2. Complete a quest — a page is inscribed automatically (edit freely)  
3. **Add note** — manual IC entries (weapons, oaths, memories)  
4. **Presentation** — full-page reading mode  
5. **Regenerate** — re-roll template prose from the same facts  

RP prose is **template-based** (no AI in-game). Always editable. K.C. years are approximate flavor.

---

## Architecture

- [docs/architecture-suite.md](docs/architecture-suite.md) — immersion suite roadmap  
- [docs/architecture.md](docs/architecture.md) — discovery module build spec  
- [docs/QA-log.md](docs/QA-log.md) — **checklist QA log (check items off in-game)**  
- [docs/testing.md](docs/testing.md) — smoke tests  

---

## Legal

World of Warcraft is a trademark of Blizzard Entertainment. This is a fan addon, not affiliated with Blizzard.