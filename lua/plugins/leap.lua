return {
	"ggandor/leap.nvim",
	config = function()
    vim.keymap.set({'n', 'x', 'o'}, 's',  '<Plug>(leap-forward)')
    vim.keymap.set({'n', 'x', 'o'}, '<A-s>',  '<Plug>(leap-backward)')
  end,
	opts = {}
}
