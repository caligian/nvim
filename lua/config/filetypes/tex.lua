local nvim = require 'nvim-utils.nvim'
local buffer = user_config.buffer

local function insert_env(env_name)
  local function put_lines(name)
    pcall(function()
      local buffer = user_config.buffer
      vim.cmd(sprintf('normal! o'))
      local linenum = buffer.get_linenum(vim.fn.bufnr())
      vim.api.nvim_buf_set_lines(0, linenum, linenum, false, {
        sprintf("\\begin{%s}", name),
        sprintf("\\end{%s}", name)
      })
      vim.cmd(sprintf('?\\\\begin'))
      vim.cmd('normal! vj=')
      vim.cmd(sprintf('normal! %dG', linenum + 3))
      vim.cmd('normal! dd')
      vim.cmd('normal! kk')
    end)
  end

  if not env_name then
    vim.ui.input({
      prompt = 'Environment name % ',
      default = '',
    }, function(s)
      if s and #s > 0 then
        put_lines(string.trim(s))
      end
    end)
  else
    put_lines(env_name)
  end
end

local put_item = function()
  vim.cmd("normal! o")
  vim.api.nvim_put({ "\\item  " }, "c", true, true)
  vim.cmd("normal! ==")
  vim.cmd("normal! $")
end

local insert_enum = function()
  insert_env('enumerate')
end

local insert_items = function()
  insert_env('itemize')
end

local next_main_section = function()
  buffer.find_below_and_goto(buffer.current(), true, "\\section%*?")
end

local prev_main_section = function()
  buffer.find_above_and_goto(buffer.current(), true, "\\section%*?")
end

local next_section = function()
  buffer.find_below_and_goto(buffer.current(), true, "\\[a-z]*section%*?")
end

local prev_section = function()
  buffer.find_above_and_goto(buffer.current(), true, "\\[a-z]*section%*?")
end

local next_env = function()
  pcall(function()
    vim.cmd '/\\\\begin'
  end)
end

local prev_env = function()
  pcall(function()
    vim.cmd '?\\\\begin'
  end)
end

local next_item = function()
  pcall(function()
    vim.cmd '/\\\\item'
  end)
end

local prev_item = function()
  pcall(function()
    vim.cmd '?\\\\item'
  end)
end

local mark_env = function()
  local buf = buffer.current()
  local line = buffer.current_line(buf)
  local ind = string.find(line, '\\[a-zA-Z0-9_*]+%{')
  local normal = nvim.normal

  if ind == nil then
    return
  end

  normal("0", sprintf("%dl", ind), "f{v%o")
end

local make_bib = function ()
  nvim.command()
end

local topdf = function()
  vim.cmd [[ ! pdflatex % ]]
end

local tex2pdf = function(bufname)
  bufname = bufname:gsub("[.]tex$", ".pdf")
  return bufname
end

local topdf_and_open = function()
  local bufname = buffer.name(buffer.current())
  local cmd = '! pdflatex ' .. bufname .. ' && evince ' .. tex2pdf(bufname)
  vim.cmd(cmd)
end

local open = function()
  local bufname = buffer.name(buffer.current())
  vim.cmd(sprintf([[ ! evince %s ]], tex2pdf(bufname)))
end

return {
  name = 'tex',
  lsp = { "texlab" },
  buffer = {
    opts = {
      wrapmargin = 0,
      formatoptions = vim.o.formatoptions .. 't',
      textwidth = 80,
    }
  },
  keymaps = {
    insert_env = { 'n', '<space>ie', insert_env, { desc = 'Insert env' } },
    insert_enum = { 'n', '<space>il', insert_enum, { desc = 'Insert list env' } },
    insert_items = { 'n', '<space>ii', insert_items, { desc = 'Insert items env' } },
    insert_item = { { 'i', 'n' }, '<M-j>', put_item, { desc = 'Insert item on next line' } },

    mark_env = { 'n', '<space>%', mark_env, { desc = 'Visually mark environment' } },

    toggle_toc = { 'n', '<C-t>', '<plug>(vimtex-toc-toggle)', { desc = 'Toggle table of contents' } },
    open_toc = { 'n', '<C-z>', '<plug>(vimtex-toc-open)', { desc = 'Open table of contents' } },

    next_main_section = { { 'i', 'v', 'n' }, "<C-M-e>", next_main_section, { desc = 'Goto next \\section' } },
    prev_main_section = { { 'i', 'v', 'n' }, '<C-M-a>', prev_main_section, { desc = 'Goto prev \\section' } },
    next_section = { { 'i', 'v', 'n' }, "<C-M-n>", next_section, { desc = 'Goto next \\*section' } },
    prev_section = { { 'i', 'v', 'n' }, '<C-M-p>', prev_section, { desc = 'Goto prev \\*section' } },
    next_env = { { 'i', 'v', 'n' }, "<M-n>", next_env, { desc = 'Goto next env' } },
    prev_env = { { 'i', 'v', 'n' }, '<M-p>', prev_env, { desc = 'Goto prev env' } },
    next_item = { { 'i', 'v', 'n' }, "<M-f>", next_item, { desc = 'Goto next item' } },
    prev_item = { { 'i', 'v', 'n' }, '<M-b>', prev_item, { desc = 'Goto prev item' } },

    topdf = { 'n', '<space>cp', topdf, { desc = 'To PDF' } },
    topdf_and_open = { 'n', '<space>cP', topdf_and_open, { desc = 'To PDF and preview (blocking)' } },
    preview = { 'n', "<space>co", open, { desc = 'Preview file (blocking)' } },
  }
}
