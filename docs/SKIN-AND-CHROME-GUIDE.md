# Blackacre — Skin, Chrome & Frame Architecture Guide

**The definitive technical guide for visual design, frame canvas modeling, and skinning in Blackacre.**  
Source anchors: Mayron *Creating WoW AddOns* (Ep. 5–10), Blizzard FrameXML, and DBM modularity.

---

## 1. Texture Pipeline & Local Workflow

To avoid guesswork and external hallucinations, we follow a strict local pipeline:

```
[In-Game TAV]                  [Local Disk Export]               [Addon Code]
Owner inspects piece  ──>  Owner shares Atlas/BLP name  ──>  Agent inspects files in:
via Texture Atlas Viewer    & target region code (1S..13S)    C:\Users\kvebe\OneDrive\Desktop\
                                                             Blackacre, In Character
                                                                    │
                                                                    ▼
                                                            Agent builds NineSlice/
                                                            Coords in Theme.lua
```

### Critical Rules for Coding Agents
1. **Never browse the public web for random textures or guess BLP filenames.**
2. When the owner provides an atlas or texture name from in-game **Texture Atlas Viewer (TAV)**, inspect the local exported client files located at:
   `C:\Users\kvebe\OneDrive\Desktop\Blackacre, In Character` (textures extracted via `-console`).
3. Cross-reference with Blizzard FrameXML definitions for UV coordinates (`TexCoords`) or atlas sizes.
4. **Theme owns all paths:** Feature modules call `Blackacre.UI.Theme` APIs; never hardcode `Interface\...` strings in feature UI files.

---

## 2. Visual Modeling: Tome Regions & Element Codes

We divide the interface into **S (Skin / Art Pack)** and **F (Function / Layout)** to keep layouts rock-solid across different faction or custom skins.

### In-Game Visual Inspection
Toggle region overlays in-game:
* `/ba tome` to open the Tome
* `/ba skin` to toggle region markers (Gold = **S**, White = **F**)

```
  1S outer nineslice (whole window border)
  ┌────────────────────────────────────────────────────────────────────────┐
  │ 2F Title [2F.sub Subtitle]          [Add Page F]            3F Close X │
  │  ┌────── 8S TOC Bookmark Tab                                           │
  │  │                                                                     │
  │  │  4F Book Art Canvas (Shared parchment background)                   │
  │  │  ┌────────────────────────┬─────┬────────────────────────────────┐  │
  │  │  │ 5F LEFT LEAF           │ 7F  │ 6F RIGHT LEAF                  │  │
  │  │  │ 5S.sub Title Ornament  │ Sp- │ 6S.sub Header Art              │  │
  │  │  │ 5F.sub Left Body Text  │ ine │ 6F.sub Right Body Text         │  │
  │  │  │                        │ Gut-│                                │  │
  │  │  │                        │ ter │                                │  │
  │  │  │                        │     │                                │  │
  │  │  │                        │     │                                │  │
  │  │  │                        │     │         12F Page Turn < 1 2 >  │  │
  │  │  └────────────────────────┴─────┴────────────────────────────────┘  │
  │  └─────────────────────────────────────────────────────────────────────│
  │  9S Under-book Rail (Faction trim / wood / stone bar)                  │
  │ 10F Footer Strip: [Journal: On/Locked] │ 11F Tool Buttons (Save/Sticky)│
  └────────────────────────────────────────────────────────────────────────┘
  13S Backstory Sidecar Window (Docked to the right of Tome when opened)
```

### Region Code Reference

| Code | Role | Type | Standard Art / Blueprint |
|------|------|------|--------------------------|
| **1S** | Outer Window Border | Skin | NineSlice: `AllianceFrame-Corner-TopLeft` / `HordeFrame-Corner-TopLeft` |
| **2F** | Header Title Bar | Function | FontString on `OVERLAY`, clipped left of action buttons |
| **3F** | Close Button | Function | Standard Blizzard `UIPanelCloseButton` anchored `TOPRIGHT, -4, -4` |
| **4F** | Book Art Canvas | Function | `UI-EJ-JournalBG` (Encounter Journal open book background) |
| **5F / 6F** | Left & Right Leaves | Function | Two equal halves with margins; host for text, stickies, and entries |
| **5S / 6S** | Leaf Title Ornaments| Skin | Faction title caps (`AllianceFrame_Title-End`, `_Tile`, etc.) |
| **7F** | Spine / Gutter | Function | Visual spine dividing left leaf from right leaf |
| **8S** | TOC Bookmark Tab | Skin | `AlliedRaces-AllianceHordeBanner` cropped bookmark sticking out left |
| **9S** | Under-book Rail | Skin | Faction under-rail (`_warboard-title-alliance-middle`, FrameLevel above 1S) |
| **10F** | Footer Status | Function | `Journaling: Locked` / `Journaling: On` toggle button (width 200) |
| **11F** | Footer Tool Strip | Function | Action buttons: Save, Add Note, Pin, Delete |
| **12F** | Page Navigation | Function | `<` `>` arrows and footer jump box `n / total` |
| **13S** | Backstory Window | Skin | Docked sidecar window (`Neutral-NineSlice-Corner` + tiles) |

---

## 3. Frame Canvas & Draw Layer Hierarchy (Mayron Ep. 5)

A frame in WoW is a **canvas**. Sizing, positioning, alpha, and visibility cascade down the tree.

### The 5 Draw Layers (Lowest to Highest)

