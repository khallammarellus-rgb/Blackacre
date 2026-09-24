# Blackacre — BLP / FrameXML training (after Mayron 5–10)

You already watched Mayron **Creating WoW AddOns** episodes 5–10. This page is the Blackacre cheat sheet: two different “XML vs JSON” worlds, why `` ` `` did nothing, TexCoords, and where official plots live.

**Look restore:** committed `330b885` — two-page Tome, experimental BLP chrome dropped.

---

## Tome region map (how we talk)

In-game: `/ba tome` then `/ba skin` (toggle numbers on the window).

```
  1 outer box (whole window edge)
  ┌─────────────────────────────────────────┐
  │ 2 title bar                    3 close X│
  │  ┌──── 8 TOC tab                        │
  │  │                                      │
  │  │  4 book picture                      │
  │  │   5 left page  |7|  6 right page     │
  │  │                                      │
  │  │           12  <  1  2  >             │
  │  └──────────────────────────────────────│
  │  9  under-book rail                     │
  │ 10 footer: Journal | 11 tools | Add note Go Backstory │
  └─────────────────────────────────────────┘
  13 Backstory window (to the right, when open)
```

**Skin (S) vs function (F)** — `/ba skin` numbers gold **S** = art pack, white **F** = clicks/layout (same on every skin).

```
  1S outer nineslice
  ┌─────────────────────────────────────────┐
  │ 2F title   [+F add page]      3F close X│
  │  ┌──── 8S TOC tab                       │
  │  │                                      │
  │  │  4F book picture                     │
  │  │   5F LEFT      |7F|  6F RIGHT        │
  │  │   (TOC title caps = S ornament)      │
  │  │           12F  <  1  2  >            │
  │  └──────────────────────────────────────│
  │  9S under-book rail                     │
  │ 10F footer / 11F tools / notes          │
  └─────────────────────────────────────────┘
  13S Backstory outer chrome (same skin pack)
```

| S — skin (Theme.Skins) | F — function (one skeleton) |
|------------------------|-----------------------------|
| 1 nineslice corners/tiles | 2 title, 3 X, add-page |
| 8 TOC banner UV | 4 book art (shared EJ), 5/6 leaves, 7 gutter |
| 9 rail | 10–12 Journal, tools, page turn |
| TOC title caps, Backstory 13 chrome | stickies, delete, resize, Capture |

A new skin is a new row in `Theme.Skins`, not new regions. Options: **Interface → AddOns → Blackacre → Tome skin**.

Copy-paste to assign a TAV piece:

```
REGION:
ATLAS:
NOTE:
```

**This try (chrome locked until you REGION/ATLAS again):**
- **1** outer shell — NineSlice `AllianceFrameCorner-TopLeft` / `HordeFrame-Corner-TopLeft` + tiles, PAD=12, host OVERLAY +45
- **2** title — clipped left of add-page so it never runs under the icon
- **3** close X — 32×26, header right
- **Add page** — `GarrMission_MissionIcon-Logistics` 22×22, in line left of X (both factions)
- **8** TOC tab — `AlliedRaces-AllianceHordeBanner`. Same crop width `0.41268` both factions. Alliance `0–0.41268`. Horde `0.50–0.91268` (past leftover blue). Size 50% of that crop. Top aligned to bookOpen (`y = 0`).
- **9** under-book rail — `_warboard-title-alliance-middle` / `_warboard-title-horde-middle`. FrameLevel above the nineslice. Re-approach later if the atlas is wrong.
- **5 / 6 leaves** — TOC title: `AllianceFrame_Title-End-2` + `_AllianceFrame_Title-Tile` + `AllianceFrame_Title-End` (HordeFrame_* equivalents). Year: `PetJournal-PetBattleAchievementBG` left, same atlas flipped on the right. TOC jump hover: `Garr_ListButton-Selection`. Stickies: `adventureguide-pane-small` (150×90 default, resizable).
- **Backstory B1** — BACKGROUND `islands-queue-background`; nineslice `Neutral-NineSlice-Corner` + `_Neutral-NineSlice-EdgeTop` / `EdgeBottom` (`Interface/FrameGeneral/UIFrameNeutral`).
- **Backstory B2** — `UI-Frame-Neutral-TitleLeft` + `_UI-Frame-Neutral-TitleMiddle` + `UI-Frame-Neutral-TitleRight`.
- **Backstory B5** — Spellbook tab file, icons masked with `SpellbookElementsIconMask`, hover `SpellbookElementsAutoCastMask`, nudged 5px left.

---

---

## 1. Two stacks — they are not the same

You read that “XML was replaced with JSON over HTTPS.” That is **true for Battle.net’s web APIs**. It is **not** true for the Tome’s pictures.

| | **In-game UI (Blackacre)** | **Battle.net Game Data APIs** |
|--|----------------------------|-------------------------------|
| What | Frames, textures, TexCoords | Character / item / achievement / realm **data** |
| Format | **FrameXML** (still XML) + Lua | **JSON over HTTPS** (REST) |
| Login | WoW client | Blizzard developer **OAuth** client on [developer.battle.net](https://community.developer.battle.net/documentation/world-of-warcraft/game-data-apis) |
| Example | `<TexCoords left="0" right="0.5625" …/>` | `GET https://us.api.blizzard.com/data/wow/achievement/6?namespace=static-us` |
| Use for skins? | **Yes** | **No** — no BLP paths, no UV plots |

Old Battle.net “Community Platform” APIs used XML/JSON. Those were retired. The replacement is JSON/HTTPS. That never painted a book border.

Addon UI is still:

