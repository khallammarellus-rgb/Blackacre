# Blackacre UX / UI vision

**Metaphor:** A **trail journal** — worn leather cover, parchment pages, gold ink titles, brown edges. Skyrim-adjacent immersion inside WoW’s native quest/journal language.  
**Not:** TRP3 clone, Discord-like social chrome, or plain black addon boxes for core solo features.

Living implementation: `InCharacter/UI/Theme.lua` (see [`THEME-TOKENS.md`](THEME-TOKENS.md)).  
Custom art: [`MEDIA-GUIDE.md`](MEDIA-GUIDE.md).

---

## Design principles

1. **In-character always** — Labels, empty states, and toasts sound like the world (“You cannot truly rest in combat”), not compiler output.  
2. **One Theme API** — Feature files call Theme helpers; they do not invent one-off backdrops (except short prototypes that then fold into Theme).  
3. **Native, not TRP3** — Quest parchment, tooltip borders, spellbook cues — Blizzard’s visual language.  
4. **Subtle at rest, rich when open** — Survival meters stay quiet; opening the Tome feels like opening a book.  
5. **Texture registry only** — Every path is a Theme key. No scattered `Interface\...` strings in feature modules.  
6. **Custom Media welcome** — Your TGA art under `Media/`, registered in Theme, with Blizzard fallbacks.  
7. **Presence freeze** — Do not restyle beacons/bulletins until Phase 10 ([`PRESENCE-FREEZE.md`](PRESENCE-FREEZE.md)).

---

## Surface types (pick the right chrome)

| Surface | Use for | Helper (today) |
|---------|---------|----------------|
| **Book shell** | Tome hub, setup-as-book, path picker chapter | `CreateBookShell` / `ApplyBookBackdrop` |
| **Page panel** | Content inside the book | `ApplyPagePanel` / filled `"page"` |
| **Parchment tool** | Floating utilities (survival meters, small tools) | `ApplyParchmentBackdrop` |
| **Toast** | Short IC feedback | `Theme.Toast` |
| **HUD meters** | Always-on survival | Compact parchment + Theme bar colors |
| **Modal / wizard step** | Setup steps | Book or parchment; same fonts as Theme |
| **Presence** | Beacons / boards | Frozen; already parchment-aware in places |

---

## Do / don’t

| Do | Don’t |
|----|--------|
| Gold titles + ink body | Red combat-error spam for RP feedback |
| Soft parchment toasts | Stack many floating windows when one book will do |
| Register textures first | Hard-code random Blizzard paths in feature files |
| Match trail-journal palette | Neon / Discord purple “modern UI” for solo loop |
| Esc-close floating frames | Uncloseable modal traps |
| Fall back if custom art missing | Leave black/empty panels |

---

## Visual density default

**Trail journal (restrained)** — clear hierarchy, readable ink, modest ornament.  
Optional later: richer “ornate grimoire” if you choose it explicitly.

---

## Per-phase UX expectations (summary)

| Phase | UX focus |
|------:|----------|
| 0 | Vision + token inventory + media guide (**this phase**) |
| 1 | Visual baseline checklist in-game (screenshots / notes) |
| 2 | Formalize Theme module; no full reskin |
| 3 | Brand strings/icon only |
| 4 | Survival HUD fully Theme-tokened; optional custom meter art |
| 5 | Path picker as book cards |
| 6 | Roadmap list states (done/current/locked) on Theme |
| 7 | Journal pages readable and beautiful |
| 8 | Setup wizard inside book chrome |
| 9 | Peer cards / seals, quiet opt-in |
| 10 | Presence Theme audit |

---

## UX checklist (any phase that ships UI)

- [ ] Theme helpers only for chrome  
- [ ] Colors/textures from registry  
- [ ] Gold title + ink body where appropriate  
- [ ] IC empty / first-run state  
- [ ] Soft toast, not red spam  
- [ ] Readable at 1080p; Esc closes floaters  
- [ ] Same world as sibling surfaces  
- [ ] New texture keys documented  

---

## How to proof in-game

1. `/reload` after file save.  
2. Open Tome (`/ic tome`) — book shell, tabs, no black void.  
3. Open Survival (`/ic survival`) — parchment meters.  
4. Trigger a toast (e.g. low survival or `/ic eat`) — soft parchment, top of screen.  
5. Compare to this doc: still “trail journal”?  

VS Code: start at `InCharacter/UI/Theme.lua`, then the feature’s `UI_*.lua`.
