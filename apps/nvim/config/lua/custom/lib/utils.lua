local M = {}

function M.augroup(name)
  return vim.api.nvim_create_augroup('sudo_tee/' .. name, { clear = true })
end

function M.autocmd(event, pattern, callback, desc)
  vim.api.nvim_create_autocmd(event, {
    pattern = pattern,
    callback = callback,
    desc = desc,
  })
end

function M.lazy_bind(func)
  return function(...)
    local args = { ... }
    return function()
      return func(unpack(args))
    end
  end
end

function M.lazy_return(...)
  local args = { ... }
  return function()
    return unpack(args)
  end
end

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

---Map to a specific buffer for a FileType
---@param pattern string|table
---@param cb fun(args: table, map: fun(mode: string, lhs: string, rhs: string|function, opts?: table))
function M.ft_map(pattern, cb)
  vim.api.nvim_create_autocmd('FileType', {
    group = M.augroup('filetype_keymap'),
    pattern = pattern,
    callback = function(args)
      local map = function(mode, lhs, rhs, opts)
        opts = opts or { silent = true, noremap = true }
        vim.api.nvim_buf_set_keymap(args.buf, mode, lhs, rhs, opts)
      end
      cb(args, map)
    end,
  })
end

function M.cmd(command)
  return string.format('<cmd>%s<cr>', command)
end

function M.open_url_callback(url)
  return function()
    require('custom.lib.wezterm').open_url(url)
    vim.fn.setreg('+', url)
  end
end

function M.yank(text, title)
  title = title or 'Yanked'
  vim.fn.setreg('+', text)
  vim.notify(text, vim.log.levels.INFO, { title = title })
end

function M.first_to_upper(str)
  return (str:gsub('^%l', string.upper))
end

function M.starts_with(str, start)
  return str:sub(1, #start) == start
end

function M.rpad(str, l, c)
  str = str or ''
  local res = str .. string.rep(c or ' ', l - #str)

  return res, res ~= str
end

function M.lpad(str, l, c)
  str = str or ''
  local res = string.rep(c or ' ', l - #str) .. str

  return res, res ~= str
end

function M.truncate(str, len)
  str = str or ''
  if #str > 0 and #str > len then
    return str:sub(1, len) .. '…'
  end
  return str
end

function M.fixed_width(str, width)
  return M.rpad(M.truncate(str, width), width)
end

function M.iif(cond, is_thruty, is_falsy)
  if cond then
    return is_thruty
  else
    return is_falsy
  end
end

function M.value_or(val, default)
  if M.is_falsy(val) then
    return default
  end

  return val
end

function M.is_falsy(value)
  return value == false or value == nil or value == '' or value == 0
end

function M.is_thruty(value)
  return not M.is_falsy(value)
end

function M.just(val)
  local t = { val = val }

  t.or_else = function(default)
    if M.is_falsy(t.val) then
      return M.just(default)
    end
    return M.just(t.val)
  end

  t.unwrap = function()
    return t.val
  end

  t.map = function(fn)
    return M.just(M.is_falsy(t.val) and nil or fn(t.val))
  end

  return t
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

function M.some(predicate, tbl)
  for i, v in ipairs(tbl) do
    if predicate(v, i) then
      return true
    end
  end
  return false
end

function M.read_file(path)
  local success, file = pcall(io.open, path, 'rb')

  local function read_file(f)
    local content = f:read('*a')
    f:close()
    return content
  end

  return M.just(success and file).map(read_file).or_else(nil).unwrap()
end

M.path_join = function(...)
  return table.concat({ ... }, '/'):gsub('//', '/')
end

function M.decode_json(cmd_output)
  local success, json = pcall(vim.json.decode, cmd_output)

  return M.just(success and json).or_else(nil).unwrap()
end

function M.get_current_branch()
  local cmd_output = vim.fn.system('git branch --show-current'):gsub('\n', '')

  return M.just(cmd_output).or_else(nil).unwrap()
end

function M.memoize(cb)
  local mem = {}
  return function(...)
    local key = vim.inspect({ ... })
    if not mem[key] then
      mem[key] = cb(...)
    end
    return mem[key]
  end
end

function M.system(cmd)
  return vim.fn.system(cmd):gsub('\n', '')
end

function M.string_hash(str)
  local h = 5381
  for i = 1, #str do
    h = ((h * 33) + string.byte(str, i)) % 0x100000000
  end
  return h
end

function M.throttle(cb, treshold)
  local callCount = 0
  return function(...)
    local args = { ... }
    callCount = callCount + 1
    if callCount % treshold == 1 then
      vim.schedule(function()
        cb(unpack(args))
      end)
    end
  end
end

return M
