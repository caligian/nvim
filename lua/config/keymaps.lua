local cmd = vim.cmd
local dict = require 'lua-utils.dict'
local buffer = require 'nvim-utils.buffer'
local filetype = user_config.filetype
local keymap = user_config.keymap
local nvim = user_config.nvim
local recent_buffers = user_config.buffers.recent
local define = keymap.define

local function topts(opts)
  opts = dict.merge(require('telescope.themes').get_ivy(), opts or {})
  dict.merge(opts, user_config.telescope)
  return opts
end

local function tbuiltin(what, opts)
  return function ()
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
  return function ()
    local bufnr = vim.fn.bufnr()
    local exists = user_config.repl.get(bufnr, shell, running)
    if exists then
      if running then
        return exists:running() and callback(exists)
      else
        return callback(exists)
      end
    end
  end
end

local function create_repl(shell, callback)
  return function ()
    local bufnr = vim.fn.bufnr()
    local term = user_config.repl.create(bufnr, shell)
    if term then return callback(term) end
  end
end

local function get_running_repl(shell, callback)
  return get_repl(shell, true, callback)
end

local function shell_call(method, running)
  running = ifnil(running, true)
  return function ()
    local term = user_config.repls.shell
    if not term then
      user_config.repl.start_shell()
    end

    if term then
      if running then
        return term:running() and term[method](term)
      else
        return term[method](term)
      end
    end
  end
end

local function get_project()
  local buf = buffer.current()
  local ft = filetype.buf_get(buf)
  local proj

  if not ft then
    proj = buffer.workspace(buf)
  else
    proj = ft:root_dir(buf)
  end

  if not proj then
    return false
  end

  return proj
end

