local path = require 'lua-utils.path_utils'
local dict = require 'lua-utils.dict'

require 'nvim-utils.keymap'
require 'nvim-utils.buffer'
require 'nvim-utils.buffer_group'
require 'nvim-utils.filetype'
require 'nvim-utils.nvim'
require 'nvim-utils.repl'
require 'nvim-utils.tabpage'

local recent_buffers = user_config.buffer.recent
local scratch_buffer_path = user_config.path.dir.data .. '/scratch.lua'
local bg_utils = buffer_group.utils

local function create_scratch_buffer()
  local buf = vim.fn.bufexists(scratch_buffer_path)
  if buf == 0 then
    buf = vim.fn.bufadd(scratch_buffer_path)
    vim.keymap.set('n', 'q', ':hide<CR>', { desc = 'Hide buffer', buffer = buf })
    vim.cmd 'setlocal ft=lua'
  else
    buf = vim.fn.bufnr(scratch_buffer_path)
  end
  return buf
end

local function topts(opts)
  opts = opts or {}
  opts = dict.merge(require('telescope.themes').get_ivy(), opts)
  opts = dict.force_merge(opts, user_config.telescope)
  return opts
end

local function tbuiltin(what, opts)
  return function()
    local builtin = require('telescope.builtin')
    local fn = builtin[what]
    if not fn then
      return
    else
      fn(topts(opts))
    end
  end
end

local function hide_diagnostics()
  vim.diagnostic.config {
    virtual_text = false,
    signs = false,
    underline = false,
  }
end

local function show_diagnostics()
  vim.diagnostic.config {
    virtual_text = true,
    signs = true,
    underline = true,
  }
end

local function get_repl(shell, running, callback)
  return function()
    local bufnr = vim.fn.bufnr()
    local exists = repl.get(bufnr, shell, running)

    if exists then
      if running then
        return exists:is_running() and callback(exists)
      else
        return callback(exists)
      end
    end
  end
end

local function make_repl(sh, callback)
  return function()
    local bufnr = vim.fn.bufnr()
    local term = repl.create(bufnr, sh)
    if term then return callback(term) end
  end
end

local function get_running_repl(sh, callback)
  return get_repl(sh, true, callback)
end

local function sh_call(method, running)
  running = when_nil(running, L(true))
  return function()
    local term = user_config.repl.sh
    if running then
      return term --[[@as terminal]]:is_running() and term[method](term)
    else
      return term[method](term)
    end
  end
end

local function get_project()
  local bufnr = buffer.get_current_id()
  local ok, msg = buffer.get_filetype(bufnr)
  local ft

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

local function grep_project(live)
  return function()
    local proj = get_project()
    if not proj then
      return false
    end

    local proj_display = proj:gsub(os.getenv('HOME'), '~')
    local picker_name = live and 'live_grep' or 'grep_string'
    local prompt_title = live and 'Live grep workspace %s' or 'Grep workspace %s'

    local picker = tbuiltin(picker_name, {
      search_dirs = { proj },
      prompt_title = prompt_title:format(proj_display)
    })

    picker()
  end
end

local function grep_cwd(live)
  return function()
    local proj = path.getcwd()
    local proj_display = proj:gsub(os.getenv('HOME'), '~')
    local picker_name = live and 'live_grep' or 'grep_string'
    local prompt_title = live and 'Live grep %s' or 'Grep %s'

    local picker = tbuiltin(picker_name, {
      search_dirs = { proj },
      prompt_title = prompt_title:format(proj_display)
    })

    picker()
  end
end

local function project_file_browser()
  local proj = get_project()
  if not proj then
    return false
  end

  require("telescope").extensions.file_browser.file_browser(
    topts { cwd = proj, depth = 3 }
  )
end

local function project_ripgrep()
  local proj = get_project()
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

local _grep_project = grep_project()
local _grep_cwd = grep_cwd()
local _live_grep_cwd = grep_cwd(true)
local _live_grep_project = grep_project(true)

