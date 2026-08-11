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
            tooltip:AddLine("Right-click: Traveler’s Tome", 1, 1, 1)
            tooltip:AddLine("Shift+Right-click: emit beacon", 0.8, 0.8, 0.8)
            if unread > 0 then
                tooltip:AddLine(unread .. " new nearby", 0.8, 0.7, 0.2)
            end
        end,
    })

    if not BlackacreDB.minimap then
        BlackacreDB.minimap = { hide = false }
    end
    icon:Register("Blackacre", dataObj, BlackacreDB.minimap)
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
