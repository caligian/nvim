return {
  name = 'perl',
  buffer = {
    opt = {
      shiftwidth = 2,
      softtabstop = 2,
      tabstop = 2,
      expandtab = true,
    },
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
