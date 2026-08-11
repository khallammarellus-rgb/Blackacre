# Blackacre — Project Brief & Operating Instructions

**Status:** Phase 0 (docs / freeze). Working tree still named **In Character** until Phase 3 rename.  
**Repo path:** `C:\Users\kvebe\InCharacter`  
**Target client:** Retail WoW mainline (`## Interface: 120007` — verify on each patch).  
**Current suite version:** 1.2.0 (In Character packages).

This document is the long-form product brief for humans and coding agents. Session-start rules for Grok CLI also live in root [`AGENTS.md`](../AGENTS.md).

---

## User profile & working style

- Owner is **not** a professional developer; first serious WoW addon (after In Character experiments).
- Stack: VS Code + WoW API extension, Git, Grok CLI with GitHub access. Windows 11.
- **You (the human) direct every major decision.** The CLI does heavy lifting, explains clearly, shows before/after, and teaches how to navigate and proof code.
- Prefer **small, reviewable steps** over giant rewrites.
- **Always ask** before deleting or heavily refactoring working pieces.
- After meaningful changes: show key code, plain English, exact in-game tests, VS Code file pointers.
- Incremental commits; push/PRs only when the human asks.

---

## Goal

Rename and overhaul **In Character** into **Blackacre**: Skyrim-inspired RPG / solo RP in World of Warcraft (especially RP servers). Light community layer later so other Blackacre users can optionally see developments via signals.

### Core features (priority order — solo first)

1. **Survival meters** — Exposure, Thirst, Hunger (Fatigue later). Light, immersive, persistent.
2. **Path / Alternate Start** — Data-driven origins (Druid of the Claw, Defias Bandit, etc.). Quest IDs filled manually later.
3. **Quest ID repository + Roadmap** — Ordered/free-form chains, zone suggestions, level-lock *hints*.
4. **Living Tome** — Journal/backstory from achievements, quests, character data; editable and growing.
5. **Advanced setup** — TRP3 demographics if present; custom lineage; era/timeline flavor.
6. **Light community signals** — Opt-in AceComm-style; minimal.

### Explicit freeze

**Bulletins & Beacons (Presence package)** — leave untouched for feature work until Phase 10. Preserve working code. Rename-only touches in Phase 3 must not change behavior.

See [`PRESENCE-FREEZE.md`](PRESENCE-FREEZE.md).

---

## Architecture preferences

- Aim for **DBM-level cleanliness**: modular Core, clear packages, minimal global pollution.
- Prefer **Ace3**: AceAddon, AceDB (+ profiles), AceEvent, AceConfig/Dialog, AceGUI (as needed), AceLocale, AceTimer, AceComm, AceConsole. Embed only what we need via `embeds.xml` / LibStub.
- **Multi-package layout (recommended for v1):**

  ```
  Blackacre/              # core
  Blackacre_Survival/
  Blackacre_Tome/
  Blackacre_Presence/     # FREEZE feature work
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
- **TRP3:** public `TRP3_API` (e.g. profile APIs) when loaded; graceful fallback if absent. Never write TRP3 SavedVariables.
- **Game data:** prefer modern `C_` APIs (`C_QuestLog`, `C_AchievementInfo`, etc.).
- **Timeline / era:** simple growing mapping table; flavor and content windows > perfect historiography.

---

## UX / UI & custom art

- Design system SSOT in code: `InCharacter/UI/Theme.lua` (→ Blackacre later).
- Docs: [`UX-VISION.md`](UX-VISION.md), [`THEME-TOKENS.md`](THEME-TOKENS.md), [`MEDIA-GUIDE.md`](MEDIA-GUIDE.md).
- **Custom images are allowed** under `Media/` (TGA preferred), registered in Theme, with Blizzard fallbacks.
- Visual metaphor: **trail journal** — parchment, leather cover, gold titles, ink body — not TRP3 clone, not plain black boxes.

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

## Current package map (pre-rename)

| Folder | Role |
|--------|------|
| `InCharacter` | Core: DB, comms, lifecycle, theme, TRP3 bridge, minimap |
| `InCharacter_Survival` | Hunger / thirst / exposure |
| `InCharacter_Tome` | Chronicle, roadmap, lineage, setup, afterlife, hardcore, PvP, share |
| `InCharacter_Presence` | **FREEZE** — beacons & bulletins |

---

## Legal

World of Warcraft © Blizzard Entertainment. Fan addon; not affiliated with Blizzard.
