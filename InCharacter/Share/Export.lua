InCharacter = InCharacter or {}
InCharacter.Share = InCharacter.Share or {}
InCharacter.Share.Export = {}

local function Line(s)
    return (s or "") .. "\n"
end

function InCharacter.Share.Export.BuildSummaryText(maxEntries)
    maxEntries = maxEntries or 8
    local name = InCharacter.GetCharName()
    local level = UnitLevel("player") or 0
    local class = UnitClass("player") or ""
    local race = UnitRace("player") or ""
    local parts = {}
    parts[#parts + 1] = Line("— In Character summary —")
    parts[#parts + 1] = Line(string.format("%s · %s %s · level %d", name, race, class, level))

    if InCharacter.Hardcore and InCharacter.Hardcore.GetStatus then
        local s = InCharacter.Hardcore.GetStatus()
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

    if InCharacter.Survival and InCharacter.Survival.GetState then
        local sv = InCharacter.Survival.GetState()
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

    local activeRoad = InCharacter.Roadmap and InCharacter.Roadmap.GetActive and InCharacter.Roadmap.GetActive()
    if activeRoad then
        local step = activeRoad.steps and activeRoad.steps[activeRoad.currentIndex]
        parts[#parts + 1] = Line(string.format(
            "Expedition: %s · chapter %s",
            activeRoad.name or "—",
            step and step.name or "—"
        ))
    end

    local after = InCharacter.Afterlife and InCharacter.Afterlife.GetActive and InCharacter.Afterlife.GetActive()
    if after then
        local done, total = InCharacter.Afterlife.PathTracker.Progress()
        parts[#parts + 1] = Line(string.format("Afterlife rite: %s (%d/%d)", after.pathName or "—", done, total))
    end

    parts[#parts + 1] = Line("")
    parts[#parts + 1] = Line("Recent chronicle:")
    local entries = InCharacter.Chronicle and InCharacter.Chronicle.Store and InCharacter.Chronicle.Store.List({}) or {}
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
    parts[#parts + 1] = Line("(Paste into TRP3 About/Notes if you wish. Full journal stays local unless shared via In Character.)")
    return table.concat(parts)
end

function InCharacter.Share.Export.CopyToClipboard()
    local text = InCharacter.Share.Export.BuildSummaryText(10)
    if not text or text == "" then
        InCharacter.Print("Nothing to export.")
        return
    end
    -- Prefer WoW's editbox copy frame pattern for paste into TRP3
    if not InCharacter.Share.Export._box then
        local f = CreateFrame("Frame", "InCharacterExportFrame", UIParent, "BackdropTemplate")
        f:SetSize(480, 320)
        f:SetPoint("CENTER")
        f:SetFrameStrata("DIALOG")
        InCharacter.UI.Theme.ApplyParchmentBackdrop(f, 0.98)
        f:Hide()
        tinsert(UISpecialFrames, "InCharacterExportFrame")

        local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOP", 0, -12)
        title:SetText("Export for TRP3 / notes")
        InCharacter.UI.Theme.GoldTitle(title)

        local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT", -2, -2)

        local hint = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        hint:SetPoint("TOPLEFT", 16, -36)
        hint:SetText("Select all (Ctrl+A) · Copy (Ctrl+C) · paste into TRP3 About/Notes")
        InCharacter.UI.Theme.InkFont(hint)

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
        InCharacter.Share.Export._box = f
    end
    local f = InCharacter.Share.Export._box
    f.edit:SetText(text)
    f.edit:HighlightText()
    f:Show()
    f.edit:SetFocus()
    if InCharacter.UI and InCharacter.UI.Theme then
        InCharacter.UI.Theme.Toast("Summary ready to copy.")
    end
end

function InCharacter.Share.Export.BuildPeerPayload()
    local name = InCharacter.GetCharName()
    local level = UnitLevel("player") or 0
    local hc = InCharacter.Hardcore and InCharacter.Hardcore.GetStatus and InCharacter.Hardcore.GetStatus() or {}
    local headlines = {}
    local entries = InCharacter.Chronicle and InCharacter.Chronicle.Store and InCharacter.Chronicle.Store.List({}) or {}
    for i = 1, math.min(5, #entries) do
        headlines[#headlines + 1] = entries[i].title or entries[i].kind
    end
    local road = InCharacter.Roadmap and InCharacter.Roadmap.GetActive and InCharacter.Roadmap.GetActive()
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
        version = InCharacter.VERSION,
    }
end