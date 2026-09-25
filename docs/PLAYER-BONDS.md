# Player bonds — future feature, not built yet

Idea from the owner, written down so it doesn't get lost before it's scoped. Nothing here is implemented. This is a concept doc, not a spec to start coding from without a go-ahead.

## The pitch

A reputation system, but between players instead of between a player and a faction. Two characters can "add" each other in character, and the relationship only exists once both sides accept it — it's not something one player can force on another. Once established, both sides can grant or take away "rep" toward each other over time, in character, through whatever interaction triggers it (probably tied into Beacons/Bulletins or manual actions, TBD).

## Tiers

Seven tiers, "Acquainted" sitting in the middle as the neutral starting point once a bond is accepted.

Going up from Acquainted:

1. Acquainted (neutral / starting tier)
2. Associate
3. Friend
4. Companion
5. (top tier, custom-named per relationship — could read as Spouse, Partner, Dear Friend, whatever fits the two characters. Not a fixed label like the others.)

Going down from Acquainted:

1. Acquainted (neutral / starting tier)
2. Stranger
3. Estranged
4. Rival
5. Enemy

## Open questions (not decided yet)

- What actually moves rep up or down — manual player action, Beacon/Bulletin interactions, both?
- Does the bond ever expire or decay, or is it permanent until one side breaks it?
- Is the top custom-named tier locked in once both agree on a label, or editable later?
- Where does this live in the UI — Character Sheet? Its own panel? Tome page when a tier changes?
- Does a tier change ever write a Tome page automatically, and if so is that meta-tier enough to qualify (see Tome scope rules) or does it need to stay opt-in?

## Why it's not scoped yet

This needs a real design pass — data model (mutual acceptance state, per-pair storage, comms to sync between two players' addons), UI surface, and how it plays with the retcon-vs-new-event rule if a bond history ever needs correcting. Don't start building this until the owner scopes it properly and picks a phase for it.
