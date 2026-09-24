Blackacre = Blackacre or {}
Blackacre.InnBoard = {}

local seeBtn
local listFrame
local detailFrame
local rows = {}
local listed = {}

local function IsInnkeeperGossip()
    if C_GossipInfo and C_GossipInfo.GetOptions then
        local opts = C_GossipInfo.GetOptions()
        if type(opts) == "table" then
            for i = 1, #opts do
                local o = opts[i]
                local name = (o.name or o.text or ""):lower()
                local typ = tostring(o.type or o.gossipOptionID or "")
                if name:find("home", 1, true) or name:find("inn", 1, true) or name:find("bind", 1, true) then
                    return true
                end
                if typ:lower():find("binder", 1, true) then
                    return true
                end
            end
        end
    end
    if GetGossipOptions then
        local args = { GetGossipOptions() }
        for i = 1, #args, 2 do
            local text = tostring(args[i] or ""):lower()
            if text:find("home", 1, true) or text:find("inn", 1, true) then
                return true
            end
        end
    end
    return false
end

local function CachedBulletinsForHere()
    local key, name = Blackacre.Boards.CurrentZoneKey()
    local out = {}
    local now = time()
    local function consider(b)
        if not b then return end
        if b.expiresAt and b.expiresAt < now then return end
        if Blackacre.Boards.BulletinMatchesZone(b, key, name) then
            out[#out + 1] = b
        end
    end
    for _, b in pairs(BlackacreDB.bulletins or {}) do consider(b) end
    local cache = BlackacreDB.cache and (BlackacreDB.cache.bulletin or BlackacreDB.cache.notice)
    if cache then
        for _, wrapped in pairs(cache) do
            consider(wrapped.data)
        end
    end
    table.sort(out, function(a, b)
        return (a.receivedAt or a.createdAt or 0) > (b.receivedAt or b.createdAt or 0)
    end)
    return out
end

local function ApplyStationery(tex, bulletin)
    if Blackacre.PostEditor and Blackacre.PostEditor.PaintStationery then
        Blackacre.PostEditor.PaintStationery(tex, bulletin and bulletin.stationary)
        return
    end
    if tex then tex:SetTexture("Interface\\QuestFrame\\QuestBackgroundParchment") end
end

local function ApplySeal(tex, bulletin)
    if Blackacre.PostEditor and Blackacre.PostEditor.PaintSeal then
        Blackacre.PostEditor.PaintSeal(tex, bulletin and bulletin.waxSeal)
        return
    end
    if tex then tex:Hide() end
end

local function EnsureList()
    if listFrame then return listFrame end
    local f = CreateFrame("Frame", "BlackacreInnPostings", UIParent)
    f:SetSize(420, 360)
    f:SetPoint("CENTER", 80, 0)
    f:SetFrameStrata("DIALOG")
    if Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.ApplyFactionFrameChrome then
        Blackacre.UI.Theme.ApplyFactionFrameChrome(f)
    end
    f:Hide()
    tinsert(UISpecialFrames, "BlackacreInnPostings")
    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.title:SetPoint("TOP", 0, -22)
    f.title:SetText("Inn postings")
    if Blackacre.UI and Blackacre.UI.Theme then Blackacre.UI.Theme.GoldTitle(f.title) end
    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -16, -8)
    close:SetScript("OnClick", function() f:Hide() end)
    for i = 1, 8 do
        local row = CreateFrame("Button", nil, f)
        row:SetSize(360, 22)
        row:SetPoint("TOPLEFT", 28, -48 - (i - 1) * 24)
        row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
        row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        row.text:SetPoint("LEFT", 4, 0)
        row.text:SetWidth(350)
        row.text:SetJustifyH("LEFT")
        rows[i] = row
    end
    listFrame = f
    return f
end

local function EnsureDetail()
    if detailFrame then return detailFrame end
    local f = CreateFrame("Frame", "BlackacreInnPostDetail", UIParent)
    f:SetSize(460, 400)
    f:SetPoint("CENTER", -40, 10)
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    f.paper = f:CreateTexture(nil, "BACKGROUND")
    f.paper:SetAllPoints()
    f.seal = f:CreateTexture(nil, "OVERLAY")
    f.seal:SetSize(56, 56)
    f.seal:SetPoint("BOTTOMRIGHT", -22, 18)
    f.seal:Hide()
    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.title:SetPoint("TOPLEFT", 36, -36)
    f.title:SetWidth(340)
    f.body = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.body:SetPoint("TOPLEFT", 36, -70)
    f.body:SetPoint("BOTTOMRIGHT", -36, 56)
    f.body:SetJustifyH("LEFT")
    f.body:SetJustifyV("TOP")
    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -8, -8)
    close:SetScript("OnClick", function() f:Hide() end)
    f.journal = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    f.journal:SetSize(120, 22)
    f.journal:SetPoint("BOTTOMLEFT", 28, 20)
    f.journal:SetText("Journal")
    f:Hide()
    tinsert(UISpecialFrames, "BlackacreInnPostDetail")
    detailFrame = f
    return f
end

