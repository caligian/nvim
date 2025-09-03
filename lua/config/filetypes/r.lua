return {
  name = 'r',
  repl = {command = 'R'},
  buffer = {
    opts = {
      shiftwidth = 2,
      tabstop = 2,
      expandtab = true,
    }
  },
  lsp = {
    'r_language_server'
  },
  autocmds = {
    disable_ts_indent = function (_)
      vim.cmd 'TSBufDisable indent'
    end,
    disable_diagnostics = function(_)
      vim.diagnostic.config {
        virtual_text = false,
        signs = false,
        underline = false,
      }
    end
  }
}
