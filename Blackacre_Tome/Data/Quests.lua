-- Shared quest ID repository (optional cross-path lookups).
-- Paths can also embed quests[] inline; this table is for named chains you reuse.
--
-- Example:
--   Blackacre.QuestRepo["stratholme_memory"] = {
--     { questId = 12345, title = "..." },
--   }
-- Then a path can copy or reference that list later.

Blackacre = Blackacre or {}
Blackacre.QuestRepo = Blackacre.QuestRepo or {}

-- You paste named lists here as you scrub Wowhead. Keep keys lowercase_snake.
-- Blackacre.QuestRepo["example_chain"] = {
--     { questId = 0, title = "Replace me", optional = false },
-- }
