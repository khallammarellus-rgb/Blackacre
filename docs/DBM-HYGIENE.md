# DBM-grade code hygiene (Pass D hard pass)

**Gold standard:** Deadly Boss Mods — especially **DBM-Core** structure and style  
(GitHub: [DeadlyBossMods/DeadlyBossMods](https://github.com/DeadlyBossMods/DeadlyBossMods); lineage associated with Paul Emmerich / MysticalOS-era modularity and current maintainers).

We do **not** copy DBM features. We copy **discipline**: tight Lua, low waste, clear modules.

Use this checklist **after** an element’s art is accepted (Pass D).

---

## Checklist

### Globals & locals
- [ ] No new globals unless required (AceAddon name, SavedVariables, slash tables)
- [ ] File-level `local` for helpers, upvalues for hot paths
- [ ] Namespace tables (`Blackacre.*`) are the public API — not a junk drawer

### Structure
- [ ] One clear job per file/module
- [ ] Package boundary respected (Core / Survival / Tome / Presence freeze)
- [ ] Theme owns chrome helpers; features call Theme, don’t fork backdrops

### Events & time
- [ ] Prefer events over OnUpdate
- [ ] Timers via AceTimer (or existing C_Timer) — cancel on disable/hide
- [ ] No leaked frame scripts when UI is torn down

### Memory & performance
- [ ] No `{}` allocation every tick/frame
- [ ] Reuse frames/textures/fontstrings (pool rows if many)
- [ ] Avoid string concat in tight loops
- [ ] Status bars / meters: update only when values change (or throttled)

### SavedVariables
- [ ] Write only when needed
- [ ] Don’t thrash profiles
- [ ] Feature data vs AceDB options stay intentional (`BlackacreDB` vs `BlackacreAceDB`)

### Ace3
- [ ] Libs only via embeds.xml / LibStub
- [ ] No duplicate Ace copies in child packages

### Readability
- [ ] Names describe intent
- [ ] Comments explain *why* / RP vision where useful
- [ ] Dead code removed
- [ ] Matches FRAME-LAYERS (text on OVERLAY, fills on BACKGROUND, etc.)

---

## Anti-patterns (reject on hard pass)

- Global functions for one-off UI  
- Creating new frames every open without reusing  
- OnUpdate for “is zone changed?” (use events)  
- Hard-coded texture paths outside Theme  
- Settings controls inside journal pages (belongs in Blackacre Menu)  
- Silent history rewrites without retcon prompt (when that system lands)  

---

## How to Analyze Code Using DBM-Core as the Benchmark

When reviewing or writing code in Blackacre, compare your implementation against DBM-Core’s architectural discipline:

### Step 1: Upvalues at the File Header
* **DBM Pattern:** Hot globals and Lua standard functions are cached as file-level locals at the very top of each file:
  ```lua
  local pairs, ipairs, type, tostring = pairs, ipairs, type, tostring
  local CreateFrame, UIParent = CreateFrame, UIParent
  local GetTime = GetTime
  ```
* **Why:** In Lua 5.1 (WoW's engine), global lookups perform a table query every invocation. Local upvalues are direct register lookups, significantly reducing execution overhead in hot loops and event callbacks.

### Step 2: Event-Driven vs. Polling (`OnUpdate`)
* **DBM Pattern:** DBM-Core never uses continuous `OnUpdate` timers to poll world state. Everything is strictly reactive, registered via Blizzard events (`BAG_UPDATE_DELAYED`, `ZONE_CHANGED_NEW_AREA`, `PLAYER_REGEN_DISABLED`).
* **Why:** Polling burns CPU cycles while the player is standing still. If an `OnUpdate` script is ever needed (e.g. smooth dragging or progress animations), it must be set only during the active operation and set to `nil` immediately upon completion.

### Step 3: Zero Memory Allocation in Loops
* **DBM Pattern:** Avoid allocating tables (`{}`) or dynamic strings inside functions that fire repeatedly.
* **Why:** In Lua, creating `{}` forces garbage collection cycles (GC pauses) which manifest in-game as micro-stutter. Reuse persistent tables or module-level scratch tables:
  ```lua
  -- Anti-pattern (causes GC churn):
  local function UpdateStatus()
      local data = { level = UnitLevel("player"), hp = UnitHealth("player") }
      Render(data)
  end

  -- DBM pattern (zero allocation):
  local statusCache = {}
  local function UpdateStatus()
      statusCache.level = UnitLevel("player")
      statusCache.hp = UnitHealth("player")
      Render(statusCache)
  end
  ```

### Step 4: Frame & Widget Pooling
* **DBM Pattern:** Frames, FontStrings, and status bars are created once, indexed in a pool, and toggled via `:Show()` / `:Hide()`.
* **Why:** Never destroy or recreate UI elements during window refresh. If a list has variable rows, reuse the existing rows and hide unused ones.

### Step 5: Clean Modular Separation & Namespace Discipline
* **DBM Pattern:** Modules communicate via clean registrations (`RegisterMod`, `NewHeader`). There is zero global pollution.
* **Why:** Only `Blackacre` is allowed in the global table. All internal helpers, tables, and caches must be scoped locally or namespaced under `Blackacre.<Package>`.

---

## Pass D Notes — Historical Baseline

Applied to `UI_Chronology.lua`, `TomeHub.lua`, `Theme.lua` (body fonts / chrome menus):

| Rule | Application |
|------|-------------|
| Locals / upvalues | File-local helpers; `Theme()` accessor; no one-off globals |
| Theme owns paths | Popup menus via `ApplyChromeMenuFrame`; parchment via `GetParchmentPath` |
| No double work | `RenderSpread(skipRebuild)` after `TurnPage` / `GoToToc` / jump already rebuilt |
| No tick waste | `OnUpdate` only during sticky resize; cleared in `ClearLeaf` / drag stop |
| Frames reused | Tool strip / menus built once (`_baBuilt`, `journal.stickyMenu`, `addNoteMenu`) |
| IC vs OOC | Backstory Menus = separate parent; journal pages stay story-only |
| Dead code | Removed unused `White` alias path, unused right-click wire helper |

