return {
  name = 'r',
  repl = { command = 'R' },
  buffer = {
    opt = { shiftwidth = 2, tabstop = 2, expandtab = true },
  },
  lsp = { r_language_server = {} },
  autocmd = {
    indent = function()
      vim.b.r_indent_align_args = 1
    end,
    disable_diagnostics = function(args)
      vim.diagnostic.config {
        virtual_text = false,
        signs = false,
        underline = false,
        bufnr = args.buf,
      }
    end
  },
}
