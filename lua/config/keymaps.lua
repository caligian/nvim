local cmd = vim.cmd
local dict = require 'lua-utils.dict'
local buffer = user_config.buffer
local filetype = user_config.filetype
local keymap = user_config.keymap
local define = keymap.define

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

--- Regular filetype REPL in workspace
define['repl.start']('n', '<space>rr', create_repl(false, function (term)
  term:start()
end), {desc = 'Start'})

define['repl.stop']('n', '<space>rq', get_running_repl(false, function (term)
  term:stop()
end), {desc = 'Stop'})

define['repl.split_below']('n', '<space>rs', get_running_repl(false, function (term)
  term:split_below()
end), {desc = 'Split below'})

define['repl.split_right']('n', '<space>rv', get_running_repl(false, function (term)
  term:split_right()
end), {desc = 'Split on right'})

define['repl.send_buffer']('n', '<space>rb', get_running_repl(false, function (term)
  term:send_buffer()
end), {desc = 'Send buffer'})

define['repl.send_line']('n', '<space>re', get_running_repl(false, function (term)
  term:send_current_line()
end), {desc = 'Send current line'})

define['repl.send_region']('v', '<space>re', get_running_repl(false, function (term)
  term:send_region()
end), {desc = 'Send region'})

define['repl.send_C-c']('n', '<space>rc', get_running_repl(false, function (term)
  term:send_ctrl_c()
end), {desc = 'Send Ctrl-c'})

define['repl.send_C-d']('n', '<space>rd', get_running_repl(false, function (term)
  term:send_ctrl_d()
end), {desc = 'Send Ctrl-d'})

--- Workspace root shell
keymap('n', '<space><enter><enter>', create_repl(true, function (term)
  term:start()
end), {desc = 'Start'})

keymap('n', '<space><enter>q', get_running_repl(true, function (term)
  term:stop()
end), {desc = 'Stop'})

keymap('n', '<space><enter>s', get_running_repl(true, function (term)
  term:split_below()
end), {desc = 'Split below'})

keymap('n', '<space><enter>v', get_running_repl(true, function (term)
  term:split_right()
end), {desc = 'Split on right'})

keymap('n', '<space><enter>b', get_running_repl(true, function (term)
  term:send_buffer()
end), {desc = 'Send buffer'})

keymap('n', '<space><enter>e', get_running_repl(true, function (term)
  term:send_current_line()
end), {desc = 'Send current line'})

keymap('v', '<space><enter>e', get_running_repl(true, function (term)
  term:send_region()
end), {desc = 'Send region'})

keymap('n', '<space><enter>c', get_running_repl(true, function (term)
  term:send_ctrl_c()
end), {desc = 'Send Ctrl-c'})

keymap('n', '<space><enter>d', get_running_repl(true, function (term)
  term:send_ctrl_d()
end), {desc = 'Send Ctrl-d'})

