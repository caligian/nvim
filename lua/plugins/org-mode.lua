return {
  'nvim-orgmode/orgmode',
  event = 'VeryLazy',
  config = function()
    -- Setup orgmode
    require('orgmode').setup({
      org_agenda_files = '~/Work/agendas/*',
      org_startup_indented = true,
      org_indent_mode_turns_on_hiding_stars = false,

      -- org_default_notes_file = '~/orgfiles/refile.org',
    })
  end,
}