--- Lua eval
keymap.define {
  --- sudo rw
  sudo_read = { 'n', '<leader>fR', ':SudaRead ', { desc = 'sudo read' } },
  sudo_write = { 'n', '<leader>fS', ':SudaWrite ', { desc = 'sudo write' } },

  --- Misc
  gj = { { "n", "v" }, 'j', 'gj' },
  gk = { { 'n', 'v' }, 'k', 'gk' },
  C_z = { { 'n', 'v', 'o', 'i', 'c' }, '<C-z>', '<Nop>' },
  esc_term = { 't', '<Esc>', '<C-\\><C-n>', { desc = 'Go to normal mode' } },
  registers = { 'n', "<leader>'", tbuiltin('registers'), { desc = 'Registers' } },
  jumplist = { 'n', "<C-M-o>", tbuiltin('jumplist'), { desc = 'Jumplist' } },
  save_and_quit = { 'n', '<leader>qq', '<cmd>wa <bar> qa<CR>', { desc = 'Write & quit' } },
  window = { 'n', '<leader>w', '<C-w>', { desc = 'Window' } },
  picker_resume = { 'n', '<leader><leader>', tbuiltin('resume'), { desc = 'Resume picker' } },
  wrap_text = { 'n', '<M-q>', 'gqq', { desc = 'Wrap text' } },
  wrap_text_in_region = { { 'v' }, '<M-q>', 'gq', { desc = 'Wrap text' } },

  -- Clipboard
  clip_paste = { { 'n' }, '<C-M-y>', '"+p', { desc = 'wl-paste' } },
  clip_copy = { { 'v' }, '<M-w>', '"+y', { desc = 'wl-copy' } },

  -- Git stuff
  git_git = { 'n', '<leader>gg', ':vert Git<CR>', { desc = "Git" } },
  git_stage = { 'n', '<leader>gs', ':Git stage %<CR>', { desc = "Stage buffer" } },
  git_add = { 'n', '<leader>ga', ':Git add %<CR>', { desc = "Add buffer" } },
  git_commit = { 'n', '<leader>gc', ':Git commit<CR>', { desc = "Commit" } },
  git_log = { 'n', '<leader>gl', ':Git log<CR>', { desc = "Log" } },
  git_push = { 'n', '<leader>gp', ':Git push<CR>', { desc = "Push to remote" } },
  git_files = { 'n', '<leader>gf', tbuiltin('git_files'), { desc = "Push to remote" } },
  git_branches = { 'n', '<leader>gb', tbuiltin('git_branches'), { desc = 'Branches' } },
  git_status = { 'n', '<leader>gS', tbuiltin('git_status'), { desc = 'Status' } },
  git_commits = { 'n', '<leader>g?', tbuiltin('git_commits'), { desc = 'Commits' } },

  -- LSP
  lsp_code_action = { 'n', '<leader>la', function() vim.lsp.buf.code_action() end, { desc = 'Code actions' } },
  lsp_implementation = { 'n', '<leader>li', function() vim.lsp.buf.implementation() end, { desc = 'Find implementation' } },
  lsp_buffer_rename = { 'n', '<leader>l%', function() vim.lsp.buf.rename() end, { desc = 'Rename something' } },
  lsp_buffer_references = { 'n', '<leader>lr', function() vim.lsp.buf.references() end, { desc = 'References' } },
  lsp_start = { 'n', '<leader>ll', ':LspStart<CR>', { desc = 'Start LSP' } },
  lsp_stop = { 'n', '<leader>lq', ':LspStop<CR>', { desc = 'Stop LSP' } },
  lsp_restart = { 'n', '<leader>lL', ':LspRestart<CR>', { desc = 'Restart LSP' } },
  lsp_document_symbols = { 'n', '<leader>ls', tbuiltin('lsp_document_symbols'), { desc = 'Document symbols' } },
  lsp_workspace_symbols = { 'n', '<leader>lw', tbuiltin('lsp_workspace_symbols'), { desc = 'Workspace symbols' } },
  lsp_log = { 'n', '<leader>l?', ':LspLog<CR>', { desc = 'Workspace symbols' } },
  lsp_buffer_format = { 'n', '<leader>lf', ':lua vim.lsp.buf.format()<CR>', { desc = 'Format buffer' } },

  -- Tabs
  tab_next = { 'n', '<leader><tab>n', ':tabnext<CR>', { desc = 'Next tab' } },
  tab_previous = { 'n', '<leader><tab>p', ':tabprev<CR>', { desc = 'Previous tab' } },
  tab_close = { 'n', '<leader><tab>k', ':tabclose<CR>', { desc = 'Close tab' } },
  tab_new = { 'n', '<leader><tab><tab>', ':tabnew <CR>', { desc = 'Open a new tab' } },
  tab_buffers = { 'n', '<leader><tab>b', function() tabpage.buffer_picker() end, { desc = 'Select buffer' } },
  tab_1 = { 'n', '<leader><tab>1', '1gt', { desc = 'Tab 1' } },
  tab_2 = { 'n', '<leader><tab>2', '2gt', { desc = 'Tab 2' } },
  tab_3 = { 'n', '<leader><tab>3', '3gt', { desc = 'Tab 3' } },
  tab_4 = { 'n', '<leader><tab>4', '4gt', { desc = 'Tab 4' } },
  tab_5 = { 'n', '<leader><tab>5', '5gt', { desc = 'Tab 5' } },
  tab_6 = { 'n', '<leader><tab>6', '6gt', { desc = 'Tab 6' } },
  tab_7 = { 'n', '<leader><tab>7', '7gt', { desc = 'Tab 7' } },
  tab_8 = { 'n', '<leader><tab>8', '8gt', { desc = 'Tab 8' } },
  tab_9 = { 'n', '<leader><tab>9', '9gt', { desc = 'Tab 9' } },
  tab_0 = { 'n', '<leader><tab>10', '10gt', { desc = 'Tab 10' } },

  --- Eval lua on the fly like emacs lisp
  eval_region = {
    'v', '<leader>ee', function()
    local region = nvim.region()
    if not region then return end
    nvim.loadstring(region)
  end, { desc = 'Lua eval region' }
  },
  eval_buffer = {
    'n', '<leader>eb', function()
    local ok, bufstring = buffer.as_string(
      buffer.get_current_id()
    )
    if ok then
      nvim.loadstring(bufstring)
    end
  end, { desc = 'Lua eval region' }
  },
  eval_line = {
    'n', '<leader>ee', function()
    local ok, line = buffer.get_current_line(
      buffer.get_current_id()
    )
    if ok then
      nvim.loadstring(line)
    end
  end, { desc = 'Lua eval line' }
  },

  --- File operations
  file_find = { 'n', '<leader>f.', tbuiltin('find_files'), { desc = 'List dir' } },
  file_live_grep = { 'n', '<leader>f?', tbuiltin('live_grep'), { desc = 'Live grep dir' } },
  file_git_files = { 'n', '<leader>fg', tbuiltin('git_files'), { desc = 'git ls-files' } },
  file_grep_string = { 'n', '<leader>f/', tbuiltin('grep_string'), { desc = 'Grep dir' } },
  file_oldfiles = { 'n', '<leader>fr', tbuiltin('oldfiles'), { desc = 'List dir' } },
  file_write_buffer = { 'n', '<leader>fs', ':w<CR>', { desc = 'Write buffer' } },
  file_write_buffer_as = { 'n', '<leader>fw', ':w ', { desc = 'Save as?' } },
  file_open_nvim_config = { 'n', '<leader>fp', ':e ~/.config/nvim<CR>', { desc = 'Nvim config dir' } },
  file_open_nvim_lua_config = { 'n', '<leader>fP', ':e ~/.config/nvim/lua<CR>', { desc = 'Nvim lua config dir' } },
  file_source = { 'n', '<leader>fv', ':w! <bar> source %<CR>', { desc = 'Source buffer' } },
  file_browser = {
    'n', '<leader>ff',
    function()
      require("telescope").extensions.file_browser.file_browser(topts({ depth = 2 }))
    end,
    { desc = 'File browser' }
  },
  file_netrw = { 'n', '<leader>fd', ':exec ":e " . getcwd()<CR>', { desc = 'Netrw cwd' } },
}

