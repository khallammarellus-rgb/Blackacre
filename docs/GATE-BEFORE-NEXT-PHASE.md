# Gate — before next phase

**Goal:** One clean in-game pass over the open-book polish slice, then decide: **commit & move on**, **fix list**, or **hold**.  
**Not this gate:** full Roadmap, Afterlife deep paths, Presence beacons deep pass, aging/watermarks, faction flair.  
**Build:** local working tree (Theme + Chronicle + TomeHub + Options + fonts).  
**Start:** `/reload` → wait for no red errors → right-click minimap **or** `/ba tome`.

---

## How to use this plan

1. Work **top to bottom**. Sections A–B are stop-gates.  
2. Mark **P** / **F** / **skip** in Notes.  
3. If a stop-gate fails twice after `/reload`, **stop** and report that step only.  
4. When done, paste the **Reply template** at the bottom.  
5. We do **not** start the next phase until Decision = **OK to move on** (or you explicitly waive items).

**Time budget:** ~20–30 min if data already exists; +10 min if you need sample entries.

**Prep (once):**
- Have at least **3–5 chronicle pages** (quests, sample, manual notes).  
- Journal mode **On** when testing edit/stickies.  
- Quiet place (city / inn) so combat UI doesn’t steal focus.

---

## A — Smoke (stop-gate, ~2 min)

| # | Check | P/F | Notes |
|---|--------|-----|-------|
| A1 | `/reload` — **no red Lua errors** | | |
| A2 | Minimap **book** icon present | | |
| A3 | `/ba packages` lists Presence, Tome, Survival | | |
| A4 | `/ba tome` opens Traveler’s Tome | | |
| A5 | **Esc** closes the tome | | |
| A6 | Left-click minimap still opens **Presence** flyout (not Tome) | | |

**Stop if:** any red error, tome won’t open, minimap broken.

---

## B — Book shell (stop-gate, look only)

Open **Pages**. Look at the open book. No clicking required yet.

| # | Check | P/F | Notes |
|---|--------|-----|-------|
| B1 | **One** close **X** (header) — closes whole tome | | |
| B2 | Tabs on the **bottom** of the window | | |
| B3 | Small **TOC** bookmark on the **left** of the book (not a full-height bar) | | |
| B4 | **Single** parchment art under both leaves (not two plates meeting in the middle) | | |
| B5 | Art centered / cropped cleanly (no huge grey frame, no stretch corners) | | |
| B6 | **Left leaf** and **right leaf** both present, roughly equal width | | |
| B7 | Clear **gutter** (spine gap) between leaves | | |
| B8 | Body text **graphite / readable** on parchment (not muddy, not empty □ boxes) | | |
| B9 | Footer tools: Save · Add note · Pin · Delete on bottom strip | | |
| B10 | Footer page readout like `n / total` | | |

**Stop if:** dual art, missing leaf, unreadable text, double X, wrong chrome.

Optional: `/ba bookart` — note path if art looks wrong.

---

## C — Flip & TOC (do)

| # | Check | P/F | Notes |
|---|--------|-----|-------|
| C1 | `<` / `>` flip spreads (TOC → entries) | | |
| C2 | TOC is **pages you flip**, not a permanent side panel | | |
| C3 | Click a TOC **title line** → jumps to that entry spread | | |
| C4 | Click **TOC bookmark** → returns toward TOC / start | | |
| C5 | Page `n / total` updates when flipping | | |
| C6 | **Page jump:** type a valid # in footer box → **Enter** → lands there | | |
| C7 | Jump `1` → near TOC; jump past max → clamps (no crash) | | |
| C8 | Jump `0` or junk text → no Lua error | | |
| C9 | **Top TOC rows** are clickable (not dead under bookmark) | | |
| C10 | TOC **hover** is a soft gold wash — not a solid black box | | |

### C-TOC — leaders & page numbers (fixed this slice)

Layout is pixel-anchored (not monospaced dots): **title left · leaders fill · page # flush right of that leaf**.  
Left leaf right edge = **gutter**; right leaf right edge = **outer** margin.

| # | Check | P/F | Notes |
|---|--------|-----|-------|
| C11 | Each TOC entry: **title (year)** then **……** then **page #** | | |
| C12 | **Left TOC leaf:** page numbers sit at the **gutter** (right edge of left leaf) | | |
| C13 | **Right TOC leaf** (if enough entries for a second TOC page): page numbers at **outer right** of that leaf | | |
| C14 | Long titles wrap; only the **last** wrap line has leaders + page # | | |
| C15 | Page numbers form a clean vertical column on each leaf (not drifting mid-line) | | |

**If C11–C15 fail but the book works:** note under Decision as *fix before commit*. Do not block the whole gate unless it looks broken.

---

## D — Freeform pages & titles (journal On)

| # | Check | P/F | Notes |
|---|--------|-----|-------|
| D1 | Journal **On** | | |
| D2 | On an **entry** leaf: click body, type, **Save** → text stays after flip away and back | | |
| D3 | `/reload` → same entry still has your edit | | |
| D4 | Title editable on the entry (click title field if present) | | |
| D5 | **Right-click** TOC line → edit title → Save → TOC + entry show new title | | |
| D6 | **Pin** on an entry → pin state feels correct in TOC / toast | | |
| D7 | **Delete** → confirm → page gone from book (or hidden as designed) | | |
| D8 | Save / pin / delete on **TOC-only** spread → toast or no-op, **no crash** | | |

---

## E — Sticky scraps (both leaves)

