# Blackacre — Project Brief & Operating Instructions

**Status:** Packages renamed to **Blackacre** (v2.0.0-dev). Phase 1 tooling in place. Now splitting into two separate add ons/repos — Retail and Forever — see [`RETAIL-VS-FOREVER.md`](RETAIL-VS-FOREVER.md). This split is the current thing to plan around, everything below still applies to both but read that doc too before touching Forever-only or Retail-only code.  
**Repo path:** `C:\Users\kvebe\InCharacter` (disk folder may lag; addon packages are `Blackacre*`) — will become two repo paths once the split happens, owner will say when.  
**Target client:** Retail mainline (`## Interface: 120007`) and WoW Forever beta (`16001` / Camelot in `_classic_beta_`). Flavor helpers: `Blackacre/Core/Compat.lua`.  
**Current suite version:** 2.0.0-dev.

This document is the long-form product brief for humans and coding agents. Session-start rules also live in root [`AGENTS.md`](../AGENTS.md).

---

## User profile & working style

- Owner is **not** a professional developer; first serious WoW addon (after early In Character experiments, now Blackacre).
- Stack: VS Code + WoW API extension, Git, Grok CLI with GitHub access. Windows 11.
- **You (the human) direct every major decision.** The CLI does heavy lifting, explains clearly, shows before/after, and teaches how to navigate and proof code.
- Prefer **small, reviewable steps** over giant rewrites.
- **Always ask** before deleting or heavily refactoring working pieces.
- After meaningful changes: show key code, plain English, exact in-game tests, VS Code file pointers.
- Incremental commits; push/PRs only when the human asks.

---

## Goal

Blackacre: Skyrim-inspired RPG / solo RP in World of Warcraft (especially RP servers), now split across two flavors of the game that don't have the same amount of content to draw on. Beacons & Bulletins is the community layer, and it's not a "later" thing anymore, it's a top-priority feature — see below.

### Core features (priority order — solo first)

