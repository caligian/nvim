require 'lua-utils.string'

return {
  repl = { command = 'luajit' },
  buffer = {
    opt = { shiftwidth = 2, softtabstop = 2, tabstop = 2, expandtab = true },
  },
  lsp = {
    lua_ls = {
      settings = {
        Lua = {
          runtime = { version = 'LuaJIT' },
          diagnostics = {
            globals = {
              "vim", "apply", "as_list", "assertf", "assert_type", "assert_unless", "assert_when", "bless", "callable",
              "defined", "dump", "equals", "errorf", "identity", "inspect", "invert", "is_falsy", "is_truthy", "L",
              "literal", "partial", "paste", "paste0", "pp", "printf", "readlines", "rpartial", "slurp", "spit",
              "sprintf", "thread", "undefined", "unless", "unless_falsy", "unless_nil", "unless_truthy", "unpack", "when",
              "when_falsy", "when_nil", "when_truthy", "writelines", "system", "systemlist", "user_config", "user_state",
              "basename", "dirname", "buffer", "autocmd", "keymap", "buffer_group", "nvim", "augroup", "filetype",
              'class', 'metatable',
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
            library = {
              vim.env.VIMRUNTIME,
              vim.fn.expand("$HOME/lua_modules/share/lua/5.1"),
              vim.fn.expand("$HOME/lua_modules/lib/lua/5.1"),
              vim.fn.expand("$HOME/.config/nvim/lua/lua-utils"),
              vim.fn.expand("$HOME/.config/nvim/lua/nvim-utils"),
            },
          },
          telemetry = { enable = false },
        },
      },
    }
  }
}
