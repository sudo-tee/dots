-- [[ Basic Autocommands ]]
--  See :help lua-guide-autocommands

local function augroup(name)
  return vim.api.nvim_create_augroup('sudo_tee/' .. name, { clear = true })
end

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
  group = augroup('sudo_tee/highlight-yank'),
  callback = function()
    vim.highlight.on_yank()
  end,
})

local focus_cmd_group = augroup('focus_commands')

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
  group = augroup('close_with_q'),
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
