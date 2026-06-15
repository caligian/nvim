return {
  name = 'perl',
  repl = {
    command = 'perlconsole'
  },
  lsp = {
    perlpls = {},
    perlnavigator = {
      settings = {
        perlnavigator = {
          perlPath = 'perl',
          enableWarnings = true,
          perltidyProfile = '',
          perlcriticProfile = '',
          perlcriticEnabled = true,
        }
      }
    }
  }
}
