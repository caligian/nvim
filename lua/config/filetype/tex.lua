local list = require 'lua-utils.list'
-- local nvim = require 'nvim-utils.nvim'
local buffer = require 'nvim-utils.buffer'
local path = require 'lua-utils.path_utils'
local nvim = require 'nvim-utils.nvim'
local tex = bless {}

function tex.change_extension(s, from, to)
  return (string.gsub(s, '%.' .. from .. '$', '.' .. to))
end

function tex.run(cmd, ...)
  return nvim.cmd(":! " .. sprintf(cmd, ...))
end

function tex.in_project(file)
  return path.is_dir(dirname(file) .. '/.git')
end

function tex.if_in_project(file, when, unless)
  if tex.in_project(file) then
    return when(file)
  else
    return unless(file)
  end
end

function tex.git_stage()
  vim.cmd('Git stage %')
end

function tex.git_commit()
  vim.cmd(':Git commit')
end

---@param bufname string
---@return string
function tex.get_bib_file(bufname)
  return (bufname:gsub('%.tex$', '.bib'))
end

---@param bufname string
function tex.clear(bufname)
  local exclude = {
    [bufname] = true,
    [tex.get_bib_file(bufname)] = true
  }

  for _, file in ipairs(path.ls(dirname(bufname))) do
    if not exclude[file] then
      tex.run('rm %s', file)
    end
  end
end

---@param file string
---@param ext string
---@return string?
function tex.has_file(file, ext)
  file = tex.change_extension(file, 'tex', ext)
  ---@type string
  return (path.is_file(file) and file)
end

---@param file string
---@param dir string
---@return string?
function tex.has_dir(file, dir)
  d = dirname(file)
  local check = d .. '/' .. dir
  ---@type string
  return (path.is_dir(check) and check)
end

function tex.ls_files(bufname, exclude_this)
  local basename = path.basename(bufname)
  local file = string.split(basename, '%.')
  local name = file[1]
  local files = list.filter(
    path.glob(name .. '.' .. '*'),
    function(check)
      if exclude_this and basename == path.basename(check) then
        return false
      else
        return path.is_file(check)
      end
    end,
    false
  )

  if #files == 0 then
    print("No files found")
  else
    return list.sort(files)
  end
end

function tex.clear_dir(bufname)
  for _, delete in ipairs(tex.ls_files(bufname, true) or {}) do
    tex.run('rm ' .. delete)
  end
end

function tex.ls(bufname)
  for _, file in ipairs(tex.ls_files(bufname)) do
    print(file)
  end
end

---@param bufname string
function tex.compile_bib(bufname)
  local auxfile = tex.change_extension(bufname, 'tex', 'aux')
  local name = basename(bufname:gsub("%.tex$", ""))

  if not is_file(auxfile) then
    tex.run('pdflatex %s', bufname)
    if not is_file(auxfile) then return end
  end

  tex.run('bibtex %s', name)
  tex.run('pdflatex %s', bufname)
end

---Open a tex PDF using xdg-open
---@param bufname string
function tex.open(bufname)
  local app = user_config.app and user_config.app.pdf or 'xdg-open'
  local pdf = tex.change_extension(bufname, 'tex', 'pdf')

  if path.is_file(pdf) then
    tex.run(app .. ' ' .. pdf)
  end
end

---@param bufname string
---@return string?
function tex.compile_pdf(bufname)
  local pdf = tex.change_extension(bufname, 'tex', 'pdf')
  tex.run('pdflatex %s', bufname)
  tex.compile_bib(bufname)

  if not is_file(pdf) then
    return
  else
    return pdf
  end
end

function tex.wrap(name, ...)
  local args = { ... }
  return function()
    local bufnr = vim.fn.bufnr()
    local bufname = buffer.get_name(bufnr)
    table.insert(args, 1, bufname)
    return tex[name](unpack(args))
  end
end

function tex.normal(cmd, ...)
  nvim.normal(sprintf(cmd, ...))
end

function tex.search_below(pattern)
  vim.cmd('/' .. pattern)
  vim.cmd(':noh')
end

function tex.search_above(pattern)
  vim.cmd('/' .. pattern)
  vim.cmd(':noh')
end

function tex.search(pattern, direction, buf)
  buf = buf or buffer.current()
  local linenums = {}
  local _, current_linenum = buffer.get_current_linenum(buf)

  if direction:match 'below' then
    local _, lc = buffer.get_line_count(buf)
    linenums = list.seq(current_linenum + 1, lc - 1)
  else
    linenums = list.seq(current_linenum - 1, 0, -1)
  end

  for _, linenum in ipairs(linenums) do
    local _, line = buffer.get_line(buf, linenum)
    if line and string.match(line, pattern) then
      vim.cmd(sprintf(':normal! %dG', linenum + 1))
      break
    end
  end
end

