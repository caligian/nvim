local config_dir = vim.fn.stdpath('config')
local base_vim = config_dir .. '/base.vim'
vim.cmd(string.format(':source %s', base_vim))

vim.api.nvim_create_autocmd('ColorScheme', {
  pattern = '*',
  callback = function(_)
    if vim.o.background == 'dark' then
      vim.api.nvim_set_hl(0, "Normal", { fg = "#ffffff" })
      vim.api.nvim_set_hl(0, "Normal", { fg = "#ffffff" })
      vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'NONE' })
      vim.api.nvim_set_hl(0, "LineNr", { bg = "NONE", fg = "#ffffff" })
      vim.api.nvim_set_hl(0, "LineNrAbove", { bg = "NONE", fg = "#818181" })
      vim.api.nvim_set_hl(0, "LineNrBelow", { bg = "NONE", fg = "#818181" })
    end
  end
})

vim.api.nvim_create_autocmd(
  { 'VimEnter', 'UIEnter' },
  {
    pattern = '*',
    callback = function()
      user_config.theme()
      vim.api.nvim_set_hl(0, "Normal", { fg = "#ffffff" })
      vim.api.nvim_set_hl(0, "Normal", { fg = "#ffffff" })
      vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'NONE' })
      vim.api.nvim_set_hl(0, "LineNr", { bg = "NONE", fg = "#ffffff" })
      vim.api.nvim_set_hl(0, "LineNrAbove", { bg = "NONE", fg = "#818181" })
      vim.api.nvim_set_hl(0, "LineNrBelow", { bg = "NONE", fg = "#818181" })
    end
  }
)

local function unicode2ascii()
  local substitutions = {
    { '—', '--' },
    { '–', '-' },
    { '“', '"' },
    { '”', '"' },
    { '‘', "'" },
    { '’', "'" },
    { '‚', ',' },
    { '„', ',' },
    { '…', '...' },
    { '•', '*' },
    { '◦', 'o' },
    { '▪', '*' },
    { '×', 'x' },
    { '÷', '/' },
    { '±', '+/-' },
    { '≠', '!=' },
    { '≤', '<=' },
    { '≥', '>=' },
    { '≈', '~=' },
    { '∞', 'inf' },
    { '©', '(c)' },
    { '®', '(R)' },
    { '™', '(TM)' },
    { '½', '1/2' },
    { '¼', '1/4' },
    { '¾', '3/4' },
    { '⅓', '1/3' },
    { '⅔', '2/3' },
    { '²', '^2' },
    { '³', '^3' },
    { '¹', '^1' },
    { '€', 'EUR' },
    { '£', 'GBP' },
    { '¥', 'JPY' },
    { '₹', 'Rs' },
    { '§', 'S' },
    { '¶', 'P' },
    { '†', '+' },
    { '‡', '++' },
    { '•', '*' },
    { '\\u00A0', ' ' },
  }

  for _, sub in ipairs(substitutions) do
    pcall(vim.cmd, '%s/' .. sub[1] .. '/' .. sub[2] .. '/g')
  end

  pcall(vim.cmd, '%s/[^\\x00-\\x7F]//g')
  vim.cmd.noh()
end

-- Create a Vim command to call the function
vim.api.nvim_create_user_command('Unicode2Ascii', function()
  unicode2ascii()
end, { desc = "Convert UTF-8 chars to ascii equivalents" })

--- Setup everything
require('nvim-utils.setup')

vim.defer_fn(
  vim.schedule_wrap(function()
    user_config.theme()
    vim.api.nvim_set_hl(0, "Normal", { fg = "#ffffff" })
    vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'NONE' })
    vim.api.nvim_set_hl(0, "LineNr", { bg = "NONE", fg = "#ffffff" })
    vim.api.nvim_set_hl(0, "LineNrAbove", { bg = "NONE", fg = "#818181" })
    vim.api.nvim_set_hl(0, "LineNrBelow", { bg = "NONE", fg = "#818181" })
  end),
  300
)
