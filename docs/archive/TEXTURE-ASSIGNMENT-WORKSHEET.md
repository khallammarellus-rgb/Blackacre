# Texture assignment worksheet — Tome · Sidecar · Survival (later)

**Purpose:** You assign **which art** goes on **which field**. I execute in Theme + widgets.  
**Desktop library (reference only — never import PNGs):**  
`C:\Users\kvebe\OneDrive\Desktop\Blackacre, In Character`

**Rules (locked):**
1. Desktop files are **name reference** → map to Blizzard `Interface\...` BLP (or TGA you drop in `Media/`).  
2. Multi-piece sheets need **TexCoords** (from Blizzard XML or measured).  
3. Skip Presence / bulletins / beacons.  
4. Survival meters = **last**; WeakAura-style under player frame (later).  
5. Sidecar stays **docked** to the book.  
6. Class flair / aging dirt / boss portraits = **embellishment later** unless you mark a field now.

---

## Part A — How WoW texture kits work (research summary)

### A1. BLP vs your PNG previews

| Concept | Meaning |
|---------|---------|
| **BLP** | Game-native texture inside the client. Path: `Interface\Folder\FileName` (no `.blp` required in Lua). |
| **Your Desktop PNG** | Extracted **preview** of that BLP (or a composite). Filename usually matches the BLP stem. |
| **We do not ship Desktop PNGs** | Addon uses the live Blizzard path so every player has the art. |

Example:

| Desktop | In-game path |
|---------|----------------|
| `UI-EJ-JournalBG.png` | `Interface\EncounterJournal\UI-EJ-JournalBG` |
| `UI-Achievement-Parchment-Horizontal.png` | `Interface\AchievementFrame\UI-Achievement-Parchment-Horizontal` |

### A2. XML → Lua (how Blizzard crops kits)

Blizzard UI XML often looks like:

```xml
<Texture parentKey="Background" file="Interface\EncounterJournal\UI-EJ-JournalBG">
  <TexCoords left="0" right="0.766601562" top="0" bottom="0.830078125"/>
</Texture>
```

Lua equivalent (what Theme already does for the book):

```lua
tex:SetTexture("Interface\\EncounterJournal\\UI-EJ-JournalBG")
tex:SetTexCoord(0, 0.766601562, 0, 0.830078125)
```

| XML idea | Lua / addon |
|----------|-------------|
| `<Texture file="...">` | `CreateTexture` + `SetTexture` |
| `<TexCoords left right top bottom>` | `SetTexCoord(L, R, T, B)` — **normalized 0–1** |
| `<Size>`, `<Anchors>` | `SetSize` / `SetPoint` |
| Nine-slice edge | `BackdropTemplate` `edgeFile` + `edgeSize` **or** 9 separate textures |
| Atlas name (modern) | `SetAtlas("AtlasName")` when the art is in an atlas (not a full file path) |
| Status bar fill | `StatusBar:SetStatusBarTexture(path)` + width/value |

**Important:** A single PNG/BLP can hold **many widgets** (tabs idle/active, corners, buttons). Without the right **coords**, you get the whole sheet stretched wrong.

### A3. Ways we build widgets

| Pattern | When | Example |
|---------|------|---------|
| **Full-bleed texture** | One image = one region | Journal open-book BG |
| **Cropped sheet (TexCoords)** | One file, many pieces | EJ tab strip, map frame left/mid |
| **Backdrop edge** | Border around a panel | Dialog / tooltip borders |
| **Tiled center + edge pieces** | Tileable parchment + L/R/T/B edges | Your `Tileable-Parchment*` set |
| **StatusBar bubble** | Fill progress (XP/rep style) | Survival later |
| **Layer stack** | BACKGROUND wash → ARTWORK ornament → OVERLAY text | All Tome chrome |

Layers always: **BACKGROUND → BORDER → ARTWORK → OVERLAY → HIGHLIGHT** (`docs/FRAME-LAYERS.md`).

### A4. Finding TexCoords when we don’t have XML

1. Prefer **Gethe wow-ui-source** / in-game FrameXML for that filename.  
2. Else measure: if sheet is 512×512 and a tab is pixels (x,y,w,h) →  
   `left=x/W`, `right=(x+w)/W`, `top=y/H`, `bottom=(y+h)/H`.  
3. Store coords next to the Theme path (like `bookArtTexCoords` today).  
4. You never need to write XML yourself — I translate to Theme Lua.

### A5. Theme registry (where assignments land)

All paths go in `Blackacre.UI.Theme.Textures` (and `Colors`, `*TexCoords`, helpers).  
Feature code only calls helpers — **no raw paths** in Survival/Tome pages.

