local copy = require 'lua-utils.copy'
local dict = require 'lua-utils.dict'
local validate = require 'lua-utils.validate'

---@class UserSettings
---@field name string
---@field o table<string,any>
---@field g table<string,any>
---@field current_config table
---@field previous_config table
local settings = bless {
    name = 'settings',
    o = {
        tabstop = 4,
        shiftwidth = 4,
        softtabstop = 4,
        expandtab = true,
        autoindent = true,
        autochdir = true,
        background = 'dark',
        cursorline = true,
        wildmenu = true,
        wildmode = 'longest:full,full',
        number = true,
        relativenumber = true,
    },
    g = {
        netrw_keepdir = 0,
    },
    current_config = {},
    previous_config = {},
    filetype = {},
}

---@class UserOverrides
---@field o table<string,any>
---@field g table<string,any>

---@param overrides? UserOverrides
---@return table
function settings:config(overrides)
    overrides = overrides or {}
    validate {
        opt_o = { 'table', overrides.o },
        opt_g = { 'table', overrides.g }
    }

    local g = copy.deep(self.g)
    local o = copy.deep(self.o)
    local global_config = { g = g, o = o }

    self.previous_config = copy.deep(self.current_config)
    self.current_config = copy.deep(overrides)

    return dict.merge(global_config, overrides, true)
end

function settings:setup(overrides)
    overrides = self:config(overrides)

    local function set_values(varname, tbl)
        for key, value in pairs(tbl) do
            vim[varname][key] = value
        end
    end

    set_values('o', overrides.o)
    set_values('g', overrides.g)

    self.previous_config = copy.deep(self.current_config)
    self.current_config = copy.deep(overrides)

    return overrides
end

user_config.utils.settings = settings
return settings
