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

Player-facing UI goes through **Theme** (`InCharacter/UI/Theme.lua`). Register textures (Blizzard or `Media/`) before use. No new plain black panels for solo features. Presence freeze still applies to cosmetics.

## Git / GitHub

- Prefer incremental commits with clear messages.  
- Push, force-push, or open PRs **only when the human asks**.  
- Do not amend published history without explicit approval.  

## Phase discipline

Work the roadmap in order unless the human picks another phase.  
Current foundation phase after docs: **Phase 1 (tooling)** then **Phase 2 (Ace3)**.
