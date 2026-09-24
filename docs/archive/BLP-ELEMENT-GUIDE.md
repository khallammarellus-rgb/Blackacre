# BLP / texture elements — how we use pieces (not raw sheets)

**Regression bookmark:** git tag `bookmark/pre-texture-deliberate` (commit `6448fa9`)  
**Desktop library:** name reference only — map to `Interface\...` BLP, never import PNGs.

---

## The rule

| Wrong | Right |
|-------|--------|
| `SetTexture("…\\UI-Achievement-Borders")` full bleed | Crop **one** border piece via `SetTexCoord` **or** use a **named atlas** |
| Stretch a multi-widget sheet as a button face | Find Blizzard XML / atlas for that widget |
| Guess | Document path + coords/atlas + fallback |

---

## Four ways Blizzard ships “pieces”

### 1. Full-bleed single art (rare for chrome)

One image ≈ one region. Still often has **packing crop**.

Example: EJ open book — we already do this correctly:

```lua
tex:SetTexture("Interface\\EncounterJournal\\UI-EJ-JournalBG")
tex:SetTexCoord(0, 0.766601562, 0, 0.830078125) -- from FrameXML
```

### 2. TexCoords on a sheet (classic BLP atlas)

One file holds many widgets. XML:

```xml
<Texture file="Interface\AchievementFrame\UI-Achievement-Borders">
  <TexCoords left="…" right="…" top="…" bottom="…"/>
</Texture>
```

Lua:

```lua
tex:SetTexture(path)
tex:SetTexCoord(left, right, top, bottom) -- 0–1 UV
```

**This is what we missed** when borders/toasts/tabs looked “raw.”

### 3. Named atlas (retail preferred)

```lua
tex:SetAtlas("UI-Frame-GenericMetal-Corner", true)
-- or CreateAtlasMarkup for text
```

Find names with **Texture Atlas Viewer** (CurseForge) or wiki / wow-ui-source.

### 4. Nine-slice / edgeFile

Borders as **8 edge pieces + corners**, not one stretched frame:

- `BackdropTemplate` + proper `edgeFile` (designed for tiling edges), **or**
- `NineSlice` layout (Blizzard templates) with separate corner/edge textures

`UI-Goldborder-_tile` may work as tile edge **if** it is a true edgeFile layout; many “border” BLPs are **not** edgeFiles and must use multi-piece + TexCoords instead.

---

## Research order (every art element)

1. Owner names Desktop file / Interface path  
2. Search **Gethe wow-ui-source** for that filename  
3. If atlas: use `SetAtlas`  
4. If TexCoords in XML: copy into `Theme.TexCoords`  
5. Else measure from PNG (x/W, y/H) and document  
6. Always register **fallback** (dialog edge, parchment, UIPanelButton)

---

## Theme registration pattern

```lua
Theme.Textures.foo = "Interface\\…"
Theme.TexCoords.fooPiece = { 0.1, 0.2, 0.3, 0.4 }  -- or
Theme.Atlases.fooPiece = "Some-Atlas-Name"
Theme.Fallbacks.foo = "Interface\\DialogFrame\\UI-DialogBox-Border"
```

Feature code never hardcodes UV math.

---

## Owner path → strategy (assignment pack)

| Owner path / name | Likely correct use | Notes |
|-------------------|--------------------|-------|
| `UI-EJ-JournalBG` | Full-bleed + **known crop** | Keep; already good pattern |
| `UI-Achievement-Parchment-Horizontal` | Bar / panel **fill** (whole usable art) | OK as fill; not a multi-widget sheet |
| `UI-Achievement-Borders` | **Multiple** border pieces via TexCoords | Never full-bleed |
| `UI-Goldborder-_tile` | Edge tile **if** edgeFile-compatible | Else multi-piece gold |
| `UI-Achievement-Alert-Background` | One alert plate; check XML crop | Not full sheet smear |
| `UI-Achievement-Reward-Background` | Thin reward strip; XML crop | |
| `PVP-Banner-5-Border-2` | Banner **border** piece / vertical crop | Not full 128×256 as fat tab without crop |
| `UI-GuildBankFrame-Tab` | Tab face; often needs specific coords or atlas | |
| `UIFrameAlliance` / `UIFrameHorde` | Large kits → **center crop or atlas members** | Full raw = muddy |
| `DragonflightMajorFactionsCentaur` | Renown toast **region** via coords/atlas | |
| `CommonIcons` | Many icons; red X = **specific UV** or use `UI-GroupLoot-Pass-Up` | |
| `MapPinCursor` | Cursor art; buttons need a **real button icon** fallback | |
| `Spellbook-Page-1` | Page fill; may need crop | |
| `UI_Warlords_SkyGLow_*` | Soft glow region only | Easy to over-apply |

---

## Missing controls (E0)

Icon-only buttons that use failed atlases appear **blank**. E0 rule: **stock `UIPanelButtonTemplate` + short label**, optional icon if texture resolves.

---

## Restore

**Look (current working tree):** Tome/Theme/hub files restored **as-is from `d2adfe0`** (true flip-book). Not mixed with later skins.

**Rough-skin museum:** git tag `bookmark/pre-texture-deliberate` (`6448fa9`).  
**E0 framed-icon WIP:** `git stash list` → `e0-framed-icons-before-restore-to-d2adfe0`.

Training (console, XML vs JSON/HTTPS, TexCoords): [`SKIN-TRAINING.md`](SKIN-TRAINING.md).