| # | Check | P/F | Notes |
|---|--------|-----|-------|
| E1 | On an **entry** page: **Add note** → sticky scrap appears on **this** entry (not a new TOC full page) | | |
| E2 | Sticky looks like a scrap (borderless-ish), not a full journal frame | | |
| E3 | Type on sticky → survives flip away/back (or after Pin if that’s the save path) | | |
| E4 | **Right-click sticky** → Pin / Delete (or equivalent menu) works | | |
| E5 | **Right-click empty leaf** (or page area) → can **Add note** for that side | | |
| E6 | Stickies on **left** leaf stay left; **right** leaf stay right after flip/reload | | |
| E7 | Flip to another entry → previous stickies **gone** (not ghosted on wrong page) | | |
| E8 | Flip back → stickies return on the correct entry | | |
| E9 | Add note while on **TOC only** → hint/toast, no crash, no orphan scrap | | |
| E10 | `/reload` → stickies still on the right entry + side | | |

---

## F — Fonts (quick)

| # | Check | P/F | Notes |
|---|--------|-----|-------|
| F1 | Body text uses a readable catalog font (no empty □ for normal letters) | | |
| F2 | `/ba config` (or Options) → change **body font** if listed → `/reload` or re-open tome → body updates | | |
| F3 | Titles / TOC still readable after font change | | |
| F4 | No mid-line dual-font glitch (one entry, one body face) | | |

Skip F2–F4 if you are not changing fonts this session.

---

## G — IC book vs OOC Backstory (boundary)

| # | Check | P/F | Notes |
|---|--------|-----|-------|
| G1 | **Pages** tab = story book only (chronicle / TOC / stickies) | | |
| G2 | Lineage / Honor / Road / Realms / Voice / Share open as **Backstory / menus** (sidecar or tab content), **not** as extra IC parchment tabs inside the flip leaves | | |
| G3 | Switching those tabs does **not** spawn a second floating feature window | | |
| G4 | Esc still closes the whole Tome cleanly | | |
| G5 | Returning to **Pages** restores the flip-book without blank/broken leaves | | |

---

## H — Survival / chronicle filters (short)

| # | Check | P/F | Notes |
|---|--------|-----|-------|
| H1 | `/ba survival` works (panel or status) | | |
| H2 | `/ba survival off` → chat confirms off; meters not meaningfully decaying | | |
| H3 | `/ba survival on` → resumes | | |
| H4 | Book does **not** grow SURVIVAL auto-pages while meters run | | |
| H5 | Survival off does **not** break `/ba tome` | | |

Mount/fly HC spam check is optional (only if you use those gates).

---

## I — Presence freeze & packages (regression)

| # | Check | P/F | Notes |
|---|--------|-----|-------|
| I1 | Left-click minimap → Presence flyout still works | | |
| I2 | Presence did not pick up random new chrome/layout breakage from Tome work | | |
| I3 | Disable **nothing** for this gate unless you want package isolation later | | |

Deep beacon/board two-client tests are **out of scope** for this gate.

---

## J — Final reload soak

| # | Check | P/F | Notes |
|---|--------|-----|-------|
| J1 | After all edits: `/reload` once — **no errors** | | |
| J2 | Tome opens; last pages/titles/stickies/fonts still make sense | | |
| J3 | Second open/close cycle (Esc → open again) — clean | | |

---

## Recommended order (play this)

```
A smoke
 → B shell look
 → C flip + TOC (+ C-TOC leaders)
 → D freeform save/title
 → E stickies both leaves
 → G IC vs Backstory
 → F fonts (if you care)
 → H survival quick
 → I Presence left-click
 → J final /reload
 → Decision
```

**Do not** start a new feature while any of **A / B / D2–D3 / E6–E8** are red.

---

## Decision gate

Pick one:

| Decision | When |
|----------|------|
| **OK to move on** | A–B pass; D/E core pass; C mostly pass; C-TOC good enough or waived |
| **Fix list first** | Anything in A–B, data loss, ghost stickies, crash, broken minimap |
| **Polish pass only** | Only C-TOC leaders / minor visual nits; book is usable |

### Next phase candidates (after OK)

You pick priority after this gate — **do not start until Decision is clear**:

1. **Commit** the open-book polish (Pass D notes already in `DBM-HYGIENE.md`)  
2. **TOC leader layout rewrite** (if C11–C15 fail and you want it fixed now)  
3. **Survival / Menu** product work  
4. **Embellishments later:** aging, watermarks, class flair  
5. **Fonts** catalog trim only if F fails  

---

## Reply template (paste back)

```
GATE: before next phase
CHAR / REALM:
DATE:

A SMOKE:
B SHELL:
C NAV / TOC:
C-TOC LEADERS (left gutter / right outer):
D FREEFORM / TITLE / PIN / DELETE:
E STICKIES (L/R, no ghosts):
F FONTS:
G IC vs BACKSTORY:
H SURVIVAL:
I PRESENCE:
J FINAL RELOAD:

STOPPERS (must fix):
NITS (optional):
WAIVE (ok to live with):

DECISION: OK to move on / Fix list first / Polish pass only
NEXT PHASE PRIORITY: (commit / TOC leaders / Survival / other)
```

---

## If something fails

1. Write the **exact** step id (e.g. `E7 sticky ghosts on next entry`).  
2. `/reload` once; retry **that** step only.  
3. Still fail → screenshot + whether Journal On + TRP3 on/off if relevant.  
4. Do not keep bulk-testing until stop-gates are green.
