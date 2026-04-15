return {
  "prichrd/netrw.nvim",
  config = function ()
    require("netrw").setup({
      icons = {
        symlink = '',
        directory = '',
        file = '',
      },
      use_devicons = true,
      mappings = {
        ['p'] = function(payload) print(vim.inspect(payload)) end,
      },
    })
  end
}
