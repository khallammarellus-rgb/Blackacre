# Blackacre — multi-package layout

**Version:** 1.0.0

Modeled after Total RP 3’s modular TOC layout: one **core** addon owns SavedVariables and shared APIs; feature packages depend on core and register themselves on load.

## Folders

```
In-Character/
  Blackacre/                 # core
  Blackacre_Presence/
  Blackacre_Tome/
  Blackacre_Survival/
```

Each folder is a separate Blizzard addon entry under `Interface/AddOns/`.

## Load contract

1. **Core** (`Blackacre`) loads first.
2. AceAddon `OnInitialize`: DB migrate, `Comms`, `Lifecycle`, `History`, minimap.
3. Child TOCs use `## RequiredDeps: Blackacre`.
4. Each child’s last file `Bootstrap.lua` calls:

```lua
Blackacre.RegisterPackage("Presence", InitPresence)
```

`RegisterPackage` runs the init function once and records the package name (`/ic packages`).

## Shared globals

- `Blackacre` table — single namespace across packages  
- `BlackacreDB` / `BlackacreCharDB` — only declared in core TOC  
- Prefix `BA_RP`, channel `BA_Channel` — core only  

Packages must **not** redeclare SavedVariables.

## Optional packages

| Disabled package | Effect |
|---|---|
| Presence | No flyout/beacons/bulletins UI; core still stores beacon DB fields |
| Tome | No chronicle/HC/afterlife/roadmap/lineage/share |
| Survival | No meters; no hunger ticks |

Slash commands and minimap print a short hint if a required package is missing.

## Adding a new package

1. Create `Blackacre_Foo/` with `Blackacre_Foo.toc` and `## RequiredDeps: Blackacre`.
2. Put Lua under that folder; extend `Blackacre.*` tables.
3. End with `Bootstrap.lua` calling `Blackacre.RegisterPackage("Foo", InitFn)`.
4. Junction into AddOns and enable on character select.
