--- files
vim.cmd "noremap <space>fs :w!<CR>"
vim.cmd "noremap <space>fw :w "
vim.cmd "noremap <space>fp :e ~/.config/nvim/lua/<CR>"
vim.cmd "noremap <space>fP :e ~/.config/nvim/<CR>"
vim.cmd "noremap <space>fv :w! <bar> source %<CR>"

--- buffers
vim.cmd 'noremap <space>bp <cmd>bprev<CR>'
vim.cmd 'noremap <space>bn <cmd>bnext<CR>'
vim.cmd 'noremap <space>bq <cmd>bwipeout! %<CR>'
vim.cmd 'noremap <space>bk <cmd>hide<CR>'

-- quit
vim.cmd 'noremap <space>qq <cmd>wa <bar> qa<CR>'

--- misc
vim.cmd 'noremap <space>w <C-w>'
vim.cmd 'noremap \\\\ :noh<CR>'
vim.cmd 'tnoremap <Esc> <C-\\><C-n>'
vim.cmd 'noremap <A-f> W'
vim.cmd 'noremap <A-b> B'

--- lua eval
vim.keymap.set('v', '<space>ee', function()
  local region = user_config.nvim.region()
  if not region then return end
  user_config.nvim.loadstring(region)
end, {desc = 'Lua eval region'})

vim.keymap.set('n', '<space>eb', function()
  local bufstring = user_config.buffer.as_string(
    user_config.buffer.current()
  )
  user_config.nvim.loadstring(bufstring)
end, {desc = 'Lua eval region'})

vim.keymap.set('n', '<space>ee', function()
  local line = user_config.buffer.current_line(
    user_config.buffer.current()
  )
  user_config.nvim.loadstring(line)
end, {desc = 'Lua eval line'})

--- REPL stuff
local buffer = user_config.buffer

local function get_repl(shell, running, callback)
  return function ()
    local bufnr = vim.fn.bufnr()
    local exists = user_config:get_repl(bufnr, shell, running)
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
    local term = user_config:create_repl(bufnr, shell)
    if term then return callback(term) end
  end
end

local function create_shell(callback)
  return create_repl(true, callback)
end

local function get_shell(running, callback)
  return get_repl(true, running, callback)
end

local function get_running_repl(shell, callback)
  return get_repl(shell, true, callback)
end

local function get_running_shell(callback)
  return get_repl(true, true, callback)
end

local kset = vim.keymap.set

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
local function shell_call(method, running)
  running = ifnil(running, true)
  return function ()
    local term = user_config.repls.shell
    if not term then
      user_config:start_shell()
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
