# AGENTS.md — Blackacre

Instructions for coding agents (Grok CLI and similar) working in this repository.

## Read first

1. [`docs/BLACKACRE-BRIEF.md`](docs/BLACKACRE-BRIEF.md) — product goals, priorities, process  
2. [`docs/HANDOFF-WOW-FOREVER.md`](docs/HANDOFF-WOW-FOREVER.md) — active state, recent performance changes, copy review  
3. [`docs/PRESENCE-FREEZE.md`](docs/PRESENCE-FREEZE.md) — **do not modify Presence features** until Phase 10  
4. [`docs/UX-VISION.md`](docs/UX-VISION.md) — immersive UI rules (Bethesda × Warcraft)  
5. [`docs/SKIN-AND-CHROME-GUIDE.md`](docs/SKIN-AND-CHROME-GUIDE.md) — **canvas hierarchy, draw layers, BLP UV cropping, nine-slice & regions**  
6. [`docs/THEME-TOKENS.md`](docs/THEME-TOKENS.md) — colors, textures, helpers  
7. [`docs/DBM-HYGIENE.md`](docs/DBM-HYGIENE.md) — hard-pass standards (DBM-Core style)  
8. [`docs/UI-ELEMENT-WORKFLOW.md`](docs/UI-ELEMENT-WORKFLOW.md) — **Pass A skeleton → B art → C combine → D DBM hard pass**  
9. [`docs/QA-TESTING-GUIDE.md`](docs/QA-TESTING-GUIDE.md) — **in-game modular testing & pass/fail checklists**  
10. [`docs/MEDIA-GUIDE.md`](docs/MEDIA-GUIDE.md) — custom images  
11. [`docs/TOOLING.md`](docs/TOOLING.md) — edit → `/reload` → `/ba`  

## Local Texture Lookup Rule

- **Do not browse the web or guess BLP/Atlas names.**
- The owner inspects textures in-game via **Texture Atlas Viewer (TAV)** and shares names/region codes (1S..13S).
- The agent inspects the owner's local exported client files at:
  `C:\Users\kvebe\OneDrive\Desktop\Blackacre, In Character` (textures extracted with `-console`).
- Theme owns all paths (`Blackacre/UI/Theme.lua`). Feature code never hardcodes texture strings.

## Human is the driver

- Non-developer owner; teach as you go; small steps.  
- **Ask before** deletes, heavy refactors, force-pushes, or PRs (normal push when requested is OK).  
- Restate goal + next step at the start of major work.  
- After changes: key code, plain English, in-game test steps, VS Code paths.  

## Product priorities (solo first)

1. Survival → 2. Paths (Alternate Start) → 3. Quests/Roadmap → 4. Living Tome → 5. Setup/TRP3 → 6. Community signals  

**Not** the same as Afterlife “paths” (death rites in Tome). Keep those separate.

**Life Path data (offline):** `Blackacre_Tome/Data/Paths/` — owner fills `zones`/`quests`; see `docs/PATHS-GUIDE.md`. Catalog API: `Blackacre.Paths.Get` / `List`.

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
- **UI structure:** Frame = canvas with parent/children; paint with layers BACKGROUND → BORDER → ARTWORK → OVERLAY → HIGHLIGHT (see SKIN-AND-CHROME-GUIDE.md). Do not put body text under page art.  
- **Per element:** Pass **A** plain box layout (text/size/buttons/position) → **B** textures/art → **C** combine → **D** DBM hygiene hard pass. Do not skip to art before owner OKs skeleton.  
- **Templates:** Tome ≈ Achievement Frame chrome; Menu ≈ Settings/Game Menu; Survival ≈ status bars (keep current meters for now).

## Namespaces

- Global: `Blackacre`  
- SV: `BlackacreDB` / `BlackacreCharDB` (migrate from `InCharacterDB` / `InCharacterCharDB` when present)  
- Slash: `/ba`, `/blackacre`, `/ic`  
- Comms: `BA_RP` / `BA_Channel`  
- Flavor: `Blackacre.Compat` (Retail vs WoW Forever / Camelot). TOC `120007, 16001`. Do not treat Forever as Classic API.  

## Git / GitHub

- Prefer incremental commits with clear messages.  
- Push when the human asks.  
- Do not force-push or amend published history without approval.  

## Phase discipline

After rename + Phase 1 tooling: next is typically **Phase 2 (Ace3 foundation)** unless the human picks otherwise.