function tex.search_wrap(pattern, direction, buf)
  return function()
    local use = buf or buffer.current()
    tex.search(pattern, direction, use)
  end
end

function tex.cmd_mark_env()
  local ok, line = buffer.get_current_line(buffer.current())
  if not ok or not line then
    return
  elseif not string.match(line, '\\begin') then
    return
  end

  local ind = string.find(line, '\\begin')
  nvim.normal(sprintf("%d|", ind), "vae")
end

function tex.cmd_mark_cmd()
  local ok, line = buffer.get_current_line(buffer.current())
  if not ok or not line then
    return
  elseif not string.match(line, '\\[a-zA-Z0-9]') then
    return
  end

  local ind = string.find(line, '\\[a-zA-Z0-9]')
  nvim.normal(sprintf("%d|", ind), "vac")
end

function tex.cmd_clear()
  tex.clear_dir(buffer.get_name(buffer.current()))
end

tex.cmd_goto_next_main_section = tex.search_wrap('\\section[*]?[{]', 'below')
tex.cmd_goto_prev_main_section = tex.search_wrap('\\section[*]?[{]', 'above')
tex.cmd_goto_next_section = tex.search_wrap('\\[sub]*section[*]?[{]', 'below')
tex.cmd_goto_prev_section = tex.search_wrap('\\[sub]*section[*]?[{]', 'above')
tex.cmd_goto_next_env = tex.search_wrap('\\begin%{', 'below')
tex.cmd_goto_prev_env = tex.search_wrap('\\begin%{', 'above')
tex.cmd_goto_next_item = tex.search_wrap('\\item', 'below')
tex.cmd_goto_prev_item = tex.search_wrap('\\item', 'above')
tex.cmd_compile_pdf = tex.wrap 'compile_pdf'
tex.cmd_compile_bib = tex.wrap 'compile_bib'
tex.cmd_open = tex.wrap 'open'

--[[
\begin[]{}{
some content
}
\end

--]]

return {
  name = 'tex',
  lsp = { texlab = {} },
  buffer = {
    opt = {
      wrapmargin = 0,
      formatoptions = vim.o.formatoptions .. 't',
      textwidth = 80,
      shiftwidth = 2,
    }
  },
  keymap = {
    disable_lsp_format = { 'n', '<space>lf', ':echo "Cannot use lsp formatter on latex files."<CR>', { desc = 'Disable LSP formatter' } },
    toggle_toc = { 'n', '<C-t>', '<plug>(vimtex-toc-toggle)', { desc = 'Toggle table of contents' } },
    open_toc = { 'n', '<C-z>', '<plug>(vimtex-toc-open)', { desc = 'Open table of contents' } },
    mark_cmd = { { 'v', 'n' }, "<C-h>", tex.cmd_mark_cmd, { desc = 'Visually mark nearest command' } },
    mark_env = { { 'v', 'n' }, "<C-.>", tex.cmd_mark_env, { desc = 'Visually mark nearest env' } },
    -- mark_cmd_or_env = { { 'v', 'n' }, "<C-M-h>", tex.cmd_mark_cmd_or_env, { desc = 'Visually mark nearest env/command' } },
    next_main_section = { { 'i', 'v', 'n' }, "<C-M-e>", tex.cmd_goto_next_main_section, { desc = 'Goto next \\section' } },
    prev_main_section = { { 'i', 'v', 'n' }, '<C-M-a>', tex.cmd_goto_prev_main_section, { desc = 'Goto prev \\section' } },
    next_section = { { 'i', 'v', 'n' }, "<C-M-n>", tex.cmd_goto_next_section, { desc = 'Goto next \\(sub)*section' } },
    prev_section = { { 'i', 'v', 'n' }, '<C-M-p>', tex.cmd_goto_prev_section, { desc = 'Goto prev \\(sub)*section' } },
    next_env = { { 'i', 'v', 'n' }, "<M-n>", tex.cmd_goto_next_env, { desc = 'Goto next env' } },
    prev_env = { { 'i', 'v', 'n' }, '<M-p>', tex.cmd_goto_prev_env, { desc = 'Goto prev env' } },
    next_item = { { 'i', 'v', 'n' }, "<M-f>", tex.cmd_goto_next_item, { desc = 'Goto next item' } },
    prev_item = { { 'i', 'v', 'n' }, '<M-b>', tex.cmd_goto_prev_item, { desc = 'Goto prev item' } },
    compile_bibliography = { 'n', '<leader>cb', tex.cmd_compile_bib, { desc = 'Compile bibliography' } },
    compile_pdf = { 'n', '<leader>cp', tex.cmd_compile_pdf, { desc = 'Create PDF' } },
    open = { 'n', '<leader>co', tex.cmd_open, { desc = "Open PDF" } },
    clear = { 'n', '<leader>cr', tex.cmd_clear, { desc = 'Clear everything except .bib and .tex' } }
  }
}
