# Blackacre UX / UI vision

## Anchor: Bethesda × Warcraft — familiar, but bigger for adventure

Blackacre’s UX is a **marriage of Bethesda’s game-design principles with World of Warcraft’s visual design language**.

This is about **in-game** experience design — **not** replacing Blizzard’s Base UI (unit frames, action bars, default HUD overhaul). We are not building an ElvUI-style skin. We are expanding how adventure *feels* inside Azeroth.

| From Bethesda (design principles) | From Warcraft (visual / UI system) |
|-----------------------------------|-------------------------------------|
| **Player immersion** — you inhabit the world | Distinct **Warcraft art** (parchment, gold ink, quest chrome, icon language) |
| **Freedom** — choose path, rewrite, explore on your terms | Familiar **WoW UI patterns** (frames, fonts, borders, book/quest cues) |
| **Interactive design** — systems respond to choices; the world feels editable | Surfaces that feel like **expanded WoW**, not a foreign app |

**Result:** It should feel **familiar but bigger for adventure** — living more deeply in Azeroth, not installing a different game’s UI.

**Do not confuse with:**
- Replacing Base UI / default Blizzard frames wholesale  
- Copying Skyrim’s HUD layout 1:1  
- TRP3’s look-and-feel  

**Do aim for:** Bethesda-style *agency and immersion* expressed through *Warcraft-looking* frames. Trail-journal chrome (leather, parchment, gold titles) is the **texture** of that marriage — not a Skyrim skin.

Living Theme code: `Blackacre/UI/Theme.lua` (see [`THEME-TOKENS.md`](THEME-TOKENS.md)).  
**Frame/layer model (required):** [`FRAME-LAYERS.md`](FRAME-LAYERS.md) — Mayron Ep. 5: frame = canvas; BACKGROUND → BORDER → ARTWORK → OVERLAY → HIGHLIGHT; parent + unlimited children.  
Custom art: [`MEDIA-GUIDE.md`](MEDIA-GUIDE.md).  
Presence freeze: [`PRESENCE-FREEZE.md`](PRESENCE-FREEZE.md).

---

## Design principles

1. **Immersion + freedom + interaction** (Bethesda) delivered in **Warcraft visual grammar**.  
2. **Journal is in-character** — Tome pages are the story. OOC controls live in the **Blackacre Menu**, never as settings inside journal pages.  
3. **One Theme API** — feature UI uses Theme helpers; textures registered once.  
4. **Familiar but expanded** — same art family as quest/spellbook; more adventure surface.  
5. **Custom Media welcome** — your TGA under `Media/`, Theme keys, Blizzard fallbacks.  
6. **Presence freeze** — no beacon/bulletin feature or cosmetic work until Phase 10.  
7. **History has integrity** — changing past-affecting settings asks **retcon vs new event** (see below).

---

## Surface types

| Surface | Scope | Rules |
|---------|--------|--------|
| **Book shell** | **Tome hub only** | The journal book window. Not for OOC settings. Theme: `CreateBookShell` / `ApplyBookBackdrop`. |
| **Blackacre Menu** | Path picker, settings, **mount status**, anything **OOC** that changes the Tome or overall experience | Separate surface from the journal. **No settings may be changed inside the journal.** |
| **Page panel** | Pages of content from achievements, quests, path completion, leveling, and **manual journaling** | Story/data only — not options UI. Theme: `ApplyPagePanel` / page fill. |
| **Parchment tool** | A **menu strip at the bottom of the Tome** that toggles **journaling mode** so players can edit contents — including auto-populated entries | Not a free-floating survival panel. Survival stays on **HUD meters**. |
| **HUD meters** | Always-on survival (hunger / thirst / exposure…); **compact**; **minimizable or hideable** | See reminder rules below. |
| **Modal / wizard step** | Setup / first-run flows | **No changes yet** — keep current approach until a later phase. |
| **Presence** | Beacons & bulletins | **Freeze** until Phase 10. |
| **Toast** | Short soft feedback when meters UI is visible | Parchment-style; not combat-red spam. |

### Book shell vs Blackacre Menu (hard split)

```
┌─────────────────────────────────────┐
│  BOOK SHELL = Tome (IC journal)     │
│  pages of story · no settings       │
│  ┌───────────────────────────────┐  │
│  │ Page panels (data + prose)    │  │
│  └───────────────────────────────┘  │
│  [ Parchment tool: journaling on ]  │  ← edit mode toggle only
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  BLACKACRE MENU (OOC)               │
│  paths · settings · mount status    │
│  anything that reconfigures the     │
│  experience / can rewrite story     │
└─────────────────────────────────────┘
```

