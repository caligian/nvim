return {
  name = 'python',
  repl = {
    command = 'ipython3',
    input = {
      use_file = true,
      file_string = 'load -y %s',
    }
  }
}
