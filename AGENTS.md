# AGENTS.md — Blackacre

Instructions for coding agents (Grok CLI and similar) working in this repository.

## Read first

1. [`docs/BLACKACRE-BRIEF.md`](docs/BLACKACRE-BRIEF.md) — product goals, priorities, process  
2. [`docs/PRESENCE-FREEZE.md`](docs/PRESENCE-FREEZE.md) — **do not modify Presence features** until Phase 10  
3. [`docs/UX-VISION.md`](docs/UX-VISION.md) — immersive UI rules (Bethesda × Warcraft)  
4. [`docs/THEME-TOKENS.md`](docs/THEME-TOKENS.md) — colors, textures, helpers  
5. [`docs/FRAME-LAYERS.md`](docs/FRAME-LAYERS.md) — **frame canvas + draw layers** (Mayron Ep. 5; required for Tome/Menu UI)  
6. [`docs/MEDIA-GUIDE.md`](docs/MEDIA-GUIDE.md) — custom images  
7. [`docs/TOOLING.md`](docs/TOOLING.md) — edit → `/reload` → `/ba`  
8. [`docs/UI-ELEMENT-WORKFLOW.md`](docs/UI-ELEMENT-WORKFLOW.md) — **Pass A skeleton → B art → C combine → D DBM hard pass**  
9. [`docs/DBM-HYGIENE.md`](docs/DBM-HYGIENE.md) — hard-pass standards (DBM-Core style)

## Human is the driver

- Non-developer owner; teach as you go; small steps.  
- **Ask before** deletes, heavy refactors, force-pushes, or PRs (normal push when requested is OK).  
- Restate goal + next step at the start of major work.  
- After changes: key code, plain English, in-game test steps, VS Code paths.  

## Product priorities (solo first)

1. Survival → 2. Paths (Alternate Start) → 3. Quests/Roadmap → 4. Living Tome → 5. Setup/TRP3 → 6. Community signals  

**Not** the same as Afterlife “paths” (death rites in Tome). Keep those separate.

## Codebase shape

```
Blackacre/              # core — Theme, Comms, Lifecycle, DB
Blackacre_Survival/
Blackacre_Tome/
Blackacre_Presence/     # FROZEN feature work
docs/
```

Disk path may still be `C:\Users\kvebe\InCharacter` (repo folder); **addon package names are Blackacre***.

## UX rule

- **Anchor:** Bethesda (immersion, freedom, interactive design) × Warcraft visual UI — familiar but bigger for adventure. Not a Base UI replacement.  
- **Journal vs Menu:** Book shell = Tome (IC pages only). **Blackacre Menu** = OOC settings, path picker, mount status.  
- History-changing Menu edits: **retcon** vs **new event** prompt.  
- HUD meters: min/hide; hidden → player-only system text; visible → popups/toasts.  
- Theme: `Blackacre/UI/Theme.lua`. Presence freeze until Phase 10.  
- **UI structure:** Frame = canvas with parent/children; paint with layers BACKGROUND → BORDER → ARTWORK → OVERLAY → HIGHLIGHT (see FRAME-LAYERS.md). Do not put body text under page art.  
- **Per element:** Pass **A** plain box layout (text/size/buttons/position) → **B** textures/art → **C** combine → **D** DBM hygiene hard pass. Do not skip to art before owner OKs skeleton.  
- **Templates:** Tome ≈ Achievement Frame chrome; Menu ≈ Settings/Game Menu; Survival ≈ status bars (keep current meters for now).

## Namespaces

- Global: `Blackacre`  
- SV: `BlackacreDB` / `BlackacreCharDB` (migrate from `InCharacterDB` / `InCharacterCharDB` when present)  
- Slash: `/ba`, `/blackacre`, `/ic`  
- Comms: `BA_RP` / `BA_Channel`  

## Git / GitHub

- Prefer incremental commits with clear messages.  
- Push when the human asks.  
- Do not force-push or amend published history without approval.  

## Phase discipline

After rename + Phase 1 tooling: next is typically **Phase 2 (Ace3 foundation)** unless the human picks otherwise.
