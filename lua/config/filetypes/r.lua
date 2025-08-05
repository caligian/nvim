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
    disable_ts_indent = function (args)
      vim.cmd 'TSBufDisable indent'
    end,
  }
}
