return {
  name = 'python',
  lsp = {
    {
      'ruff',
      init_options = {
        settings = {
          configuration = os.getenv("HOME") .. '/ruff.toml',
        }
      },
    },
    { 'jedi_language_server' }
  },
  repl = {
    command = 'ipython',
    input = {
      use_file = true,
      file_string = 'load -y %s\r\n',
    }
  }
}
