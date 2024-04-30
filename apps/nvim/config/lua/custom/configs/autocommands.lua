-- [[ Basic Autocommands ]]
--  See :help lua-guide-autocommands

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('sudo_tee/highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

local focus_cmd_group = vim.api.nvim_create_augroup('sudo_tee/focus_commands', { clear = true })

-- Disable mouse when not in focus so it never ends in visual mode when clicking the neovim window
-- FocusGained autocommand
vim.api.nvim_create_autocmd('FocusGained', {
  group = focus_cmd_group,
  pattern = '*',
  callback = function()
    vim.defer_fn(function()
      vim.api.nvim_set_option_value('mouse', 'a', { scope = 'global' })
    end, 1000)
  end,
})

-- FocusLost autocommand
vim.api.nvim_create_autocmd('FocusLost', {
  group = focus_cmd_group,
  pattern = '*',
  callback = function()
    vim.api.nvim_set_option_value('mouse', '', { scope = 'global' })
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('sudo_tee/close_with_q', { clear = true }),
  desc = 'Close with <q>',
  pattern = {
    'fugitive',
    'lspinfo',
    'help',
    'man',
    'qf',
    'query',
    'scratch',
    'spectre_panel',
    'neo-tree',
    'lazy',
    'checkhealth',
    'neotest-summary',
    'neotest-output',
    'neotest-output-panel',
  },
  callback = function(args)
    vim.keymap.set('n', 'q', '<cmd>quit<cr>', { buffer = args.buf })
    vim.keymap.set({ 'n' }, '<ESC>', '<cmd>close<CR>', { silent = true, buffer = true })
  end,
})
