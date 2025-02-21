---@module 'snacks'

local DEFAULT_PRINT_TAG = '⭕'
local function get_print_tag()
  local tag = DEFAULT_PRINT_TAG
  if vim.g.debug_tag then
    tag = DEFAULT_PRINT_TAG .. '' .. vim.g.debug_tag
  end
  return tag
end

local VALID_FUNCTION_TYPES = {
  function_declaration = true,
  method_definition = true,
  function_definition = true,
  ['function'] = true,
  arrow_function = true,
  variable_list = true,
}

local VALID_DECLARATION_TYPES = {
  variable_declarator = true,
  local_declaration = true,
  lexical_declaration = true,
}

local function get_current_function_name()
  local node = vim.treesitter.get_node()
  local buf = vim.api.nvim_get_current_buf()

  while node do
    local ntype = node:type()
    local names = node:field('name')
    if VALID_FUNCTION_TYPES[ntype] and names[1] then
      return vim.treesitter.get_node_text(names[1], buf)
    elseif VALID_DECLARATION_TYPES[ntype] then
      local value = node:field('value')[1]
      if value and VALID_FUNCTION_TYPES[value:type()] and names[1] then
        return vim.treesitter.get_node_text(names[1], buf)
      end
    end
    node = node:parent()
  end
  return 'anonymous'
end

return {
  'sudo-tee/printer.nvim',
  -- dir = "~/Projects/_nvim/printer.nvim",
  lazy = true,
  keys = {
    { mode = 'n', 'gP', '<Plug>(printer_print)iw', desc = '[P]rint debug line' },
    { mode = 'n', 'gpp', '<Plug>(insert_below)', desc = '[P]rint debug line below' },
    { mode = { 'v' }, 'gp', '<Plug>(printer_print)', desc = '[P]rint debug' },
    { mode = { 'v' }, 'gP', '<Plug>(printer_print)', desc = '[P]rint debug' },
    {
      '<localleader>py',
      function()
        vim.fn.setreg([["]], DEFAULT_PRINT_TAG)
        vim.fn.setreg([[*]], DEFAULT_PRINT_TAG)
        vim.notify('copied ' .. DEFAULT_PRINT_TAG .. 'to clipboard')
      end,
      desc = 'Copy debug prefix',
      silent = false,
    },
    {
      '<localleader>pY',
      function()
        local print_tag = get_print_tag()
        vim.fn.setreg([["]], print_tag)
        vim.fn.setreg([[*]], print_tag)
        vim.notify('copied ' .. print_tag .. 'to clipboard')
      end,
      desc = 'Copy debug prefix + project prefix',
      silent = false,
    },
    {
      '<localleader>px',
      ':g/' .. DEFAULT_PRINT_TAG .. '/norm va(o$O_d',
      desc = 'Delete prints for buffer',
      silent = false,
    },
    {
      '<localleader>ps',
      function()
        Snacks.picker.grep({ search = DEFAULT_PRINT_TAG })
      end,
      desc = 'Find all debug print for project',
      silent = false,
    },
  },
  opts = {
    keymap = 'gp',
    behavior = 'insert_below',
    formatters = {
      lua = function(text_inside, text_var)
        if not text_var then
          return string.format('vim.print("%s")', text_inside)
        end
        return string.format('vim.print("%s =" , %s)', text_inside, text_var)
      end,
      typescriptreact = function(text_inside, text_var)
        if not text_var then
          return string.format('console.warn("%s")', text_inside)
        end
        return string.format('console.warn("%s=", %s)', text_inside, text_var)
      end,
      vue = function(text_inside, text_var)
        if not text_var then
          return string.format('console.warn("%s")', text_inside)
        end
        return string.format('console.warn("%s=", %s)', text_inside, text_var)
      end,
    },
    -- function which modifies the text inside string in the print statement, by default it adds the path and line number
    add_to_inside = function(text)
      local fn = get_current_function_name()
      local file = vim.fn.expand('%:t')
      local line = vim.fn.line('.')

      local sections = { get_print_tag(), ('%s:%s'):format(file, line) }

      if fn then
        table.insert(sections, ('ƒ(%s)'):format(fn))
      end

      table.insert(sections, ('%s'):format(text or ''))

      return table.concat(sections, ' ❱ ')
    end,
  },
}
