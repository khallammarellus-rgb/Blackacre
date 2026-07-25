InCharacter = InCharacter or {}
InCharacter.MinimapButton = {}

local ldb = LibStub("LibDataBroker-1.1")
local icon = LibStub("LibDBIcon-1.0")

local unread = 0

function InCharacter.MinimapButton.Init()
    local dataObj = ldb:NewDataObject("InCharacter", {
        type = "launcher",
        icon = "Interface\\Icons\\INV_Misc_Book_09",
        OnClick = function(_, button)
            if button == "RightButton" then
                if IsShiftKeyDown() then
                    if InCharacter.PostEditor and InCharacter.PostEditor.ShowBeaconEditor then
                        InCharacter.PostEditor.ShowBeaconEditor()
                    else
                        InCharacter.Print("Enable In Character Presence for beacons.")
                    end
                else
                    if InCharacter.Chronicle and InCharacter.Chronicle.UI then
                        InCharacter.Chronicle.UI.Toggle()
                    else
                        InCharacter.Print("Enable In Character Tome for the journal.")
                    end
                end
            else
                if InCharacter.Flyout and InCharacter.Flyout.Toggle then
                    InCharacter.Flyout.Toggle()
                else
                    InCharacter.Print("Enable In Character Presence for the presence panel.")
                end
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("In Character")
            tooltip:AddLine("Left-click: Presence (beacons & bulletins)", 1, 1, 1)
            tooltip:AddLine("Right-click: Tome (chronicle)", 1, 1, 1)
            tooltip:AddLine("Shift+Right-click: emit beacon", 0.8, 0.8, 0.8)
            if unread > 0 then
                tooltip:AddLine(unread .. " new nearby", 0.8, 0.7, 0.2)
            end
        end,
    })

    if not InCharacterDB.minimap then
        InCharacterDB.minimap = { hide = false }
    end
    icon:Register("InCharacter", dataObj, InCharacterDB.minimap)
end

function InCharacter.MinimapButton.Notify()
    unread = unread + 1
end

function InCharacter.MinimapButton.ClearNotify()
    unread = 0
end

function InCharacter.MinimapButton.GetUnread()
    return unread
end
