return {
  "folke/persistence.nvim",
  opts = {
    dir = vim.fn.stdpath("state") .. "/sessions/",
    need = 1,
    branch = true,
  },
}
