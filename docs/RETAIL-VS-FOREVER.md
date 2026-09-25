# Retail vs Forever — why they're splitting

Two different games wearing the same UI right now, basically. Retail has 20 years of quests, lore, and canon to pull from. Forever is new, it's basically vanilla-era content on a mainline-style client (Camelot, interface 16001), and nobody — me included — knows the quest/canon depth well enough yet to build the same stuff Retail has. So instead of forcing Forever to fake being Retail, the two are becoming separate add ons that share a design language but not a feature list.

## The actual split

Two repos, two folders, eventually two separate installs. Not "one addon with a flavor flag that silently disables half its features" — that's what it is today and it's risky, because touching shared code for one flavor can quietly break the other. Splitting them means Retail work can't accidentally break Forever and vice versa.

Until the owner says the folders are actually splitting on disk, keep flavor-specific stuff behind `Blackacre.Compat` like now, but don't be surprised if a feature is Retail-only going forward — check this doc before assuming Forever should get it too.

## What Forever doesn't have (don't try to backfill)

- **No Paths / Alternate Start.** Paths need a spine of real, verified quest IDs and lore beats (see `docs/LORE-SOURCES.md` for how that's built on Retail — wiki graph → Wowhead IDs → curated spine). That process doesn't exist for Forever content yet because the quests and canon aren't documented well enough. Don't invent a Forever path off guesses.
- **No TRP3.** No official port. `Blackacre.Compat.SupportsTRP3()` gates this, and on Forever it should just always say no.
- **No Renown.** Not registered on Forever at all (see handoff notes).
- **No road/expedition Tome pages.** The old retail-style "road chart" screen is hidden on Forever on purpose, not a bug. It needs to be rebuilt for Forever specifically later, not patched to reuse the Retail one.

## What both flavors DO share

- Tome (first-person, meta-tier logging), Survival meters, Beacons & Bulletins, Character Sheet — these are the core feature set on both, they just may look or behave a little differently per the Backstory/Menu split (see BLACKACRE-BRIEF).
- Theme/chrome language (Bethesda × Warcraft, parchment/gold), the frame/layer rules, the DBM-style code hygiene standard. Visual grammar stays consistent even if content doesn't.

## Textures and API differences

Owner has console-extracted the client files separately for Retail and for Forever, both under the WoW folder on the drive (OneDrive desktop export). These are NOT guaranteed to match — an atlas or API that exists on Retail may not exist, or may behave differently, on Forever's client build. When working on Forever-specific chrome or code, check the Forever export, not the Retail one, even if the texture name looks identical.

## Baseline mindset

Retail is the mature baseline in terms of content depth. Forever is not a smaller Retail, it's its own thing still being figured out. When in doubt on a Forever feature, ask "do we actually know this yet" before building it out — it's fine for Forever to just have fewer features for a while.