--- Global shell
keymap('n', '<space>xx', shell_call('start', false), {desc = 'Start'})
keymap('n', '<space>xk', shell_call('hide'), {desc = 'Hide window'})
keymap('n', '<space>xs', shell_call('split_below'), {desc = 'Split below'})
keymap('n', '<space>xv', shell_call('split_right'), {desc = 'Split right'})
keymap('n', '<space>xq', function ()
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
keymap('n', "<space>'", tbuiltin('registers'), {desc = 'Registers'})
keymap('n', '<space>qq', '<cmd>wa <bar> qa<CR>', {desc = 'Write & quit'})
keymap('n', '<space>w', '<C-w>', {desc = 'Window'})
keymap('n', '<space><space>', tbuiltin('resume'), {desc = 'Resume picker'})
keymap('n', '<space>;', tbuiltin('builtin'), {desc = 'Builtin picker'})
cmd 'tnoremap <Esc> <C-\\><C-n>'

--- File operations
keymap('n', '<space>f.', tbuiltin('find_files'), {desc = 'List dir'})
keymap('n', '<space>f?', tbuiltin('live_grep'), {desc = 'Live grep dir'})
keymap('n', '<space>fg', tbuiltin('git_files'), {desc = 'git ls-files'})
keymap('n', '<space>f/', tbuiltin('grep_string'), {desc = 'Grep dir'})
keymap('n', '<space>fr', tbuiltin('oldfiles'), {desc = 'List dir'})
keymap('n', '<space>fs', ':w<CR>', {desc = 'Write buffer'})
keymap('n', '<space>fw', ':w ', {desc = 'Save as?'})
keymap('n', '<space>fp', ':e ~/.config/nvim<CR>', {desc = 'Nvim config dir'})
keymap('n', '<space>fP', ':e ~/.config/nvim/lua<CR>', {desc = 'Nvim lua config dir'})
keymap('n', '<space>fv', ':w! <bar> source %<CR>', {desc = 'Source buffer'})
keymap('n', '<space>ff', function ()
  require("telescope").extensions.file_browser.file_browser(topts())
end, {desc = 'File browser'})

-- Tabs
keymap('n', '<space>tn', ':tabnext<CR>', {desc = 'Next tab'})
keymap('n', '<space>tp', ':tabprev<CR>', {desc = 'Previous tab'})
keymap('n', '<space>tk', ':tabclose<CR>', {desc = 'Previous tab'})
keymap('n', '<space>tt', ':tabnew ', {desc = 'Previous tab'})
keymap('n', '<space>tb', function () user_config.tabpage.buffer_picker() end, {desc = 'Select buffer'})
keymap('n', '<space>1', ':tabnext 1<CR>', {desc = 'Tab 1'})
keymap('n', '<space>2', ':tabnext 2<CR>', {desc = 'Tab 2'})
keymap('n', '<space>3', ':tabnext 3<CR>', {desc = 'Tab 3'})
keymap('n', '<space>4', ':tabnext 4<CR>', {desc = 'Tab 4'})
keymap('n', '<space>5', ':tabnext 5<CR>', {desc = 'Tab 5'})
keymap('n', '<space>6', ':tabnext 6<CR>', {desc = 'Tab 6'})
keymap('n', '<space>7', ':tabnext 7<CR>', {desc = 'Tab 7'})
keymap('n', '<space>8', ':tabnext 8<CR>', {desc = 'Tab 8'})
keymap('n', '<space>9', ':tabnext 9<CR>', {desc = 'Tab 9'})
keymap('n', '<space>0', ':tabnext 0<CR>', {desc = 'Tab 10'})

--- Buffers
keymap('n', '<space>bb', tbuiltin('buffers'), {desc = 'Buffers'})
keymap('n', '<space>bp', '<cmd>bprev<CR>', {desc = 'Previous buffer'})
keymap('n', '<space>bn', '<cmd>bnext<CR>', {desc = 'Next buffer'})
keymap('n', '<space>bk', '<cmd>hide<CR>', {desc = 'Hide buffer'})
keymap('n', '<space>bq', '<cmd>bwipeout! %<CR>', {desc = 'Wipeout buffer'})
keymap('n', '<space>bt', function () user_config.tabpage.buffer_picker() end, {desc = 'Select buffer in tab'})
keymap('n', '<space>bg', function () user_config.buffer_group.buffer_picker(vim.fn.bufnr()) end, {desc = 'Show buffer groups for buffer'})

-- LSP stuff
keymap('n', '<space>la', function () vim.lsp.buf.code_action() end, {desc = 'Code actions'})
keymap('n', '<space>li', function () vim.lsp.buf.implementation() end, {desc = 'Find implementation'})
keymap('n', '<space>ls', function () vim.lsp.buf.rename() end, {desc = 'Rename something'})
keymap('n', '<space>lr', function () vim.lsp.buf.references() end, {desc = 'References'})
keymap('n', '<space>ll', ':LspStart<CR>', {desc = 'Start LSP'})
keymap('n', '<space>lq', ':LspStop<CR>', {desc = 'Stop LSP'})
keymap('n', '<space>lL', ':LspRestart<CR>', {desc = 'Restart LSP'})
keymap('n', '<space>ls', tbuiltin('lsp_document_symbols'), {desc = 'Document symbols'})
keymap('n', '<space>lw', tbuiltin('lsp_workspace_symbols'), {desc = 'Workspace symbols'})
keymap('n', '<space>l?', ':LspLog<CR>', {desc = 'Workspace symbols'})

-- Project management
keymap('n', '<space>pp', function ()
  require('telescope').extensions.project.project(topts())
end, {desc = 'Projects'})

keymap('n', '<space>pb', function ()
  local bufnr = user_config.buffer.current()
  local ws = user_config:root_dir(bufnr)
  local exists = user_config.buffer_groups[ws]
  if exists then exists:picker() end
end, {desc = 'Show buffer groups'})

--- Buffer groups
keymap('n', '<space>>', function ()
  user_config.buffer_group.buffer_group_picker()
end, {desc = 'Show buffer groups'})

keymap('n', '<space>.', function ()
  local bufnr = user_config.buffer.current()
  local ft = user_config.buffer.filetype(bufnr)
  local exists = user_config.buffer_groups[ft]
  if exists then exists:picker() end
end, {desc = 'Show buffer groups'})

--- Git stuff
keymap('n', '<space>gg', ':Git<CR>', {desc = "Git"})
keymap('n', '<space>gs', ':Git stage %<CR>', {desc = "Stage buffer"})
keymap('n', '<space>gc', ':Git commit<CR>', {desc = "Commit"})
keymap('n', '<space>gl', ':Git log<CR>', {desc = "Log"})
keymap('n', '<space>gp', ':Git push<CR>', {desc = "Push to remote"})
keymap('n', '<space>gf', tbuiltin('git_files'), {desc = "Push to remote"})
keymap('n', '<space>gb', tbuiltin('git_branches'), {desc = 'Branches'})
keymap('n', '<space>gs', tbuiltin('git_status'), {desc = 'Status'})
keymap('n', '<space>gc', tbuiltin('git_commits'), {desc = 'Commits'})

--- Diagnostic stuff
keymap("n", "<space>dk", hide_diagnostics, {desc = 'hide diagnostics'})
keymap("n", "<space>de", show_diagnostics, {desc = 'show diagnostics'})
keymap('n', '<space>dd', '<cmd>Trouble diagnostics toggle filter.buf=0<CR>', {desc = 'Buffer diagnostics'})
keymap('n', '<space>dD', '<cmd>Trouble diagnostics toggle<CR>', {desc = 'Workspace diagnostics'})

keymap("n", "<leader>qs", function() require("persistence").load() end, {desc = 'Load'})
keymap("n", "<leader>qS", function() require("persistence").select() end, {desc = 'Select'})
keymap("n", "<leader>ql", function() require("persistence").load({ last = true }) end, {desc = 'Load previous'})
keymap("n", "<leader>qd", function() require("persistence").stop() end, {desc = 'Stop'})

-- Disable highlight
keymap('n', '<C-g>', ':noh<CR>', {desc = 'Disable search highlighting'})

-- Live grep project
local function grep_project()
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

  local proj_display = proj:gsub(os.getenv('HOME'), '~')
  local picker = tbuiltin('live_grep', {
    search_dirs = {proj},
    prompt_title = 'Live grepping ' .. proj_display
  })

  picker()
end

keymap('n', '<leader>/', grep_project, {desc = 'Search in current project'})
