# Presence freeze — Bulletins & Beacons

**Status:** Frozen for feature and cosmetic work until **Phase 10**.  
**Package folder:** `Blackacre_Presence/`

---

## What is frozen

Do **not** change behavior, UI layout, data shapes, or message formats for:

| Area | Location (approx.) |
|------|---------------------|
| Presence package | `Blackacre_Presence/**` (all files) |
| Beacon / bulletin lifecycle | `Blackacre/Core/Lifecycle.lua` |
| Comms payloads used by Presence | `Blackacre/Core/Comms.lua` (careful: shared with future Community) |
| History drafts for beacons/bulletins | `Blackacre/History/History.lua` |
| Profanity / blocklist (bulletin safety) | `Core/ProfanityFilter.lua`, `Data/Blocklist.lua` |
| Slash entry points | `/ba` (aliases `/blackacre`, `/ic`), `beacon`, `bulletin`, `beacons on\|off` |
| Minimap left-click / shift-right beacon | `UI/MinimapButton.lua` |
| DB keys | `BlackacreDB.beacons`, `.bulletins`, `.notices`, `.history`, `.mutes`; CharDB `presence.*`, bulletin TTL settings |

---

## What *is* allowed before Phase 10

| Change type | Allowed? | Notes |
|-------------|----------|--------|
| Folder/TOC/global rename (completed → Blackacre) | Done | Re-test beacons after `/reload` |
| SavedVariables migration In Character → Blackacre | Yes | Keep Presence keys intact (`_migratedFromIC`) |
| Comments / docs pointing at freeze | Yes | |
| Fixing a **crash** that blocks all of core | Ask human first | Prefer minimal fix |
| Visual restyle of Presence | **No** | Wait for Phase 10 |
| New beacon/bulletin features | **No** | |
| Deleting Presence package | **No** | |

---

## Why freeze

Blackacre solo loop (Survival → Paths → Roadmap → Tome → Setup) is the product priority. Presence already works as a separate package. Changing it mid-migration risks regressions and distracts from rename/Ace3/survival work.

---

## Phase 10 (later)

- Align Presence chrome fully to Theme tokens  
- Audit raw backdrops → Theme  
- Optional custom Media for boards/seals  
- Only then expand features  

Until the human says **“start Phase 10”**, treat this file as a stop sign.
