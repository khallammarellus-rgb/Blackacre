Blackacre = Blackacre or {}
Blackacre.MinimapButton = {}

local ldb = LibStub("LibDataBroker-1.1")
local icon = LibStub("LibDBIcon-1.0")

local unread = 0

function Blackacre.MinimapButton.Init()
    local dataObj = ldb:NewDataObject("Blackacre", {
        type = "launcher",
        icon = "Interface\\Icons\\INV_Misc_Book_09",
        OnClick = function(_, button)
            if button == "RightButton" then
                if IsShiftKeyDown() then
                    if Blackacre.PostEditor and Blackacre.PostEditor.ShowBeaconEditor then
                        Blackacre.PostEditor.ShowBeaconEditor()
                    else
                        Blackacre.Print("Enable Blackacre Presence for beacons.")
                    end
                else
                    if Blackacre.TomeHub and Blackacre.TomeHub.Toggle then
                        Blackacre.TomeHub.Toggle()
                    elseif Blackacre.Chronicle and Blackacre.Chronicle.UI then
                        Blackacre.Chronicle.UI.Toggle()
                    else
                        Blackacre.Print("Enable Blackacre Tome for the journal.")
                    end
                end
            else
                if Blackacre.Flyout and Blackacre.Flyout.Toggle then
                    Blackacre.Flyout.Toggle()
                else
                    Blackacre.Print("Enable Blackacre Presence for the presence panel.")
                end
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("Blackacre")
            tooltip:AddLine("Left-click: Presence (beacons & bulletins)", 1, 1, 1)
            tooltip:AddLine("Right-click: Traveler's Chronicle", 1, 1, 1)
            tooltip:AddLine("Shift+Right-click: emit beacon", 0.8, 0.8, 0.8)
            if unread > 0 then
                tooltip:AddLine(unread .. " new nearby", 0.8, 0.7, 0.2)
            end
        end,
    })

    -- Ensure a valid LibDBIcon table (hide must be boolean false to show)
    local minimapDB
    if Blackacre.db and Blackacre.db.profile then
        Blackacre.db.profile.minimap = Blackacre.db.profile.minimap or { hide = false }
        if Blackacre.db.profile.minimap.hide == nil then
            Blackacre.db.profile.minimap.hide = false
        end
        minimapDB = Blackacre.db.profile.minimap
    else
        BlackacreDB = BlackacreDB or {}
        BlackacreDB.minimap = BlackacreDB.minimap or { hide = false }
        if BlackacreDB.minimap.hide == nil then
            BlackacreDB.minimap.hide = false
        end
        minimapDB = BlackacreDB.minimap
    end
    -- Force visible on init unless user explicitly hid
    if minimapDB.hide ~= true then
        minimapDB.hide = false
    end
    if not icon:IsRegistered("Blackacre") then
        icon:Register("Blackacre", dataObj, minimapDB)
    else
        icon:Refresh("Blackacre", minimapDB)
    end
    icon:Show("Blackacre")
end

function Blackacre.MinimapButton.Refresh()
    local minimapDB = (Blackacre.db and Blackacre.db.profile and Blackacre.db.profile.minimap)
        or (BlackacreDB and BlackacreDB.minimap)
    if not minimapDB then
        icon:Show("Blackacre")
        return
    end
    if minimapDB.hide then
        icon:Hide("Blackacre")
    else
        icon:Show("Blackacre")
    end
end

function Blackacre.MinimapButton.Notify()
    unread = unread + 1
end

function Blackacre.MinimapButton.ClearNotify()
    unread = 0
end

function Blackacre.MinimapButton.GetUnread()
    return unread
end
