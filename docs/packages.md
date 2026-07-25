# In Character — multi-package layout

**Version:** 1.0.0

Modeled after Total RP 3’s modular TOC layout: one **core** addon owns SavedVariables and shared APIs; feature packages depend on core and register themselves on load.

## Folders

```
In-Character/
  InCharacter/                 # core
  InCharacter_Presence/
  InCharacter_Tome/
  InCharacter_Survival/
```

Each folder is a separate Blizzard addon entry under `Interface/AddOns/`.

## Load contract

1. **Core** (`InCharacter`) loads first.
2. AceAddon `OnInitialize`: DB migrate, `Comms`, `Lifecycle`, `History`, minimap.
3. Child TOCs use `## RequiredDeps: InCharacter`.
4. Each child’s last file `Bootstrap.lua` calls:

```lua
InCharacter.RegisterPackage("Presence", InitPresence)
```

`RegisterPackage` runs the init function once and records the package name (`/ic packages`).

## Shared globals

- `InCharacter` table — single namespace across packages  
- `InCharacterDB` / `InCharacterCharDB` — only declared in core TOC  
- Prefix `IC_RP`, channel `IC_Channel` — core only  

Packages must **not** redeclare SavedVariables.

## Optional packages

| Disabled package | Effect |
|---|---|
| Presence | No flyout/beacons/bulletins UI; core still stores beacon DB fields |
| Tome | No chronicle/HC/afterlife/roadmap/lineage/share |
| Survival | No meters; no hunger ticks |

Slash commands and minimap print a short hint if a required package is missing.

## Adding a new package

1. Create `InCharacter_Foo/` with `InCharacter_Foo.toc` and `## RequiredDeps: InCharacter`.
2. Put Lua under that folder; extend `InCharacter.*` tables.
3. End with `Bootstrap.lua` calling `InCharacter.RegisterPackage("Foo", InitFn)`.
4. Junction into AddOns and enable on character select.
