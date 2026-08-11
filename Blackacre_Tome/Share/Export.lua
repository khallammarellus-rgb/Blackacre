Blackacre = Blackacre or {}
Blackacre.Share = Blackacre.Share or {}
Blackacre.Share.Export = {}

local function Line(s)
    return (s or "") .. "\n"
end

function Blackacre.Share.Export.BuildSummaryText(maxEntries)
    maxEntries = maxEntries or 8
    local name = Blackacre.GetCharName()
    local level = UnitLevel("player") or 0
    local class = UnitClass("player") or ""
    local race = UnitRace("player") or ""
    local parts = {}
    parts[#parts + 1] = Line("— Blackacre summary —")
    parts[#parts + 1] = Line(string.format("%s · %s %s · level %d", name, race, class, level))

    if Blackacre.Birthpath and Blackacre.YearCalendar and Blackacre.YearCalendar.GetBirthADP
        and Blackacre.YearCalendar.GetBirthADP() then
        parts[#parts + 1] = Line(Blackacre.Birthpath.GetSummary())
    end

    if Blackacre.Hardcore and Blackacre.Hardcore.GetStatus then
        local s = Blackacre.Hardcore.GetStatus()
        parts[#parts + 1] = Line(string.format(
            "Hardcore honor: %s · deaths %d · mount stains %d · sky stains %d · encumbrance %s",
            s.clean and "unstained" or "stained",
            s.deathCount or 0,
            s.mountViolations or 0,
            s.flyViolations or 0,
            s.encumbranceActive and "active" or "clear"
        ))
        parts[#parts + 1] = Line(string.format(
            "Rites: ground %s · flying %s",
            s.groundGate and "complete" or "unsworn",
            s.flyingGate and "complete" or "unsworn"
        ))
    end

    if Blackacre.Survival and Blackacre.Survival.GetState then
        local sv = Blackacre.Survival.GetState()
        if sv.enabled then
            parts[#parts + 1] = Line(string.format(
                "Condition: hunger %d · thirst %d · exposure %d (%s)",
                math.floor(sv.hunger or 0),
                math.floor(sv.thirst or 0),
                math.floor(sv.exposure or 0),
                sv.climate and sv.climate.label or "—"
            ))
        end
    end

    local activeRoad = Blackacre.Roadmap and Blackacre.Roadmap.GetActive and Blackacre.Roadmap.GetActive()
    if activeRoad then
        local step = activeRoad.steps and activeRoad.steps[activeRoad.currentIndex]
        parts[#parts + 1] = Line(string.format(
            "Expedition: %s · chapter %s",
            activeRoad.name or "—",
            step and step.name or "—"
        ))
    end

    local after = Blackacre.Afterlife and Blackacre.Afterlife.GetActive and Blackacre.Afterlife.GetActive()
    if after then
        local done, total = Blackacre.Afterlife.PathTracker.Progress()
        parts[#parts + 1] = Line(string.format("Afterlife rite: %s (%d/%d)", after.pathName or "—", done, total))
    end

    parts[#parts + 1] = Line("")
    parts[#parts + 1] = Line("Recent chronicle:")
    local entries = Blackacre.Chronicle and Blackacre.Chronicle.Store and Blackacre.Chronicle.Store.List({}) or {}
    local n = 0
    for _, e in ipairs(entries) do
        n = n + 1
        if n > maxEntries then break end
        local dateStr = e.createdAt and date("%Y-%m-%d", e.createdAt) or "?"
        parts[#parts + 1] = Line(string.format("· [%s] %s — %s", dateStr, e.kind or "?", e.title or "Untitled"))
    end
    if n == 0 then
        parts[#parts + 1] = Line("· (no pages yet)")
    end

    parts[#parts + 1] = Line("")
    parts[#parts + 1] = Line("(Paste into TRP3 About/Notes if you wish. Full journal stays local unless shared via Blackacre.)")
    return table.concat(parts)
end

function Blackacre.Share.Export.CopyToClipboard()
    local text = Blackacre.Share.Export.BuildSummaryText(10)
    if not text or text == "" then
        Blackacre.Print("Nothing to export.")
        return
    end
    -- Prefer WoW's editbox copy frame pattern for paste into TRP3
    if not Blackacre.Share.Export._box then
        local f = CreateFrame("Frame", "BlackacreExportFrame", UIParent, "BackdropTemplate")
        f:SetSize(480, 320)
        f:SetPoint("CENTER")
        f:SetFrameStrata("DIALOG")
        Blackacre.UI.Theme.ApplyParchmentBackdrop(f, 0.98)
        f:Hide()
        tinsert(UISpecialFrames, "BlackacreExportFrame")

        local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOP", 0, -12)
        title:SetText("Export for TRP3 / notes")
        Blackacre.UI.Theme.GoldTitle(title)

        local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT", -2, -2)

        local hint = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        hint:SetPoint("TOPLEFT", 16, -36)
        hint:SetText("Select all (Ctrl+A) · Copy (Ctrl+C) · paste into TRP3 About/Notes")
        Blackacre.UI.Theme.InkFont(hint)

        local scroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", 16, -56)
        scroll:SetPoint("BOTTOMRIGHT", -36, 16)

        local edit = CreateFrame("EditBox", nil, scroll)
        edit:SetMultiLine(true)
        edit:SetFontObject(GameFontHighlightSmall)
        edit:SetWidth(420)
        edit:SetAutoFocus(true)
        edit:SetScript("OnEscapePressed", function() f:Hide() end)
        scroll:SetScrollChild(edit)
        f.edit = edit
        Blackacre.Share.Export._box = f
    end
    local f = Blackacre.Share.Export._box
    f.edit:SetText(text)
    f.edit:HighlightText()
    f:Show()
    f.edit:SetFocus()
    if Blackacre.UI and Blackacre.UI.Theme then
        Blackacre.UI.Theme.Toast("Summary ready to copy.")
    end
end

function Blackacre.Share.Export.BuildPeerPayload()
    local name = Blackacre.GetCharName()
    local level = UnitLevel("player") or 0
    local hc = Blackacre.Hardcore and Blackacre.Hardcore.GetStatus and Blackacre.Hardcore.GetStatus() or {}
    local headlines = {}
    local entries = Blackacre.Chronicle and Blackacre.Chronicle.Store and Blackacre.Chronicle.Store.List({}) or {}
    for i = 1, math.min(5, #entries) do
        headlines[#headlines + 1] = entries[i].title or entries[i].kind
    end
    local road = Blackacre.Roadmap and Blackacre.Roadmap.GetActive and Blackacre.Roadmap.GetActive()
    local ageLine = nil
    if Blackacre.Birthpath and Blackacre.YearCalendar.GetBirthADP and Blackacre.YearCalendar.GetBirthADP() then
        ageLine = Blackacre.Birthpath.FormatAge()
    end
    return {
        opcode = "IC_SUM",
        name = name,
        level = level,
        class = UnitClass("player"),
        race = UnitRace("player"),
        deaths = hc.deathCount or 0,
        clean = hc.clean and true or false,
        groundGate = hc.groundGate and true or false,
        flyingGate = hc.flyingGate and true or false,
        headlines = headlines,
        expedition = road and road.name or nil,
        ageLine = ageLine,
        birthYear = Blackacre.YearCalendar.GetBirthADP and Blackacre.YearCalendar.GetBirthADP() or nil,
        version = Blackacre.VERSION,
    }
end