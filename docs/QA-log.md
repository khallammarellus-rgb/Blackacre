# In Character — QA Log

Check items off as you verify in-game. Mark fails with notes under **Failures**.  
**Last build:** 0.5.0 (Phase D afterlife) · **Repo:** https://github.com/khallammarellus-rgb/In-Character

How to use: change `- [ ]` to `- [x]` when pass. Add date/character in Notes if useful.

---

## Load & smoke

- [ ] `/reload` — no Lua errors (TRP3 enabled)
- [ ] `/reload` — no Lua errors (TRP3 disabled)
- [ ] Addon appears in character-select AddOns list as **In Character**
- [ ] Minimap book icon visible
- [ ] Version / TOC shows **0.5.0** after update

---

## Phase A — Traveler’s Chronicle

### Journal UI (native feel)

- [ ] `/ic chronicle` opens parchment two-panel journal (not a plain black box)
- [ ] Gold/title + ink-colored body text readable
- [ ] Frame movable; Esc closes (`UISpecialFrames`)
- [ ] Soft parchment toast on new auto-entry (unless quiet mode)

### Auto capture

- [ ] Turn in a quest → QUEST entry with correct quest name
- [ ] Earn an achievement → ACHIEVEMENT entry
- [ ] Equip/change title → TITLE entry (may take up to ~15s poll)
- [ ] Profession skill-up chat → PROFESSION entry
- [ ] `/ic sample` adds a sample QUEST-style page

### Edit & presentation

- [ ] Edit title/body → **Save page** → persists after `/reload`
- [ ] **Regenerate** rewrites template prose from same facts
- [ ] **Pin** keeps entry preferred in list
- [ ] **Delete** / tear-out removes entry
- [ ] **Add note** / Inscribe creates MANUAL entry
- [ ] **Presentation** hides index; full-page read; **Edit mode** restores layout
- [ ] Search box filters chronology
- [ ] Newest/Oldest sort toggle works

### Minimap / slash

- [ ] Right-click minimap → chronicle
- [ ] Left-click minimap → discovery flyout
- [ ] Shift+Right-click → beacon editor
- [ ] `/ic log` and `/ic journal` open chronicle

---

## Phase B — Hardcore integrity

### Gatekeeper (IC honor system)

- [ ] `/ic hardcore` or `/ic gates` opens gatekeeper / integrity panel (parchment style)
- [ ] Can mark **ground mount rite** complete / incomplete
- [ ] Can mark **flying rite** complete / incomplete
- [ ] Status shows death count and encumbrance/mount stain summary

### Encumbrance (bags)

- [ ] Equip a bag that is **not** 6 slots (and not reagent bag) → HC_ENCUMBRANCE chronicle entry + toast
- [ ] Reagent bag is **ignored** (no false positive)
- [ ] Empty bag slots do not spam
- [ ] Removing the oversized bag stops new spam (may already have one historical entry)

### Mounts

- [ ] Mount ground mount **without** ground gate → HC_MOUNT entry (debounced, not every tick)
- [ ] Complete ground gate, remount → no new HC_MOUNT while gated
- [ ] Use flying mount **without** flying gate → HC_FLY entry
- [ ] Complete flying gate → no new HC_FLY while gated

### Death

- [ ] Die → DEATH chronicle entry with zone context
- [ ] Death count increments on hardcore panel
- [ ] Release/resurrect does not double-count same death

---

## Phase C — Survival meters

### Condition panel

- [ ] Parchment **Condition** panel appears near top-right after `/reload` (if survival enabled)
- [ ] Shows Hunger, Thirst, Exposure bars with numeric values
- [ ] Climate label updates by zone (e.g. city / desert / woodland / temperate)
- [ ] Indoors vs outdoors reflected in subtitle
- [ ] Panel is draggable; tooltip explains Eat/Drink/Rest
- [ ] `/ic survival` toggles panel visibility
- [ ] `/ic survival off` hides meters and stops decay; `/ic survival on` restores

### Decay & recovery

- [ ] Meters slowly decrease over time (~12s ticks)
- [ ] Desert/arid zones increase thirst pressure (travel Tanaris or similar if available)
- [ ] Cold-tagged zones increase exposure pressure (if available)
- [ ] Resting at an inn slows decay / slight recovery
- [ ] **Eat** button or `/ic eat` raises hunger + toast
- [ ] **Drink** / `/ic drink` raises thirst + toast
- [ ] **Rest** / `/ic rest` raises exposure (blocked in combat with message)
- [ ] Well Fed / drink-style buffs give light passive top-up (best-effort)

### Critical & chronicle

- [ ] Meter ≤15 → parchment toast warning (not spammed every tick)
- [ ] Meter ≤5 → SURVIVAL chronicle entry (cooldown ~3 min per meter)
- [ ] SURVIVAL entry editable in `/ic chronicle`

---

## Phase D — Afterlife return rites

### Realm picker

- [ ] `/ic realms` opens parchment list of afterlives (not a black box)
- [ ] Tooltips show realm blurbs on hover
- [ ] **Not this death** dismisses without starting a path
- [ ] Selecting a realm starts a path + toast + AFTERLIFE chronicle “Entered …”
- [ ] On death (with prompt enabled), realm picker appears after ~1.5s
- [ ] Checkbox “Prompt realm picker on death” can disable auto-prompt

### Active rite

- [ ] `/ic afterlife` shows active path name, blurb, progress X/Y
- [ ] Task checkboxes list IC steps with body text
- [ ] Checking a task completes it (cannot uncheck), logs AFTERLIFE page
- [ ] Completing **all** tasks auto-finishes return + “Returned from …” chronicle + toast
- [ ] **Abandon** clears active path + logs abandoned page
- [ ] **Chronicle** button opens journal
- [ ] Cannot start second path until abandon/finish (message if trying)

### Realms present

- [ ] Spirit World, Bastion, Ardenweald, Revendreth, Maldraxxus, De Other Side
- [ ] Emerald Dream, Emerald Nightmare, Twisting Nether, Maw of Souls
- [ ] Oribos, Zereth Mortis, Odyn's Halls, Ny'alotha, Elemental Planes

---

## Discovery (regression)

- [ ] `/ic` flyout opens
- [ ] `/ic beacon` editor + Broadcast
- [ ] `/ic notice` editor near board / away message
- [ ] `/ic ping` works with a friend (optional)
- [ ] `/ic history` prints draft counts
- [ ] Profanity hard-block on notice still works

---

## Failures / notes

| Date | Char | Item | Result | Notes |
|---|---|---|---|---|
| | | | | |

---

## Sign-off

| Milestone | Tester | Date | Pass? |
|---|---|---|---|
| Phase A Chronicle | | | |
| Phase B Hardcore | | | |
| Phase C Survival | | | |
| Phase D Afterlife | | | |
| Discovery regression | | | |

---

## Planned QA sections (not built yet)

- [ ] Phase E — Leveling roadmap
- [ ] Phase F — PvP after-action reports
- [ ] Phase G — Peer share / export
