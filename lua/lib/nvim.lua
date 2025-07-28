require('lib.utils')
local list = require('lib.list')
local nvim = {}
user_config.nvim = nvim

function nvim.normal()
  vim.cmd.normal({ vim.fn.mode(), bang = true })
end

function nvim.region(as_list)
  as_list = ifnil(as_list, false)
  local esc = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
  vim.api.nvim_feedkeys(esc, "x", false)
  local vstart = vim.fn.getpos("'<")
  local vend = vim.fn.getpos("'>")
  local ok, _region = pcall(vim.fn.getregion, vstart, vend, vim.empty_dict())

  if ok and _region then
    if as_list then
      return _region
    else
      return list.concat(_region, "\n")
    end
  end
end

function nvim.mode()
  return vim.fn.mode()
end

function nvim.in_visual_mode()
  local mode = nvim.mode()
  return mode == 'v' or mode == 'V' or mode == ''
end

function nvim.in_normal_mode()
  return nvim.mode() == 'n'
end

function nvim.with_region(fn, ...)
  local _region = nvim.region()
  if _region then
    return fn(_region, ...)
  end
end

function nvim.ls(dirname, fullname)
  local res = {}
  local abspath = fullname and vim.fs.abspath(dirname)
  for f in vim.fs.dir(dirname) do
    if fullname then
      res[#res+1] = abspath .. '/' .. f
    else
      res[#res+1] = f
    end
  end
  return res
end

return nvim
