-- Blackacre options (AceConfig + AceDB profile for UI prefs only).
-- Feature data stays in BlackacreDB / BlackacreCharDB until a later migration.

local addonName, _ = ...
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceDBOptions = LibStub("AceDBOptions-3.0")

Blackacre = Blackacre or {}
Blackacre.Options = Blackacre.Options or {}

local function L(key)
    local locale = Blackacre.L
    if locale and locale[key] then
        return locale[key]
    end
    return key
end

local function BuildOptions()
    return {
        type = "group",
        name = L("OPTIONS_TITLE"),
        args = {
            desc = {
                type = "description",
                name = L("OPTIONS_DESC"),
                order = 1,
                fontSize = "medium",
            },
            general = {
                type = "group",
                name = "General",
                order = 2,
                inline = true,
                args = {
                    minimap = {
                        type = "toggle",
                        name = L("OPT_MINIMAP"),
                        desc = L("OPT_MINIMAP_DESC"),
                        order = 1,
                        get = function()
                            return not (Blackacre.db and Blackacre.db.profile.minimap.hide)
                        end,
                        set = function(_, v)
                            if not Blackacre.db then return end
                            Blackacre.db.profile.minimap.hide = not v
                            if Blackacre.MinimapButton and Blackacre.MinimapButton.Refresh then
                                Blackacre.MinimapButton.Refresh()
                            end
                        end,
                    },
                    quiet = {
                        type = "toggle",
                        name = L("OPT_QUIET"),
                        desc = L("OPT_QUIET_DESC"),
                        order = 2,
                        get = function()
                            return Blackacre.db and Blackacre.db.profile.quietNotifications
                        end,
                        set = function(_, v)
                            if not Blackacre.db then return end
                            Blackacre.db.profile.quietNotifications = v and true or false
                            -- Mirror into char settings for existing toast code paths
                            if Blackacre.CharDB and Blackacre.CharDB.settings then
                                Blackacre.CharDB.settings.quietNotifications = v and true or false
                            end
                        end,
                    },
                },
            },
            profiles = {
                type = "group",
                name = L("OPT_PROFILES"),
                order = 90,
                childGroups = "tab",
                args = {}, -- filled after AceDB exists
            },
        },
    }
end

function Blackacre.Options.Init(addon)
    if not addon or not Blackacre.db then return end

    local options = BuildOptions()
    options.args.profiles = AceDBOptions:GetOptionsTable(Blackacre.db)
    options.args.profiles.order = 90

    AceConfig:RegisterOptionsTable("Blackacre", options)
    AceConfigDialog:AddToBlizOptions("Blackacre", L("OPTIONS_TITLE"))

    -- /ba config
    if addon.RegisterChatCommand then
        addon:RegisterChatCommand("ba_config", function()
            AceConfigDialog:Open("Blackacre")
        end)
    end
end

function Blackacre.Options.Open()
    AceConfigDialog:Open("Blackacre")
end
