return {
  name = 'r',
  repl = {command = 'R'},
  autocmds = {
    disable_diagnostics = function () vim.lsp.disable(0) end
  },
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
}
