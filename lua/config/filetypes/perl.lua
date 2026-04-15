return {
  name = 'perl',
  repl = {
    command = 'perlconsole'
  },
  lsp = {
    {
      'perlls',
    },
    {
      'perlnavigator',
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
