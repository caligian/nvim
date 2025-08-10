string.length = string.len

function string.trim(x)
  x = x:gsub('^%s+', '')
  x = x:gsub('%s+$', '')
  return x
end

function string.ltrim(x)
  x = x:gsub('^%s+', '')
  return x
end

function string.rtrim(x)
  x = x:gsub('%s+$', '')
  return x
end

function string.startswith(x, pat)
  return string.match(x, '^' .. pat) ~= nil
end

function string.endswith(x, pat)
  return string.match(x, pat .. '$') ~= nil
end

function string.split(x, sep)
  local fields
  sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  x:gsub(pattern, function(c) fields[#fields+1] = c end)
  return fields
end

function string.title(x)
  local words = vim.split(x, "%s")
  for i=1, #words do
    local letter = words[i]:sub(1, 1):upper()
    words[i] = letter .. words[i]:sub(2, #words[i])
  end
  return table.concat(words, " ")
end

return string
