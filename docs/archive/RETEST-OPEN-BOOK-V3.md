# Retest — open book v3 (this round)

**Goal:** Confirm the mid-retest fixes before we call the flip-book “done enough” to move on.  
**Build:** local uncommitted / latest Theme + Chronicle + Capture + Options  
**Start:** `/reload` then `/ba tome` (or right-click minimap → Tome)

---

## What this round is checking

| Your note | Expected fix |
|-----------|----------------|
| Book not fully centered / weird art | **One** parchment art full-bleed under both leaves; path via `/ba bookart` |
| No left leaf / only right content | **Equal left + right leaves** (two halves of the open book) |
| TOC pinned vs flip-book | TOC is still **pages you flip**; bookmark jumps to TOC |
| Right-click edit title | **Right-click** a TOC line / title → edit title (journal on) |
| Sticky notes = full new entry | **Add note** = sticky on **current entry page** (not a full chronicle page) |
| Page number jump | Type a page # in footer jump box → Enter → go there |
| Survival / HC mount / fly in journal | Those kinds **blocked** from new auto-entries and **hidden** in the book list |
| Survival always on | Config toggle **Survival tracking** + `/ba survival off` / `on` |

---

## A — Smoke (2 min)

Do this first. If it fails, stop and report before deep book testing.

| # | Check | Pass? | Notes |
|---|--------|-------|-------|
| A1 | `/reload` — no red Lua errors | ☐ | |
| A2 | Minimap book icon still there | ☐ | |
| A3 | `/ba packages` shows Presence, Tome, Survival | ☐ | |
| A4 | `/ba tome` opens Traveler’s Tome | ☐ | |
| A5 | Esc closes tome | ☐ | |

---

## B — Book shell layout (look)

Stand in a quiet place. Open **Pages** (chronicle). Look at the **open book** only.

| # | Check | Pass? | Notes |
|---|--------|-------|-------|
| B1 | **One** close **X** (top-right header) — closes whole tome | ☐ | |
| B2 | Tabs sit at the **bottom** of the window (not top) | ☐ | |
| B3 | Small **TOC** bookmark sticks out left of the book (not full-height bar) | ☐ | |
| B4 | **Single** book background art (not two images meeting in the gutter) | ☐ | |
| B5 | Art feels **centered** under the whole open book | ☐ | |
| B6 | **Left leaf** has content area (TOC list or entry half) — not empty/missing | ☐ | |
| B7 | **Right leaf** has content area — roughly same width as left | ☐ | |
| B8 | Visible **gutter** (spine gap) between left and right | ☐ | |
| B9 | Body text is **white / readable** (not muddy brown on parchment) | ☐ | |
| B10 | Footer tools: Save · Add note · Pin · Delete on the **bottom strip** (not crushed on the page) | ☐ | |
| B11 | Footer shows page like `n / total` | ☐ | |

**Texture path (if art looks wrong):**

```
/ba bookart
```

Should print something like:

`Interface\AchievementFrame\UI-Achievement-Parchment-Horizontal`

---

## C — Flip-book navigation (do)

Need at least a few chronicle entries. If empty: turn in a small quest, or use sample if you have `/ic sample` / manual notes.

| # | Check | Pass? | Notes |
|---|--------|-------|-------|
| C1 | `<` / `>` flip through spreads (TOC pages then entry pages) | ☐ | |
| C2 | TOC is **book pages**, not a permanent left panel | ☐ | |
| C3 | Click a TOC line → jumps to that **entry spread** | ☐ | |
| C4 | Click **TOC bookmark** → back toward TOC / page 1 | ☐ | |
| C5 | Page number in footer updates when you flip | ☐ | |
| C6 | **Page jump:** click the page # box, type a valid number, press **Enter** → lands on that spread | ☐ | |
| C7 | Jump to **1** → TOC-ish start; jump past max → clamps (no crash) | ☐ | |
| C8 | Jump to **0** or junk text → no Lua error | ☐ | |

---

## D — Titles, stickies, edit (journal)