If a control **changes the rules of the experience** or **rewrites character history**, it belongs in the **Blackacre Menu**, not the journal.

### Page panel — what fills the pages

Content is **populated by data** and player voice:

- Achievements  
- Quests  
- Path completion (life paths / related beats)  
- Leveling  
- Manual journaling (when parchment tool journaling mode is on)

Players may edit auto-populated text while journaling mode is enabled; that is freedom (Bethesda), still presented as Warcraft book pages.

### Parchment tool — journaling toggle

- Lives at the **bottom of the Tome** (book shell).  
- Toggles whether the player can **edit** page contents (including auto entries).  
- Does **not** host survival meters or global settings.

### HUD meters — visibility and reminders

| Meter state | Critical / soft reminders |
|-------------|---------------------------|
| **Visible / open** | Normal popup / parchment toast reminders (as designed for immersive feedback). |
| **Hidden** (or minimized away) | **Soft reminders only** as **player-only system text** (visible to the local player; not a full popup screen). |

Always-on in the sense of “the system is running”; the chrome may be minimized or hidden without turning survival off unless the player disables survival itself in Menu/settings later.

### Modal / wizard step

No design changes in this revision. First-run setup may later route OOC choices through Blackacre Menu patterns; implementation deferred.

### Presence

Frozen. See [`PRESENCE-FREEZE.md`](PRESENCE-FREEZE.md).

---

## Blackacre Menu — retcon vs new event

When an OOC change would alter something **already written** into the character’s story (examples: death-realm attunement Revendreth → De Other Side; life path; other Tome-affecting decisions):

1. Show a clear prompt: **“Do you want to retcon?”** with **Yes** / **No**.  
2. **Yes — retcon**  
   - Rewrite the decision **at the original time** it was chosen.  
   - Example: the chronicle beat that recorded Revendreth now records De Other Side.  
   - **Nothing else** is rewritten (later events stay; only that original choice is corrected).  
3. **No — new event**  
   - Leave the past as written.  
   - Log a **new** beat (e.g. attunement shifted from Revendreth to De Other Side *now*).  

This protects immersion and freedom: players can correct a mistake (retcon) or role-play a change (new event). Implementation lands when Menu + chronicle/path systems are built; this doc is the product law.

Also under Menu scope: **mount status** and other OOC experience toggles that must not appear as “settings inside the journal.”

---

## Do / don’t

| Do | Don’t |
|----|--------|
| Warcraft-looking chrome with deeper adventure systems | Replace Base UI / unit frames as the product goal |
| Keep journal IC; put OOC in Blackacre Menu | Bury settings inside page panels |
| Ask retcon vs new event on history-changing edits | Silently rewrite the whole chronicle |
| Soft system text when meters are hidden | Spam full popups while HUD is hidden |
| Gold titles + ink body; register textures | Neon “modern app” skins or plain black solo panels |
| Custom Media for identity art | Unregistered random texture paths in feature files |

---

## Visual density

Default: **trail journal (restrained)** — clear hierarchy, readable ink, modest ornament — still **Warcraft**, not a third-party UI pack.  
Richer “ornate grimoire” only if you choose it explicitly later.

---

## Per-phase UX expectations (summary)

| Phase | UX focus |
|------:|----------|
| 0 / 0.1 | Vision, tokens, media, **this anchor** |
| 1 | In-game visual baseline notes |
| 2 | Theme formalization |
| 3 | Blackacre brand pass |
| 4 | HUD meters: Theme tokens, minimize/hide, dual reminders |
| 5+ | Blackacre Menu (paths, settings, retcon prompts); page data; parchment journaling strip |
| 7–8 | Page population + wizard (wizard rules still “no change yet” until scoped) |
| 10 | Presence unfreeze |

---

## UX checklist (any phase that ships UI)

- [ ] Theme helpers / registered textures  
- [ ] Journal vs Menu separation respected  
- [ ] History-changing settings use retcon prompt (when applicable)  
- [ ] HUD hide → system text only; HUD open → normal popups  
- [ ] Gold title + ink body where appropriate  
- [ ] IC empty / first-run states  
- [ ] Readable at 1080p; Esc closes floaters  
- [ ] Familiar Warcraft look, bigger adventure feel  
- [ ] New texture keys documented  

---

## How to proof in-game (today’s build)

1. `/reload` after saves.  
2. `/ic tome` — **book shell** only; note what is still mixed (settings tabs) as **debt** toward Blackacre Menu.  
3. `/ic survival` — meters; later: hide vs visible reminder modes.  
4. Compare to this doc: *familiar Warcraft, bigger adventure?*  

VS Code: `Blackacre/UI/Theme.lua`, then Tome / Survival UI files.
