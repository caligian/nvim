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
    -- {
    --   'basedpyright',
    --   settings = {
    --     basedpyright = {
    --       analysis = {
    --         typeCheckingMode = "off",
    --         diagnosticMode = "openFilesOnly",
    --         autoSearchPaths = true,
    --         useLibraryCodeForTypes = true,
    --       },
    --     },
    --   },
    --   init_options = {
    --     settings = {
    --       basedpyright = {
    --         analysis = {
    --           typeCheckingMode = "off",
    --           diagnosticMode = "openFilesOnly",
    --           autoSearchPaths = true,
    --           useLibraryCodeForTypes = true,
    --         },
    --       },
    --     }
    --   },
    --   on_attach = function(client, _bufnr)
    --     client.server_capabilities.diagnosticProvider = false
    --   end,
    -- }
  },
  repl = {
    command = 'ipython',
    input = {
      use_file = true,
      file_string = 'load -y %s\r\n',
    }
  }
}

