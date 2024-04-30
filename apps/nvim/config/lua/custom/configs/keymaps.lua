local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

local function map_pair(mode, key, prev, next, desc)
  map(mode, ']' .. key, next, { desc = 'Next ' .. desc })
  map(mode, '[' .. key, prev, { desc = 'Previous ' .. desc })
end

--file related maps
map('n', '<leader>fn', '<cmd>enew<cr>', { desc = 'New File' })

map('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- I hate the "q:" I will use <C-f> in command mode if needed
map('n', 'q:', '<Nop>')

-- Macros
-- Disable default macro key the plugin will set it up to <F4>
map('n', 'q', '<Nop>')

-- Don't yank on delete char
map('n', 'x', '"_x')
map('n', 'X', '"_X')
map('v', 'x', '"_x')
map('v', 'X', '"_X')
map('n', '<Del>', '"_x')
map('v', '<Del>', '"_x')

-- Duplicate lines without affecting PRIMARY and CLIPBOARD selections.
map('n', '<localleader>d', 'm`""Y""P``', { desc = 'Duplicate line' })
map('x', '<localleader>d', '""Y""Pgv', { desc = 'Duplicate selection' })
map('n', '<S-A-Down>', 'm`""Y""P``', { desc = 'Duplicate line' })
map('x', '<S-A-Down>', '""Y""Pgv', { desc = 'Duplicate selection' })

-- Move Lines
map('n', '<A-Down>', ':m .+1<CR>==', { desc = 'Move line down' })
map('n', '<A-Up>', ':m .-2<CR>==', { desc = 'Move line up' })
map('v', '<A-Down>', ":m '>+1<CR>gv=gv", { desc = 'Move line down' })
map('v', '<A-Up>', ":m '<-2<CR>gv=gv", { desc = 'Move line down' })
map('i', '<A-Down>', '<esc><cmd>m .+1<cr>==gi', { desc = 'Move line down' })
map('i', '<A-Up>', '<esc><cmd>m .-2<cr>==gi', { desc = 'Move line up' })

-- Insert lines stay in normal mode
map('n', '<localleader>o', 'o<Esc>', { desc = 'Insert new line in normal mode' })
map('n', '<localleader>O', 'O<Esc>', { desc = 'Insert new line before in normal mode' })

-- Select all
map('n', '<localleader>a', 'ggVG', { desc = 'Select all' })

-- Diagnostics keymap ]e ]i ]w ]d
local diag = require('custom.lib.diagnostics')
map_pair('n', 'd', diag.prev(), diag.next(), '[D]iagnostic')
map_pair('n', 'e', diag.prev('E'), diag.next('E'), '[E]rror diagnostic')
map_pair('n', 'w', diag.prev('W'), diag.next('W'), '[W]arning diagnostic')
map_pair('n', 'i', diag.prev('I'), diag.next('I'), '[I]nfo diagnostic')

map('n', '<S-l>', diag.float, { desc = 'Show diagnostic messages' })
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Terminal quick exit to vim mode
map('t', '<C-o>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Use tab for indenting in visual/select mode
map('x', '<Tab>', '>gv|', { desc = 'Indent Left' })
map('x', '<S-Tab>', '<gv', { desc = 'Indent Right' })

-- Keep viewport centered
map('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down' })
map('n', '<C-u>', '<C-u>zz', { desc = 'Scroll down' })
map('n', '<C-o>', '<C-o>zz', { desc = 'Previous position' })
map('n', '<C-i>', '<C-i>zz', { desc = 'Next position' })
map('n', '<C-f>', '<C-f>zz', { desc = 'Scroll forward' })
map('n', '<C-b>', '<C-b>zz', { desc = 'Scroll backward' })
map('n', 'G', 'Gzz')

-- Close anything order: floating window | splits | buffer
map({ 'n', 'i', 't' }, '<A-q>', function()
  require('custom.lib.smart-close').close()
end, { desc = 'Close floating windows' })

--Profiling
map('n', '<leader>uz', ':ToggleProfile<cr>', { silent = false, noremap = true, desc = 'Start a profilling session' })

-- run quick shell cmd
map('n', '!', ':R ', { desc = 'Execute Shell Command in the floating term', silent = false })

-- Work/Workflow specific keymaps
map('n', '<leader>pl', function()
  local pl = require('custom.lib.project-links')
  local select_menu = require('custom.lib.select-menu')
  local menu = select_menu.creat_select_menu('Project links', pl.get_links())
  menu()
end, { desc = 'Project links' })

-- Helper to create a jira link
map('v', '<leader>pj', ':JiraLink <C-R>"<CR>', { silent = false, desc = 'Create a jira link in markdown' })
map('n', '<leader>pj', ':JiraLink', { silent = false, desc = 'Create a jira link in markdown' })

-- Gitlab shortcuts
map('n', '<leader>glo', function()
  require('custom.lib.gitlab').open_git_remote()
end, { desc = 'Open Git remote for project' })

map('n', '<leader>glm', function()
  require('custom.lib.gitlab').open_git_mr()
end, { desc = 'Open Git mr for branch' })

map('n', '<leader>glc', function()
  require('custom.lib.gitlab').generate_chat_message_for_mr()
end, { desc = 'Generate a sharing message for MR' })
