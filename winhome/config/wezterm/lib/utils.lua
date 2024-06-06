local wezterm = require("wezterm")

local M = {}

function M.switch(case, options)
  return (options[case] or options.default or function() end)()
end

function M.starts_with(str, start)
  return str:sub(1, #start) == start
end

function M.some(tbl, func)
  for _, v in pairs(tbl) do
    if func(v) then
      return true
    end
  end
  return false
end

function M.get_files(dir)
  return M.map(wezterm.read_dir(dir), function(v)
    return M.basename(v)
  end)
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

function M.strip_extension(file)
  return string.sub(file, 1, -5)
end

-- Equivalent to POSIX basename(3)
-- Given "/foo/bar" returns "bar"
-- Given "c:\\foo\\bar" returns "bar"
---@param s string
function M.basename(s)
  return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

function M.filter(tbl, func)
  local newtbl = {}
  for i, v in pairs(tbl) do
    if func(v) then
      table.insert(newtbl, v)
    end
  end
  return newtbl
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

function M.map(tbl, func)
  local newtbl = {}
  for i, v in pairs(tbl) do
    newtbl[i] = func(v)
  end
  return newtbl
end

function M.split(s, delimiter)
  local result = {}
  for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
    table.insert(result, match)
  end
  return result
end

function M.concat(starting_table, ...)
  local merged = starting_table or {}
  local args = { ... }
  for _, v in pairs(args) do
    if v then
      table.insert(merged, v)
    end
  end

  return merged
end

function M.tail(tbl)
  return tbl[#tbl]
end

function M.head(tbl)
  return tbl[1]
end

---comment
---@param path string
---@return string|nil
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

function M.ucfirst(str)
  return str:lower():gsub("^%l", string.upper)
end

function M.format_label(text, foreground, background)
  local color_type = function(color)
    return (color and string.sub(color, 1, 1) == "#") and "Color" or "AnsiColor"
  end

  return (
    M.concat(
      {},
      foreground and { Foreground = { [color_type(foreground)] = foreground } },
      background and { Background = { [color_type(background)] = background } },
      { Text = text }
    )
  )
end

return M
