# AGENTS.md — Blackacre

Instructions for coding agents (Grok CLI, Claude, and similar) working in this repo.

Two add ons now, not one. Retail Blackacre and Forever Blackacre are becoming separate repos/folders because Forever doesn't have everything Retail has and trying to keep them one codebase risks breaking both when you touch one. Treat them as siblings, not the same product with a flavor flag glued on. Until the actual folder split happens, keep changes scoped to one flavor at a time and say which flavor you're touching before you touch it.

## Read first

1. [`docs/BLACKACRE-BRIEF.md`](docs/BLACKACRE-BRIEF.md) — product goals, priorities, process
2. [`docs/RETAIL-VS-FOREVER.md`](docs/RETAIL-VS-FOREVER.md) — what's different between the two, why they're split, what Forever just doesn't have
3. [`docs/HANDOFF-WOW-FOREVER.md`](docs/HANDOFF-WOW-FOREVER.md) — active state, recent performance changes, copy review
4. [`docs/PRESENCE-FREEZE.md`](docs/PRESENCE-FREEZE.md) — beacons & bulletins, still chrome-frozen till Phase 10 even though it's a top feature now
5. [`docs/UX-VISION.md`](docs/UX-VISION.md) — immersive UI rules (Bethesda × Warcraft)
6. [`docs/SKIN-AND-CHROME-GUIDE.md`](docs/SKIN-AND-CHROME-GUIDE.md) — canvas hierarchy, draw layers, BLP UV cropping, nine-slice & regions
7. [`docs/THEME-TOKENS.md`](docs/THEME-TOKENS.md) — colors, textures, helpers
8. [`docs/DBM-HYGIENE.md`](docs/DBM-HYGIENE.md) — hard-pass standards (DBM-Core / Paul Emmerich style)
9. [`docs/UI-ELEMENT-WORKFLOW.md`](docs/UI-ELEMENT-WORKFLOW.md) — Pass A skeleton → B art → C combine → D hard pass
10. [`docs/QA-TESTING-GUIDE.md`](docs/QA-TESTING-GUIDE.md) — in-game modular testing & pass/fail checklists
11. [`docs/MEDIA-GUIDE.md`](docs/MEDIA-GUIDE.md) — custom images
12. [`docs/TOOLING.md`](docs/TOOLING.md) — edit → `/reload` → `/ba`
13. [`docs/PLAYER-BONDS.md`](docs/PLAYER-BONDS.md) — future feature, mutual player relationship tiers. Not built yet, just written down so it doesn't get lost.

## Local texture / API lookup rule

- Don't browse the web or guess BLP/Atlas names, and don't guess API differences either.
- Owner has console-extracted the client files for **both flavors separately**, Retail and Forever, under the WoW folder on the drive (OneDrive desktop export). If you're not sure which flavor folder you're looking at, ask, because Forever textures/atlases can differ from Retail even when the name looks the same.
- Owner inspects textures in-game via Texture Atlas Viewer (TAV) and gives names/region codes (1S..13S). Match against the extracted files, don't invent coordinates.
- If you need to know how the extraction folder is normally laid out (the `-console` export structure) and you're not sure, it's fine to check general docs on that online — just don't guess actual file names or paths for this project off the web.
- Theme owns all paths (`Blackacre/UI/Theme.lua`, will split per-flavor). Feature code never hardcodes texture strings.

## Human is the driver

- Non-developer owner, visual learner. Teach as you go, small steps.
- For anything visual (chrome, text placement, buttons) talk in region codes and describe it plainly, owner will confirm by eye in-game, not by reading Lua.
- Ask before deletes, heavy refactors, force-pushes, or PRs. Normal push when asked is fine.
- Restate goal + next step before major work.
- After changes: key code, plain English, in-game test steps, VS Code file paths.
- Be creative when it helps solve a real problem the owner flagged — e.g. a font that's missing glyphs (dwarf runes have no digits, just show boxes), figure out a workaround like pulling numerals from a font that visually matches instead of leaving broken boxes on screen.

## Product priorities (solo first)

1. **Tome** — has to work and has to look good, this is the main thing
2. **Survival** — three meters (Exposure/Thirst/Hunger), no debuffs anymore, just the meters plus a Preparation buff when food/water is on hand
3. **Backstory menus** — differ between Retail and Forever, don't force them to match
4. **Beacons & Bulletins** — primary IC community feature (still chrome-frozen, see Presence doc)
5. **Character Sheet** — TRP3-lite, own implementation not a TRP3 dependency
6. Paths / Alternate Start — **Retail only for now.** Forever has no quest/canon reference deep enough yet to build paths off of, so there are no Forever paths. Don't try to backfill this by guessing quests.

