# Handoff — Blackacre In Character (WoW Forever)

Resume note for the next session. Written 2026-09-21 after a performance pass, a full copy review, and two chrome-size fixes.

Read this first, then `AGENTS.md` and `docs/BLACKACRE-BRIEF.md` if the task is structural.

## Where the code is

- Repo on disk: `C:\Users\kvebe\InCharacter`
- Addon packages (what WoW loads): `Blackacre`, `Blackacre_Tome`, `Blackacre_Survival`, `Blackacre_Presence`
- The desktop folder `OneDrive\Desktop\Blackacre, In Character` is art reference, not the addon.
- Target client: **WoW Forever** (interface `16001`, game type Camelot). Mainline-style UI APIs on a vanilla-era world. Do not treat it as Classic 3.3.5, and do not add retail-only systems (renown, roads, talking-head beacons) to the Forever path.
- TOC: `## Interface: 120007, 16001` in `Blackacre/Blackacre.toc`. Flavor split lives in `Blackacre/Core/Compat.lua` (`Blackacre.Compat.IsForever()`).

## How to test

1. Copy or junction the four `Blackacre*` folders into the Forever AddOns directory if they are not already there.
2. `/reload`
3. `/ba` opens the tool box. Right-click the minimap button for the tome. Left-click for the tool box.
4. Watch the default chat frame. Red Lua errors are the first thing to fix.

## What this session changed

### Performance (always-on cost)

Rules used: events instead of polling, no bag or map queries while standing still, no combat aura work that does not change the game. Details are in the code, not a second design doc.

- Survival bag scan is cached until `BAG_UPDATE_DELAYED`. `GetItemInfo` is not used (it queries the server).
- Hardcore no longer listens to `UNIT_AURA`. Bag checks are one delayed pass. The mount watch runs only while mounted.
- Battlefield score polling runs only inside a battleground or arena.
- Title checks use `UNIT_NAME_UPDATE`, not a 15-second timer. Renown is not registered on Forever.
- Comms remember the hidden channel. Full bulletin whispers go through AceComm (the old `SendAddonMessageLogged` call did not exist).
- Zone position is cached for a quarter of a second and cleared on zone change. Board and beacon distance run on movement, not a standing timer.
- Map pins are pooled. Climate lookups are cached. Dun Morogh / Coldridge are tundra.
- AceBucket is not loaded. The spare `Blackacre/Libs/ChatThrottleLib.lua` is not in the TOC. Leave it.

### Copy the owner already signed off

The review list was a numbered table (M, V, T, P, J, U, B, L, H, R, A, O, C, E, F, N, S, X). Only IDs the owner marked were changed. Do not revert unmarked strings.

Notable behavior, not just wording:

- **Journal this** on the quest-complete window writes the page immediately. It does not wait for the complete button. With **Active Journaling** on, a turn-in still writes one page if the button was never clicked. A quest already inked is not written twice.
- Quest pages quote the pane text and use the new prompt questions (`Chronicle/Prompt.lua`).
- Auto journal lines are first person, dated with faction year plus calendar month and day. Alliance displays K.C., Horde displays ADP (`Theme.FormatFactionYear`, `YearCalendar.JournalStamp`).
- These chronicle kinds are not written: encumbrance, unsanctioned mount, fly, survival-critical. **Road / expedition pages are not written on Forever, and the Path backstory tab is hidden there.** The owner said that screen must be rebuilt later, not patched.
- Profession pages fire only when a skill rank hits 75, 150, 225, or 300 (apprentice, journeyman, expert, artisan). Existing ranks are recorded once at login and not journaled.
- **Prepared** buff appears beside the survival meters when food or water is in the bags. Tooltip: "Your preparation keeps you sated." Hunger still pauses on food and thirst on water. Those "paused" lines were removed from the meter tooltips.
- Meter arrow tooltips: **Expand** / **Collapse**.
- **Recover is unavailable in combat** only fires if Recover is clicked during combat.
- Pin and unpin are system chat lines, not toasts. The "click a leaf" toast is gone.
- Footer label is **Journaling: Locked** / **Journaling: On**. Chat says **Journaling is On** / **Journaling is Off**.

### Chrome size (last request)

- TOC ribbon in `Blackacre_Tome/Chronicle/UI_Chronology.lua` (`RenderTocLeaf`): height 45 (was 36). Width is `(text width + 48) * 1.25`, minimum 200. The list below the ribbon uses that height.
- Journaling button in `Blackacre/UI/Theme.lua`: width 200 (was 110) so "Journaling: Locked" stays inside the button art.

## Owner rules that still apply

- Owner is not a professional developer. Explain in plain language, name the file, and give an in-game test.
- Ask before deletes, heavy refactors, force-pushes, or anything that throws away a working screen.
- Presence feature work was frozen until a later phase. This session only changed when Presence runs (no idle polling) and a few strings. Do not redesign beacons or bulletins unless asked.
- Journal pages are IC. Backstory is the OOC sidecar. Do not put settings inside chronicle pages.
- Theme owns textures. Do not hard-code new paths outside `Blackacre/UI/Theme.lua`.
- Frame paint order: BACKGROUND, BORDER, ARTWORK, OVERLAY, HIGHLIGHT. Body text sits on OVERLAY, above page art. See `docs/FRAME-LAYERS.md`.

## If they want to continue copy

Unmarked strings were left as they were. Still not a line-by-line review:

- Accent word swaps in `Blackacre_Tome/Data/VoiceLexicon.lua` (`you` to `ye` and the rest). Language names and the OOC confirm line were touched. Draenei and Pandaren greetings were removed.
- Deity blurbs, afterlife path blurbs, and expedition preset names.
- Developer-only `/ba skin` and `/ba toast` lines.

The owner reviews by ID. Do not rewrite a string they did not mark.

## Open work they named

- Rebuild the Path / expedition screen for Forever. Hidden on purpose. Do not turn the old retail road chart back on.
- They may still want the TOC ribbon or the Journaling button nudged after they look in game. Current sizes are the 25% ribbon and the 200-wide button above.

## Files touched this session

Core: `Blackacre/Core/Init.lua`, `Comms.lua`, `Lifecycle.lua`, `Options.lua`, `Locales/enUS.lua`, `embeds.xml`, `UI/Theme.lua`, `UI/ToolBox.lua`, `UI/MinimapButton.lua`

Survival: `Blackacre_Survival/Survival/Engine.lua`, `UI_Meters.lua`, `Data/ZoneClimate.lua`

Tome: `Chronicle/Capture.lua`, `Hooks.lua`, `Prompt.lua`, `UI_Chronology.lua`, `Data/HookTemplates.lua`, `Data/YearCalendar.lua`, `UI/TomeHub.lua`, `UI/SetupWizard.lua`, `Hardcore/Monitor.lua`, `Hardcore/UI_Gates.lua`, `PvP/AfterAction.lua`, `Lore/UI_Lineage.lua`, `Lore/Birthpath.lua`, `Voice/Engine.lua`, `Data/VoiceLexicon.lua`, `Afterlife/UI_Paths.lua`, `Afterlife/PathTracker.lua`

Presence: `UI/BoardView.lua`, `UI/Flyout.lua`, `Presence/BeaconHead.lua`, `Presence/BeaconPins.lua`, `Presence/InnGossip.lua`, `Data/Boards.lua`

## Suggested commit message

Not committed. Only commit if asked.

`Tighten Forever runtime cost and apply the signed-off In Character copy.`