---

## Part B — Your library map (favorites → Blizzard paths)

### B1. Core parchment & book (high priority for 90%)

| Desktop name / folder | Likely `Interface\...` path | Suggested use |
|----------------------|----------------------------|---------------|
| `UI-EJ-JournalBG.png` | `Interface\EncounterJournal\UI-EJ-JournalBG` | **T2** Open-book face (already wired + coords) |
| `UI-Achievement-Parchment-Horizontal.png` | `Interface\AchievementFrame\UI-Achievement-Parchment-Horizontal` | Header/footer washes, tools |
| `UI-Achievement-Parchment-Horizontal-Desaturated.png` | same family, desaturated variant | Soft/disabled wash, OOC sidecar |
| `Tileable-Parchment.png` | *Confirm path* (often mission/landing parchment tile) | Page fill if we switch from solid wash |
| `Tileable-ParchmentEdge-Left/Right/Top/Bottom.png` | Matching edge files | True parchment **frame** border |
| `T_VFX_Dirt.png` | VFX dirt (path TBD) | **Later** aging — not 90% |

### B2. Borders & polish (shell / sidecar)

| Desktop name | Likely family | Suggested use |
|--------------|---------------|---------------|
| `UI-EJ-MapFrame-Cata-Left` / `Mid` | EncounterJournal map frame | Outer or leaf edge trim |
| `UI-EJ-DungeonMapFrame-Cata` | EJ map frame | Alternate chrome |
| `UI-EJ-Classic` / `BurningCrusade` / `CATACLYSM` / `Legion` | EJ expansion plates | Era chrome **later** or Road tab flair |
| `DungeonJournalTierBackgrounds1–5` | EJ tier sheets | Background kits (needs coords) |
| `AllianceBfAMissionFrame` / `Horde...` / `Frame2` | BfA mission frames | **Sidecar** OOC chrome (faction-aware later) |
| `BfAMissionsLandingPageAlliance` / `Horde` | Landing page BG | Sidecar full-page wash |

### B3. Tabs

| Desktop name | Suggested use |
|--------------|---------------|
| `LootTab.png` / `loottab-item-background.png` | Sidecar / bookmark tab language |
| `HeadhunterUI.png` | Tab frame experiment (needs coords if sheet) |
| `MobileAppIcons.png` | Icon strip (optional; often skip) |
| EJ tab coords already in Theme | TOC bookmark (current) |

### B4. Later embellishment (do **not** assign for 90% unless you insist)

| Folder | Content | Phase |
|--------|---------|--------|
| `Class Flair` | OrderHallLandingPage* per class | Embellishment |
| `Afterlife Polish` | Shadowlands covenant landing BGs | Realms tab polish later |
| `Model Embellishment` | UI-EJ-BOSS-* portraits | Page ornaments later |
| `Reflection Embellishment` | Lore / professions / scenarios | Later storytelling art |
| `Parchment Blemish` | Dirt | Aging pass |

---

## Part C — Assignment fields (you fill **YOUR PICK**)

### How to fill

For each row:
- **YOUR PICK:** Desktop filename **or** `Interface\...` path **or** `KEEP` **or** `SKIP`  
- **NOTES:** crop / tile / faction / “too dark” etc.  
- Leave blank = I propose a default from Part B and you OK on execute plan  

Mark priority: **P1** must for 90% · **P2** nice · **P3** later  

---

### C-T0 — Theme tokens (meta)

| Field key | What it drives | Default now | YOUR PICK | P | Notes |
|-----------|----------------|-------------|-----------|---|-------|
| `Colors.ink` | Body / TOC graphite | graphite | | P1 | |
| `Colors.gold` | Titles | gold | | P1 | |
| `Colors.pageFill` | Leaf wash | parchment tint | | P1 | |
| `Colors.edge` | Borders | brown | | P1 | |
| `Sounds.pageTurn` | Arrow flip | 836 | KEEP | P1 | |
| `Sounds.bookOpen` | Open tome | 829 | KEEP | P1 | |

---

### C-T1 — Outer book shell

| Field key | Widget | Default now | YOUR PICK | P | Notes |
|-----------|--------|-------------|-----------|---|-------|
| `shell.bg` | Outer frame fill | white tint + dialog edge | | P1 | |
| `shell.edge` | Outer border | DialogBox border | | P1 | |
| `shell.header.bg` | Title bar | Achievement parchment | | P1 | |
| `shell.header.title` | Font/color | Gold title | | P1 | |
| `shell.close` | Close X button skin | UIPanelButton | | P1 | |
| `shell.footer.bg` | Bottom bar | parchment | | P1 | |
| `shell.tabBar.bg` | Bottom tab strip (if any) | solid | | P2 | |

