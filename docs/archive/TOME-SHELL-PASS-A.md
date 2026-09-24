# Tome book shell — Pass A (skeleton)

**Status:** Implemented — waiting for your layout approval before Pass B (Achievement parchment art).

## Goal

Plain boxes + borders for the **Traveler’s Tome** root window at Achievement-frame scale. No final art.

## Regions (parent → children)

```
BlackacreTomeHub (ROOT) 900×620
├── header     (top band)     title, subtitle, close
├── tabRail    (left)         Pages, Lineage, Honor, …
├── pageHost   (center)       module content mounts here
└── footer     (bottom)       Journal On/Off placeholder + hint
```

Corner labels (`HEADER`, `TABS`, `PAGE HOST`, `FOOTER`) are temporary landscaping guides for Pass A.

## How to test

1. `/reload`  
2. `/ba tome`  
3. Check:
   - [ ] Window size/position (center, drag works)  
   - [ ] Header text readable; close works  
   - [ ] Left tabs clickable; active tab obvious  
   - [ ] Page area fills remaining space  
   - [ ] Footer strip visible; **Journal: On/Off** toggles print a message  
   - [ ] Esc closes tome  
   - [ ] Landscaping (gaps/margins) feels OK at 1080p  

## VS Code

- `Blackacre/UI/Theme.lua` — `CreateBookShell`, `ApplySkeletonPanel`  
- `Blackacre_Tome/UI/TomeHub.lua` — tabs, pages, journal toggle hook  

## Next

**You approve Pass A** → Pass B: Achievement Frame parchment textures on these same regions (layout frozen unless you request changes).
