# Blackacre — developer tooling (Phase 1)

## Your core loop

1. Edit files under `C:\Users\kvebe\InCharacter\Blackacre*` in **VS Code**.  
2. Save.  
3. In WoW: **`/reload`**.  
4. Test with **`/ba`** (or `/blackacre` / legacy `/ic`).  

No Notepad++ required. No AddOn Studio required.

## Already set up

| Tool | Role |
|------|------|
| VS Code | Editor |
| WoW API extension | Completions for game APIs |
| Git + GitHub | History (`In-Character` remote for now) |
| Grok CLI | Pair programming |
| Junctions | `_retail_\Interface\AddOns\Blackacre*` → this repo |

## Recommended in-game (install from CurseForge / Wago when you can)

| Addon | Why |
|-------|-----|
| **BugGrabber** + **BugSack** | Catch Lua errors cleanly while testing Blackacre |
| **DevTool** (optional) | Inspect tables/events while debugging |

These are **not** dependencies of Blackacre. Players do not need them.

## VS Code project files

| File | Purpose |
|------|---------|
| [`.luarc.json`](../.luarc.json) | Lua Language Server: Lua 5.1, Blackacre globals, ignore `Libs` |
| [`AGENTS.md`](../AGENTS.md) | Rules for coding agents |

If the Lua extension still warns on WoW APIs, the WoW API extension + this `.luarc.json` globals list should cover most Blackacre code.

## Junctions (recreate if broken)

```powershell
$root = "C:\Users\kvebe\InCharacter"
$addons = "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns"
foreach ($p in @("Blackacre","Blackacre_Presence","Blackacre_Tome","Blackacre_Survival")) {
  $link = "$addons\$p"
  if (Test-Path $link) { cmd /c rmdir "$link" }
  New-Item -ItemType Junction -Path $link -Target "$root\$p" -Force
}
```

## Character select

Enable all four:

1. **Blackacre**  
2. **Blackacre Presence**  
3. **Blackacre Tome**  
4. **Blackacre Survival**  

Disable old **In Character*** entries if they still appear (they should be gone after junction update).

## Visual proof

Use [`PHASE1-VISUAL-BASELINE.md`](PHASE1-VISUAL-BASELINE.md) to note how the UI looks now so later phases do not regress immersion.
