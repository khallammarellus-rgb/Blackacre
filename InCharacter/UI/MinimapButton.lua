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
                    InCharacter.PostEditor.ShowBeaconEditor()
                else
                    InCharacter.Chronicle.UI.Toggle()
                end
            else
                InCharacter.Flyout.Toggle()
            end
        end,
        OnTooltipShow = function(tooltip)
            tooltip:AddLine("In Character")
            tooltip:AddLine("Left-click: discovery flyout", 1, 1, 1)
            tooltip:AddLine("Right-click: traveler's chronicle", 1, 1, 1)
            tooltip:AddLine("Shift+Right-click: broadcast beacon", 0.8, 0.8, 0.8)
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