```
XML template (virtual="true")  →  CreateFrame("Frame", name, parent, "TemplateName")
Texture file="Interface\…"     →  tex:SetTexture(...)
<TexCoords left right top bottom> → tex:SetTexCoord(left, right, top, bottom)
```

Retail extras (do not replace XML plots):

- **`SetAtlas("AtlasMemberName")`** — named crop Blizzard already defined  
- **Edit Mode** — player HUD layout (not FrameXML TexCoords)  
- **Lua-only Settings** — options panels built in Lua  

Midnight combat-secret API changes also do **not** turn FrameXML into JSON.

---

## 2. Why `` ` `` does nothing (login / warband)

`` ` `` (grave / tilde, top-left of a US keyboard) only opens the **engine console** if the client was started with **`-console`**. Without that flag, the key is ignored on the login and warband (character select) screens. `/console` **in-world** cannot run `ExportInterfaceFiles`.

### Enable it (Battle.net — do this first)

1. Battle.net → **gear next to Play** (or Battle.net logo → **Settings**) → **Game Settings**.  
2. Expand **World of Warcraft** (Retail, not Classic).  
3. Check **Additional command line arguments**.  
4. In the box, only:

```
-console
```

5. **Done**. Fully quit WoW, then Play again.

You should see a dark strip drop from the **top** of the login/warband window when the console key works — not chat.

### If the box is already `-console` and `` ` `` still does nothing

| Try | Why |
|-----|-----|
| Key is **grave** `` ` `` (with tilde `~` on the same key). Not apostrophe `'` | Wrong key |
| US keyboard layout, or press the key that types `` ` `` | Non-US layouts often need a dead key; Wowpedia: console never sees the modifier |
| Log **into a character**, type `/run SetConsoleKey("-")`, then **log out** (don’t restart) | Binds console to `-` for this session; then at warband press `-` |
| Confirm Retail, not Classic | Flag is per game in Game Settings |

We do **not** need your export if GitHub FrameXML is enough (section 4). Enable console when you want the files on disk next to the game.

### Once the console actually opens (login or warband only)

```
ExportInterfaceFiles code
```

Wait until the prompt returns. Output:

`World of Warcraft\_retail_\BlizzardInterfaceCode\` (Retail) or `World of Warcraft\_classic_beta_\BlizzardInterfaceCode\` (WoW Forever beta).

Optional (large, slow):

```
ExportInterfaceFiles art
```

→ `BlizzardInterfaceArt\` (BLPs). Then search that folder for the filename (Mayron Ep. 10: Find in Files for `UIPanelDialogTemplate`).

---

## 3. TexCoords (Discord note, locked)

Values are **0–1 UV**, not pixels.

```xml
<TexCoords left="0" right="1" top="0" bottom="1"/>
```

```lua
tex:SetTexCoord(left, right, top, bottom)
```

| Intent | left, right, top, bottom |
|--------|--------------------------|
| Whole image | `0, 1, 0, 1` |
| Flip horizontal | `1, 0, 0, 1` |
| Flip vertical | `0, 1, 1, 0` |
| Top-right quarter | `0.5, 1, 0, 0.5` |

Pixels → UV:

```
left   = x / imageWidth
right  = (x + pieceWidth) / imageWidth
top    = y / imageHeight
bottom = (y + pieceHeight) / imageHeight
```

Blizzard XML uses power-of-two sizes (256, 512, …). Example: `0.5625 = 144/256` on Achievement IconFrame. **Copy XML numbers; do not guess.** Stretching `0,1,0,1` on a sheet is why chrome looked raw.

Four legal uses: full-bleed (rare) · TexCoord crop · `SetAtlas` · NineSlice / true `edgeFile`. Never a multi-widget sheet as `edgeFile`. Desktop PNGs = name reference only.

---

## 4. Official plots without the console (what I use)

Same XML the export would write:

- [Gethe/wow-ui-source](https://github.com/Gethe/wow-ui-source) branch `live`  
- [Townlong Yak FrameXML](https://www.townlong-yak.com/framexml/live)  
- Art as PNG (look, don’t import): [Gethe/wow-ui-textures](https://github.com/Gethe/wow-ui-textures)

Per piece:

```
Owner names Interface\ path
  → search FrameXML for that filename
  → copy <TexCoords> / atlas / NineSlice
  → Theme.Textures + Theme.TexCoords
  → one widget
  → /reload
```

---

## 5. Mayron 5–10 → Blackacre (already watched)

Playlist: [Creating WoW AddOns](https://www.youtube.com/playlist?list=PL3wt7cLYn4N-3D3PTTUZBM2t1exFmoA2G)

| Ep | Use when we skin |
|----|------------------|
| **5** XML Templates | Frame = canvas; layers BACKGROUND → BORDER → ARTWORK → OVERLAY → HIGHLIGHT; `virtual` templates; export Interface. Written up in [`FRAME-LAYERS.md`](FRAME-LAYERS.md). |
| **6** Widgets | Prefer `CreateFrame(..., "UIPanelButtonTemplate")` until a crop is proven. |
| **7** Slash / events | `/ba` — not skin. |
| **8** Scroll + more XML | `UIPanelDialogTemplate`; parentKey vs `$parent`; clip children. |
| **9** Tabs | Backstory tabs **after** shell is clean. |
| **10** Reskinning | Re-export after a patch; Find in Files; swap **named regions**, not a whole BLP sheet. |

Our last failure: `SetTexture(full sheet)` without the XML piece.

---

## 6. Next skin (not started)

Outer Tome **shell border** only, after you `/reload` the restored book and say the look is OK.

Research first (FrameXML): dialog/gold **edgeFile**, or Achievement/EJ **NineSlice / TexCoords** — never `UI-Achievement-Borders` full bleed.
