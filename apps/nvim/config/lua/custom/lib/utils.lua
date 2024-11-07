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

function M.iif(cond, is_thruty, is_falsy)
  if cond then
    return is_thruty
  else
    return is_falsy
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
  return function(...)
    local c = cache
    for i = 1, select('#', ...) do
      local a = select(i, ...) or memoize_nil
      c[a] = c[a] or {}
      c = c[a]
    end
    c[memoize_fnkey] = c[memoize_fnkey] or { fn(...) }
    return unpack(c[memoize_fnkey])
  end
end

function M.string_hash(str)
  local h = 5381
  for i = 1, #str do
    h = ((h * 33) + string.byte(str, i)) % 0x100000000
  end
  return h
end

local function get_function_parts(function_text, node)
  local ts_utils = require('nvim-treesitter.ts_utils')
  local parsers = require('nvim-treesitter.parsers')
  local lang = parsers.get_buf_lang(0)
  local query_string = [[
    (lexical_declaration
      (variable_declarator
        name: (identifier) @var_name
        value: (arrow_function
          parameters: (formal_parameters) @params
          body: (call_expression) @body)))

    (function_declaration
      name: (identifier) @name
      parameters: (formal_parameters) @params
      body: (statement_block) @body)

    (arrow_function
      parameters: (formal_parameters) @params
      body: (statement_block) @body)

    (arrow_function
      parameters: (formal_parameters) @params
      body: (call_expression) @body)
  
  ]]

  local parsed_query = vim.treesitter.query.parse(lang, query_string)
  for p, matches, m in parsed_query:iter_matches(node, 0) do
    local parts = {}
    for id, capture in pairs(matches) do
      local name = parsed_query.captures[id]

      for _, node in ipairs(capture) do
        print('⭕ ❱ utils.lua:254 ❱ ƒ(get_function_parts) ❱ parts =', vim.inspect(capture), vim.inspect(name), function_text)
        parts[name] = vim.treesitter.get_node_text(node, 0)
      end
    end
    return parts
  end
end

function M.select_current_function()
  local ts_utils = require('nvim-treesitter.ts_utils')
  local node = ts_utils.get_node_at_cursor()
  while node do
    if node:type() == 'function_declaration' or node:type() == 'arrow_function' or node:type() == 'variable_declaration' then
      ts_utils.update_selection(0, node)
      local start_row, start_col, end_row, end_col = node:range()
      local lines = vim.api.nvim_buf_get_lines(0, start_row, end_row + 1, false)
      local function_text = table.concat(lines, '\n')
      return function_text, node:type(), start_row, end_row, node
    end
    node = node:parent()
  end
end

function M.parse_function_text(function_text)
  local ts = require('nvim-treesitter.parsers')
  local parser = ts.get_parser(0, 'typescript')
  local tree = parser:parse(function_text)
  return tree[1]:root()
end

function M.toggle_function(function_text)
  local function_type, start_row, end_row, node
  if not function_text then
    function_text, function_type, start_row, end_row, node = M.select_current_function()
  else
    node = M.parse_function_text(function_text)
    function_type = node:type()
    print('⭕ ❱ utils.lua:301 ❱ ƒ(M.toggle_function) ❱ function_type =', vim.inspect(function_type))
  end

  local parts = get_function_parts(function_text, node)
  if not parts then
    return
  end

  local new_function_text

  if function_type == 'function_declaration' then
    -- Convert to arrow function
    new_function_text = string.format('%s => %s', parts.params, parts.body)
  elseif function_type == 'variable_declaration' then
    -- Convert to normal function with variable name
    new_function_text = string.format('function %s %s { return %s; }', parts.var_name, parts.params, parts.body)
  elseif function_type == 'arrow_function' then
    -- Convert to normal function
    new_function_text = string.format('function %s { return %s; }', parts.params, parts.body)
  else
    -- Convert to arrow function with variable name
    new_function_text = string.format('const %s = %s => %s', parts.var_name, parts.params, parts.body)
  end

  print('⭕ ❱ utils.lua:303 ❱ ƒ(M.toggle_function) ❱ new_function_text =', vim.inspect(new_function_text))
  vim.api.nvim_buf_set_lines(0, start_row, end_row + 1, false, vim.split(new_function_text, '\n'))
end

vim.keymap.set('n', '<leader>cfs', M.toggle_function, { noremap = true, silent = true })

return M
