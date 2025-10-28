require 'lua-utils.string'
local list = require 'lua-utils.list'
local path = require 'lua-utils.path_utils'
local usr_share_dir = '/usr/share/lua/5.1'
local home_dir = path(os.getenv('HOME'), '.luarocks', 'share', 'lua', '5.1')
local workspaces = list.filter(list.extend(
  path.glob(usr_share_dir .. '/*'),
  path.glob(home_dir .. '/*')
), path.is_dir)
list.append(workspaces, '/usr/share/lua/5.1', home_dir)

return {
  name = 'lua',
  repl = { command = 'luajit' },
  buffer = {
    opts = {
      shiftwidth = 2,
      tabstop = 2,
      expandtab = true,
    }
  },
  lsp = {
    'lua_ls',
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
          path = string.split(os.getenv("LUA_PATH"), ";"),
        },
        diagnostics = {
          globals = {
            'vim', 'user_config',
            'printf', 'sprintf', 'pp', 'inspect',
            'ifelse', 'ifnil', 'ifnonnil',
            'apply', 'unless',
            'partial', 'rpartial',
            'thread', 'identity',
            'spit', 'slurp',
            'readlines', 'writelines',
          },
          disable = {
            'cast-local-type',
            'missing-fields',
            'lowercase-global',
            'unused-vararg',
            'need-check-nil',
            'assign-type-match',
            'param-type-mismatch',
            'inject-field',
            'redundant-parameter',
          }
        },
        workspace = {
          library = list.extend(
            vim.api.nvim_get_runtime_file("", true),
            workspaces
          ),
        },
        telemetry = {
          enable = false,
        },
      },
    },
  }
}

