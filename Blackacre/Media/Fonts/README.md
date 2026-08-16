# Chronicle fonts

## Already extracted (from your Downloads zips)

Many `.ttf` / `.otf` files are in this folder, including:

- `bilboregular.ttf` / `bilbobold.ttf` / `bilbofine.ttf`
- `Middleearth-ao6m.ttf`
- `Elvencommonspeak-0WXz.ttf`
- `PartyBusiness-4B0K.ttf`
- Plus WoW-style packs (Friz, Morpheus, Dwarven, etc.)

Registered keys in `Theme.Fonts`: `bilbo`, `middleEarth`, `elvenCommon`, `partyBusiness`, `hobbiton`, `friz`, `morpheus`, …

### Activate a body font in-game (temporary)

```
/run Blackacre.UI.Theme.SetBodyFontKey("bilbo"); ReloadUI()
```

Keys: `bilbo`, `middleEarth`, `elvenCommon`, `partyBusiness`, `hobbiton`, `friz`, `morpheus`

## Windows system fonts (Ink Free, Segoe Script, Matura, Copperplate)

WoW **cannot** read `C:\Windows\Fonts` for other players.  
If you may redistribute them: copy the `.ttf` into this folder and add a line under `Theme.Fonts`.

## Word documents

Word (`.docx`) may **embed** fonts, but those are not freely extractable as reusable `.ttf` files for an addon, and many are licensed only for Office. Prefer:

1. The zips you already downloaded (done), or  
2. Explicit `.ttf` copies you own.

**Not TIFF** — fonts are **TTF/OTF**, not TIFF images.

**Copyright:** only ship fonts you may redistribute with Blackacre.
