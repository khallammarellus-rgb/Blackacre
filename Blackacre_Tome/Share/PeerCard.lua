Blackacre = Blackacre or {}
Blackacre.Share = Blackacre.Share or {}

function Blackacre.Share.OnPeerSummary(sender, data)
    if not data then return end
    local honor = data.clean and "unstained" or "stained"
    local lines = {
        string.format("|cffc9a227Blackacre card — %s|r", data.name or sender),
        string.format("%s %s · level %s · honor %s · deaths %s",
            data.race or "?", data.class or "?", tostring(data.level or "?"), honor, tostring(data.deaths or 0)),
        string.format("Rites: ground %s · flying %s",
            data.groundGate and "complete" or "unsworn",
            data.flyingGate and "complete" or "unsworn"),
    }
    if data.ageLine then
        lines[#lines + 1] = "Lineage: " .. data.ageLine
    end
    if data.expedition then
        lines[#lines + 1] = "Expedition: " .. data.expedition
    end
    if data.headlines and #data.headlines > 0 then
        lines[#lines + 1] = "Recent pages:"
        for _, h in ipairs(data.headlines) do
            lines[#lines + 1] = "  · " .. tostring(h)
        end
    end
    for _, line in ipairs(lines) do
        print(line)
    end
    if Blackacre.UI and Blackacre.UI.Theme then
        Blackacre.UI.Theme.Toast("Received summary from " .. (data.name or sender))
    end
end