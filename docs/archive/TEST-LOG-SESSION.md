# Test log — filled from owner session

**Smoke:** PASS (A1–A5 OK; BugSack N/A)  
**Tome Pass A:** PASS with notes → rework in progress  
**Regression:** PASS with notes (minimap FAIL, first char, roadmap note)  

## Owner notes → actions

| Note | Action |
|------|--------|
| Larger font | Mail/letter-style larger body fonts |
| Need X to close | UIPanelClose + labeled **X** button |
| Title Traveler's Chronicle | Done |
| Active tab gold outline white text | Horizontal EJ-style tabs |
| Dead space top — expand content | Slim header, content fills book |
| Adventure Guide open book + two pages | Spellbook page BG, left/right pages, arrows |
| Tabs like dungeon boss/loot/spells | Horizontal tab bar |
| Chronology = TOC + left bookmark | Chronicle bookmark + TOC left page |
| Save does nothing | ClearFocus + toast if no selection + enable on Journal On |
| Fuzzy doubled body | Single title; no text shadow; mail font |
| Keep region labels for now | Removed dense labels; open book is clearer |
| Minimap fail | Force LibDBIcon show on init |
| Roadmap progress bar | Logged for later (not this pass) |

## Retest after this push

1. `/reload`  
2. `/ba tome` — open book, horizontal tabs, Chronology bookmark  
3. Click Chronology bookmark — TOC left, page right  
4. Select entry, **Journal: On**, edit, **Save page** — toast  
5. `<` `>` arrows flip entries  
6. Minimap icon present (right-click Chronicle)  
