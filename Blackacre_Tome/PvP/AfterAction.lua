Blackacre = Blackacre or {}
Blackacre.PvP = Blackacre.PvP or {}
Blackacre.PvP.AfterAction = {}

local pendingReport = false
local lastReportKey = nil

local function SoftToast(msg)
    if Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.Toast then
        Blackacre.UI.Theme.Toast(msg)
    else
        Blackacre.Print(msg)
    end
end

local function EnsureDB()
    Blackacre.CharDB.pvp = Blackacre.CharDB.pvp or {
        enabled = true,
        lastReports = {},
    }
    return Blackacre.CharDB.pvp
end

local function GetPlayerScoreRow()
    local myName = UnitName("player")
    local num = GetNumBattlefieldScores and GetNumBattlefieldScores() or 0
    for i = 1, num do
        local name, killingBlows, honorableKills, deaths, honorGained, faction, race, class, classToken, damageDone, healingDone =
            GetBattlefieldScore(i)
        -- GetBattlefieldScore return order varies by client; use defensive unpack
        if type(name) == "string" then
            local short = name:match("([^%-]+)") or name
            if short == myName or name == myName then
                -- Retail signature often: name, kb, hk, deaths, honor, faction, rank, race, class, classToken, damage, healing
                local kb, hk, dth, honor, fac = killingBlows, honorableKills, deaths, honorGained, faction
                local dmg, heal = damageDone, healingDone
                -- If damageDone looks like class string, try alternate indices via select
                if type(damageDone) ~= "number" then
                    local n, killingBlows2, honorableKills2, deaths2, honorGained2, faction2, _, _, _, _, damageDone2, healingDone2 = GetBattlefieldScore(i)
                    name, kb, hk, dth, honor, fac = n, killingBlows2, honorableKills2, deaths2, honorGained2, faction2
                    dmg, heal = damageDone2, healingDone2
                end
                return {
                    name = name,
                    killingBlows = tonumber(kb) or 0,
                    honorableKills = tonumber(hk) or 0,
                    deaths = tonumber(dth) or 0,
                    honor = tonumber(honor) or 0,
                    faction = fac,
                    damage = tonumber(dmg) or 0,
                    healing = tonumber(heal) or 0,
                }
            end
        end
    end
    return nil
end

local function FormatNumber(n)
    n = tonumber(n) or 0
    if n >= 1000000 then
        return string.format("%.1fm", n / 1000000)
    elseif n >= 1000 then
        return string.format("%.1fk", n / 1000)
    end
    return tostring(math.floor(n))
end

local function OutcomeForPlayer(row)
    local winner = GetBattlefieldWinner and GetBattlefieldWinner()
    if winner == nil then
        return "inconclusive", "The field fell silent without a clear victor."
    end
    -- winner: 0 = Horde, 1 = Alliance on many clients; also may be team index
    local playerFaction = UnitFactionGroup("player") -- "Alliance" / "Horde"
    local won
    if winner == 0 then
        won = (playerFaction == "Horde")
    elseif winner == 1 then
        won = (playerFaction == "Alliance")
    else
        -- fallback: compare to row.faction if numeric
        won = (row and row.faction == winner)
    end
    if won then
        return "victory", "The day was won."
    end
    return "defeat", "The day was lost — but the tale remains."
end

local function BuildFacts(row, mapName, isArena)
    local outcome, outcomeLine = OutcomeForPlayer(row)
    return {
        outcome = outcome,
        outcomeLine = outcomeLine,
        mapName = mapName or "the field",
        isArena = isArena and true or false,
        damage = row and row.damage or 0,
        healing = row and row.healing or 0,
        deaths = row and row.deaths or 0,
        killingBlows = row and row.killingBlows or 0,
        damageText = FormatNumber(row and row.damage or 0),
        healingText = FormatNumber(row and row.healing or 0),
        title = string.format(
            "%s — %s",
            isArena and "Arena" or "Battleground",
            outcome == "victory" and "Victory" or (outcome == "defeat" and "Defeat" or "Skirmish")
        ),
    }
end

function Blackacre.PvP.AfterAction.TryReport()
    local db = EnsureDB()
    if db.enabled == false then return end
    if not GetNumBattlefieldScores or GetNumBattlefieldScores() == 0 then return end

    local row = GetPlayerScoreRow()
    if not row then return end

    local mapName = GetRealZoneText and GetRealZoneText() or "the field"
    local isArena = IsActiveBattlefieldArena and IsActiveBattlefieldArena()
    local facts = BuildFacts(row, mapName, isArena)
    local key = string.format("%s:%s:%s:%s", facts.mapName, facts.outcome, facts.damageText, facts.healingText)
    if key == lastReportKey then return end
    lastReportKey = key

    Blackacre.Chronicle.Capture.AddEntry("PVP", facts, "auto")
    table.insert(db.lastReports, 1, { at = time(), facts = facts })
    while #db.lastReports > 20 do table.remove(db.lastReports) end
    SoftToast("After-action page written: " .. (facts.title or "PvP"))
    pendingReport = false
end

function Blackacre.PvP.AfterAction.Init()
    EnsureDB()
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    if C_PvP and C_PvP.IsMatchComplete then
        -- no dedicated event on all builds; score update is enough
    end
    frame:SetScript("OnEvent", function(_, event)
        if event == "UPDATE_BATTLEFIELD_SCORE" then
            local winner = GetBattlefieldWinner and GetBattlefieldWinner()
            if winner ~= nil or pendingReport then
                C_Timer.After(0.5, Blackacre.PvP.AfterAction.TryReport)
            end
        elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
            -- Leaving a BG often fires this after scores were available; one more attempt
            if pendingReport then
                C_Timer.After(1, Blackacre.PvP.AfterAction.TryReport)
            end
            -- Detect entry into BG for request
            local inInstance, instanceType = IsInInstance()
            if inInstance and (instanceType == "pvp" or instanceType == "arena") then
                pendingReport = true
                if RequestBattlefieldScoreData then
                    RequestBattlefieldScoreData()
                end
            end
        end
    end)

    -- Poll lightly while in PvP instance for match end
    C_Timer.NewTicker(5, function()
        local inInstance, instanceType = IsInInstance()
        if inInstance and (instanceType == "pvp" or instanceType == "arena") then
            pendingReport = true
            if RequestBattlefieldScoreData then
                RequestBattlefieldScoreData()
            end
            local winner = GetBattlefieldWinner and GetBattlefieldWinner()
            if winner ~= nil then
                Blackacre.PvP.AfterAction.TryReport()
            end
        end
    end)
end

function Blackacre.PvP.AfterAction.SetEnabled(on)
    EnsureDB().enabled = on and true or false
end

function Blackacre.PvP.AfterAction.DebugSample()
    Blackacre.Chronicle.Capture.AddEntry("PVP", {
        outcome = "victory",
        outcomeLine = "The day was won.",
        mapName = "Warsong Gulch",
        isArena = false,
        damage = 420000,
        healing = 85000,
        deaths = 2,
        killingBlows = 5,
        damageText = "420.0k",
        healingText = "85.0k",
        title = "Battleground — Victory",
    }, "manual")
    SoftToast("Sample PvP after-action page added.")
end
