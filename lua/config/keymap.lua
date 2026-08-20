local path = require 'lua-utils.path_utils'
local dict = require 'lua-utils.dict'

require 'nvim-utils.keymap'
require 'nvim-utils.buffer'
require 'nvim-utils.buffer_group'
require 'nvim-utils.filetype'
local nvim = require 'nvim-utils.nvim'
require 'nvim-utils.repl'
require 'nvim-utils.tabpage'

local recent_buffers = user_config.buffer.recent
local bg_utils = buffer_group.utils

local utils = { telescope = {} }
local telescope = utils.telescope
user_config.utils = utils

function telescope.make_opts(opts)
  opts = vim.deepcopy(opts or {})
  local theme = user_config.telescope.theme or {}
  ---@diagnostic disable-next-line
  local defaults = user_config.telescope.opts or {}

  dict.merge(opts, defaults)
  dict.merge(opts, theme)

  return opts
end

function telescope.get_builtin_picker(what, opts)
  return function()
    local builtin = require('telescope.builtin')
    local fn = builtin[what]
    if not fn then
      return
    else
      fn(telescope.make_opts(opts))
    end
  end
end

function utils.hide_diagnostics(overrides)
  local patched = dict.force_merge({
    virtual_text = false,
    signs = false,
    underline = false,
  }, overrides or {})
  vim.diagnostic.config(patched)
end

function utils.show_diagnostics(overrides)
  local patched = dict.force_merge({
    virtual_text = true,
    signs = true,
    underline = true,
  }, overrides or {})
  vim.diagnostic.config(patched)
end

function utils.get_root_dir(bufnr)
  bufnr = bufnr or buffer.get_current_id() or -1
  local ft
  local ok, msg = buffer.get_filetype(bufnr)

  if not ok then
    return
  else
    ft = msg
  end

  local ft_obj = user_config.filetype[ft]
  if not ft_obj then
    ft_obj = { pattern = { '.git' }, check_depth = 4 }
  else
    ft_obj = ft_obj.root
  end

  local pattern, check_depth = ft_obj.pattern, ft_obj.check_depth
  return buffer.get_root_dir(bufnr, pattern, check_depth)
end

function utils.insert_tab()
  return string.rep(" ", vim.bo.shiftwidth)
end

function utils.grep_project(live)
  return function()
    local proj = utils.get_root_dir()
    if not proj then
      return false
    end

    local proj_display = proj:gsub(os.getenv('HOME'), '~')
    local picker_name = live and 'live_grep' or 'grep_string'
    local prompt_title = live and 'Live grep workspace %s' or 'Grep workspace %s'
    local picker = telescope.get_builtin_picker(picker_name, {
      search_dirs = { proj },
      prompt_title = prompt_title:format(proj_display)
    })
    picker()
  end
end

function utils.grep_cwd(live)
  return function()
    local proj = path.getcwd()
    local proj_display = proj:gsub(os.getenv('HOME'), '~')
    local picker_name = live and 'live_grep' or 'grep_string'
    local prompt_title = live and 'Live grep %s' or 'Grep %s'
    local picker = telescope.get_builtin_picker(picker_name, {
      search_dirs = { proj },
      prompt_title = prompt_title:format(proj_display)
    })
    picker()
  end
end

function utils.browse_project()
  local proj = utils.get_root_dir()
  if not proj then
    return false
  end

  require("telescope").extensions.file_browser.file_browser(
    telescope.make_opts { cwd = proj, depth = 2 }
  )
end

function utils.ripgrep_project()
  local proj = utils.get_root_dir()
  if not proj then
    return false
  end

  nvim.input(
    sprintf("Ripgrep (%s) > ", proj:gsub(os.getenv('HOME'), '~')),
    function(input)
      vim.cmd(sprintf(':Rgp %s %s', input, proj))
    end
  )
end

local _grep_project = utils.grep_project()
local _grep_cwd = utils.grep_cwd()
local _live_grep_cwd = utils.grep_cwd(true)
local _live_grep_project = utils.grep_project(true)

