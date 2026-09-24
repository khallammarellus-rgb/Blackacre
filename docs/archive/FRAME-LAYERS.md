# Frame & draw-layer framework (Mayron Ep. 5 → Blackacre)

**Source:** Mayron — *Creating WoW AddOns, Episode 5 – XML Templates*  
(Video: [Creating WoW AddOns – Episode 5](https://www.youtube.com/watch?v=0Z3b0SJuvI0))  
**Also:** Warcraft UI docs on layers / FrameXML patterns.

This is **required mental model** for Tome, Blackacre Menu, page panels, parchment tools, HUD chrome, and any custom textures. Whether we author UI in **XML** or **Lua** (`CreateFrame` / `CreateTexture`), the engine is the same.

---

## 1. Canvas = Frame

A **frame** is the canvas (container) that holds layout, scripts, and layered art.

| Idea | In WoW |
|------|--------|
| Canvas | `Frame` (or Button, ScrollFrame, etc.) |
| Parent | Another frame (or `UIParent`) — position and visibility inherit from parent |
| Children | Unlimited child frames (and regions) — nested tree, not a flat list |
| Show/hide | Hiding a parent hides descendants |

```
UIParent
 └── BlackacreTome (book shell frame)          ← parent canvas
      ├── tabRail (child frame)
      ├── pageHost (child frame)
      │    └── journal page content (children…)
      └── textures / fontstrings on each frame (regions on that canvas)
```

**Blackacre surfaces map to frames:**

| Surface (UX-VISION) | Typical frame role |
|---------------------|--------------------|
| Book shell | Root Tome frame |
| Blackacre Menu | Separate root (OOC) — not inside page panels |
| Page panel | Child of book `pageHost` |
| Parchment tool | Child strip at bottom of book |
| HUD meters | Independent frame on `UIParent` |
| Modal / wizard | Frame parented to book or UIParent |

---

## 2. Layers on a frame (draw order)

Textures and font strings sit on a frame in **draw layers**. Mayron (Ep. 5): a frame has **five layer types**, listed **lowest → highest** (back → front):

| Layer | Order | Put here |
|-------|------:|----------|
| **BACKGROUND** | 0 (back) | Full-frame fill, parchment wash, dark cover, “page paper” |
| **BORDER** | 1 | Edge / frame border art (when not using Backdrop edge) |
| **ARTWORK** | 2 | Main decorative art — spine strip, seals, icons that are part of the panel |
| **OVERLAY** | 3 | Titles, body text, most icons that must sit on top of art |
| **HIGHLIGHT** | 4 (front) | Mouse-hover glow; **auto show/hide** on mouse enter/leave |

Within the same layer, you can use a **sublevel** (−8 … +7) for fine ordering:

```lua
frame:CreateTexture(nil, "BACKGROUND", nil, -8)  -- further back inside BACKGROUND
frame:CreateTexture(nil, "BACKGROUND", nil, -6)  -- slightly in front of that
frame:CreateFontString(nil, "OVERLAY")           -- text above art
```

**Rule of thumb for Blackacre book:**

```
BACKGROUND  → cover fill, page wash, tab rail fill
BORDER      → (optional) custom edge textures
ARTWORK     → spine, ribbon, chapter ornaments, path card art
OVERLAY     → titles (gold), body (ink), close button chrome, edit fields
HIGHLIGHT   → hover states on clickable rows/tabs (when we use texture highlights)
```

---

## 3. Parent / child (infinite tree)

- Every frame (except roots under `UIParent`) has **one parent**.  
- A frame can have **many children** (Mayron: effectively unlimited nesting).  
- **Position** children relative to parent (`SetPoint`).  
- **Scale / alpha / hide** cascade.  
- Prefer **compose small frames** (tab rail, page host, footer tool) over one giant frame with dozens of unrelated textures fighting layers.

```
Book shell (parent)
 ├─ BACKGROUND: cover
 ├─ ARTWORK: spine, ribbon
 ├─ child: tabRail (own BACKGROUND + OVERLAY labels)
 ├─ child: pageHost (own BACKGROUND page + OVERLAY text)
 └─ child: parchmentTool (bottom journaling strip)
```

---

## 4. XML vs Lua (same framework)

Mayron teaches this often via **XML templates** (`virtual="true"`). Blackacre today builds mostly in **Lua**, which is fine:

| XML (Mayron style) | Lua equivalent |
|--------------------|----------------|
| `<Frame parent="...">` | `CreateFrame("Frame", name, parent)` |
| `<Layers><Layer level="BACKGROUND">` | `CreateTexture(nil, "BACKGROUND")` |
| `<Scripts>` | `frame:SetScript("OnClick", ...)` |
| Virtual template | Reusable Theme helpers (`CreateBookShell`, etc.) |

**We do not need to rewrite everything to XML.** We **must** respect layer + parent hierarchy the same way Episode 5 describes.

---

## 5. Backdrop vs layers

`SetBackdrop` (our current Theme panels) draws a **background + edge** as frame chrome. That is still “background/border” conceptually.

Custom art (TGA / Blizzard paths) should use **explicit layers**:

| Need | Prefer |
|------|--------|
| Solid panel color + simple edge | `ApplyFilledPanel` / Backdrop |
| Spine, ribbon, page wash, path art | `CreateTexture` on BACKGROUND / ARTWORK |
| Title / body | `CreateFontString` on **OVERLAY** |
| Hover affordance | HIGHLIGHT layer or button highlight texture |

Do **not** put body text on BACKGROUND (it will sit under art and look wrong).  
Do **not** put full-page parchment on OVERLAY (it will cover titles).

---

## 6. Theme code convention (Blackacre)

Helpers live in `Blackacre/UI/Theme.lua`. Going forward:

1. **Create parent frame first** (correct surface: book / menu / page / HUD).  
2. **Paint layers bottom-up** (BACKGROUND → … → OVERLAY).  
3. **Attach children** for interactive regions (tabs, scroll, buttons).  
4. Register texture paths in `Theme.Textures` / Media before use.  
5. Use sublevels when two BACKGROUND pieces stack (spine behind wash, etc.) — already used for `_baSpine` / `_baWash`.

Existing book shell already follows this partially:

- Spine / wash → `BACKGROUND` (sublevels −8 / −6)  
- Ribbon → `ARTWORK`  
- Title / subtitle → `OVERLAY` (via font strings)

New Tome/Menu work must keep that discipline.

---

## 7. Quick checklist (any new UI)

- [ ] Root frame has a clear parent (`UIParent` or book/menu host)  
- [ ] Background fill is BACKGROUND (or Backdrop), not OVERLAY  
- [ ] Decorative art is ARTWORK (or BACKGROUND sublevels), not covering text  
- [ ] Text / primary controls read as OVERLAY  
- [ ] Hover-only art uses HIGHLIGHT when appropriate  
- [ ] Nested UI is a **child frame**, not more textures on the wrong parent  
- [ ] Matches surface type in [`UX-VISION.md`](UX-VISION.md)  

---

## 8. How you can “see” layers while learning

In VS Code, open `Blackacre/UI/Theme.lua` and find `ApplyBookBackdrop` / `CreateBookShell`:

1. `CreateTexture(..., "BACKGROUND", nil, -8)` — spine (back)  
2. `CreateTexture(..., "BACKGROUND", nil, -6)` — page wash  
3. `CreateTexture(..., "ARTWORK")` — ribbon  
4. Title font string — OVERLAY  

That is Episode 5’s model in Lua form.
