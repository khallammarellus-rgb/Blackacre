# UI element workflow (Pass A → D)

**Rule:** When we work on an element (Tome shell, Menu, page, meters, …), we do **not** invent final art and logic in one giant change. We finish each pass before the next.

Frame/layer model always applies: [`FRAME-LAYERS.md`](FRAME-LAYERS.md).  
UX surfaces: [`UX-VISION.md`](UX-VISION.md).  
Code hard pass: [`DBM-HYGIENE.md`](DBM-HYGIENE.md).

---

## Pass A — Skeleton (layout first)

**Ship:** plain box + borders only (Backdrop / simple edge). Temporary solid fills OK.

| Nail this | Done when |
|-----------|-----------|
| Text | Titles, labels, body readable |
| Size | Fits 1080p without clip |
| Orientation | Panel shape as intended |
| Landscaping | Margins, padding, gaps feel right |
| Buttons | Present, labeled, clickable; Esc/close where needed |
| Positioning | Parent/child + anchors correct |

**Still required:** correct frame tree and draw layers (even if colors are temporary).  
**Not yet:** custom Media, final parchment washes, path portraits.

**Owner gate:** You approve layout before Pass B.

---

## Pass B — Textures & art

Skin the **approved** skeleton:

- Register textures in Theme  
- BACKGROUND fills, ARTWORK ornaments, OVERLAY text  
- Use **template art** (below) until custom Media exists  
- Do not reflow layout unless skeleton was wrong (then return to A)

**Owner gate:** You approve look before Pass C.

---

## Pass C — Combine

Skeleton + art together:

- `/reload` QA  
- No text under art; no wrong surface (Menu ≠ Book)  
- Visual checklist from UX-VISION  

---

## Pass D — DBM hard pass

**After art is accepted.** Tighten code to DBM-grade hygiene ([`DBM-HYGIENE.md`](DBM-HYGIENE.md)).  
Then commit. Only then start the next element (unless you explicitly defer debt).

---

## Pipeline

```
Element N
  A Skeleton → you OK
  B Art      → you OK
  C Combine  → /reload OK
  D Hard pass → commit
Element N+1
```

---

## Template art (for Pass B until Media is final)

| Surface | Template |
|---------|----------|
| **Tome book shell** | **Achievement Frame** family (parchment, large window, header, content) — not achievement features, only chrome language |
| **Blackacre Menu** | **Settings / Game Menu** style (dialog + category list + content) — OOC, not the journal |
| **Survival meters** | **Health / mana / energy status bar** language; **keep current skeleton for now** |
| Page panels | Inside Tome; plain page → achievement parchment |
| Parchment tool | Bottom strip of Tome; plain → parchment |

---

## CLI behavior

At the start of work on an element, restate: **element name + Pass letter**.  
Do not jump to Pass B art until you say skeleton is OK.