--- Lua eval
keymap.define {
  --- sudo rw
  sudo_read = { 'n', '<leader>fR', ':SudaRead ', { desc = 'sudo read' } },
  sudo_write = { 'n', '<leader>fS', ':SudaWrite<CR>', { desc = 'sudo write' } },

  --- Misc
  gj = { { "n", "v" }, 'j', 'gj' },
  gk = { { 'n', 'v' }, 'k', 'gk' },
  C_z = { { 'n', 'v', 'o', 'i', 'c' }, '<C-z>', '<Nop>' },
  esc_term = { 't', '<Esc>', '<C-\\><C-n>', { desc = 'Go to normal mode' } },
  registers = { 'n', "<leader>'", telescope.get_builtin_picker('registers'), { desc = 'Registers' } },
  jumplist = { 'n', "<C-M-o>", telescope.get_builtin_picker('jumplist'), { desc = 'Jumplist' } },
  save_and_quit = { 'n', '<leader>qQ', '<cmd>qa!<CR>', { desc = 'Write & quit' } },
  window = { 'n', '<leader>w', '<C-w>', { desc = 'Window' } },
  picker_resume = { 'n', '<leader><leader>', telescope.get_builtin_picker('resume'), { desc = 'Resume picker' } },
  wrap_text = { 'n', '<M-q>', 'gqq', { desc = 'Wrap text' } },
  wrap_text_in_region = { { 'v' }, '<M-q>', 'gq', { desc = 'Wrap text' } },

  -- Clipboard
  clip_paste = { { 'n' }, '<C-M-y>', '"+p', { desc = 'Paste from clipboard' } },
  clip_copy = { { 'v' }, '<M-w>', '"+y', { desc = 'copy to clipboard' } },

  -- Git stuff
  git_git = { 'n', '<leader>gg', ':vert Git<CR>', { desc = "Git" } },
  git_stage = { 'n', '<leader>gs', ':Git stage %<CR>', { desc = "Stage buffer" } },
  git_add = { 'n', '<leader>ga', ':Git add %<CR>', { desc = "Add buffer" } },
  git_commit = { 'n', '<leader>gc', ':Git commit<CR>', { desc = "Commit" } },
  git_log = { 'n', '<leader>gl', ':Git log<CR>', { desc = "Log" } },
  git_push = { 'n', '<leader>gp', ':Git push<CR>', { desc = "Push to remote" } },
  git_files = { 'n', '<leader>gf', telescope.get_builtin_picker('git_files'), { desc = "Push to remote" } },
  git_branches = { 'n', '<leader>gb', telescope.get_builtin_picker('git_branches'), { desc = 'Branches' } },
  git_status = { 'n', '<leader>gS', telescope.get_builtin_picker('git_status'), { desc = 'Status' } },
  git_commits = { 'n', '<leader>g?', telescope.get_builtin_picker('git_commits'), { desc = 'Commits' } },

  -- LSP
  lsp_code_action = { 'n', '<leader>la', function() vim.lsp.buf.code_action() end, { desc = 'Code actions' } },
  lsp_implementation = { 'n', '<leader>li', function() vim.lsp.buf.implementation() end, { desc = 'Find implementation' } },
  lsp_buffer_rename = { 'n', '<leader>l%', function() vim.lsp.buf.rename() end, { desc = 'Rename something' } },
  lsp_buffer_references = { 'n', '<leader>lr', function() vim.lsp.buf.references() end, { desc = 'References' } },
  lsp_start = { 'n', '<leader>ll', ':LspStart<CR>', { desc = 'Start LSP' } },
  lsp_stop = { 'n', '<leader>lq', ':LspStop<CR>', { desc = 'Stop LSP' } },
  lsp_restart = { 'n', '<leader>lL', ':LspRestart<CR>', { desc = 'Restart LSP' } },
  lsp_document_symbols = { 'n', '<leader>ls', telescope.get_builtin_picker('lsp_document_symbols'), { desc = 'Document symbols' } },
  lsp_workspace_symbols = { 'n', '<leader>lw', telescope.get_builtin_picker('lsp_workspace_symbols'), { desc = 'Workspace symbols' } },
  lsp_log = { 'n', '<leader>l?', ':LspLog<CR>', { desc = 'Workspace symbols' } },
  lsp_buffer_format = { 'n', '<leader>lf', ':lua vim.lsp.buf.format()<CR>', { desc = 'Format buffer' } },

  -- Tabs
  tab_next = { 'n', '<leader><tab>n', ':tabnext<CR>', { desc = 'Next tab' } },
  tab_previous = { 'n', '<leader><tab>p', ':tabprev<CR>', { desc = 'Previous tab' } },
  tab_close = { 'n', '<leader><tab>k', ':tabclose<CR>', { desc = 'Close tab' } },
  tab_new = { 'n', '<leader><tab>c', ':tabnew <CR>', { desc = 'Create a new tab' } },
  tab_buffers = { 'n', '<leader><tab>b', function() tabpage.buffer_picker() end, { desc = 'Select buffer' } },
  tab_swap_next = { 'n', '<leader><tab>>', ':+tabmove<CR>', { desc = 'Swap with next tab' } },
  tab_swap_prev = { 'n', '<leader><tab><', ':-tabmove<CR>', { desc = 'Swap with prev tab' } },

  --- Eval lua on the fly like emacs lisp
  eval_region = {
    'v', '<leader>ee', function()
      local region = nvim.region()
      if not region then
        print('No region selected')
      end

      local ok, msg = loadstring(region, 'current_region')
      if not ok then
        error(msg)
      else
        print(msg)
      end
    end, { desc = 'Lua eval region' }
  },
  eval_buffer = {
    'n', '<leader>eb', function()
    local ok, msg = buffer.string(buffer.get_current_id())
    if ok then
      nvim.loadstring(msg)
    else
      error(msg)
    end
  end, { desc = 'Lua eval region' }
  },
  eval_line = {
    'n', '<leader>ee', function()
    local ok, msg = buffer.get_current_line(
      buffer.get_current_id()
    )
    if ok then
      nvim.loadstring(msg)
    else
      error(msg)
    end
  end, { desc = 'Lua eval line' }
  },

  --- File operations
  file_find = { 'n', '<leader>f.', telescope.get_builtin_picker('find_files'), { desc = 'List dir' } },
  file_live_grep = { 'n', '<leader>f?', telescope.get_builtin_picker('live_grep'), { desc = 'Live grep dir' } },
  file_git_files = { 'n', '<leader>fg', telescope.get_builtin_picker('git_files'), { desc = 'git ls-files' } },
  file_grep_string = { 'n', '<leader>f/', telescope.get_builtin_picker('grep_string'), { desc = 'Grep dir' } },
  file_oldfiles = { 'n', '<leader>fr', telescope.get_builtin_picker('oldfiles'), { desc = 'List dir' } },
  file_write_buffer = { 'n', '<leader>fs', ':w<CR>', { desc = 'Write buffer' } },
  file_write_buffer_as = { 'n', '<leader>fw', ':w ', { desc = 'Save as?' } },
  file_open_nvim_config = { 'n', '<leader>fp', ':e ~/.config/nvim<CR>', { desc = 'Nvim config dir' } },
  file_open_nvim_lua_config = { 'n', '<leader>fP', ':e ~/.config/nvim/lua<CR>', { desc = 'Nvim lua config dir' } },
  file_source = { 'n', '<leader>fv', ':w! <bar> source %<CR>', { desc = 'Source buffer' } },
  file_browser = {
    'n', '<leader>ff',
    function()
      require("telescope").extensions.file_browser.file_browser(telescope.make_opts({ depth = 2 }))
    end,
    { desc = 'File browser' }
  },
  file_netrw = { 'n', '<leader>fd', ':exec ":e " . getcwd()<CR>', { desc = 'Netrw cwd' } },
}

