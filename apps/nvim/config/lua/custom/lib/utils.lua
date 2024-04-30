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

function M.rpad(s, l, c)
  local res = s .. string.rep(c or ' ', l - #s)

  return res, res ~= s
end

function M.lpad(s, l, c)
  local res = string.rep(c or ' ', l - #s) .. s

  return res, res ~= s
end

function M.truncate(str, len)
  if #str > len then
    return str:sub(1, len) .. '...'
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

function M.some(val)
  local t = { val = val }

  t.or_else = function(default)
    if M.is_falsy(t.val) then
      return default
    end
    return t.val
  end

  t.or_error = function(msg)
    if M.is_falsy(t.val) then
      error(msg)
    end
    return t.val
  end

  t.unwrap = function()
    return t.val
  end

  t.map = function(fn)
    return M.some(M.is_falsy(t.val) and nil or fn(t.val))
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

function M.read_file(path)
  local success, file = pcall(io.open, path, 'rb')

  local function read_file(f)
    local content = f:read('*a')
    f:close()
    return content
  end

  return M.some(success and file).map(read_file).or_else(nil)
end

function M.decode_json(cmd_output)
  local success, json = pcall(vim.json.decode, cmd_output)

  return M.some(success and json).or_else(nil)
end

function M.get_current_branch()
  local cmd_output = vim.fn.system('git branch --show-current'):gsub('\n', '')

  return M.some(cmd_output).or_else(nil)
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

function M.auto_restart_lsp(name)
  local uv = vim.uv or vim.loop
  if not vim.g.focus_lost then
    local total_retries = 3
    local duration = 1000

    local timer = uv.new_timer()
    if timer == nil then
      print('Failed to create new timer')
      return
    end

    local elapsed_retries = 0
    local timer_callback
    timer_callback = vim.schedule_wrap(function()
      -- Check if the desired number of retries has been met
      if elapsed_retries >= total_retries then
        timer:stop()
        timer:close()
        return
      end

      vim.cmd(':LspStart ' .. name)

      elapsed_retries = elapsed_retries + 1

      timer:start(duration, 0, timer_callback)
    end)

    timer:start(duration, 0, timer_callback)
  end
end

return M
