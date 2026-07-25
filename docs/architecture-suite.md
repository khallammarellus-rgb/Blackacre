# In Character — Immersion Suite Architecture

**Product:** One addon (In Character) combining discovery, chronicle, survival, hardcore integrity, afterlife paths, roadmaps, PvP reports, and peer sharing.

**Repo:** https://github.com/khallammarellus-rgb/In-Character  
**Target:** Retail WoW 12.0.7+

---

## Design principles

1. **In-character always** — player-facing prose is written as the character’s world, not OOC meta.
2. **Native + immersive UX** — journal, map, and parchment chrome; not plain black addon boxes. Shared shell: `UI/JournalFrame.lua` + `UI/Theme.lua`.
3. **Complement TRP3** — nil-checked reads only; never write TRP3 SavedVariables.
4. **No AI in-client** — RP hooks from template banks + game facts; always player-editable.
5. **Honor-system hardcore** — log and prompt; cannot enforce bag/mount/death rules server-side.
6. **Discovery remains** — beacons/boards stay as Module Discovery (see `architecture.md`).

---

## Module roadmap

| Phase | Module | Status |
|---|---|---|
| Shipped | Discovery (beacons, boards) | MVP+ |
| A | Chronicle (log, hooks, journal UI) | **0.2.0 shipped** |
| **B** | **Hardcore integrity log** | **0.3.0 shipped** |
| C | Survival meters | Planned |
| D | Afterlife return paths | Planned |
| E | Leveling roadmap | Planned |
| F | PvP after-action reports | Planned |
| G | Peer share + TRP3-friendly export | Planned |

---

## Phase A — Chronicle

### Data

Per-character `InCharacterCharDB.chronicle.entries[]`:

```
ChronicleEntry {
  id, kind, createdAt, editedAt,
  zoneId, zoneName,
  facts = {},
  context = { name, race, class, level, spec },
  title, body,
  tags, pinned,
  source = "auto" | "manual",
  yearKC,
}
```

Kinds: `QUEST`, `ACHIEVEMENT`, `TITLE`, `PROFESSION`, `MANUAL` (+ later DEATH, HC_*, PVP, AFTERLIFE, ROADMAP).

### Capture

| Source | Events |
|---|---|
| Quests | `QUEST_TURNED_IN` |
| Achievements | `ACHIEVEMENT_EARNED` |
| Titles | `KNOWN_TITLES_UPDATE` + current title poll |
| Professions | `CHAT_MSG_SKILL` |
| Manual | Journal “Add entry” UI |

### Hooks

`Data/HookTemplates.lua` + `Chronicle/Hooks.lua` — Mad-Libs with `{name}`, `{race}`, `{class}`, `{level}`, `{zone}`, `{questName}`, `{yearKC}`, `{spec}`, etc. Approximate K.C. year via `Data/YearCalendar.lua`.

### UI metaphor

**Character journal** — parchment two-panel (index + page), presentation mode for story reading. Warnings use soft parchment toasts, not red error spam.

---

## UX shell (all long-form UI)

| Surface | Metaphor |
|---|---|
| Chronicle | Travel journal |
| Hardcore / survival warnings | Sealed missive toast |
| Survival meters | Tracker-adjacent bars |
| Roadmap | Expedition chart |
| Afterlife | Ritual checklist |
| PvP report | Field journal page |

---

## Non-goals

- LLM/RAG inside the addon
- Server custom afterlife quests
- Forced starvation / bag ban enforcement
- Writing into TRP3 SavedVariables