| # | Check | Pass? | Notes |
|---|--------|-------|-------|
| D1 | **Journal: On** (toggle on shell if present) | ☐ | |
| D2 | On an **entry** page: edit body → **Save** on footer → stays after `/reload` | ☐ | |
| D3 | **Right-click** TOC line (or title) → can edit **title** | ☐ | |
| D4 | Save title → shows on TOC and entry after flip/reload | ☐ | |
| D5 | On an **entry** page: **Add note** opens sticky popup (“Sticky note on this page”) | ☐ | |
| D6 | Pin sticky → note shows on **that page** (not a brand-new full chronicle entry in TOC) | ☐ | |
| D7 | **Add note** while still on **TOC only** → toast / hint, no crash | ☐ | |
| D8 | **Pin** toggles pin on current entry | ☐ | |
| D9 | **Delete** asks confirm → tears page out | ☐ | |

---

## E — Chronicle filters (what should *not* appear)

These kinds should **not** become new auto journal pages, and should not show as book content if filtered:

| Kind | How to stress (optional) | Expected |
|------|--------------------------|----------|
| SURVIVAL | Leave survival **on**, let meters run / low status | No new SURVIVAL page in book |
| HC_MOUNT | Mount without ground rite (if HC gates matter) | No new HC_MOUNT page in book |
| HC_FLY | Fly without flying rite | No new HC_FLY page in book |

| # | Check | Pass? | Notes |
|---|--------|-------|-------|
| E1 | After normal play with survival on, book list has **no** “Survival” auto pages | ☐ | |
| E2 | Mount/fly HC does **not** spam the chronicle with mount/fly entries | ☐ | |
| E3 | **Quests / achievements / manual notes** still *can* appear | ☐ | |
| E4 | Old junk SURVIVAL/HC_MOUNT/HC_FLY pages (if any already saved) stay **hidden** in the flip-book list | ☐ | |

---

## F — Survival tracking off

| # | Check | Pass? | Notes |
|---|--------|-------|-------|
| F1 | `/ba survival` shows Condition panel (if tracking on) | ☐ | |
| F2 | `/ba survival off` → meters stop / panel updates; chat says disabled | ☐ | |
| F3 | Bars no longer decay meaningfully while off (wait ~1 min or zone change) | ☐ | |
| F4 | `/ba survival on` → tracking resumes | ☐ | |
| F5 | `/ba config` → **Survival tracking** toggle matches slash behavior | ☐ | |
| F6 | Survival off does **not** break `/ba tome` or chronicle | ☐ | |

---

## G — Regression (only if A–F mostly pass)

| # | Check | Pass? | Notes |
|---|--------|-------|-------|
| G1 | Left-click minimap still opens Presence flyout | ☐ | |
| G2 | Other tome tabs still switch (Lineage / Road / etc.) without second floating window | ☐ | |
| G3 | Alliance year labels **K.C.**; Horde **ADP** (if years show) | ☐ | |
| G4 | Second `/reload` after edits — no error, data still there | ☐ | |

---

## Order to play (recommended)

1. **A** smoke  
2. **B** look at the book (screenshot if FAIL)  
3. **C** flip + page jump  
4. **D** journal / sticky / title  
5. **F** survival off (quick)  
6. **E** only if you have time for mount/survival stress  
7. **G** quick regression  

**Skip for later:** full Roadmap progress, Afterlife paths, Presence beacons deep pass — not this round’s focus.

---

## Reply template (paste back)

```
ROUND: open book v3
CHAR / REALM:
DATE:

A SMOKE: pass / fail
B LAYOUT:
  ONE X:
  BOTTOM TABS:
  TOC BOOKMARK:
  SINGLE CENTERED ART:
  LEFT LEAF:
  RIGHT LEAF / EQUAL HALF:
  WHITE TEXT:
  FOOTER TOOLS:
  PAGE n/total:
C NAV:
  FLIP < >:
  TOC AS PAGES:
  CLICK TOC TO ENTRY:
  PAGE JUMP BOX:
D EDIT:
  SAVE BODY:
  RIGHT-CLICK TITLE:
  STICKY (not full entry):
E FILTER (survival/mount/fly out of book):
F SURVIVAL OFF TOGGLE:
G REGRESSION:

DECISION: OK / needs changes
CHANGES: (short list, numbered)
SCREENSHOT NOTES: (optional)
```

---

## If something fails

1. Note **exact** step (e.g. “B6 left leaf empty after open”).  
2. `/reload` once and retry that step.  
3. If still fail: `/ba bookart` output + whether TRP3 is on.  
4. Do **not** keep testing deep features until shell (B) is OK.
