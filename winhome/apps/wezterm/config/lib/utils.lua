local M = {}

-- This function normalize the path of a pane in WSL.
-- It removes the WSL prefix and converts Windows paths to Unix paths.
-- It also removes the domain name from the path if it matches the WSL domain.
-- example of path that you can receive from wezterm:
--   /mnt/c/Users/username/
--   /Ubuntu/home/username/
--   /C:/Users/username/

---@param pane Pane
function M.get_pane_path(pane)
  local domain = pane:get_domain_name()

  local path = pane:get_current_working_dir().path
  if domain:match("^WSL:") then
    domain = domain:sub(5) -- Remove "WSL:" prefix

    -- Convert Windows path to Unix path if needed
    if path:match("^[A-Za-z]:\\") or path:match("^/[A-Za-z]:/") then
      -- Remove drive letter and convert backslashes
      path = path:gsub("^/?([A-Za-z]):[/\\]", "/mnt/%1/"):lower():gsub("\\", "/")
    end

    if path:match("^/" .. domain) then
      path = path:sub(#domain + 2)
    end
  end
  return path
end

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
  -- Remove trailing slashes first
  s = s:gsub("[/\\]+$", "")
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

function M.deep_merge(t1, t2)
  for k, v in pairs(t2) do
    if type(v) == "table" then
      if type(t1[k] or false) == "table" then
        M.deep_merge(t1[k], t2[k])
      else
        t1[k] = v
      end
    else
      t1[k] = v
    end
  end
  return t1
end

function M.index_by(list, key)
  local result = {}

  for _, item in ipairs(list) do
    result[item[key] or item] = item
  end

  return result
end

function M.keys(tbl)
  local keyset = {}
  local n = 0
  for k, v in pairs(tbl) do
    n = n + 1
    keyset[n] = k
  end
  table.sort(keyset)
  return keyset
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
function M.read_file(path)
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

function M.run_child_process(args)
  -- assume that if the target triple contains "windows" then we want to run the process in wsl
  if wezterm.target_triple:find("windows") then
    args = { "wsl.exe", "--exec", table.unpack(args) }
  end

  return wezterm.run_child_process(args)
end

return M