Paths are not the same thing as Afterlife "paths" (death rites in Tome). Keep those separate, always have.

**Life Path data (Retail, offline):** `Blackacre_Tome/Data/Paths/` — owner fills `zones`/`quests`, see `docs/PATHS-GUIDE.md`. Catalog API: `Blackacre.Paths.Get` / `List`.

## Tome scope — don't over-log

Tome is not a quest logger. It's for meta stuff: chain finales, meta achievements, feats of strength, winning or losing a BG, big moments. It used to auto-log almost everything (bags, survival state, every quest turn-in) and that was too much, so that got pulled back. There is an opt-in toggle for logging every single quest if a player wants that, default off. Don't add new always-on auto-log hooks without checking they're meta-tier, not routine.

Tome pages are always written in first person. No exceptions, no OOC voice leaking into a page.

## Codebase shape (current, pre-split)

```
Blackacre/              # core — Theme, Comms, Lifecycle, DB
Blackacre_Survival/
Blackacre_Tome/
Blackacre_Presence/     # beacons & bulletins, chrome frozen till Phase 10
docs/
```

Disk path may still be `C:\Users\kvebe\InCharacter` (repo folder); addon package names are Blackacre*. This layout is going to become two separate repos (Retail / Forever) — see `docs/RETAIL-VS-FOREVER.md`. Until the owner says go on the actual split, don't restructure folders on your own, just keep flavor-specific logic behind `Blackacre.Compat` like today.

## UX rule

- Anchor: Bethesda (immersion, freedom, interactive design) × Warcraft visual UI — familiar but bigger for adventure. Not a Base UI replacement.
- Journal vs Menu: Book shell = Tome (IC pages only). Blackacre Menu = OOC settings, path picker, mount status.
- History-changing Menu edits: retcon vs new event prompt.
- HUD meters: min/hide; hidden → player-only system text; visible → popups/toasts.
- Theme: `Blackacre/UI/Theme.lua`. Presence chrome freeze until Phase 10 (feature/perf work on beacons & bulletins is fine, see Presence doc).
- UI structure: Frame = canvas with parent/children; paint with layers BACKGROUND → BORDER → ARTWORK → OVERLAY → HIGHLIGHT (see SKIN-AND-CHROME-GUIDE.md). Never put body text under page art, text is always OVERLAY.
- Per element: Pass A plain box layout (text/size/buttons/position) → B textures/art → C combine → D DBM hygiene hard pass. Don't skip to art before owner OKs skeleton.
- Templates: Tome ≈ Achievement Frame chrome; Menu ≈ Settings/Game Menu; Survival ≈ status bars.

## Code hygiene standard

Paul Emmerich / DBM-Core discipline, applied thoroughly, every pass. See `docs/DBM-HYGIENE.md` for the checklist. In short: locals/upvalues at file header, event-driven not OnUpdate polling, zero table allocation in hot paths, pool frames instead of recreating them, no globals outside `Blackacre.*`. When reviewing or writing a module, actually walk the DBM-Core benchmark steps, don't just skim.

When it helps to see how a real, respected addon solves a problem (DBM, TRP3, WeakAuras, whatever's relevant), it's fine to pull up its source on GitHub for reference. Don't copy features wholesale, copy the discipline and the pattern.

## Namespaces

- Global: `Blackacre` (per repo once split — Retail and Forever will each have their own SavedVariables and slash namespace, don't merge them)
- SV: `BlackacreDB` / `BlackacreCharDB` (migrate from `InCharacterDB` / `InCharacterCharDB` when present)
- Slash: `/ba`, `/blackacre`, `/ic`
- Comms: hidden global addon channel, addon-to-addon only. This is Blackacre installs talking to other Blackacre installs automatically, not a player chat channel — no player-typed chat ever goes through it.
- Flavor: `Blackacre.Compat` (Retail vs WoW Forever / Camelot). TOC `120007, 16001`. Do not treat Forever as Classic API, it isn't one.

## Git / GitHub

- Prefer incremental commits with clear messages.
- Push when the human asks.
- Do not force-push or amend published history without approval.
- Two repos are coming (Retail, Forever). Don't create or push either until the owner explicitly says go — this session is prep, not the cutover.

## Phase discipline

After rename + Phase 1 tooling: next is typically Phase 2 (Ace3 foundation) unless the human picks otherwise.