keymap.define.insert_tab('i', '<C-M-i>', function()
  local count = vim.bo.shiftwidth
  vim.api.nvim_feedkeys(string.rep(' ', count), 'n', false)
end, { desc = "Insert tab", silent = true, noremap = true })

--- Buffers
keymap.define.buffer_select('n', '<leader>bb', telescope.get_builtin_picker('buffers'), { desc = 'Buffers' })
keymap.define.buffer_select('n', '<leader>br', ':set nomodifiable<CR>', { desc = 'RO' })
keymap.define.buffer_select('n', '<leader>bR', ':set modifiable<CR>', { desc = 'RW' })
keymap.define.buffer_wl_copy('n', '<leader>by', ':! cat % <bar> wl-copy<CR>', { desc = 'Copy buffer' })
keymap.define.buffer_previous('n', '<leader>bp', '<cmd>bprev<CR>', { desc = 'Previous buffer' })
keymap.define.buffer_next('n', '<leader>bn', '<cmd>bnext<CR>', { desc = 'Next buffer' })
keymap.define.buffer_hide('n', '<leader>bk', '<cmd>hide<CR>', { desc = 'Hide buffer' })
keymap.define.buffer_groups(
  'n', '<leader>bg',
  function() bg_utils.buffer_picker(vim.fn.bufnr()) end,
  { desc = 'Show buffer groups for buffer' }
)
keymap.define.buffer_pop(
  'n', '<leader>bl', function()
    if #recent_buffers < 2 then
      return
    else
      local other = table.remove(recent_buffers, #recent_buffers - 1)
      recent_buffers[other] = nil
      if other ~= buffer.get_name(buffer.get_current_id()) then
        vim.cmd(':b ' .. other)
      end
    end
  end, { desc = 'Recent buffer' }
)

-- LSP stuff
--- Buffer groups
keymap.define.buffer_groups('n', '<leader>>', function()
  bg_utils.buffer_group_picker()
end, { desc = 'Show buffer groups' })

keymap.define.filetype_buffer_groups('n', '<leader>bf', function()
  local bufnr = buffer.get_current_id()
  local ft = buffer.filetype(bufnr)
  local exists = user_config.buffer_group[ft]
  if exists then exists:picker() end
end, { desc = 'Show buffer groups' })

--- Git stuff
--- Diagnostic stuff
keymap.define.diagnostics_hide("n", "<leader>dk", utils.hide_diagnostics, { desc = 'hide diagnostics' })
keymap.define.diagnostics_show("n", "<leader>de", utils.show_diagnostics, { desc = 'show diagnostics' })
keymap.define.diagnostics_show_buffer('n', '<leader>dd', '<cmd>Trouble diagnostics toggle filter.buf=0<CR>',
  { desc = 'Buffer diagnostics' })
keymap.define.diagnostics_show_workspace('n', '<leader>dD', '<cmd>Trouble diagnostics toggle<CR>',
  { desc = 'Workspace diagnostics' })

--- Persistence
keymap.define.persistence_load("n", "<leader>qL", function() require("persistence").load() end, { desc = 'Load' })
keymap.define.persistence_select("n", "<leader>q.", function() require("persistence").select() end, { desc = 'Select' })
keymap.define.persistence_load_last("n", "<leader>ql", function() require("persistence").load({ last = true }) end,
  { desc = 'Load previous' })
keymap.define.persistence_stop("n", "<leader>qk", function() require("persistence").stop() end, { desc = 'Stop' })

-- Disable highlight
keymap.define.noh('n', '<C-g>', ':noh<CR>', { desc = 'Disable search highlighting' })

-- Project stuff
keymap.define.project_select('n', '<leader>pp', function()
  require('telescope').extensions.project.project(telescope.make_opts())
end, { desc = 'Projects' })
keymap.define.project_buffers('n', '<leader>pb', function()
  local bufnr = buffer.get_current_id()
  local ws = buffer.get_root_dir(bufnr)
  local exists = user_config.buffer_group[ws]
  if exists then exists:picker() end
end, { desc = 'Show buffer groups' })
keymap.define.project_buffer_group('n', '<leader>.', function()
  local bufnr = buffer.get_current_id()
  local ws = buffer.get_root_dir(bufnr)
  local exists = user_config.buffer_group[ws]

  if not exists then
    exists = buffer_group(ws, ws)
  end

  exists:picker()
end, { desc = 'Show project buffer group' })
keymap.define.project_live_grep('n', '<leader>?', _live_grep_project, { desc = 'Live grep project' })
keymap.define.project_grep('n', '<leader>p?', _live_grep_project, { desc = 'Live grep' })
keymap.define.project_live_grep_1('n', '<leader>/', _grep_project, { desc = 'Grep project' })
keymap.define.project_grep_1('n', '<leader>p/', _grep_project, { desc = 'Grep' })
keymap.define.project_file_browser('n', '<leader>pf', utils.browse_project, { desc = 'File browser' })
keymap.define.project_ripgrep('n', '<leader>pr', utils.ripgrep_project, { desc = 'Ripgrep' })
keymap.define.project_netrw('n', '<leader>pd', function()
    local proj = utils.get_root_dir()
    if proj then
      vim.cmd(':e ' .. proj)
    else
      vim.cmd(':e ' .. vim.fn.getcwd())
    end
  end,
  { desc = 'Netrw dir' }
)

keymap.define.grep_project('n', '<leader>sP', _grep_project, { desc = 'Grep project' })
keymap.define.grep_live_project('n', '<leader>sp', _live_grep_project, { desc = 'Live grep project' })
keymap.define.grep_cwd('n', '<leader>s>', _grep_cwd, { desc = 'Grep cwd' })
keymap.define.grep_live_cwd('n', '<leader>s.', _live_grep_cwd, { desc = 'Live grep cwd' })

--- Change background
keymap.define.toggle_bg(
  'n', '<leader>hb',
  function()
    if vim.o.background == 'light' then
      vim.o.background = 'dark'
    else
      vim.o.background = 'light'
    end
  end,
  { desc = 'Toggle light/dark bg' }
)

--- Template insertion
keymap.define.insert_default_template('n', '<leader>it', function()
  local buf = buffer.get_current_id()
  local name = buffer.get_name(buf)
  local ft = vim.bo.filetype

  if not ft:match('[a-zA-Z0-9]') then
    return
  elseif name:sub(0, 0) == '.' then
    return
  elseif not name:match(ft .. '$') then
    return
  end

  local check = vim.fn.stdpath('config') .. '/autoinsert/' .. ft .. '.lua'
  local ok, msg = loadfile(check)

  if not ok then
    error(msg)
  end

  local s = msg()
  vim.cmd('normal! G')
  vim.cmd(':r ' .. s)
  vim.cmd('normal! G')
end, { desc = 'Insert default template for filetype' })

vim.cmd [[
nnoremap <C-Up> :resize +5 <CR>
nnoremap <C-Down> :resize -5 <CR>
nnoremap <C-Left> :vertical resize -5 <CR>
nnoremap <C-Right> :vertical resize +5 <CR>

nnoremap <leader>bk :call HideWindowIfPossible()<CR>
nnoremap <leader>bQ :bwipeout %<CR>
nnoremap <leader>bq :call DeleteBufferWindowIfPossible()<CR>
nnoremap <leader>bn :bnext<CR>
nnoremap <leader>bp :bprev<CR>

nnoremap <leader>fs :w<CR>
nnoremap <leader>fv :w <bar> luafile %<CR>
nnoremap <leader>fV :w <bar> source %<CR>
nnoremap <leader>f. :e .<CR>

nnoremap <C-g> :noh <CR>
nnoremap <C-x>. :!ls -lctrshA <CR>

nnoremap <M-.> :
vnoremap <M-.> :

nnoremap <M-!> :!

nnoremap <RightMouse> <Nop>
inoremap <RightMouse> <Nop>
vnoremap <RightMouse> <Nop>
]]

-- ~/.config/nvim/lua/emacs-insert.lua
local opts = { noremap = true, silent = true }

-- Movement
vim.keymap.set('i', '<C-a>', '<Home>', opts)
vim.keymap.set('i', '<C-e>', '<End>', opts)
vim.keymap.set('i', '<C-b>', '<Left>', opts)
vim.keymap.set('i', '<C-f>', '<Right>', opts)
vim.keymap.set('i', '<M-b>', '<C-o>B', opts)
vim.keymap.set('i', '<M-f>', '<C-o>W', opts)
vim.keymap.set('i', '<C-p>', '<Up>', opts)
vim.keymap.set('i', '<C-n>', '<Down>', opts)
vim.keymap.set('i', '<C-d>', '<Del>', opts)
vim.keymap.set('i', '<M-d>', '<C-o>dW', opts)
vim.keymap.set('i', '<M-BS>', '<C-o>db', opts)
vim.keymap.set('i', '<C-u>', '<C-o>d0', opts)
vim.keymap.set('i', '<C-_>', '<C-o>u', opts)
vim.keymap.set('i', '<M-p>', '<Up>', opts)
vim.keymap.set('i', '<M-n>', '<Dovwn>', opts)
vim.keymap.set('i', '<M-l>', '<C-o>guw', opts)
vim.keymap.set('i', '<M-u>', '<C-o>gUw', opts)
vim.keymap.set('n', '<leader>qq', ':qall!<CR>', { desc = 'qall!' })
vim.keymap.set('n', '<leader>Q', ':detach<CR>', { desc = 'Detach UI' })