| Order | Layer | Purpose | Blackacre Usage |
|:-----:|-------|---------|-----------------|
| 0 | `BACKGROUND` | Solid fills, backdrop wash | Outer book cover, parchment texture, page wash |
| 1 | `BORDER` | Frame borders, edges | NineSlice edge slices, line dividers |
| 2 | `ARTWORK` | Major decorative art | Book spine, ribbon, faction crests, banner icons |
| 3 | `OVERLAY` | **Text & UI Elements** | **All FontStrings (titles/body), edit boxes, button labels** |
| 4 | `HIGHLIGHT` | Mouseover states | Hover glow, button hover state (auto show/hide) |

> [!IMPORTANT]
> **Sublevels (−8 to +7):** Use sublevels when multiple textures share a layer:
> ```lua
> canvas:CreateTexture(nil, "BACKGROUND", nil, -8) -- deep background
> canvas:CreateTexture(nil, "BACKGROUND", nil, -4) -- parchment wash above deep background
> canvas:CreateFontString(nil, "OVERLAY")           -- text guaranteed on top
> ```
> **Rule:** Never put FontStrings on `BACKGROUND`, `BORDER`, or `ARTWORK`. Body text must always sit on `OVERLAY` so parchment art never obscures ink.

---

## 4. BLP Textures, UV TexCoords & Atlases

Blizzard textures come in two primary forms:

### A. Named Atlases (Modern WoW)
An atlas combines a texture file, width, height, and predefined UV coordinates managed by Blizzard's atlas registry:
```lua
texture:SetAtlas("AllianceFrame-Corner-TopLeft", true) -- true = use atlas native pixel size
```

### B. Composite BLP Sheets & TexCoords (UV Slicing)
Classic and legacy UI sheets pack multiple widgets into one file. Slicing requires **normalized 0–1 coordinates**:
$$\text{coord} = \frac{\text{pixel position}}{\text{sheet dimension}}$$

```lua
-- SetTexCoord(left, right, top, bottom)
texture:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Borders")
texture:SetTexCoord(0.0, 0.5625, 0.0, 0.140625)
```

> [!CAUTION]
> **Anti-Pattern:** Never stretch a multi-widget sheet across a full frame without `SetTexCoord`. If you do not have UV coordinates, find the XML definition or measure the pixels from the local desktop export.

---

## 5. Building Skins with Nine-Slice

A NineSlice frame creates scalable borders without stretching or blurring the corners. It is composed of 9 pieces:

```
  TopLeftCorner      TopEdge (tiles horizontally)      TopRightCorner
  LeftEdge           Center / Fill                     RightEdge
  BottomLeftCorner   BottomEdge (tiles horizontally)   BottomRightCorner
```

### Method 1: Modern NineSlice Layout (Table Configuration)
```lua
local NINESLICE_ALLIANCE = {
    TopLeftCorner =     { atlas = "AllianceFrame-Corner-TopLeft" },
    TopRightCorner =    { atlas = "AllianceFrame-Corner-TopRight" },
    BottomLeftCorner =  { atlas = "AllianceFrame-Corner-BottomLeft" },
    BottomRightCorner = { atlas = "AllianceFrame-Corner-BottomRight" },
    TopEdge =           { atlas = "_AllianceFrame-EdgeTop" },
    BottomEdge =        { atlas = "_AllianceFrame-EdgeBottom" },
    LeftEdge =          { atlas = "!AllianceFrame-EdgeLeft" },
    RightEdge =         { atlas = "!AllianceFrame-EdgeRight" },
}

function Blackacre.UI.Theme.ApplyNineSlice(frame, layout)
    NineSliceUtil.ApplyLayout(frame, layout)
end
```

### Method 2: BackdropTemplate (Classic / Universal Fallback)
For standard dialogs and panels, using Blizzard's `BackdropTemplate`:
```lua
local backdrop = {
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 8, right = 8, top = 8, bottom = 8 }
}
frame:SetBackdrop(backdrop)
frame:SetBackdropColor(0.05, 0.05, 0.05, 0.85)
frame:SetBackdropBorderColor(0.85, 0.70, 0.25, 1.0)
```

---

## 6. XML Template Reference Baseline

To prevent layout regression if Lua constructors are modified, here is the baseline XML specification for Blackacre's core surfaces:

```xml
<!-- Root Book Shell Template -->
<Frame name="BlackacreBookShellTemplate" virtual="true" enableMouse="true" movable="true">
    <Size x="900" y="620"/>
    <Anchors>
        <Anchor point="CENTER"/>
    </Anchors>
    <Layers>
        <!-- Layer 0: Background Fill -->
        <Layer level="BACKGROUND">
            <Texture parentKey="CoverBG">
                <Color r="0.05" g="0.03" b="0.02" a="0.95"/>
            </Texture>
        </Layer>
        <!-- Layer 2: Main Open Book Art -->
        <Layer level="ARTWORK">
            <Texture parentKey="BookArt" file="Interface\EncounterJournal\UI-EJ-JournalBG">
                <TexCoords left="0" right="0.766601562" top="0" bottom="0.830078125"/>
                <Anchors>
                    <Anchor point="TOPLEFT" x="20" y="-30"/>
                    <Anchor point="BOTTOMRIGHT" x="-20" y="45"/>
                </Anchors>
            </Texture>
        </Layer>
        <!-- Layer 3: Overlay (Titles & Headers) -->
        <Layer level="OVERLAY">
            <FontString parentKey="Title" inherits="GameFontNormalLarge" justifyH="LEFT">
                <Anchors>
                    <Anchor point="TOPLEFT" x="24" y="-12"/>
                </Anchors>
                <Color r="0.85" g="0.70" b="0.25"/>
            </FontString>
        </Layer>
    </Layers>
    <Frames>
        <!-- Region 3F: Close Button -->
        <Button parentKey="CloseButton" inherits="UIPanelCloseButton">
            <Anchors>
                <Anchor point="TOPRIGHT" x="-4" y="-4"/>
            </Anchors>
        </Button>
    </Frames>
</Frame>
```
