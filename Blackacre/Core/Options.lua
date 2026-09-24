-- Blackacre options (AceConfig + AceDB profile).
-- The active AceDB profile contains both UI preferences and character data.

local addonName, _ = ...
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

Blackacre = Blackacre or {}
Blackacre.Options = Blackacre.Options or {}

local function L(key)
    local locale = Blackacre.L
    if locale and locale[key] then
        return locale[key]
    end
    return key
end

local function GetProfileSettings()
    return Blackacre.GetProfileSettings and Blackacre.GetProfileSettings() or nil
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
                            local p = GetProfileSettings()
                            return not (p and p.minimap and p.minimap.hide)
                        end,
                        set = function(_, v)
                            local p = GetProfileSettings()
                            if not p then return end
                            p.minimap = p.minimap or {}
                            p.minimap.hide = not v
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
                            local p = GetProfileSettings()
                            return p and p.quietNotifications
                        end,
                        set = function(_, v)
                            local p = GetProfileSettings()
                            if not p then return end
                            p.quietNotifications = v and true or false
                            if Blackacre.CharDB and Blackacre.CharDB.settings then
                                Blackacre.CharDB.settings.quietNotifications = v and true or false
                            end
                        end,
                    },
                    chromeSkin = {
                        type = "select",
                        name = "Tome skin",
                        desc = "Art only (outer shell, TOC tab, rail, Backstory chrome, TOC title caps). Does not change buttons, pages, or journal behavior. Auto follows your faction.",
                        order = 4,
                        values = {
                            auto = "Auto (character faction)",
                            Alliance = "Alliance",
                            Horde = "Horde",
                            Dragonflight = "Dragonflight",
                            Metal = "Metal",
                            Kyrian = "Kyrian",
                            Seafarer = "Seafarer",
                            Workshop = "Workshop",
                            Scholomance = "Scholomance",
                            Tavern = "Tavern",
                            Skyborne = "Skyborne",
                            Slate = "Slate",
                            Ornate = "Ornate",
                            Ironforge = "Ironforge",
                            Forsaken = "Forsaken",
                            Void = "Void",
                        },
                        sorting = {
                            "auto", "Alliance", "Horde", "Dragonflight", "Metal",
                            "Kyrian", "Seafarer", "Workshop", "Scholomance", "Tavern",
                            "Skyborne", "Slate", "Ornate", "Ironforge", "Forsaken",
                            "Void",
                        },
                        get = function()
                            local p = GetProfileSettings()
                            return (p and p.chromeSkin) or "auto"
                        end,
                        set = function(_, key)
                            if Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.SetActiveSkin then
                                Blackacre.UI.Theme.SetActiveSkin(key)
                            elseif GetProfileSettings() then
                                GetProfileSettings().chromeSkin = key
                            end
                        end,
                    },
                    survival = {
                        type = "toggle",
                        name = "Survival tracking",
                        desc = "When unchecked, survival stats will run but no longer be tracked for a simpler experience.",
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
                name = "Journal Settings",
                order = 3,
                inline = true,
                args = {
                    bodyFont = {
                        type = "select",
                        name = "Journal Fonts",
                        desc = "Only affects editable text and main headers",
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
                            local p = GetProfileSettings()
                            if p and p.bodyFontKey then
                                return p.bodyFontKey
                            end
                            if Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.Fonts then
                                return Blackacre.UI.Theme.Fonts.activeKey or "default"
                            end
                            return "default"
                        end,
                        set = function(_, key)
                            if Blackacre.UI and Blackacre.UI.Theme and Blackacre.UI.Theme.SetBodyFontKey then
                                Blackacre.UI.Theme.SetBodyFontKey(key, false)
                            elseif GetProfileSettings() then
                                GetProfileSettings().bodyFontKey = key
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
                    promptEveryQuest = {
                        type = "toggle",
                        name = "Active Journaling",
                        desc = "Journals every quest turn in.",
                        order = 3,
                        get = function()
                            local s = Blackacre.CharDB and Blackacre.CharDB.settings
                            if s and s.promptEveryQuest ~= nil then
                                return s.promptEveryQuest and true or false
                            end
                            return Blackacre.Compat and Blackacre.Compat.IsForever and Blackacre.Compat.IsForever()
                        end,
                        set = function(_, v)
                            Blackacre.CharDB = Blackacre.CharDB or {}
                            Blackacre.CharDB.settings = Blackacre.CharDB.settings or {}
                            Blackacre.CharDB.settings.promptEveryQuest = v and true or false
                        end,
                    },
                },
            },
            profiles = {
                type = "group",
                name = L("OPT_PROFILES"),
                order = 90,
                args = {
                    note = {
                        type = "description", order = 1,
                        name = "A profile holds the full Blackacre character record and settings. Switching is live: characters assigned to the same profile share its tome. Creating a profile makes a separate copy of the current one. No merge, reset, or delete controls are provided here.\n",
                        fontSize = "medium",
                    },
                    active = {
                        type = "select", name = "Active profile", order = 2,
                        values = function()
                            local values = {}
                            if Blackacre.db then
                                for _, profile in ipairs(Blackacre.GetProfiles()) do
                                    values[profile.id] = profile.name
                                end
                            end
                            return values
                        end,
                        get = function()
                            return Blackacre.db and Blackacre.db:GetCurrentProfile() or Blackacre.ActiveProfileID
                        end,
                        set = function(_, id)
                            if not Blackacre.SetActiveProfile(id) then
                                Blackacre.Print("That profile could not be opened; your current profile is unchanged.")
                            end
                        end,
                    },
                    newName = {
                        type = "input", name = "New profile name", order = 3,
                        get = function() return Blackacre._newProfileName or "" end,
                        set = function(_, value) Blackacre._newProfileName = strtrim(value or "") end,
                    },
                    create = {
                        type = "execute", name = "Create copy of current profile", order = 4,
                        func = function()
                            local name = strtrim(Blackacre._newProfileName or "")
                            if name == "" then Blackacre.Print("Enter a profile name first."); return end
                            if #name > 48 then Blackacre.Print("Profile names must be 48 characters or fewer."); return end
                            local profile = Blackacre.CreateProfile(name)
                            if not profile then Blackacre.Print("That profile name is invalid or already in use; nothing was changed."); return end
                            Blackacre._newProfileName = ""
                            Blackacre.Print("Created a separate copy named " .. name .. ".")
                        end,
                    },
                    export = {
                        type = "execute", name = "Export full profile backup", order = 5,
                        func = function()
                            if Blackacre.Share and Blackacre.Share.Export then
                                Blackacre.Share.Export.CopyFullProfile()
                            else
                                Blackacre.Print("Enable Blackacre Tome to export a profile backup.")
                            end
                        end,
                    },
                },
            },
        },
    }
end

function Blackacre.Options.Init(addon)
    if not addon or not Blackacre.db then return end

    local options = BuildOptions()
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
