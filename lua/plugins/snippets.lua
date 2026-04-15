return {
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  build = "make install_jsregexp",
  dependencies = { "rafamadriz/friendly-snippets" },
  config = function()
    local ls = require("luasnip")
    vim.keymap.set( {"i"}, "<A-/>", function() ls.expand() end, {silent = true})
    vim.keymap.set( {"i", "s"}, "<C-K>", function() ls.jump( 1) end, {silent = true})
    vim.keymap.set( {"i", "s"}, "<C-J>", function() ls.jump(-1) end, {silent = true})
    require("luasnip.loaders.from_vscode").lazy_load()
    require("luasnip.loaders.from_vscode").lazy_load({ paths = {os.getenv('HOME') .. '/.config/nvim/snippets'} })
  end
}
