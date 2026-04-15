return {
  name = 'elixir',
  lsp = {
    'elixirls',
    cmd = {'elixir-ls'},
    root_dir = function (bufnr)
      return user_config.buffer.workspace(bufnr)
    end
  },
  repl = {
    command = 'iex',
  }
}
