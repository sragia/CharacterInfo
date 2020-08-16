local configDB = Exlist.ConfigDB
local L = Exlist.L
Exlist.accountSync = {
    init = function()
        configDB = Exlist.ConfigDB
        configDB.accountSync = Exlist.AddMissingTableEntries(
                                   configDB.accountSync or {},
                                   {enabled = false, pairedCharacters = {}})
    end
}

local function getPairedCharOptions(startOrder)
    local pairedCharacters = configDB.accountSync.pairedCharacters
    local options = {}
    if (pairedCharacters) then
        local order = startOrder
        for character, info in pairs(pairedCharacters) do
            options[character .. "name"] =
                {
                    order = order + 0.1,
                    type = "description",
                    name = character,
                    width = 1
                }
            options[character .. "account"] =
                {
                    order = order + 0.2,
                    type = "description",
                    name = string.format(L["Account %s"], info.accountID),
                    width = 0.5
                }
            options[character .. "status"] =
                {
                    order = order + 0.3,
                    type = "description",
                    name = info.status,
                    width = 0.4
                }
            options[character .. "syncbtn"] =
                {
                    order = order + 0.4,
                    type = "execute",
                    name = L["Sync"],
                    func = function()
                        Exlist.accountSync.syncData(character)
                    end,
                    width = 0.5
                }
            order = order + 1
        end
    end
    return options
end

local function AddOptions(refresh)
    local settings = configDB.settings
    local tmpConfigs = {}
    local options = {
        type = "group",
        name = L["Account Sync - (Alpha)"],
        args = {
            desc = {
                type = "description",
                order = 0,
                width = "full",
                fontSize = "medium",
                name = L["Alpha version - Use at your own discretion"]
            },
            desc2 = {
                type = "description",
                order = 1,
                width = "full",
                fontSize = "medium",
                name = L["Allow sharing character data across multiple accounts"]
            },
            toggle = {
                type = "toggle",
                name = L["Enable"],
                order = 2,
                width = "full",
                get = function()
                    return configDB.accountSync.enabled
                end,
                set = function(_, value)
                    configDB.accountSync.enabled = value
                end
            },
            userKey = {
                type = "input",
                order = 3.1,
                name = L["User Key"],
                get = function()
                    return configDB.accountSync.userKey
                end,
                set = function(_, v)
                    configDB.accountSync.userKey = v
                end,
                width = "normal"
            },
            generateUserKey = {
                type = "execute",
                order = 3.2,
                name = L["Generate User Key"],
                func = function()
                    configDB.accountSync.userKey =
                        Exlist.GenerateRandomString(6)
                end,
                width = "normal"
            },
            spacer1 = {
                type = "description",
                order = 3.9,
                name = "",
                width = "normal"
            },
            characterName = {
                type = "input",
                order = 4.1,
                name = L["Character To Sync With"],
                get = function() return tmpConfigs.charToSync end,
                set = function(_, value)
                    tmpConfigs.charToSync = value
                end,
                width = "normal"

            },
            characterNameExecute = {
                type = "execute",
                order = 4.2,
                name = L["Sync"],
                disabled = function()
                    return
                        not (tmpConfigs.charToSync and tmpConfigs.charToSync ~=
                            "")
                end,
                func = function()
                    print(tmpConfigs.charToSync)
                    Exlist.accountSync.pairAccount(tmpConfigs.charToSync,
                                                   configDB.accountSync.userKey)
                end,
                width = "normal"
            },
            pairedCharGroup = {
                type = "group",
                order = 10,
                name = L["Paired Characters"],
                args = getPairedCharOptions(1)
            }
        }
    }
    if refresh then
        Exlist.RefreshModuleOptions('accountsync', options,
                                    L["Account Sync - Alpha"])
    else
        Exlist.AddModuleOptions('accountsync', options,
                                L["Account Sync - Alpha"])
    end
end
Exlist.ModuleToBeAdded(AddOptions)

Exlist.accountSync.AddOptions = AddOptions
