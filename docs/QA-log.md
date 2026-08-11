# Blackacre — QA Log

Check items off as you verify in-game. Mark fails with notes under **Failures**.  
**Last build:** 1.2.0 (true book · setup wizard) · **Repo:** https://github.com/khallammarellus-rgb/In-Character

How to use: change `- [ ]` to `- [x]` when pass. Add date/character in Notes if useful.

---

## Load & smoke

- [ ] `/reload` — no Lua errors (TRP3 enabled)
- [ ] `/reload` — no Lua errors (TRP3 disabled)
- [ ] Character-select AddOns lists **four** entries: Blackacre, Presence, Tome, Survival (all enabled)
- [ ] Minimap book icon visible
- [ ] `/ic packages` shows Presence, Tome, Survival and version **1.2.0**
- [ ] Disable Presence only → `/ic` hints to enable Presence; `/ic tome` still works
- [ ] Disable Tome only → right-click minimap hints; Presence still works

---

## Phase 1.1 — Tome Theme 2.0 · Voice · Bulletins

### Traveler’s Tome hub

- [ ] Right-click minimap opens **Traveler’s Tome** (book chrome, spine/ribbon)
- [ ] Tabs: Pages, Lineage, Honor, Road, Realms, Voice, Share
- [ ] Pages tab shows chronicle index + page body
- [ ] Lineage / Honor / Road / Realms tabs show summary + open full panel
- [ ] `/ic tome` toggles hub; `/ic voice` opens Voice tab
- [ ] Esc closes hub (`UISpecialFrames`)

### Voice

- [ ] Voice tab: accent dropdown (auto / none / race profiles / afrikaans)
- [ ] Auto follows player race
- [ ] Sample line updates when accent changes
- [ ] New chronicle auto-page uses accent when “apply to chronicle” is checked
- [ ] Accent is one profile only (no mixing)

### Bulletin polish

- [ ] Wax seal labels [P]/[C]/[G]/[R] on board list
- [ ] Known boards list from board panel / post editor
- [ ] Boards registered beyond SW/Org/Dalaran (e.g. Valdrakken, Dornogal)
- [ ] Soft OOC lint on post (`lfg`, `ooc:`, etc.) → confirm dialog
- [ ] Post still requires board proximity

---

## Phase 1.2 — True book + setup wizard

### Single book window

- [ ] Right-click minimap opens one Traveler’s Tome only
- [ ] Tabs Pages / Lineage / Honor / Road / Realms / Voice / Share never open a second feature window
- [ ] `/ic birth`, `/ic hardcore`, `/ic roadmap`, `/ic afterlife` only switch tabs in the same book
- [ ] Realm picker for afterlife is an in-book overlay (not a floating second frame)
- [ ] Page fill reaches borders (no empty stretched-texture corners)
- [ ] Controls do not bleed outside the page host

### Setup wizard

- [ ] New character (no birth year, empty chronicle) auto-opens setup ~1.5s after login
- [ ] Existing character with birth or chronicle entries does **not** auto-open
- [ ] Steps: welcome → name/residence → lineage → voice → optional toggles → done
- [ ] Skip marks setup complete; does not wipe data
- [ ] `/ic setup` reopens the wizard
- [ ] Finish lands on Pages tab with tabs re-enabled

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

## Phase E — Expedition roadmap

### Chart UI

- [ ] `/ic roadmap` opens parchment two-panel **Expedition Chart** (not a black box)
- [ ] Left lists preset roads (Alliance EK, Kalimdor, Horde paths, etc.)
- [ ] Hover preset shows blurb tooltip
- [ ] Selecting a preset starts expedition + toast + ROADMAP chronicle “Expedition begun”
- [ ] Right panel shows ordered zones with status glyphs (pending / active / done / locked)
- [ ] Click a step shows hubs, suggested lock level, lore blurb

### Progress

- [ ] **Next chapter** marks current done, activates next, chronicle arrive/chapter pages
- [ ] Last chapter advance completes expedition + toast + complete chronicle page
- [ ] **Abandon** clears active chart + chronicle note
- [ ] Starting a new preset replaces/abandons need — starting while active overwrites via StartPreset (verify behavior OK)

### Level-lock prompts

- [ ] “Level-lock suggestions” checkbox toggles prompts
- [ ] Reaching `lockAt` for active chapter shows native StaticPopup (cannot force XP lock)
- [ ] **Mark locked in journal** writes ROADMAP lock entry
- [ ] **Keep leveling** dismisses without lock entry
- [ ] Prompt does not spam every reload at same level

---

## Phase F — PvP after-action reports

