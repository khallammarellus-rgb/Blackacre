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
| Junctions | `_retail_` and `_classic_beta_` (Forever) `Interface\AddOns\Blackacre*` → this repo |

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

Retail:

```powershell
$root = "C:\Users\kvebe\InCharacter"
$addons = "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns"
foreach ($p in @("Blackacre","Blackacre_Presence","Blackacre_Tome","Blackacre_Survival")) {
  $link = "$addons\$p"
  if (Test-Path $link) { cmd /c rmdir "$link" }
  New-Item -ItemType Junction -Path $link -Target "$root\$p" -Force
}
```

WoW Forever beta (`_classic_beta_`, game type Camelot, TOC `16001`):

```powershell
$root = "C:\Users\kvebe\InCharacter"
$addons = "C:\Program Files (x86)\World of Warcraft\_classic_beta_\Interface\AddOns"
foreach ($p in @("Blackacre","Blackacre_Presence","Blackacre_Tome","Blackacre_Survival")) {
  $link = "$addons\$p"
  if (Test-Path $link) { cmd /c rmdir "$link" }
  New-Item -ItemType Junction -Path $link -Target "$root\$p" -Force
}
```

## Character select

Enable all four (Retail or Forever — same package names):

1. **Blackacre**  
2. **Blackacre Presence**  
3. **Blackacre Tome**  
4. **Blackacre Survival**  

Disable old **In Character*** entries if they still appear (they should be gone after junction update).

On Forever, `/ba packages` should print `WoW Forever (1.60.x / 16001)` plus the loaded packages. If the addon is greyed as out of date, the TOC interface is wrong — current Forever beta is `16001`.

## Visual proof

Use [`PHASE1-VISUAL-BASELINE.md`](PHASE1-VISUAL-BASELINE.md) to note how the UI looks now so later phases do not regress immersion.
