local M = {}
--[[ create_select_menu()
-- Create a menu to execute a Vim command or Lua function using vim.ui.select()
-- Example usage:
-- local options = {
--   [1. Onedark ] = "colo onedark"
--   [2. Tokyonight ] = function() vim.cmd("colo tokyonight") end
-- }
-- create_select_menu("Choose a colorscheme", options)
--
-- @arg prompt: the prompt to display
-- @arg options_table: Table of the form { [n. Display name] = lua-function/vim-cmd, ... }
--                    The number is used for the sorting purpose and will be replaced by vim.ui.select() numbering
--]]
M.create_select_menu = function(prompt, options_table, opts)
  local u = require('custom.lib.utils')
  opts = opts or {}
  local option_names = {}
  local actions = {}
  for i, v in ipairs(options_table) do
    local prefix = ''
    local title, action = unpack(v)

    if opts.add_numbers then
      prefix = u.rpad(i .. '. ', 3)
    end

    table.insert(option_names, prefix .. title)
    table.insert(actions, action)
  end
  table.sort(option_names)

  -- Return the prompt function. These global function var will be used when assigning keybindings
  local menu = function()
    vim.ui.select(option_names, {
      prompt = prompt,
    }, function(_, index)
      local action = actions[index]
      -- When user inputs ESC or q, don't take any actions
      if action ~= nil then
        if type(action) == 'string' then
          vim.cmd(action)
        elseif type(action) == 'function' then
          action()
        end
      end
    end)
  end

  return menu
end

return M
