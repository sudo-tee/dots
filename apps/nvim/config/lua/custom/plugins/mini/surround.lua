local M = {}

-- Add/delete/replace surroundings (brackets, quotes, etc.)
--
-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
-- - sd'   - [S]urround [D]elete [']quotes
-- - sr)'  - [S]urround [R]eplace [)] [']

M.setup = function()
  require('mini.surround').setup()

  -- Disable visual mode 's' key
  vim.keymap.set('v', 's', '<nop>', { noremap = true })
  -- Surround shortcuts
  local surrounds = { '{', '}', '[', ']', '(', ')', "'", '"', '`' }
  for _, char in ipairs(surrounds) do
    vim.keymap.set('v', 's' .. char, function()
      local c = vim.api.nvim_replace_termcodes(char, true, false, true)
      vim.api.nvim_feedkeys('sa' .. c, 'v', true)
    end, { desc = 'Surround with ' .. char, noremap = true })
  end
end

return M
