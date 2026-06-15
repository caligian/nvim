return {
  delete_help_buffer = {
    'FileType', function (args)
      keymap.set('n', 'q', ':call HideWindowIfPossible()<CR>', {
        desc = 'Hide window', 
        buffer = args.buf,
      })
    end, { pattern = 'help' }
  },
  hide_help_buffer = {
    'FileType', function (args)
      keymap.set('n', 'Q', ':call WipeoutBufferWindowIfPossible()<CR>', {
        desc = 'Hide window', 
        buffer = args.buf,
      })
    end, { pattern = 'help' }
  },
  add_recent_file = {
    'BufEnter', function(args)
      user_config.recent_buffers = user_config.recent_buffers or {}
      local recent_buffers = user_config.recent_buffers
      local bufname = args.match
      recent_buffers.current = bufname

      if recent_buffers[bufname] then
        return
      else
        recent_buffers[bufname] = true
        recent_buffers[#recent_buffers + 1] = bufname
      end
    end, {pattern = '*.*'}
  }
}
