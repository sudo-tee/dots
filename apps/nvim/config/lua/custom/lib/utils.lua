local M = {}

M.reload = function(...)
  return require('plenary.reload').reload_module(...)
end

M.re_require = function(name)
  M.reload(name)
  return require(name)
end

function M.map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

function M.map_pair(mode, key, prev, next, desc)
  M.map(mode, ']' .. key, next, { desc = 'Next ' .. desc })
  M.map(mode, '[' .. key, prev, { desc = 'Previous ' .. desc })
end

function M.cmd(command)
  return string.format('<cmd>%s<cr>', command)
end

function M.first_to_upper(str)
  return (str:gsub('^%l', string.upper))
end

function M.starts_with(str, start)
  return str:sub(1, #start) == start
end

function M.rpad(s, l, c)
  local res = s .. string.rep(c or ' ', l - #s)

  return res, res ~= s
end

function M.iif(cond, a, b)
  if cond then
    return a
  else
    return b
  end
end

function M.l_if(cond, default)
  if cond then
    return cond
  else
    return default
  end
end

function M.find(predicate, tbl)
  for i, v in ipairs(tbl) do
    if predicate(v, i) then
      return i, v
    end
  end
end

function M.concat(...)
  local result = {}
  for _, tbl in ipairs({ ... }) do
    for _, v in ipairs(tbl) do
      table.insert(result, v)
    end
  end
  return result
end

function M.read_file(path)
  local open = io.open
  local file = open(path, 'rb') -- r read mode and b binary mode
  if not file then
    return nil
  end
  local content = file:read('*a') -- *a or *all reads the whole file
  file:close()
  return content
end

function M.decode_json(cmd_output)
  local success, json = pcall(vim.json.decode, cmd_output)
  if not success then
    return nil
  end
  return json
end

function M.git_default_branch()
  local handle = io.popen("basename $(git symbolic-ref refs/remotes/origin/HEAD) | tr -d '\n\r'")
  local result = handle:read('*a')
  handle:close()
  return result
end

function M.get_current_branch()
  local cmd_output = vim.fn.system('git branch --show-current'):gsub('\n', '')
  return cmd_output
end

function M.memoize(f)
  local mem = {}
  return function(...)
    local key = vim.inspect({ ... })
    if not mem[key] then
      mem[key] = f(...)
    end
    return mem[key]
  end
end

return M
