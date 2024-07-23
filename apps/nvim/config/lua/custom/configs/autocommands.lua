-- [[ Basic Autocommands ]]
--  See :help lua-guide-autocommands
local augroup = require('custom.lib.utils').augroup

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  group = augroup('checktime'),
  callback = function()
    if vim.o.buftype ~= 'nofile' then
      vim.cmd('checktime')
    end
  end,
})

--
-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = augroup('highlight-yank'),
  callback = function()
    vim.highlight.on_yank()
  end,
})

local focus_cmd_group = augroup('focus_commands')
vim.g.focus_lost = false

-- Disable mouse when not in focus so it never ends in visual mode when clicking the neovim window
-- FocusGained autocommand
vim.api.nvim_create_autocmd('FocusGained', {
  group = focus_cmd_group,
  pattern = '*',
  callback = function()
    vim.g.focus_lost = false
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
    vim.g.focus_lost = true
    vim.api.nvim_set_option_value('mouse', '', { scope = 'global' })
  end,
})

-- Open file at the last position it was edited earlier
vim.api.nvim_create_autocmd('BufReadPost', {
  desc = 'Open file at the last position it was edited earlier',
  pattern = '*',
  command = 'silent! normal! g`"zv',
})

vim.api.nvim_create_autocmd('FileType', {
  group = augroup('close_with_q'),
  desc = 'Close with <q>',
  pattern = {
    'fugitive',
    'fugitiveblame',
    'floggraph',
    'git',
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
