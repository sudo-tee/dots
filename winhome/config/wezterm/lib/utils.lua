local M = {}

function M.filter(tbl, func)
  local newtbl = {}
  for i, v in pairs(tbl) do
    if func(v) then
      table.insert(newtbl, v)
    end
  end
  return newtbl
end

function M.file_exists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

function M.path_join(...)
  local separator = package.config:sub(1, 1) -- Get the path separator (either "/" or "\")
  local paths = { ... }
  local result = paths[1]
  for i = 2, #paths do
    result = result:gsub("[" .. separator .. "]+$", "") .. separator .. paths[i]:gsub("^[" .. separator .. "]+", "")
  end
  return result
end

function M.path_split(str)
  local separator = package.config:sub(1, 1) -- Get the path separator (either "/" or "\")
  return M.split(str, separator)
end

function M.path_join(...)
  local separator
  if package.config:sub(1, 1) == "\\" then
    -- Windows
    separator = "\\"
  else
    -- Unix-like
    separator = "/"
  end

  return table.concat({ ... }, separator)
end

function M.is_windows()
  if package.config:sub(1, 1) == "\\" then
    -- Windows
    return true
  else
    -- Unix-like
    return false
  end
end

-- Equivalent to POSIX basename(3)
-- Given "/foo/bar" returns "bar"
-- Given "c:\\foo\\bar" returns "bar"
function M.basename(s)
  return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

function M.contains(tbl, value)
  for _, v in pairs(tbl) do
    if v == value then
      return true
    end
  end
  return false
end

function M.find(tbl, callback)
  for _, value in pairs(tbl) do
    if callback(value) then
      return value
    end
  end
  return nil
end

function M.split(s, delimiter)
  local result = {}
  for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
    table.insert(result, match)
  end
  return result
end

function M.tail(tbl)
  return tbl[#tbl]
end

function M.head(tbl)
  return tbl[1]
end

M.read_file = function(path)
  local open = io.open
  local file = open(path, "rb") -- r read mode and b binary mode
  if not file then
    return nil
  end
  local content = file:read("*a") -- *a or *all reads the whole file
  file:close()
  return content
end

return M
