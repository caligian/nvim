return {
  'doums/rg.nvim',
  config = function ()
    require('rg').setup {
      -- Optional function to be used to format the items in the
      -- quickfix window (:h 'quickfixtextfunc')
      qf_format = nil,
      -- Glob list of excluded files and directories when the special
      -- `e` flag is set (it uses the `--glob !*` flag of rg)
      excluded = {
        '.git',
        'node_modules',
        'package-lock.json',
        'Cargo.lock',
      },
    }
  end
}
