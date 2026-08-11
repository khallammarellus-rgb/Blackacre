# AGENTS.md — Blackacre / In Character

Instructions for coding agents (Grok CLI and similar) working in this repository.

## Read first

1. [`docs/BLACKACRE-BRIEF.md`](docs/BLACKACRE-BRIEF.md) — product goals, priorities, process  
2. [`docs/PRESENCE-FREEZE.md`](docs/PRESENCE-FREEZE.md) — **do not modify Presence features** until Phase 10  
3. [`docs/UX-VISION.md`](docs/UX-VISION.md) — immersive UI rules  
4. [`docs/THEME-TOKENS.md`](docs/THEME-TOKENS.md) — colors, textures, helpers  
5. [`docs/MEDIA-GUIDE.md`](docs/MEDIA-GUIDE.md) — custom images  

## Human is the driver

- Non-developer owner; teach as you go; small steps.  
- **Ask before** deletes, heavy refactors, renames, pushes, or PRs.  
- Restate goal + next step at the start of major work.  
- After changes: key code, plain English, in-game test steps, VS Code paths.  

## Product priorities (solo first)

1. Survival → 2. Paths (Alternate Start) → 3. Quests/Roadmap → 4. Living Tome → 5. Setup/TRP3 → 6. Community signals  

**Not** the same as Afterlife “paths” (death rites in Tome). Keep those separate.

## Codebase shape (today)

```
InCharacter/              # core — Theme, Comms, Lifecycle, DB
InCharacter_Survival/
InCharacter_Tome/
InCharacter_Presence/     # FROZEN feature work
docs/
```

Rename to Blackacre is **Phase 3**, not ad-hoc.

## UX rule

- **Anchor:** Bethesda (immersion, freedom, interactive design) × Warcraft visual UI — familiar but bigger for adventure. Not a Base UI replacement. Details: [`docs/UX-VISION.md`](docs/UX-VISION.md).
- **Journal vs Menu:** Book shell = Tome (IC pages only). **Blackacre Menu** = OOC settings, path picker, mount status. Never put settings controls inside journal pages.
- History-changing Menu edits must offer **retcon** (rewrite original choice only) vs **new event** (log a new beat).
- HUD meters: minimizable/hideable; hidden → player-only system text reminders; visible → normal popups/toasts.
- Player-facing chrome goes through **Theme** (`InCharacter/UI/Theme.lua`). Register textures before use. Presence freeze applies until Phase 10.

## Git / GitHub

- Prefer incremental commits with clear messages.  
- Push, force-push, or open PRs **only when the human asks**.  
- Do not amend published history without explicit approval.  

## Phase discipline

Work the roadmap in order unless the human picks another phase.  
Current foundation phase after docs: **Phase 1 (tooling)** then **Phase 2 (Ace3)**.
