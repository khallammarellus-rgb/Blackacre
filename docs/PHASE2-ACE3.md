# Phase 2 — Ace3 foundation

**Status:** Done (2.0.0-dev). Behavior of Survival/Tome/Presence should match prior builds; new options profile is additive.

## What landed

| Piece | Where | Why |
|-------|--------|-----|
| `embeds.xml` | `Blackacre/embeds.xml` | Load Ace3 + support libs via LibStub in order |
| AceDB | `BlackacreAceDB` (new SavedVariables) | Profiles for **options only** (minimap, quiet) |
| AceLocale | `Locales/enUS.lua` | Strings for core messages / options |
| AceConsole / AceTimer | mixins on AceAddon | Ready for cleaner slash/timer work |
| AceConfig + GUI | `Core/Options.lua` | Esc → Options → Blackacre, or `/ba config` |
| AceComm, Serializer | embeds | Same comms stack, proper package layout |

## What did **not** change (on purpose)

- `BlackacreDB` / `BlackacreCharDB` still hold chronicle, survival, presence data (flat tables).  
- Full AceDB migration of those tables is a later, careful phase.  
- Presence feature code frozen.  
- No full UI reskin.

## How to test

1. Character select → enable all four Blackacre packages.  
2. `/reload`  
3. `/ba packages` → version + package list  
4. `/ba config` → options panel (minimap toggle, quiet, profiles)  
5. `/ba tome` / `/ba survival` still work  
6. Esc → Interface Options → AddOns → **Blackacre**  

## VS Code

- `Blackacre/embeds.xml` — library load order  
- `Blackacre/Locales/enUS.lua` — English strings  
- `Blackacre/Core/Init.lua` — AceAddon + AceDB init  
- `Blackacre/Core/Options.lua` — AceConfig table  

## GitHub

Repo: https://github.com/khallammarellus-rgb/Blackacre  
