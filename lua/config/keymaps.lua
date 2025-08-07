local cmd = vim.cmd
local kset = vim.keymap.set

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

local function topts()
  return user_config.dict.force_merge(
    require('telescope.themes').get_ivy(),
    user_config.telescope
  )
end

local function tbuiltin(what)
  return function ()
    local builtin = require('telescope.builtin')
    local fn = builtin[what]
    if not fn then
      return
    else
      fn(topts())
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
kset('v', '<space>ee', function()
  local region = user_config.nvim.region()
  if not region then return end
  user_config.nvim.loadstring(region)
end, {desc = 'Lua eval region'})

kset('n', '<space>eb', function()
  local bufstring = user_config.buffer.as_string(
    user_config.buffer.current()
  )
  user_config.nvim.loadstring(bufstring)
end, {desc = 'Lua eval region'})

kset('n', '<space>ee', function()
  local line = user_config.buffer.current_line(
    user_config.buffer.current()
  )
  user_config.nvim.loadstring(line)
end, {desc = 'Lua eval line'})

--- Regular filetype REPL in workspace
kset('n', '<space>rr', create_repl(false, function (term)
  term:start()
end), {desc = 'Start'})

kset('n', '<space>rq', get_running_repl(false, function (term)
  term:stop()
end), {desc = 'Stop'})

kset('n', '<space>rs', get_running_repl(false, function (term)
  term:split_below()
end), {desc = 'Split below'})

kset('n', '<space>rv', get_running_repl(false, function (term)
  term:split_right()
end), {desc = 'Split on right'})

kset('n', '<space>rb', get_running_repl(false, function (term)
  term:send_buffer()
end), {desc = 'Send buffer'})

kset('n', '<space>re', get_running_repl(false, function (term)
  term:send_current_line()
end), {desc = 'Send current line'})

kset('v', '<space>re', get_running_repl(false, function (term)
  term:send_region()
end), {desc = 'Send region'})

kset('n', '<space>rc', get_running_repl(false, function (term)
  term:send_ctrl_c()
end), {desc = 'Send Ctrl-c'})

kset('n', '<space>rd', get_running_repl(false, function (term)
  term:send_ctrl_d()
end), {desc = 'Send Ctrl-d'})

--- Workspace root shell
kset('n', '<space><enter><enter>', create_repl(true, function (term)
  term:start()
end), {desc = 'Start'})

kset('n', '<space><enter>q', get_running_repl(true, function (term)
  term:stop()
end), {desc = 'Stop'})

kset('n', '<space><enter>s', get_running_repl(true, function (term)
  term:split_below()
end), {desc = 'Split below'})

kset('n', '<space><enter>v', get_running_repl(true, function (term)
  term:split_right()
end), {desc = 'Split on right'})

kset('n', '<space><enter>b', get_running_repl(true, function (term)
  term:send_buffer()
end), {desc = 'Send buffer'})

kset('n', '<space><enter>e', get_running_repl(true, function (term)
  term:send_current_line()
end), {desc = 'Send current line'})

kset('v', '<space><enter>e', get_running_repl(true, function (term)
  term:send_region()
end), {desc = 'Send region'})

kset('n', '<space><enter>c', get_running_repl(true, function (term)
  term:send_ctrl_c()
end), {desc = 'Send Ctrl-c'})

kset('n', '<space><enter>d', get_running_repl(true, function (term)
  term:send_ctrl_d()
end), {desc = 'Send Ctrl-d'})

