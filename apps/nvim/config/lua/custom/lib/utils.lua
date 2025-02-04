local M = {}

function M.augroup(name, opts)
  return vim.api.nvim_create_augroup('sudo_tee/' .. name, opts or { clear = true })
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

        if type(rhs) == 'function' then
          M.map(mode, lhs, rhs, vim.tbl_deep_extend('force', opts, { buffer = args.buf }))
        else
          vim.api.nvim_buf_set_keymap(args.buf, mode, lhs, rhs, opts)
        end
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

M.path_join = function(...)
  return table.concat({ ... }, '/'):gsub('//', '/')
end

function M.decode_json(cmd_output)
  local success, json = pcall(vim.json.decode, cmd_output)
  return success and json or nil
end

local memoize_fnkey = {}
local memoize_nil = {}

function M.memoize(fn)
  local cache = {}

  local function clear_cache()
    cache = {}
  end

  local memoized_callback = function(...)
    local c = cache
    local key = ''

    for i = 1, select('#', ...) do
      local a = select(i, ...) or memoize_nil
      key = key .. tostring(a) .. ':'
      c[a] = c[a] or {}
      c = c[a]
    end

    if not c[memoize_fnkey] then
      c[memoize_fnkey] = { fn(...) }
    end

    return unpack(c[memoize_fnkey])
  end

  return memoized_callback, clear_cache
end

function M.string_hash(str)
  local h = 5381
  for i = 1, #str do
    h = ((h * 33) + string.byte(str, i)) % 0x100000000
  end
  return h
end

return M
