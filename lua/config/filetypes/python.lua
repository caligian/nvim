return {
  name = 'python',
  lsp = {
    {'ruff'},
    {'jedi_language_server'}
  },
  repl = {
    command = 'ipython3',
    input = {
      use_file = true,
      file_string = 'load -y %s\r\n',
    }
  }
}
