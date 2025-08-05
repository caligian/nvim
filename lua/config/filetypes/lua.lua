return {
  name = 'lua',
  repl = { command = 'luajit' },
  buffer = {
    opts = {
      shiftwidth = 2,
      tabstop = 2,
      expandtab = true
    }
  },
  lsp = {
    'lua_ls',
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
          path = {
            '?.lua',
            '?/init.lua'
          },
        },
        diagnostics = {
          globals = {
            'vim', 'user_config',
            'printf', 'sprintf', 'pp', 'inspect',
            'ifelse', 'ifnil', 'ifnonnil',
            'apply', 'unless',
            'partial', 'rpartial',
            'thread', 'identity',
          },
          disable = {
            'missing-fields',
            'lowercase-global',
            'unused-vararg',
            'need-check-nil',
            'assign-type-match',
            'param-type-mismatch',
            'inject-field',
          }
        },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
        },
        telemetry = {
          enable = false,
        },
      },
    },
  }
}
