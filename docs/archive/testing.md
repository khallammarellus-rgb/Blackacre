# Blackacre — Smoke Test Checklist

Run these after `/reload` with the addon enabled.

## Chronicle (Phase A)

1. **`/ic chronicle`** — Parchment journal opens (not a plain black box); two panels visible.
2. **`/ic sample`** — Sample entry appears; toast may show; select entry and read IC prose.
3. **Edit + Save page** — Change body text; save; reopen entry; text persists after `/reload`.
4. **Add note** — Manual heading/body; Inscribe; entry in list.
5. **Presentation** — Hides index; full-page read; switch back to Edit mode.
6. **Regenerate** — New template wording; facts preserved.
7. **Pin / Delete** — Pin sorts preference; delete removes page.
8. **Live quest** — Turn in any quest → new QUEST entry with localized name.
9. **Minimap** — Right-click opens chronicle; Shift+Right-click beacon.

## Solo checks (Discovery)

1. **Clean load** — No Lua errors on login (with TRP3 enabled).
2. **Standalone load** — Disable TRP3, `/reload`, no errors.
3. **Minimap button** — Book icon; left-click flyout.
4. **Beacon editor** — Preview phrase, Broadcast, optional Also /say fires real say text.
5. **Notice editor** — Profanity in title/body is hard-blocked.
6. **OOC linter** — Text with `OOC:` or `lfg` shows confirm dialog before posting.
7. **Board proximity** — Stand near Stormwind Hero's Call board; `/ic notice` shows board name in hint.

## Two-client checks (friend or second account)

8. **`/ic ping`** — Sender sees "Comms pong from [name]".
9. **Beacon broadcast** — Receiver in same zone/subzone sees entry in flyout.
10. **Beacon fetch** — Click entry; full text appears in chat.
11. **Notice post** — Poster at board; receiver queries and sees title in board view.
12. **Notice fetch** — Click title; full body appears in chat.
13. **Retract** — Delete/post expiry removes entry from peer cache.
14. **TTL** — Beacon expires after 30 minutes (or adjust BEACON_TTL for dev testing).

## Dev commands

| Command | Expected |
|---|---|
| `/ic` | Toggle flyout |
| `/ic ping` | Channel ping/pong |
| `/ic beacon` | Beacon editor |
| `/ic notice` | Notice editor |
| `/ic history` | Print draft counts |