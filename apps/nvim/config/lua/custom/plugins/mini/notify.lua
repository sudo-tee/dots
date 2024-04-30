-- this helps with cmdheight=0
-- replace default print with notify
_G.print = function(...)
  local print_safe_args = {}
  local _ = { ... }
  for i = 1, #_ do
    table.insert(print_safe_args, tostring(_[i]))
  end
  local message = table.concat(print_safe_args, ' ')
  vim.schedule(function()
    vim.notify(message, vim.log.levels.INFO)
  end)
end

-- replace default error with notify
-- _G.error = function(...)
--   local print_safe_args = {}
--   local _ = { ... }
--   for i = 1, #_ do
--     table.insert(print_safe_args, tostring(_[i]))
--   end
--   local message = table.concat(print_safe_args, ' ')
--   if #message == 0 then
--     return
--   end
--   vim.schedule(function()
--     vim.notify(message, vim.log.levels.ERROR)
--   end)
-- end
--
require('mini.notify').setup({
  window = {
    config = function()
      local has_statusline = vim.o.laststatus > 0
      local bottom_space = vim.o.cmdheight + (has_statusline and 1 or 0)
      return { anchor = 'SE', col = vim.o.columns, row = vim.o.lines - bottom_space }
    end,
  },
})
vim.notify = require('mini.notify').make_notify()
