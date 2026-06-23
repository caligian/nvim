return {
  find_workspace = {
    'BufNew', function(args)
    local path = require 'lua-utils.path_utils'
    local ftobj = user_config.filetype[buffer.get_filetype(args.buf)]
    local pattern, check_depth = { '.git' }, 4

    if ftobj and ftobj.root then
      pattern = ftobj.root.patterna
      check_depth = ftobj.root.check_depth
    end

    local buf = args.buf
    local file = args.file
    local ws = buffer.get_root_dir(buf, pattern, check_depth)

    if ws and path.is_dir(ws .. '/.git') then
      user_config.workspace[buf] = ws
      user_config.workspace[file] = ws
    end
  end, { pattern = "*.*" }
  },
  delete_help_buffer = {
    'FileType', function(args)
    keymap.set('n', 'q', ':call HideWindowIfPossible()<CR>', {
      desc = 'Hide window',
      buffer = args.buf,
    })
  end, { pattern = 'help' }
  },
  hide_help_buffer = {
    'FileType', function(args)
    keymap.set('n', 'Q', ':call WipeoutBufferWindowIfPossible()<CR>', {
      desc = 'Hide window',
      buffer = args.buf,
    })
  end, { pattern = 'help' }
  },
  add_recent_file = {
    'BufRead', function(args)
    user_config.buffer.recent = user_config.buffer.recent or {}
    local recent_buffers = user_config.buffer.recent
    local bufname = args.match
    recent_buffers.current = bufname

    if recent_buffers[bufname] then
      return
    else
      recent_buffers[bufname] = true
      recent_buffers[#recent_buffers + 1] = bufname
    end
  end, { pattern = '*.*' }
  },
  indent_highlight = {
    'Colorscheme', function()
    vim.cmd.highlight('IndentLine guifg=#48494b')
    vim.cmd.highlight('IndentLineCurrent guifg=#777b7e')
  end, { pattern = '*' }
  },
}
