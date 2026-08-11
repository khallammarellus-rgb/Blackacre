# Custom Media guide — your images in Blackacre

**Yes, you can use your own images.** This guide is the practical pipeline for art you create or commission.

---

## Mental model

```
You make art  →  export TGA  →  drop in Media/  →  register in Theme  →  /reload  →  see in game
```

The CLI wires paths and UI; **you** own the art files and copyright.

---

## Folder layout (create when you are ready)

Today the core package is still `InCharacter/`. After Phase 3 rename it becomes `Blackacre/`. Use the same relative structure either way:

```
InCharacter/                    # or Blackacre/ later
└── Media/
    ├── Brand/
    │   └── minimap.tga         # minimap / LDB icon
    ├── Book/
    │   └── (optional ornaments)
    ├── Survival/
    │   ├── hunger.tga
    │   ├── thirst.tga
    │   └── exposure.tga
    ├── Paths/
    │   └── defias_bandit.tga   # path card art
    ├── UI/
    │   └── seal_wax.tga
    └── _source/                # optional: PSD/XCF — gitignored by default
        └── notes.txt
```

Phase 0 does **not** require empty folders on disk; add them when you have files.

---

## File format rules

| Rule | Guidance |
|------|----------|
| **Preferred format** | Uncompressed **TGA**, 24-bit or **32-bit with alpha** |
| **Also OK** | **BLP** (Blizzard native; harder to edit) |
| **Size** | Prefer **powers of two**: 32, 64, 128, 256, 512 |
| **Weight** | Keep modest (icons 64–128; avoid huge 4K backgrounds) |
| **Copyright** | Only art you own, commissioned, or may redistribute |

Tools: GIMP (free), Photoshop, Aseprite, Paint.NET + TGA plugin, etc.

---

## How the game finds your file

Path from the WoW install root, for example:

```text
Interface\AddOns\InCharacter\Media\Brand\minimap
```

In Lua (after registration):

```lua
-- Theme.lua — single registry (illustrative; applied in a later phase)
InCharacter.UI.Theme.Textures.minimap =
    "Interface\\AddOns\\InCharacter\\Media\\Brand\\minimap"

-- Feature code
icon:SetTexture(InCharacter.UI.Theme.Textures.minimap)
```

Notes:

- Use **backslashes** doubled in Lua strings: `"Interface\\AddOns\\..."`.  
- Extension is often **omitted** in `SetTexture`; WoW resolves `.tga` / `.blp`.  
- Texture files are **not** listed in the `.toc` like Lua files; they load when referenced.  
- Your AddOns junction must point at the package that contains `Media/` (same as today).

---

## Design-system rules

1. **Register first** in `Theme.Textures` (or a future `Theme.Media` table).  
2. **Fallback** — if custom art is missing, Theme should still point at a Blizzard texture so UI never goes blank.  
3. **Trail-journal palette** — browns, parchment, muted gold, ink (see [`UX-VISION.md`](UX-VISION.md)).  
4. **No raw paths** scattered in Survival/Tome feature files.  
5. **Presence** — no custom Presence cosmetics until Phase 10.

---

## Suggested art drops by phase

| Phase | Good first assets |
|------:|-------------------|
| 3 | Brand / minimap icon |
| 4 | Survival meter icons |
| 5 | Path card images |
| 6–8 | Roadmap ornaments, tome marks, era cards |
| 10 | Beacon/board flair |

Features can ship with **Blizzard placeholders** until your TGA is ready.

---

## Git

- **Commit** exported game-ready TGA under `Media/` (not `_source` junk).  
- **Ignore** working masters in `Media/_source/` (PSD, XCF, huge WIP) — see root `.gitignore`.  
- Do not commit multi‑MB experimental dumps.

---

## Checklist when you add art

1. Export TGA (PoT size, alpha if needed).  
2. Place under `Media/<category>/`.  
3. Ask CLI (or Phase work) to register key + fallback in Theme.  
4. `/reload` in-game.  
5. Confirm icon/panel looks correct; note any stretch/crop for next export.

---

## FAQ

**Do I need LibSharedMedia?**  
Not for Blackacre-owned art. Optional later if you want to share fonts/statusbars with other addons.

**Can I use PNG/JPG?**  
Stick to TGA/BLP for reliability. Convert in your editor before drop-in.

**Can art live outside the addon folder?**  
It can under `Interface\...`, but **shipping inside the addon** is what other players get when they install Blackacre. Prefer `Media/` inside the package.