--- Buffers
keymap.define.buffer_select('n', '<leader>bb', tbuiltin('buffers'), { desc = 'Buffers' })
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
keymap.define.diagnostics_hide("n", "<leader>dk", hide_diagnostics, { desc = 'hide diagnostics' })
keymap.define.diagnostics_show("n", "<leader>de", show_diagnostics, { desc = 'show diagnostics' })
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
  require('telescope').extensions.project.project(topts())
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
keymap.define.project_file_browser('n', '<leader>pf', project_file_browser, { desc = 'File browser' })
keymap.define.project_file_browser_1('n', '<C-p>', project_file_browser, { desc = 'File browser' })
keymap.define.project_ripgrep('n', '<leader>pr', project_ripgrep, { desc = 'Ripgrep' })
keymap.define.project_netrw('n', '<leader>pd', function()
    local proj = get_project()
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

--- Scratch buffer
keymap.define.open_scratch_buffer_below(
  'n', '<leader>,',
  function()
    local buf = create_scratch_buffer()
    local winnr = vim.fn.bufwinnr(buf)

    if winnr == -1 then
      vim.cmd('split | wincmd j | b ' .. buf)
      buffer.call(buf, function()
        vim.bo.filetype = 'text'
      end)
    end
  end,
  { desc = 'Split scratch below' }
)
keymap.define.open_scratch_buffer_right(
  'n', '<leader>;',
  function()
    local buf = create_scratch_buffer()
    local winnr = vim.fn.bufwinnr(buf)

    if winnr == -1 then
      vim.cmd('vsplit | wincmd l | b ' .. buf)
      buffer.call(buf, function()
        vim.bo.filetype = 'text'
      end)
    end
  end,
  { desc = 'Split scratch right' }
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
