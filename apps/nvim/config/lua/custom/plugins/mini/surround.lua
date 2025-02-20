local M = {}

-- Add/delete/replace surroundings (brackets, quotes, etc.)
--
-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
-- - sd'   - [S]urround [D]elete [']quotes
-- - sr)'  - [S]urround [R]eplace [)] [']

M.setup = function()
  vim.keymap.set('n', 's', '<nop>', { noremap = true })
  require('mini.surround').setup({
    mappings = {
      add = 's', -- Add surrounding in Normal and Visual modes
      delete = 'ds', -- Delete surrounding
      find = 'gsf', -- Find surrounding (to the right)
      find_left = 'gsF', -- Find surrounding (to the left)
      highlight = 'gsh', -- Highlight surrounding
      replace = 'cs', -- Replace surrounding
      update_n_lines = 'gsn', -- Update `n_lines`

      suffix_last = 'l', -- Suffix to search with "prev" method
      suffix_next = 'n', -- Suffix to search with "next" method
    },
  })
end

return M
