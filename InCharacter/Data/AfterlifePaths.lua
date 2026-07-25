InCharacter = InCharacter or {}

-- Client-side IC return rites only — not real server quests.
InCharacter.AfterlifePaths = {
    {
        id = "spirit_world",
        name = "Spirit World",
        blurb = "The pale road beside the living, where the Spirit Healer waits.",
        tasks = {
            { id = "awaken", title = "Awaken as shade", body = "Feel the weightlessness. Name what you leave behind among the living." },
            { id = "walk", title = "Walk the pale road", body = "Move through the spirit paths of the place you fell. Do not rush the Healer." },
            { id = "reckon", title = "Speak your reckoning", body = "In silence or whisper, admit the blow that unmade you." },
            { id = "return", title = "Return by the Healer's leave", body = "Accept return only when the rite feels finished — then rejoin the living world." },
        },
    },
    {
        id = "bastion",
        name = "Bastion",
        blurb = "Kyrian spires and the discipline of letting go.",
        tasks = {
            { id = "ascent", title = "Ascent of the aspirant", body = "Imagine white stone underfoot. Leave one prideful memory on the steps." },
            { id = "service", title = "Service without name", body = "Perform a quiet kindness for another soul — in RP or reflection — without seeking credit." },
            { id = "burden", title = "Set down a burden", body = "Write or speak one attachment you would release to fly lighter." },
            { id = "wing", title = "Earn the wing-path home", body = "Complete the checklist of humility; then choose return with kyrian calm." },
        },
    },
    {
        id = "ardenweald",
        name = "Ardenweald",
        blurb = "The great forest of rest, rebirth, and winter's patience.",
        tasks = {
            { id = "grove", title = "Enter the dusk grove", body = "Describe the trees that remember you. Are their leaves silver or bare?" },
            { id = "seed", title = "Tend a wildseed", body = "Name a hope or bond you would see reborn; tend it with a short IC scene." },
            { id = "queen", title = "Dream under the Queen", body = "Rest — truly rest in character — before demanding the road back." },
            { id = "spring", title = "Spring's permission", body = "When the seed feels tended, accept rebirth into living flesh." },
        },
    },
    {
        id = "revendreth",
        name = "Revendreth",
        blurb = "Stone, sin, and the long work of atonement.",
        tasks = {
            { id = "mirror", title = "Face the mirror of sin", body = "Name a flaw or cruelty you carry. Do not soften it." },
            { id = "debt", title = "Count the debt", body = "Decide what penance would balance the scale — even symbolically." },
            { id = "sire", title = "Endure the Accuser's eye", body = "Hold still under judgment; write a short confession in the chronicle if you wish." },
            { id = "redemption", title = "Climb toward redemption", body = "Only then may the venthyr roads release you to life." },
        },
    },
    {
        id = "maldraxxus",
        name = "Maldraxxus",
        blurb = "Bone, ambition, and strength proven in the endless house of war.",
        tasks = {
            { id = "arena", title = "Claim a place in the arena", body = "State what strength you still possess after death." },
            { id = "house", title = "Choose your house's virtue", body = "Ambition, might, guile, or plague-craft — pick one and justify it IC." },
            { id = "trial", title = "Win a trial of worth", body = "Complete an IC duel of words, will, or imagined combat against your fear." },
            { id = "banner", title = "Raise the banner home", body = "Only the worthy leave Maldraxxus. Affirm you earned the march back." },
        },
    },
    {
        id = "other_side",
        name = "De Other Side",
        blurb = "Bwonsamdi's bargain — death with a grin and a price.",
        tasks = {
            { id = "drums", title = "Hear the death-drums", body = "Acknowledge the Loa's laughter. What joke does he make of your fall?" },
            { id = "bargain", title = "Strike a bargain", body = "Name a price you would pay — favor, secret, or future debt — to walk again." },
            { id = "keep", title = "Keep your word", body = "Record the bargain in the journal so it cannot be denied later." },
            { id = "laugh", title = "Leave laughing", body = "Return only after the bargain is sealed in your story." },
        },
    },
    {
        id = "emerald_dream",
        name = "Emerald Dream",
        blurb = "The green mirror of what life might be.",
        tasks = {
            { id = "enter", title = "Cross into the Dream", body = "Describe the dream-shape of the place you died." },
            { id = "balance", title = "Restore a small balance", body = "Mend something — IC word, gesture, or intent — that death disordered." },
            { id = "guardian", title = "Meet a guardian spirit", body = "Imagine or RP a spirit that challenges your right to wake." },
            { id = "wake", title = "Wake with green in your lungs", body = "Return when the Dream releases you willingly." },
        },
    },
    {
        id = "emerald_nightmare",
        name = "Emerald Nightmare",
        blurb = "Corruption's dream — beauty twisted, fear given form.",
        tasks = {
            { id = "taint", title = "Name the taint", body = "What corruption would claim you if you stayed?" },
            { id = "resist", title = "Refuse the sweet lie", body = "Reject one false comfort the Nightmare offers." },
            { id = "cut", title = "Cut a path of will", body = "Force a way through fear with a clear IC choice." },
            { id = "escape", title = "Tear free", body = "Escape is victory enough; return scarred but living." },
        },
    },
    {
        id = "twisting_nether",
        name = "Twisting Nether",
        blurb = "The endless void between worlds, where demons are born of chaos.",
        tasks = {
            { id = "drift", title = "Drift between stars", body = "Admit you are lost. Orientation is a victory." },
            { id = "anchor", title = "Seize an anchor", body = "Name one memory, person, or vow that keeps your self intact." },
            { id = "refuse", title = "Refuse the fel bargain", body = "Turn aside power that would unmake your name." },
            { id = "breach", title = "Breach back to flesh", body = "Punch a path home when the anchor holds." },
        },
    },
    {
        id = "maw_of_souls",
        name = "Maw of Souls",
        blurb = "Helheim's ship and the cold tide of the damned.",
        tasks = {
            { id = "shore", title = "Stand on the black shore", body = "Hear the oars. Accept that you nearly boarded." },
            { id = "name", title = "Speak your living name", body = "Refuse the nameless throng; claim who you are." },
            { id = "defy", title = "Defy the Helya's claim", body = "State why you are not yet cargo for the long ship." },
            { id = "shoreward", title = "Turn shoreward to life", body = "Leave Helheim's tide before the gangplank takes you." },
        },
    },
    {
        id = "oribos",
        name = "Oribos",
        blurb = "The Eternal City — purpose, attendants, and the Arbiter's silence.",
        tasks = {
            { id = "gate", title = "Arrive at the gates", body = "Feel judged without words. What purpose might be read in you?" },
            { id = "attendant", title = "Heed an Attendant", body = "Accept guidance — or question it — in a short IC moment." },
            { id = "purpose", title = "Name a purpose", body = "State one reason the living still need your story." },
            { id = "thread", title = "Follow the thread back", body = "When purpose is spoken, the city may release you." },
        },
    },
    {
        id = "zereth_mortis",
        name = "Zereth Mortis",
        blurb = "The forge of afterlives — patterns, first ones, and unfinished design.",
        tasks = {
            { id = "pattern", title = "See your pattern", body = "Imagine the geometry of your life. What line is incomplete?" },
            { id = "question", title = "Question the design", body = "Ask why you fell when you did — and listen for an answer in RP or silence." },
            { id = "rewrite", title = "Choose a rewrite", body = "Decide one change you will make if flesh returns." },
            { id = "seal", title = "Seal the cipher", body = "Accept return as a second draft of the self." },
        },
    },
    {
        id = "odins_halls",
        name = "Odyn's Halls",
        blurb = "Halls of Valor — glory, mead, and the Keeper's trial.",
        tasks = {
            { id = "horn", title = "Hear the horn", body = "Were you worthy of the feast, or merely dead?" },
            { id = "boast", title = "Offer a true boast", body = "Speak one deed done well — no lies for Odyn's table." },
            { id = "trial", title = "Stand a trial of courage", body = "Face a fear in IC terms; do not flinch in the telling." },
            { id = "mead", title = "Leave the mead-hall", body = "Glory enough — return to the living fight." },
        },
    },
    {
        id = "nyalotha",
        name = "Ny'alotha",
        blurb = "The sleeping city — black empire dreams and truth that unravels.",
        tasks = {
            { id = "sleep", title = "Dream the black city", body = "Describe one impossible street. Keep your mind on a leash." },
            { id = "truth", title = "Refuse a false truth", body = "Reject one revelation that would unmake your free will." },
            { id = "eye", title = "Close the eye", body = "Turn from the gaze that watches from under the world." },
            { id = "wake", title = "Wake before the city does", body = "Escape the dream; return before it claims a name." },
        },
    },
    {
        id = "elemental_planes",
        name = "Elemental Planes",
        blurb = "Fire, water, earth, air — the raw courts beyond mortal maps.",
        tasks = {
            { id = "court", title = "Name the court that holds you", body = "Flame, tide, stone, or storm — which claimed your fall?" },
            { id = "tribute", title = "Offer a tribute", body = "Give respect (IC) to the element without surrendering your will." },
            { id = "passage", title = "Win passage", body = "Bargain, endure, or outwit the plane's mood." },
            { id = "breach", title = "Breach the veil home", body = "Step back into Azeroth when the elements allow." },
        },
    },
}

function InCharacter.GetAfterlifePath(pathId)
    for _, path in ipairs(InCharacter.AfterlifePaths) do
        if path.id == pathId then
            return path
        end
    end
    return nil
end