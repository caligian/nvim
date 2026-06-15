return {
  root = { pattern = { '.git' }, check_depth = 4 },
  repl = { command = user_config.shell_command or 'bash' }
}