- [ ] `/ic pvpsample` adds a Field (PVP) chronicle page with IC prose
- [ ] Entry is editable in `/ic chronicle`
- [ ] `/ic pvp off` stops auto reports; `/ic pvp on` re-enables
- [ ] Finish a battleground (or arena) with scores → auto field report (win/loss tone, damage/healing)
- [ ] Report does not duplicate spam for the same match (same key)
- [ ] Toast appears: “After-action page written…”
- [ ] Tone feels IC (field journal), not a raw DPS meter dump

---

## Phase G — Share / export

### Export (TRP3-friendly)

- [ ] `/ic export` opens parchment copy window
- [ ] Text includes name, hardcore honor, survival condition (if on), expedition, afterlife, recent chronicle headlines
- [ ] Can Ctrl+A / Ctrl+C and paste into TRP3 About or Notes
- [ ] Footer notes full journal stays local
- [ ] Esc closes export window

### Peer summary

- [ ] `/ic share` without name prints usage help
- [ ] `/ic share FriendName` sends request (both need Blackacre)
- [ ] Friend receives summary card in chat (name, honor, rites, headlines)
- [ ] Requester sees toast “Received summary from …”
- [ ] `/ic ping` still works alongside share

---

## Phase P — Beacons lite + Bulletins rename (0.9.0)

### Naming
- [ ] UI says **Bulletin**, not Notice
- [ ] `/ic bulletin` works; `/ic notice` does **not** (no alias)

### Beacons anti-spam
- [ ] Emit one beacon → single invisible channel blast (no chat text)
- [ ] Second emit blocked while active; Withdraw then wait 15m
- [ ] Beacon expires after 24h
- [ ] Relog does not re-spam channel
- [ ] Breadcrumb never appears as say/yell/whisper chat

### Beacons receive UX
- [ ] Same zone: map pin when world map open
- [ ] Mini talking-head top-center: fade in/out; hooded when far
- [ ] Yell-range: player head when unit resolvable
- [ ] Many beacons: only one head at a time; rolls over minutes / subzone
- [ ] Receive toggle default ON; OFF silences pins/heads
- [ ] `/ic beacons off` / `on` work
- [ ] List shows breadcrumbs; whisper only if name shown
- [ ] Name hide: anonymous list + hooded head

### Bulletins
- [ ] Post near board; fail clearly when not near
- [ ] Board panel titles “bulletin board”
- [ ] Full body still loads on click (addon whisper, not chat)

---

## Phase H — Lineage / birth year lore path

### Calendar & identity

- [ ] `/ic birth` opens parchment Lineage panel
- [ ] Era quick-pick sets birth near that era (tooltip shows ADP range)
- [ ] Save lineage writes chronicle “Lineage recorded” page
- [ ] Birth ADP **2**, present **20** → age **18**; display includes ~594 / 612 K.C. style readout
- [ ] Deep BDP (e.g. −10000) shows **BDP**, not nonsense K.C.

### Longevity & origin

- [ ] Cycle profile: auto / mortal / elf / earthen / dracthyr / undead / long_lived
- [ ] Cycle origin: born / stasis / forged / raised / awakened
- [ ] `/ic birth human` prints mortal sample summary in chat
- [ ] `/ic birth elf` → millennia age wording (not “18”)
- [ ] `/ic birth dracthyr` → stasis + small conscious age

### Suggestions & roadmap

- [ ] Suggestions list shows zone fits `[natural|stretch|legend_only|future]` + scores
- [ ] Road preset suggestions appear
- [ ] **Chart from birth** / expedition **From lineage** starts a matching roadmap
- [ ] Ancient profile tends toward ancient_kalimdor / dracthyr_wake / earthen_vaults when appropriate

### Export / share

- [ ] `/ic export` includes lineage summary line when birth set
- [ ] Peer card can include age line when shared (optional check with friend)

---

## Discovery (regression)

- [ ] `/ic` flyout opens
- [ ] `/ic beacon` editor + Broadcast
- [ ] `/ic notice` editor near board / away message
- [ ] `/ic ping` works with a friend (optional)
- [ ] `/ic history` prints draft counts
- [ ] Profanity hard-block on notice still works

---

## Full suite smoke (quick pass)

- [ ] `/ic birth` · `/ic chronicle` · `/ic hardcore` · `/ic survival` · `/ic afterlife` · `/ic roadmap` · `/ic export` all open without Lua error
- [ ] Parchment/native look still consistent (no plain black primary panels)
- [ ] No Lua errors after `/reload` with TRP3 on and off

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
| Phase E Roadmap | | | |
| Phase F PvP | | | |
| Phase G Share | | | |
| Phase H Lineage | | | |
| Discovery regression | | | |
| Full suite smoke | | | |