--- Global shell
kset('n', '<space>xx', shell_call('start', false), {desc = 'Start'})
kset('n', '<space>xk', shell_call('hide'), {desc = 'Hide window'})
kset('n', '<space>xs', shell_call('split_below'), {desc = 'Split below'})
kset('n', '<space>xv', shell_call('split_right'), {desc = 'Split right'})
kset('n', '<space>xq', function ()
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
kset('n', "<space>'", tbuiltin('registers'), {desc = 'Registers'})
kset('n', '<space>qq', '<cmd>wa <bar> qa<CR>', {desc = 'Write & quit'})
kset('n', '<space>w', '<C-w>', {desc = 'Window'})
kset('n', '\\', ':noh<CR>', {desc = 'Highlight disable'})
kset('n', '<space><space>', tbuiltin('resume'), {desc = 'Resume picker'})
kset('n', '<space>;', tbuiltin('builtin'), {desc = 'Builtin picker'})
cmd 'tnoremap <Esc> <C-\\><C-n>'

--- File operations
kset('n', '<space>f.', tbuiltin('find_files'), {desc = 'List dir'})
kset('n', '<space>f?', tbuiltin('live_grep'), {desc = 'Live grep dir'})
kset('n', '<space>fg', tbuiltin('git_files'), {desc = 'git ls-files'})
kset('n', '<space>f/', tbuiltin('grep_string'), {desc = 'Grep dir'})
kset('n', '<space>fr', tbuiltin('oldfiles'), {desc = 'List dir'})
kset('n', '<space>fs', ':w<CR>', {desc = 'Write buffer'})
kset('n', '<space>fw', ':w ', {desc = 'Save as?'})
kset('n', '<space>fp', ':e ~/.config/nvim<CR>', {desc = 'Nvim config dir'})
kset('n', '<space>fP', ':e ~/.config/nvim/lua<CR>', {desc = 'Nvim lua config dir'})
kset('n', '<space>fv', ':w! <bar> source %<CR>', {desc = 'Source buffer'})
kset('n', '<space>ff', function ()
  require("telescope").extensions.file_browser.file_browser(topts())
end, {desc = 'File browser'})

-- Tabs
kset('n', '<space>tn', ':tabnext<CR>', {desc = 'Next tab'})
kset('n', '<space>tp', ':tabprev<CR>', {desc = 'Previous tab'})
kset('n', '<space>tk', ':tabclose<CR>', {desc = 'Previous tab'})
kset('n', '<space>tt', ':tabnew ', {desc = 'Previous tab'})
kset('n', '<space>tb', function () user_config.tabpage.buffer_picker() end, {desc = 'Select buffer'})
kset('n', '<space>1', ':tabnext 1<CR>', {desc = 'Tab 1'})
kset('n', '<space>2', ':tabnext 2<CR>', {desc = 'Tab 2'})
kset('n', '<space>3', ':tabnext 3<CR>', {desc = 'Tab 3'})
kset('n', '<space>4', ':tabnext 4<CR>', {desc = 'Tab 4'})
kset('n', '<space>5', ':tabnext 5<CR>', {desc = 'Tab 5'})
kset('n', '<space>6', ':tabnext 6<CR>', {desc = 'Tab 6'})
kset('n', '<space>7', ':tabnext 7<CR>', {desc = 'Tab 7'})
kset('n', '<space>8', ':tabnext 8<CR>', {desc = 'Tab 8'})
kset('n', '<space>9', ':tabnext 9<CR>', {desc = 'Tab 9'})
kset('n', '<space>0', ':tabnext 0<CR>', {desc = 'Tab 10'})

--- Buffers
kset('n', '<space>bb', tbuiltin('buffers'), {desc = 'Buffers'})
kset('n', '<space>bp', '<cmd>bprev<CR>', {desc = 'Previous buffer'})
kset('n', '<space>bn', '<cmd>bnext<CR>', {desc = 'Next buffer'})
kset('n', '<space>bk', '<cmd>hide<CR>', {desc = 'Hide buffer'})
kset('n', '<space>bq', '<cmd>bwipeout! %<CR>', {desc = 'Wipeout buffer'})
kset('n', '<space>bt', function () user_config.tabpage.buffer_picker() end, {desc = 'Select buffer in tab'})
kset('n', '<space>bg', function () user_config.buffer_group.buffer_picker(vim.fn.bufnr()) end, {desc = 'Show buffer groups for buffer'})

-- LSP stuff
kset('n', '<space>la', function () vim.lsp.buf.code_action() end, {desc = 'Code actions'})
kset('n', '<space>li', function () vim.lsp.buf.implementation() end, {desc = 'Find implementation'})
kset('n', '<space>ls', function () vim.lsp.buf.rename() end, {desc = 'Rename something'})
kset('n', '<space>lr', function () vim.lsp.buf.references() end, {desc = 'References'})
kset('n', '<space>ll', ':LspStart<CR>', {desc = 'Start LSP'})
kset('n', '<space>lq', ':LspStop<CR>', {desc = 'Stop LSP'})
kset('n', '<space>lL', ':LspRestart<CR>', {desc = 'Restart LSP'})
kset('n', '<space>ls', tbuiltin('lsp_document_symbols'), {desc = 'Document symbols'})
kset('n', '<space>lw', tbuiltin('lsp_workspace_symbols'), {desc = 'Workspace symbols'})
kset('n', '<space>l?', ':LspLog<CR>', {desc = 'Workspace symbols'})

-- Project management
kset('n', '<space>pp', function ()
  require('telescope').extensions.project.project(topts())
end, {desc = 'Projects'})

kset('n', '<space>pb', function ()
  local bufnr = user_config.buffer.current()
  local ws = user_config:root_dir(bufnr)
  local exists = user_config.buffer_groups[ws]
  if exists then exists:picker() end
end, {desc = 'Show buffer groups'})

--- Buffer groups
kset('n', '<space>>', function ()
  user_config.buffer_group.buffer_group_picker()
end, {desc = 'Show buffer groups'})

kset('n', '<space>.', function ()
  local bufnr = user_config.buffer.current()
  local ft = user_config.buffer.filetype(bufnr)
  local exists = user_config.buffer_groups[ft]
  if exists then exists:picker() end
end, {desc = 'Show buffer groups'})

--- Git stuff
kset('n', '<space>gg', ':Git<CR>', {desc = "Git"})
kset('n', '<space>gs', ':Git stage %<CR>', {desc = "Stage buffer"})
kset('n', '<space>gc', ':Git commit<CR>', {desc = "Commit"})
kset('n', '<space>gl', ':Git log<CR>', {desc = "Log"})
kset('n', '<space>gp', ':Git push<CR>', {desc = "Push to remote"})
kset('n', '<space>gf', tbuiltin('git_files'), {desc = "Push to remote"})
kset('n', '<space>gb', tbuiltin('git_branches'), {desc = 'Branches'})
kset('n', '<space>gs', tbuiltin('git_status'), {desc = 'Status'})
kset('n', '<space>gc', tbuiltin('git_commits'), {desc = 'Commits'})

--- Diagnostic stuff
kset("n", "<space>dk", hide_diagnostics, {desc = 'hide diagnostics'})
kset("n", "<space>de", show_diagnostics, {desc = 'show diagnostics'})
kset('n', '<space>dd', '<cmd>Trouble diagnostics toggle filter.buf=0<CR>', {desc = 'Buffer diagnostics'})
kset('n', '<space>dD', '<cmd>Trouble diagnostics toggle<CR>', {desc = 'Workspace diagnostics'})
