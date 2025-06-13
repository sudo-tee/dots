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

function M.yank_diagnostic()
  local win_get_cursor = vim.api.nvim_win_get_cursor
  local diagnostic_get = vim.diagnostic.get

  local line = win_get_cursor(0)[1] - 1
  local items = diagnostic_get(0, { lnum = line })
  if not items or #items == 0 then
    return
  end

  local lines = {}
  for _, item in ipairs(items) do
    -- Replace newlines in messages with a space (sanitize for yank)
    local message = item.message and item.message:gsub('\n', ' ') or ''
    local source = item.source or ''
    lines[#lines + 1] = string.format('%s: %s', source, message)
  end

  M.yank(table.concat(lines, '\n'), 'Diagnostics')
end

local dont_kill_clients = {
  copilot = true, -- Copilot is a special case, it should not be restarted
}

function M.lsp_restart()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })

  if #clients == 0 then
    vim.api.nvim_exec_autocmds('FileType', { group = 'nvim.lsp.enable', buffer = bufnr })
    return
  end

  for _, c in ipairs(clients) do
    local config = c.config

    if dont_kill_clients[config.name] then
      vim.notify(string.format('Lsp `%s` has been skipped.', config.name))
      return
    end

    vim.lsp.stop_client(c.id, true)
    vim.defer_fn(function()
      local attached_buffers = vim.tbl_keys(c.attached_buffers) ---@type integer[]
      local id = vim.lsp.start(config)
      if id then
        for _, b in ipairs(attached_buffers) do
          vim.lsp.buf_attach_client(b, id)
        end
        vim.notify(string.format('Lsp `%s` has been restarted.', config.name))
      else
        vim.notify(string.format('Error restarting `%s`.', config.name), vim.log.levels.ERROR)
      end
    end, 600)
  end
end

function M.find_parent_node(node, type)
  while node and node:type() ~= type do
    node = node:parent()
  end
  return node
end

function M.find_child_node(parent, type)
  for child in parent:iter_children() do
    if child:type() == type then
      return child
    end
  end
  return nil
end

function M.yank_markdown_code_block()
  local node = vim.treesitter.get_node()
  if not node then
    vim.notify('No treesitter parser found', vim.log.levels.WARN)
    return
  end

  local code_block = M.find_parent_node(node, 'fenced_code_block')
  if not code_block then
    vim.notify('Not inside a Markdown code block!', vim.log.levels.WARN)
    return
  end

  local content_node = M.find_child_node(code_block, 'code_fence_content')
  if not content_node then
    vim.notify('No code content found', vim.log.levels.WARN)
    return
  end

  local start_row, start_col, end_row = content_node:range()

  vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col })
  vim.cmd('normal! v')
  vim.api.nvim_win_set_cursor(0, { end_row, 0 })
  vim.cmd('normal! $y')

  vim.cmd('normal! `<')

  vim.notify('Code block yanked!', vim.log.levels.INFO)
end

function M.restart()
  vim.api.nvim_exec_autocmds('User', { pattern = 'RestartPre' })
  vim.cmd('restart')
end

return M
