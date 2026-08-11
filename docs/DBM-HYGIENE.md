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

## How to study DBM quickly

1. Browse DBM-Core on GitHub: how modules load, how locals are used at file top.  
2. Note event registration patterns and short, dense functions.  
3. Apply the **spirit** (hygiene + performance), not boss-mod specifics.
