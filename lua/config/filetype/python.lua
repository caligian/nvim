return {
  lsp = {
    ruff = {
      init_options = {
        settings = {
          configuration = os.getenv("HOME") .. '/ruff.toml',
        }
      }
    },
    jedi_language_server = {}
  },
  repl = {
    command = 'ipython',
    input = {
      file = {
        use = true,
        format = 'load -y %s\r\n',
      },
      cd = 'import os; os.chdir("%s")',
    }
  }
}
