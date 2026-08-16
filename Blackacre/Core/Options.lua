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
                            if Blackacre.CharDB and Blackacre.CharDB.settings then
                                Blackacre.CharDB.settings.quietNotifications = v and true or false
                            end
                        end,
                    },
                    survival = {
                        type = "toggle",
                        name = "Survival tracking",
                        desc = "When off, hunger/thirst/exposure stop decaying and no longer update the journal.",
                        order = 3,
                        get = function()
                            local s = Blackacre.CharDB and Blackacre.CharDB.survival
                            if s and s.enabled == false then return false end
                            return true
                        end,
                        set = function(_, v)
                            if Blackacre.Survival and Blackacre.Survival.Engine and Blackacre.Survival.Engine.SetEnabled then
                                Blackacre.Survival.Engine.SetEnabled(v and true or false)
                            else
                                Blackacre.CharDB = Blackacre.CharDB or {}
                                Blackacre.CharDB.survival = Blackacre.CharDB.survival or {}
                                Blackacre.CharDB.survival.enabled = v and true or false
                            end
                            if Blackacre.Survival and Blackacre.Survival.UI and Blackacre.Survival.UI.Refresh then
                                Blackacre.Survival.UI.Refresh()
                            end
                        end,
                    },
                },
            },
            journal = {
                type = "group",
                name = "Chronicle",
                order = 3,
                inline = true,
                args = {
                    bodyFont = {
                        type = "select",
                        name = "Journal body font",
                        desc = "Font for chronicle page body text and sticky notes only. Does not change titles, headers, or Backstory menus.",
                        order = 1,
                        values = function()
                            local t = {}
                            local cat = Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.GetBodyFontCatalog
                                and Blackacre.UI.Theme.GetBodyFontCatalog()
                                or {}
                            for _, row in ipairs(cat) do
                                t[row.key] = row.name
                            end
                            if not next(t) then
                                t.default = "Default (WoW mail)"
                            end
                            return t
                        end,
                        get = function()
                            if Blackacre.db and Blackacre.db.profile and Blackacre.db.profile.bodyFontKey then
                                return Blackacre.db.profile.bodyFontKey
                            end
                            if Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.Fonts then
                                return Blackacre.UI.Theme.Fonts.activeKey or "default"
                            end
                            return "default"
                        end,
                        set = function(_, key)
                            if Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.SetBodyFontKey then
                                Blackacre.UI.Theme.SetBodyFontKey(key, false)
                            elseif Blackacre.db and Blackacre.db.profile then
                                Blackacre.db.profile.bodyFontKey = key
                            end
                        end,
                    },
                    bodyFontNote = {
                        type = "description",
                        order = 2,
                        name = "Body + sticky notes only (not titles or Backstory menus).\n"
                            .. "|cffffcc00Empty boxes?|r That font lacks those characters. Prefer Default / Friz / Skurri / Morpheus for full text.\n"
                            .. "Hobbiton & Middle Earth are decorative; symbols like | are rewritten as plain text (WoW cannot mix two fonts in one line).",
                        fontSize = "medium",
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
