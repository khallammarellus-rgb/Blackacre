# Theme tokens inventory

**Source of truth (code):** `InCharacter/UI/Theme.lua`  
**Namespace today:** `InCharacter.UI.Theme`  
**After Phase 3 rename:** `Blackacre.UI.Theme` (same structure).

This file is a human-readable inventory. If code and this doc disagree, **code wins** — then update this doc.

---

## Colors (`Theme.Colors`)

RGB components are 0–1 floats.

| Key | RGB (approx) | Role |
|-----|----------------|------|
| `ink` | 0.15, 0.10, 0.05 | Primary body text |
| `inkSoft` | 0.25, 0.18, 0.10 | Secondary text (reserved / soft) |
| `gold` | 0.85, 0.70, 0.25 | Titles, emphasis |
| `parchment` | 0.92, 0.86, 0.72 | Parchment tool fill |
| `page` | 0.97, 0.93, 0.82 | Page panel fill |
| `pageFill` | 0.94, 0.88, 0.74 | Book interior wash / book style fill |
| `edge` | 0.55, 0.42, 0.22 | Border brown |
| `spine` | 0.22, 0.14, 0.08 | Book spine strip |
| `tabIdle` | 0.42, 0.30, 0.14 | Inactive tabs |
| `tabActive` | 0.72, 0.55, 0.22 | Active tabs |
| `cover` | 0.32, 0.20, 0.10 | Outer book cover |

### Known gaps (fix in later phases)

| Gap | Notes |
|-----|--------|
| Survival bar colors | Still partly hard-coded in `InCharacter_Survival/Survival/UI_Meters.lua` — migrate to Theme in **Phase 4** |
| Book ribbon red | Hard-coded `0.55, 0.12, 0.12` in `ApplyBookBackdrop` — candidate for `Colors.ribbon` |
| Meter “critical” tint | Should be Theme tokens when Survival polish lands |

---

## Textures (`Theme.Textures`)

All paths are Blizzard `Interface\...` assets today. Custom paths will use `Interface\AddOns\<Addon>\Media\...` (see [`MEDIA-GUIDE.md`](MEDIA-GUIDE.md)).

| Key | Path | Typical use |
|-----|------|-------------|
| `parchment` | `Interface\AchievementFrame\UI-Achievement-Parchment-Horizontal` | Horizontal parchment art |
| `parchmentVert` | `Interface\AchievementFrame\UI-Achievement-Parchment` | Vertical parchment |
| `questBG` | `Interface\QuestFrame\QuestBG` | Quest background (**avoid stretching on large shells**) |
| `dialogEdge` | `Interface\DialogFrame\UI-DialogBox-Border` | Book / heavy edge |
| `tooltipEdge` | `Interface\Tooltips\UI-Tooltip-Border` | Light panel edge |
| `bookIcon` | `Interface\Spellbook\Spellbook-Icon` | Book cue |
| `questBook` | `Interface\QuestFrame\UI-QuestLog-BookIcon` | Tome header icon |
| `stone` | `Interface\FrameGeneral\UI-Background-Rock` | Stone fill option |
| `white` | `Interface\Buttons\WHITE8x8` | Solid tintable fill (preferred for large panels) |

---

## Seals (`Theme.Seals`)

Used for bulletin scope tiers (Presence). Keep stable while Presence is frozen.

| Tier | Label | Short | Color (RGB) |
|------|-------|-------|-------------|
| `INDIVIDUAL` | Personal | P | 0.55, 0.45, 0.30 |
| `GROUP` | Company | C | 0.35, 0.50, 0.65 |
| `GUILD` | Guild | G | 0.55, 0.35, 0.65 |
| `FACTION` | Realm | R | 0.70, 0.30, 0.25 |

Helpers: `SealLabel(scopeTier)`, `FormatSealPrefix(scopeTier)`.

---

## Helpers (functions)

| Function | Purpose |
|----------|---------|
| `ApplyFilledPanel(frame, alpha, style)` | Solid panel; `style` = `"page"` \| `"panel"` \| `"book"` |
| `ApplyParchmentBackdrop(frame, alpha)` | Parchment tool surface |
| `ApplyBookBackdrop(frame, alpha)` | Cover + spine + page wash + ribbon |
| `ApplyPagePanel(frame, alpha)` | Inner page |
| `CreateBookShell(name, titleText)` | Full hub window (tabs rail + page host + close) |
| `MountInPage(frame, parent)` | Embed a feature frame into book page host |
| `InkFont(fontString, size?)` | Body text coloring (`title` / `header` / default) |
| `GoldTitle(fontString)` | Title text gold |
| `Toast(message)` | Soft top-of-screen parchment toast (~4s) |
| `SealLabel` / `FormatSealPrefix` | Bulletin seal display |

---

## Which surface for which package (vision-aligned)

See [`UX-VISION.md`](UX-VISION.md) for the full product rules (Bethesda × Warcraft, retcon prompts, HUD hide behavior).

| Surface | Scope | Package / code target |
|---------|--------|------------------------|
| **Book shell** | **Tome hub only** | `TomeHub` + `CreateBookShell` |
| **Blackacre Menu** | OOC: path picker, settings, mount status, experience config | **Not built yet** — do not put these controls inside journal pages |
| **Page panel** | Achievements, quests, path completion, leveling, manual journal prose | Chronicle / page UIs inside the book |
| **Parchment tool** | **Bottom-of-Tome** journaling mode toggle (edit auto + manual pages) | Future Tome chrome strip — *not* survival floating panel |
| **HUD meters** | Always-on survival; minimizable / hideable; dual reminders | `InCharacter_Survival` |
| **Modal / wizard** | Setup | No design change yet |
| **Presence** | Beacons / bulletins | Frozen |
| **Toast** | Soft feedback when HUD visible | `Theme.Toast` |

**Debt vs current code:** Today, path/setup/hardcore tabs still live inside the Tome book. Phase work will peel OOC into **Blackacre Menu** and reserve the book for IC pages + bottom journaling tool.

---

## How to add a token (process)

1. Add key to `Theme.Colors` or `Theme.Textures` in `Theme.lua`.  
2. Document it here.  
3. Use only the key from feature code.  
4. If custom file: follow [`MEDIA-GUIDE.md`](MEDIA-GUIDE.md) and provide a Blizzard fallback.

---

## VS Code navigation

1. Open `InCharacter/UI/Theme.lua` — entire design system.  
2. Search feature for `Theme.Apply` or `Theme.GoldTitle` to see consumers.  
3. Survival local colors: `InCharacter_Survival/Survival/UI_Meters.lua` (Phase 4 cleanup target).