local function grep_project(live)
  return function ()
    local proj = get_project()
    if not proj then
      return false
    end

    local proj_display = proj:gsub(os.getenv('HOME'), '~')
    local picker_name = ifelse(live, 'live_grep', 'grep_string')
    local prompt_title = ifelse(live, 'Live grep project (%s)', 'Grep project (%s)')
    local picker = tbuiltin(picker_name, {
      search_dirs = {proj},
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
    function (input)
      vim.cmd(sprintf(':Rgp %s %s', input, proj))
    end
  )
end

local _grep_project = grep_project()
local _live_grep_project = grep_project(true)

--- Lua eval
define.eval_region('v', '<space>ee', function()
  local region = user_config.nvim.region()
  if not region then return end
  user_config.nvim.loadstring(region)
end, {desc = 'Lua eval region'})

define.eval_buffer('n', '<space>eb', function()
  local bufstring = user_config.buffer.as_string(
    user_config.buffer.current()
  )
  user_config.nvim.loadstring(bufstring)
end, {desc = 'Lua eval region'})

define.eval_line('n', '<space>ee', function()
  local line = user_config.buffer.current_line(
    user_config.buffer.current()
  )
  user_config.nvim.loadstring(line)
end, {desc = 'Lua eval line'})

--- REPL
define['repl.start'](
  'n', '<space>rr', create_repl(false, function (term)
    term:start()
  end), {desc = 'Start'}
)

define['repl.stop'](
  'n', '<space>rq', get_running_repl(false, function (term)
    term:stop()
  end), {desc = 'Stop'}
)

define['repl.split_below'](
  'n', '<space>rs', get_running_repl(false, function (term)
    term:split_below()
  end), {desc = 'Split below'}
)

define['repl.split_right'](
  'n', '<space>rv', get_running_repl(false, function (term)
    term:split_right()
  end), {desc = 'Split on right'}
)

define['repl.send_buffer'](
  'n', '<space>rb', get_running_repl(false, function (term)
    term:send_buffer()
  end), {desc = 'Send buffer'}
)

define['repl.send_line'](
  'n', '<space>re', get_running_repl(false, function (term)
    term:send_current_line()
  end), {desc = 'Send current line'}
)

define['repl.send_region'](
  'v', '<space>re', get_running_repl(false, function (term)
    term:send_region()
  end), {desc = 'Send region'}
)

define['repl.send_C-c'](
  'n', '<space>rc', get_running_repl(false, function (term)
    term:send_ctrl_c()
  end), {desc = 'Send Ctrl-c'}
)

define['repl.send_C-d'](
  'n', '<space>rd', get_running_repl(false, function (term)
    term:send_ctrl_d()
  end), {desc = 'Send Ctrl-d'}
)

--- Workspace root shell
define['repl.workspace.start'](
  'n', '<space><enter><enter>', create_repl(true, function (term)
    term:start()
  end), {desc = 'Start'}
)

define['repl.workspace.stop'](
  'n', '<space><enter>q', get_running_repl(true, function (term)
    term:stop()
  end), {desc = 'Stop'}
)

define['repl.workspace.split_below'](
  'n', '<space><enter>s', get_running_repl(true, function (term)
    term:split_below()
  end), {desc = 'Split below'}
)

define['repl.workspace.split_right'](
  'n', '<space><enter>v', get_running_repl(true, function (term)
    term:split_right()
  end), {desc = 'Split on right'}
)

define['repl.workspace.send_buffer'](
  'n', '<space><enter>b', get_running_repl(true, function (term)
    term:send_buffer()
  end), {desc = 'Send buffer'}
)

define['repl.workspace.send_current_line'](
  'n', '<space><enter>e', get_running_repl(true, function (term)
    term:send_current_line()
  end), {desc = 'Send current line'}
)

define['repl.workspace.send_region'](
  'v', '<space><enter>e', get_running_repl(true, function (term)
    term:send_region()
  end), {desc = 'Send region'}
)

define['repl.workspace.send_C-c'](
  'n', '<space><enter>c', get_running_repl(true, function (term)
    term:send_ctrl_c()
  end), {desc = 'Send Ctrl-c'}
)

define['repl.workspace.send_C-d'](
  'n', '<space><enter>d', get_running_repl(true, function (term)
    term:send_ctrl_d()
  end), {desc = 'Send Ctrl-d'}
)

--- Global shell
define['shell.start']('n', '<space>xx', shell_call('start', false), {desc = 'Start'})
define['shell.hide']('n', '<space>xk', shell_call('hide'), {desc = 'Hide window'})
define['shell.split_below']('n', '<space>xs', shell_call('split_below'), {desc = 'Split below'})
define['shell.split_right']('n', '<space>xv', shell_call('split_right'), {desc = 'Split right'})
define['shell.stop']('n', '<space>xq', function ()
  local term = user_config.repls.shell
  if not term then
    return
  end

  if term:running() then
    term:stop()
    user_config.repls.shell = false
  end
end, {desc = 'Kill'})

--- Misc
define['registers']('n', "<space>'", tbuiltin('registers'), {desc = 'Registers'})
define['save_and_quit']('n', '<space>qq', '<cmd>wa <bar> qa<CR>', {desc = 'Write & quit'})
define['window']('n', '<space>w', '<C-w>', {desc = 'Window'})
define['picker.resume']('n', '<space><space>', tbuiltin('resume'), {desc = 'Resume picker'})
define['picker.select']('n', '<space>;', tbuiltin('builtin'), {desc = 'Builtin picker'})
cmd 'tnoremap <Esc> <C-\\><C-n>'

--- File operations
define['file.find']('n', '<space>f.', tbuiltin('find_files'), {desc = 'List dir'})
define['file.live_grep']('n', '<space>f?', tbuiltin('live_grep'), {desc = 'Live grep dir'})
define['file.git_files']('n', '<space>fg', tbuiltin('git_files'), {desc = 'git ls-files'})
define['file.grep_string']('n', '<space>f/', tbuiltin('grep_string'), {desc = 'Grep dir'})
define['file.oldfiles']('n', '<space>fr', tbuiltin('oldfiles'), {desc = 'List dir'})
define['file.write_buffer']('n', '<space>fs', ':w<CR>', {desc = 'Write buffer'})
define['file.write_buffer_as']('n', '<space>fw', ':w ', {desc = 'Save as?'})
define['file.open_nvim_config']('n', '<space>fp', ':e ~/.config/nvim<CR>', {desc = 'Nvim config dir'})
define['file.open_nvim_lua_config']('n', '<space>fP', ':e ~/.config/nvim/lua<CR>', {desc = 'Nvim lua config dir'})
define['file.source']('n', '<space>fv', ':w! <bar> source %<CR>', {desc = 'Source buffer'})
define['file.browser']('n', '<space>ff', function ()
  require("telescope").extensions.file_browser.file_browser(topts {depth = 3})
end, {desc = 'File browser'})
define['file.netrw']('n', '<space>fd', ':exec ":e " . getcwd()<CR>', {desc = 'Netrw cwd'})


-- Tabs
define['tab.next']('n', '<space>tn', ':tabnext<CR>', {desc = 'Next tab'})
define['tab.previous']('n', '<space>tp', ':tabprev<CR>', {desc = 'Previous tab'})
define['tab.close']('n', '<space>tk', ':tabclose<CR>', {desc = 'Previous tab'})
define['tab.new']('n', '<space>tt', ':tabnew ', {desc = 'Previous tab'})
define['tab.buffers']('n', '<space>tb', function () user_config.tabpage.buffer_picker() end, {desc = 'Select buffer'})
define['tab.1']('n', '<space>1', ':tabnext 1<CR>', {desc = 'Tab 1'})
define['tab.2']('n', '<space>2', ':tabnext 2<CR>', {desc = 'Tab 2'})
define['tab.3']('n', '<space>3', ':tabnext 3<CR>', {desc = 'Tab 3'})
define['tab.4']('n', '<space>4', ':tabnext 4<CR>', {desc = 'Tab 4'})
define['tab.5']('n', '<space>5', ':tabnext 5<CR>', {desc = 'Tab 5'})
define['tab.6']('n', '<space>6', ':tabnext 6<CR>', {desc = 'Tab 6'})
define['tab.7']('n', '<space>7', ':tabnext 7<CR>', {desc = 'Tab 7'})
define['tab.8']('n', '<space>8', ':tabnext 8<CR>', {desc = 'Tab 8'})
define['tab.9']('n', '<space>9', ':tabnext 9<CR>', {desc = 'Tab 9'})
define['tab.10']('n', '<space>0', ':tabnext 10<CR>', {desc = 'Tab 10'})

--- Buffers
define['buffer.select']('n', '<space>bb', tbuiltin('buffers'), {desc = 'Buffers'})
define['buffer.previous']('n', '<space>bp', '<cmd>bprev<CR>', {desc = 'Previous buffer'})
define['buffer.next']('n', '<space>bn', '<cmd>bnext<CR>', {desc = 'Next buffer'})
define['buffer.hide']('n', '<space>bk', '<cmd>hide<CR>', {desc = 'Hide buffer'})
define['buffer.wipeout']('n', '<space>bq', '<cmd>bwipeout! %<CR>', {desc = 'Wipeout buffer'})
define['buffer.tab_buffers']('n', '<space>bt', function () user_config.tabpage.buffer_picker() end, {desc = 'Select buffer in tab'})
define['buffer.buffer_groups']('n', '<space>bg', function () user_config.buffer_group.buffer_picker(vim.fn.bufnr()) end, {desc = 'Show buffer groups for buffer'})
define['buffer.pop'](
  'n', '<leader>bl', function ()
    if #recent_buffers < 2 then
      return
    else
      local other = table.remove(recent_buffers, #recent_buffers-1)
      recent_buffers[other] = nil
      if other ~= buffer.name(buffer.current()) then
        vim.cmd(':b ' .. other)
      end
    end
  end, {desc = 'Recent buffer'}
)

-- LSP stuff
define['lsp.code_action']('n', '<space>la', function () vim.lsp.buf.code_action() end, {desc = 'Code actions'})
define['lsp.implementation']('n', '<space>li', function () vim.lsp.buf.implementation() end, {desc = 'Find implementation'})
define['lsp.buffer.rename']('n', '<space>ls', function () vim.lsp.buf.rename() end, {desc = 'Rename something'})
define['lsp.buffer.references']('n', '<space>lr', function () vim.lsp.buf.references() end, {desc = 'References'})
define['lsp.start']('n', '<space>ll', ':LspStart<CR>', {desc = 'Start LSP'})
define['lsp.stop']('n', '<space>lq', ':LspStop<CR>', {desc = 'Stop LSP'})
define['lsp.restart']('n', '<space>lL', ':LspRestart<CR>', {desc = 'Restart LSP'})
define['lsp.document_symbols']('n', '<space>ls', tbuiltin('lsp_document_symbols'), {desc = 'Document symbols'})
define['lsp.workspace_symbols']('n', '<space>lw', tbuiltin('lsp_workspace_symbols'), {desc = 'Workspace symbols'})
define['lsp.log']('n', '<space>l?', ':LspLog<CR>', {desc = 'Workspace symbols'})
define['lsp.buffer_format']('n', '<space>lf', ':lua vim.lsp.buf.format()<CR>', {desc = 'Format buffer'})

--- Buffer groups
define['buffer.buffer_groups']('n', '<space>>', function ()
  user_config.buffer_group.buffer_group_picker()
end, {desc = 'Show buffer groups'})

define['buffer.filetype_buffer_group']('n', '<space>bf', function ()
  local bufnr = user_config.buffer.current()
  local ft = user_config.buffer.filetype(bufnr)
  local exists = user_config.buffer_groups[ft]
  if exists then exists:picker() end
end, {desc = 'Show buffer groups'})

--- Git stuff
define['git.git']('n', '<space>gg', ':Git<CR>', {desc = "Git"})
define['git.stage']('n', '<space>gs', ':Git stage %<CR>', {desc = "Stage buffer"})
define['git.add']('n', '<space>ga', ':Git add %<CR>', {desc = "Add buffer"})
define['git.commit']('n', '<space>gc', ':Git commit<CR>', {desc = "Commit"})
define['git.log']('n', '<space>gl', ':Git log<CR>', {desc = "Log"})
define['git.push']('n', '<space>gp', ':Git push<CR>', {desc = "Push to remote"})
define['git.files']('n', '<space>gf', tbuiltin('git_files'), {desc = "Push to remote"})
define['git.branches']('n', '<space>gb', tbuiltin('git_branches'), {desc = 'Branches'})
define['git.status']('n', '<space>gS', tbuiltin('git_status'), {desc = 'Status'})
define['git.commits']('n', '<space>g?', tbuiltin('git_commits'), {desc = 'Commits'})

--- Diagnostic stuff
define['diagnostics.hide']("n", "<space>dk", hide_diagnostics, {desc = 'hide diagnostics'})
define['diagnostics.show']("n", "<space>de", show_diagnostics, {desc = 'show diagnostics'})
define['diagnostics.show.buffer'](
  'n', '<space>dd', '<cmd>Trouble diagnostics toggle filter.buf=0<CR>', {desc = 'Buffer diagnostics'}
)
define['diagnostics.show.workspace'](
  'n', '<space>dD', '<cmd>Trouble diagnostics toggle<CR>', {desc = 'Workspace diagnostics'}
)

--- Persistence
define['persistence.load'](
  "n", "<leader>qL", function() require("persistence").load() end, {desc = 'Load'}
)
define['persistence.select'](
  "n", "<leader>q.", function() require("persistence").select() end, {desc = 'Select'}
)
define['persistence.load_last'](
  "n", "<leader>ql", function() require("persistence").load({ last = true }) end, {desc = 'Load previous'}
)
define['persistence.stop'](
  "n", "<leader>qk", function() require("persistence").stop() end, {desc = 'Stop'}
)

-- Disable highlight
define.noh('n', '<C-g>', ':noh<CR>', {desc = 'Disable search highlighting'})

-- Project stuff
define['project.select']('n', '<space>pp', function ()
  require('telescope').extensions.project.project(topts())
end, {desc = 'Projects'})

define['project.buffers']('n', '<space>pb', function ()
  local bufnr = user_config.buffer.current()
  local ws = user_config:root_dir(bufnr)
  local exists = user_config.buffer_groups[ws]
  if exists then exists:picker() end
end, {desc = 'Show buffer groups'})

define['project.buffer_group']('n', '<space>.', function ()
  local bufnr = user_config.buffer.current()
  local ws = user_config:root_dir(bufnr)
  local exists = user_config.buffer_groups[ws]
  if exists then exists:picker() end
end, {desc = 'Show project buffer group'})

define['project.live_grep'](
  'n', '<leader>?', _live_grep_project, {desc = 'Live grep project'}
)
define['project.grep'](
  'n', '<leader>p?', _live_grep_project, {desc = 'Live grep'}
)
define['project.live_grep_1'](
  'n', '<leader>/', _grep_project, {desc = 'Grep project'}
)
define['project.grep_1'](
  'n', '<leader>p/', _grep_project, {desc = 'Grep'}
)

define['project.file_browser'](
  'n', '<space>pf', project_file_browser, {desc = 'File browser'}
)

define['project.file_browser_1'](
  'n', '<C-p>', project_file_browser, {desc = 'File browser'}
)

define['project.ripgrep'](
  'n', '<leader>pr', project_ripgrep, {desc = 'Ripgrep'}
)

define['project.netrw'](
  'n', '<leader>pd', function ()
    local proj = get_project()
    if proj then
      vim.cmd(':e ' .. proj)
    else
      vim.cmd(':e ' .. vim.fn.getcwd())
    end
  end,
  {desc = 'Netrw dir'}
)

define['toggle_bg'](
  'n', '<leader>hb',
  function ()
    if vim.o.background == 'light'  then
      vim.o.background = 'dark'
    else
      vim.o.background = 'light'
    end
  end,
  {desc = 'Toggle light/dark bg'}
)

vim.keymap.set({"n", "v"}, 'j', 'gj')
vim.keymap.set({'n', 'v'}, 'k', 'gk')

local scratch_buffer_path = user_config.data_dir .. '/scratch.lua'
local function create_scratch_buffer()
  local buf = vim.fn.bufexists(scratch_buffer_path)
  if buf == 0 then
    buf = vim.fn.bufadd(scratch_buffer_path)
    vim.keymap.set('n', 'q', ':hide<CR>', {desc = 'Hide buffer', buffer = buf})
    vim.cmd 'set ft=lua'
  else
    buf = vim.fn.bufnr(scratch_buffer_path)
  end

  return buf
end

define.open_scratch_buffer_below(
  'n', '<leader>,',
  function ()
    local buf = create_scratch_buffer()
    local winnr = vim.fn.bufwinnr(buf)

    if winnr == -1 then
      vim.cmd('split | wincmd j | b ' .. buf)
    end
  end,
  {desc = 'Split scratch below'}
)

define.open_scratch_buffer_right(
  'n', '<leader>;',
  function ()
    local buf = create_scratch_buffer()
    local winnr = vim.fn.bufwinnr(buf)

    if winnr == -1 then
      vim.cmd('vsplit | wincmd l | b ' .. buf)
    end
  end,
  {desc = 'Split scratch below'}
)
