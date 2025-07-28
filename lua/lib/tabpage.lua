local tabpage = {}
user_config.tabpage = tabpage

tabpage.del_var = vim.api.nvim_tabpage_del_var
tabpage.set_var = vim.api.nvim_tabpage_set_var
tabpage.get_win = vim.api.nvim_tabpage_get_win
tabpage.set_win = vim.api.nvim_tabpage_set_win
tabpage.is_valid = vim.api.nvim_tabpage_is_valid
tabpage.list_wins = vim.api.nvim_tabpage_list_wins
tabpage.list_bufs = vim.fn.tabpagebuflist
tabpage.winnr = vim.fn.tabpagewinnr

return tabpage