---

### C-T2 — Open-book stage

| Field key | Widget | Default now | YOUR PICK | P | Notes |
|-----------|--------|-------------|-----------|---|-------|
| `book.art` | Full open-book texture | `UI-EJ-JournalBG` | | P1 | |
| `book.artTexCoords` | Crop | EJ XML 0–0.766 / 0–0.830 | KEEP or tweak | P1 | |
| `book.gutter` | Spine gap visual | dark strip | | P2 | |
| `book.leftLeaf` | Left content host | transparent | | P1 | |
| `book.rightLeaf` | Right content host | transparent | | P1 | |
| `book.leafInset` | Margins from art edge | current 28/20/48 | | P2 | |

---

### C-T3 — TOC leaf

| Field key | Widget | Default now | YOUR PICK | P | Notes |
|-----------|--------|-------------|-----------|---|-------|
| `toc.heading` | “Table of Contents” | gold large | | P1 | |
| `toc.yearSubhead` | Year section (634 K.C.) | bronze | | P1 | |
| `toc.entryTitle` | Entry title ink | graphite | | P1 | |
| `toc.leaders` | Dot leaders | soft ink | | P1 | |
| `toc.pageNum` | Page # column | graphite | | P1 | |
| `toc.rowHover` | Soft gold wash | 0.12 gold | | P1 | |
| `toc.rowBg` | Optional row plate | none | | P2 | |

---

### C-T4 — Entry leaf

| Field key | Widget | Default now | YOUR PICK | P | Notes |
|-----------|--------|-------------|-----------|---|-------|
| `entry.title` | Title field | freeform | | P1 | |
| `entry.meta` | Kind / year line | soft ink | | P1 | |
| `entry.body` | Body edit/read | graphite + body font | | P1 | |
| `entry.continued` | “(continued)” | disable small | | P2 | |

---

### C-T5 — Sticky scraps

| Field key | Widget | Default now | YOUR PICK | P | Notes |
|-----------|--------|-------------|-----------|---|-------|
| `sticky.fill` | Scrap paper | parchment wash | | P1 | |
| `sticky.edge` | Scrap border | none/light | | P1 | |
| `sticky.ink` | Note text | graphite | | P1 | |
| `sticky.menu` | Pin/Delete menu chrome | Theme chrome menu | | P2 | |

---

### C-T6 — Footer parchment tools

| Field key | Widget | Default now | YOUR PICK | P | Notes |
|-----------|--------|-------------|-----------|---|-------|
| `footer.toolBtn` | Save / Add note / Pin / Delete | panel button skin | | P1 | |
| `footer.journalToggle` | Journal On/Off | button | | P1 | |
| `footer.backstoryBtn` | Backstory… | button | | P1 | |
| `footer.pageJump` | Jump box + → | InputBox | | P1 | |

---

### C-T7 — Page chrome (arrows / bookmark)

| Field key | Widget | Default now | YOUR PICK | P | Notes |
|-----------|--------|-------------|-----------|---|-------|
| `nav.prev` | `<` button | UIPanelButton | | P1 | |
| `nav.next` | `>` button | UIPanelButton | | P1 | |
| `nav.pageNum` | Left/right leaf numbers | graphite | | P1 | |
| `nav.tocBookmark` | Left TOC tab | small tab | | P1 | |
| `nav.tocBookmark.tex` | Tab texture sheet | EJ tab coords | | P1 | |

---

### C-T8 — Toast

| Field key | Widget | Default now | YOUR PICK | P | Notes |
|-----------|--------|-------------|-----------|---|-------|
| `toast.bg` | Toast panel | filled panel | | P2 | |
| `toast.ink` | Toast text | ink | | P2 | |

---

### C-S0 — Sidecar shell (docked)

| Field key | Widget | Default now | YOUR PICK | P | Notes |
|-----------|--------|-------------|-----------|---|-------|
| `sidecar.bg` | Outer OOC frame | book chrome clone | | P1 | Prefer mission/dialog family ≠ journal |
| `sidecar.edge` | Border | dialog | | P1 | |
| `sidecar.header` | “Backstory Menus” bar | parchment | | P1 | |
| `sidecar.content` | Page host fill | filled page | | P1 | |
| `sidecar.close` | X | button | | P1 | |
| `sidecar.dock` | Position | TOPLEFT of book TOPRIGHT +8 | DOCKED | P1 | Locked |

