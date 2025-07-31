local str = {}

str.trim = vim.trim
str.startswith = vim.startswith
str.endswith = vim.endswith
str.split = vim.split
str.cmp = vim.stricmp
str.length = string.len
str.len = string.len
str.replace = string.gsub
str.gsub = string.gsub
str.lower = string.lower
str.upper = string.upper
str.match = string.match
str.rep = string.rep
str.reverse = string.reverse
str.slice = string.sub
str.find = string.find
str.gmatch = string.gmatch
str.split = vim.split

function str.title(x)
  local words = vim.split(x, "%s")
  for i=1, #words do
    local letter = words[i]:sub(1, 1):upper()
    words[i] = letter .. words[i]:sub(2, #words[i])
  end
  return table.concat(words, " ")
end

return str