local function ShowDetail(bulletin)
    local f = EnsureDetail()
    f.bulletin = bulletin
    f.title:SetText(bulletin.title or "Bulletin")
    f.body:SetText(bulletin.bodyText or "(Ask the innkeep — the full notice is still traveling.)")
    local fontObj = "QuestFont"
    if Blackacre.PostEditor and Blackacre.PostEditor.FontObject then
        fontObj = Blackacre.PostEditor.FontObject(bulletin.font)
    end
    f.body:SetFontObject(fontObj)
    f.title:SetFontObject(fontObj)
    ApplyStationery(f.paper, bulletin)
    ApplySeal(f.seal, bulletin)
    f.journal:SetScript("OnClick", function()
        if Blackacre.Chronicle and Blackacre.Chronicle.Capture and Blackacre.Chronicle.Capture.AddEntry then
            Blackacre.Chronicle.Capture.AddEntry("BULLETIN", {
                title = bulletin.title,
                promptTitle = bulletin.title or "A notice",
                promptBody = bulletin.bodyText or "",
                playerChose = true,
            }, "manual")
            Blackacre.Print("Copied to your journal.")
        end
    end)
    if (not bulletin.bodyText or bulletin.bodyText == "") and bulletin.senderName and Blackacre.Comms then
        Blackacre.Comms.RequestBulletinFull(bulletin.senderName, bulletin.id)
    end
    f:Show()
end

function Blackacre.InnBoard.ShowPostings()
    local f = EnsureList()
    listed = CachedBulletinsForHere()
    local _, name = Blackacre.Boards.CurrentZoneKey()
    f.title:SetText((name or "Inn") .. " postings")
    for i = 1, 8 do
        local row = rows[i]
        local b = listed[i]
        if b then
            row.text:SetText(b.title or "Bulletin")
            row:Show()
            row:SetScript("OnClick", function()
                ShowDetail(b)
            end)
        else
            row:Hide()
        end
    end
    if #listed == 0 then
        rows[1].text:SetText("There are zero notices active")
        rows[1]:Show()
        rows[1]:SetScript("OnClick", nil)
    end
    f:Show()
end

function Blackacre.InnBoard.OnBulletinDiscovered(bulletin)
    if not bulletin then return end
    local p = Blackacre.Lifecycle.EnsurePresenceDB()
    if p.seekingEnabled == false then return end
    local key, name = Blackacre.Boards.CurrentZoneKey()
    if not Blackacre.Boards.BulletinMatchesZone(bulletin, key, name) then return end
    local today = date("%Y-%m-%d")
    p.innToastDay = p.innToastDay or {}
    if p.innToastDay[key] == today then return end
    p.innToastDay[key] = today
    if Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.Toast then
        Blackacre.UI.Theme.Toast("There are postings and news at the inns around here")
    else
        Blackacre.Print("There are postings and news at the inns around here")
    end
end

function Blackacre.InnBoard.OnBulletinFullReceived(bulletin)
    if detailFrame and detailFrame:IsShown() and detailFrame.bulletin and bulletin and detailFrame.bulletin.id == bulletin.id then
        ShowDetail(bulletin)
    end
end

local function MaybeZoneToast()
    local p = Blackacre.Lifecycle and Blackacre.Lifecycle.EnsurePresenceDB and Blackacre.Lifecycle.EnsurePresenceDB()
    if not p or p.seekingEnabled == false then return end
    local list = CachedBulletinsForHere()
    if #list == 0 then return end
    local key = Blackacre.Boards.CurrentZoneKey()
    local today = date("%Y-%m-%d")
    p.innToastDay = p.innToastDay or {}
    if p.innToastDay[key] == today then return end
    p.innToastDay[key] = today
    if Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.Toast then
        Blackacre.UI.Theme.Toast("There are postings and news at the inns around here")
    end
end

function Blackacre.InnBoard.Init()
    local f = CreateFrame("Frame")
    f:RegisterEvent("GOSSIP_SHOW")
    f:RegisterEvent("GOSSIP_CLOSED")
    f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:SetScript("OnEvent", function(_, event)
        if event == "ZONE_CHANGED_NEW_AREA" or event == "PLAYER_ENTERING_WORLD" then
            C_Timer.After(1, MaybeZoneToast)
            return
        end
        if event == "GOSSIP_CLOSED" then
            if seeBtn then seeBtn:Hide() end
            return
        end
        if not IsInnkeeperGossip() then
            if seeBtn then seeBtn:Hide() end
            return
        end
        local gossip = GossipFrame or _G.GossipFrame
        if not gossip then return end
        if not seeBtn then
            seeBtn = CreateFrame("Button", "BlackacreSeePostingsButton", gossip, "UIPanelButtonTemplate")
            seeBtn:SetSize(120, 22)
            seeBtn:SetText("See Postings")
            seeBtn:SetScript("OnClick", function()
                Blackacre.InnBoard.ShowPostings()
            end)
        end
        seeBtn:ClearAllPoints()
        local complete = GossipFrameReady or gossip.GreetingPanel
        seeBtn:SetParent(gossip)
        seeBtn:SetPoint("BOTTOMLEFT", gossip, "BOTTOMLEFT", 16, 16)
        seeBtn:SetFrameLevel((gossip:GetFrameLevel() or 1) + 20)
        seeBtn:Show()
    end)
end
