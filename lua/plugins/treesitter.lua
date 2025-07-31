return {
  "nvim-treesitter/nvim-treesitter",
  branch = 'master',
  lazy = false,
  build = ":TSUpdate",
  config = function ()
    require'nvim-treesitter.configs'.setup {
      ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", 'python', 'r' },
      sync_install = false,
      auto_install = true,
      ignore_install = { "javascript" },
      highlight = {
        enable = true
      },
    }
  end
}
