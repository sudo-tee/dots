local M = {}

-- Add/delete/replace surroundings (brackets, quotes, etc.)
--
-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
-- - sd'   - [S]urround [D]elete [']quotes
-- - sr)'  - [S]urround [R]eplace [)] [']

M.setup = function()
  require('mini.surround').setup({
    mappings = {
      add = 'Sa', -- Add surrounding in Normal and Visual modes
      delete = 'Sd', -- Delete surrounding
      find = 'Sf', -- Find surrounding (to the right)
      find_left = 'SF', -- Find surrounding (to the left)
      highlight = 'Sh', -- Highlight surrounding
      replace = 'Sr', -- Replace surrounding
      update_n_lines = 'Sn', -- Update `n_lines`

      suffix_last = 'l', -- Suffix to search with "prev" method
      suffix_next = 'n', -- Suffix to search with "next" method
    },
  })
end

return M