1. **Tome** — the main feature. Has to work, has to look good. First-person always, meta-tier logging only (chain finales, meta achievements, FoS, big wins/losses), not a quest-by-quest logger. Opt-in toggle exists for full quest logging, default off.
2. **Survival** — three meters, Exposure / Thirst / Hunger, no separate debuff system anymore. One buff, Preparation, shows when food and water are both on hand. Light, immersive, persistent.
3. **Backstory menus** — the OOC setup/lineage/origin screens. Retail and Forever diverge here on purpose, don't force parity.
4. **Beacons & Bulletins (Presence package)** — the primary IC community interaction feature. Chrome and talking-head art stay frozen until Phase 10, but the feature itself (viability, comms, gates) is active work. See [`PRESENCE-FREEZE.md`](PRESENCE-FREEZE.md).
5. **Character Sheet** — TRP3-lite. Own data, own UI, not a hard TRP3 dependency (Forever can't use TRP3 at all, no official port).
6. **Path / Alternate Start** — **Retail only.** Data-driven origins (Druid of the Claw, Defias Bandit, etc.), quest IDs filled manually from Wowhead/wiki research. Forever has no deep enough quest/canon reference yet to build these off of, so Forever simply has no Paths right now. That's not a gap to patch, it's a real limit of what's known about Forever content.
7. **Quest ID repository + Roadmap** — feeds Paths, Retail only for the same reason.
8. **Light community signals** — folded into Beacons & Bulletins above.

### Presence status

Beacons & Bulletins feature work (comms, gates, crumb delivery, viability) is open. Chrome restyle and talking-head art specifically are frozen until Phase 10. See [`PRESENCE-FREEZE.md`](PRESENCE-FREEZE.md) for the exact line.

---

## Architecture preferences

- Aim for **DBM-level cleanliness**: modular Core, clear packages, minimal global pollution.
- Prefer **Ace3**: AceAddon, AceDB (+ profiles), AceEvent, AceConfig/Dialog, AceGUI (as needed), AceLocale, AceTimer, AceComm, AceConsole. Embed only what we need via `embeds.xml` / LibStub.
- **Multi-package layout (recommended for v1):**

  ```
  Blackacre/              # core
  Blackacre_Survival/
  Blackacre_Tome/
  Blackacre_Presence/     # beacons & bulletins — chrome/art frozen, feature work open
  ```

- Single-folder `Modules/` layout is deferred unless we revisit after solo loop works.
- TOC: proper metadata, SavedVariables (account + character), OptionalDeps (`totalRP3`), Interface verified.
- Localization from day one once AceLocale lands (Phase 2).
- Locals by default; event-driven (almost no OnUpdate); defensive nil/load checks; performance-conscious.
- **UX/UI is cross-cutting** — every feature phase includes Theme + texture consistency (see [`UX-VISION.md`](UX-VISION.md)).

### Code quality (non-negotiable)

- Everything local unless it must be global.
- Clear names; heavy useful comments (“why” + RP vision).
- Consistent style; version/author/notes/X-Website in TOC when we brand.

---

## Data & external references

- **Quest IDs / path roadmaps:** human supplies or researches; structure tables for easy paste.
- **TRP3:** Retail only. Public `TRP3_API` when loaded; never write TRP3 SavedVariables. **WoW Forever: do not read TRP3** (no official port). `Blackacre.Compat.SupportsTRP3()` is the gate.
- **Game data:** prefer modern `C_` APIs (`C_QuestLog`, `C_AchievementInfo`, etc.).
- **Timeline / era:** simple growing mapping table; flavor and content windows > perfect historiography.

---

## UX / UI & custom art

- **Anchor:** Bethesda design principles (**immersion, freedom, interactive systems**) married to **Warcraft’s in-game visual/UI language** — familiar, but bigger for adventure. **Not** a Base UI replacement.
- Design system SSOT in code: `Blackacre/UI/Theme.lua` (→ Blackacre later).
- Docs: [`UX-VISION.md`](UX-VISION.md) (surfaces, retcon vs new event, HUD rules), [`THEME-TOKENS.md`](THEME-TOKENS.md), [`MEDIA-GUIDE.md`](MEDIA-GUIDE.md).
- **Hard split:** **Book shell** = Tome journal only (IC). **Blackacre Menu** = OOC path/settings/mount status. No settings inside the journal.
- **Custom images are allowed** under `Media/` (TGA preferred), registered in Theme, with Blizzard fallbacks.
- Chrome texture: trail-journal parchment/leather/gold — still *Warcraft*, not a Skyrim HUD clone.

---

## Working process (every major task)

1. Restate current goal and small next step.
2. Before structural change: propose plan / outline; wait for **go**.
3. When editing existing code: audit keep / improve / discard (especially Presence).
4. After change: key code + plain English + test steps + file pointers.
5. Teach navigation (“Open Modules/… look for…”).
6. Suggest git commit messages; GitHub only on request.
7. Ask clearly if extra tools/libs/data are needed.

---

## Phased roadmap (10,000ft)

| Phase | Name | Notes |
|------:|------|--------|
| **0** | Align & freeze | This brief, UX docs, gitignore — **current** |
| 1 | Tooling hygiene | Dev loop, optional BugSack, visual baseline |
| 2 | Ace3 + Theme formalization | embeds, AceDB/Locale, Theme as module |
| 3 | Rename → Blackacre | SV migration, junctions, brand pass |
| 4 | Survival | Priority 1 + HUD immersion + optional custom meter art |
| 5 | Paths (Alternate Start) | Not Afterlife death rites |
| 6 | Quests + Roadmap | Human fills quest IDs |
| 7 | Living Tome | Chronicle polish |
| 8 | Advanced Setup | TRP3 + era |
| 9 | Light Community | Opt-in signals |
| 10 | Presence unfreeze | Bulletins/Beacons visual + feature pass |

Detail + per-phase UX: session plan / roadmap notes. Success = clean Ace3-style code, solo loop immersive, Presence intact until 10, human understands every major piece.

---

## Current package map

| Folder | Role |
|--------|------|
| `Blackacre` | Core: DB, comms, lifecycle, theme, TRP3 bridge, minimap |
| `Blackacre_Survival` | Hunger / thirst / exposure |
| `Blackacre_Tome` | Chronicle, roadmap, lineage, setup, afterlife, hardcore, PvP, share |
| `Blackacre_Presence` | Beacons & bulletins — primary IC community feature, chrome frozen till Phase 10 |

---

## Legal

World of Warcraft © Blizzard Entertainment. Fan addon; not affiliated with Blizzard.