---

### C-S1 — Sidecar tabs

| Field key | Widget | Default now | YOUR PICK | P | Notes |
|-----------|--------|-------------|-----------|---|-------|
| `sidecar.tab.idle` | Tab art idle | EJ-style | | P1 | LootTab? |
| `sidecar.tab.active` | Tab art selected | EJ selected | | P1 | |
| `sidecar.tab.hover` | Glow | soft gold | | P1 | |
| `sidecar.tab.label` | Text | short labels | | P1 | |

---

### C-S2–S7 — Tab pages (chrome only)

Same three fields per tab unless you override:

| Tab | `page.bg` | `page.list/row` | `page.button` | YOUR NOTES |
|-----|-----------|-----------------|---------------|------------|
| Lineage S2 | | | | |
| Honor S3 | | | | |
| Road S4 | | | | |
| Realms S5 | | | | Afterlife folder later? |
| Voice S6 | | | | |
| Share S7 | | | | |

---

### C-V — Survival meters (**last** — design intent only)

**Intent (your note):** WeakAura-like cluster **pinned under player frame**; three mini frames; **bubble / XP-rep style** fills for hunger · thirst · exposure (fill or depletion). Flesh out later.

| Field key | Widget | Intent | YOUR PICK (later) | Notes |
|-----------|--------|--------|-------------------|-------|
| `survival.anchor` | Parent | Bottom of player frame | | Not HUD top-right long-term |
| `survival.hunger.track` | Mini frame + bar | XP/rep bubble language | | |
| `survival.thirst.track` | Mini frame + bar | | | |
| `survival.exposure.track` | Mini frame + bar | | | |
| `survival.fill.tex` | StatusBar texture | Unit/XP bar family | | |
| `survival.actions` | Eat/Drink/Rest | Compact or menu | | |

Do **not** assign survival textures until Tome + Sidecar 90% is signed.

---

## Part D — Suggested default pack (if you want a one-shot approve)

Use this if you prefer “yes to defaults” then tweak:

| Field group | Default pack |
|-------------|--------------|
| Book face | `UI-EJ-JournalBG` + existing TexCoords |
| Shell / footer parchment | `UI-Achievement-Parchment-Horizontal` |
| Sidecar OOC | Alliance/Horde BfA mission frame **or** desaturated parchment + dialog edge |
| Tabs | Keep EJ tab atlas coords; optional LootTab experiment on sidecar only |
| Borders | Dialog outer + tooltip inner; optional EJ MapFrame Left/Mid for trim |
| Stickies | Light parchment, no heavy border |
| Dirt / class / boss | SKIP until embellishment |

Reply:

```
DEFAULT PACK: yes / no
OVERRIDES:
  book.art = ...
  sidecar.bg = ...
```

---

## Part E — Execution workflow (after you assign)

1. You return **filled Part C** (or Default Pack + overrides).  
2. I build `Theme.Textures` / `*TexCoords` / helpers for each P1 field.  
3. Wire widgets T1→T7, then S0→S1, then S2–S7 chrome.  
4. You `/reload` per phase; comment with ELEMENT + NOTES.  
5. Survival C-V only after product gate on book + sidecar.

---

## Part F — Owner reply template (paste back)

```
TEXTURE ASSIGN — ROUND 1

DEFAULT PACK: yes / no

P1 FILLS (field = pick):
T1 shell.bg =
T1 shell.edge =
T1 shell.header.bg =
T2 book.art =
T2 book.artTexCoords = KEEP / tweak:
T6 footer =
T7 nav.tocBookmark.tex =
S0 sidecar.bg =
S0 sidecar.edge =
S1 tab =

SKIP FOR NOW:
P2/P3 notes:

SURVIVAL: defer (WeakAura under player frame) — confirmed
SIDECAR: docked — confirmed
PRESENCE/BULLETINS: skip — confirmed

READY TO EXECUTE: yes / need more research on:
```

---

## Part G — Research backlog (I resolve during execute)

| Item | Why |
|------|-----|
| Exact `Interface\` path for `Tileable-Parchment*` | Filename match in client / wago tools |
| TexCoords for `DungeonJournalTierBackgrounds*` | Multi-tile sheets |
| TexCoords for `LootTab` / `HeadhunterUI` | If you pick them for tabs |
| Faction mission frames: Alliance vs Horde auto-pick | Sidecar optional later |
| StatusBar texture family for survival bubbles | When V phase starts |

---

*This worksheet is the assignment plan. Fill Part F (or mark Default Pack) when you want implementation to start.*
