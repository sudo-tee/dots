local u = require('custom.lib.utils')
local cmd = u.cmd
local map = u.map
local map_pair = u.map_pair

-- Release for surround
map('n', 's', '<Nop>')

--file related maps
map('n', '<leader>fn', cmd('enew'), { desc = '[N]ew File' })

-- Yank absolute path
map('n', '<Leader>fya', function()
  u.yank(vim.fn.expand('%:p'))
end, { desc = '[a]bsolute path' })

-- Yank buffer's relative path
map('n', '<Leader>fyr', function()
  u.yank(vim.fn.expand('%:~:.'))
end, { desc = '[r]elative path' })

-- Yank buffer's filename
map('n', '<Leader>fyn', function()
  u.yank(vim.fn.expand('%:t'))
end, { desc = '[n]ame' })

map('n', '<Esc>', cmd('nohlsearch'))

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

-- quickfix list
map_pair('n', 'q', cmd('cprev'), cmd('cnext'), '[q]uickfix item')

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
map('n', 'G', 'Gzz', { desc = 'Go to end' })

-- Utilities to replace text
map('n', '<leader>*', '*Ncgn', { desc = 'Change word with . repeat' })
map('x', '<leader>rv', cmd('ReplaceSelection'), { desc = '[R]eplace [v]isually selected text' })
map('n', '<leader>rw', cmd('ReplaceWord'), { desc = '[R]eplace [w]ord under cursor' })

-- Close anything order: floating window | splits |
map({ 'n', 'i', 't' }, '<A-q>', function()
  require('custom.lib.smart-close').close()
end, { desc = 'Close floating windows' })

-- buffer navigation, only for listed buffers
-- so it does not navigate to files on unwanted layout buffers
-- like (floating windows, diffview, neotest, etc)

local function bufnav(command)
  return function()
    if vim.bo.buflisted then
      vim.cmd(command)
    end
  end
end

map('n', '<S-Right>', bufnav('bnext'), { desc = 'Prev [B]uffer' })

map('n', '<S-Left>', bufnav('bprev'), { desc = 'Next [B]uffer' })

-- ]b [b
map_pair('n', 'b', bufnav('bprev'), bufnav('bnext'), '[b]uffer')
map('n', '<leader>`', bufnav('e #'), { desc = 'Switch to alternate ' })
map('n', '<leader>bo', bufnav('%bd|edit#|bd#'), { desc = 'Close [o]ther [b]uffers' })

-- Custom UI keymaps

--Profiling
map('n', '<leader>up', cmd('ToggleProfile'), { silent = false, noremap = true, desc = 'Toggle [p]rofilling session' })
-- highlights under cursor
map('n', '<leader>ui', vim.show_pos, { desc = '[I]nspect Pos' })

map('n', '<leader>ur', cmd('w | e'), { desc = '[R]fresh file' })

-- run quick shell cmd
map('n', '!', ':Sh ', { desc = 'Execute Shell Command in the floating term', silent = false })

-- Work/Workflow specific keymaps

-- Helper to create a jira link
map('v', '<leader>pj', 'y:JiraLink <C-R>"<CR>', { silent = false, desc = 'Create a [j]ira link in markdown' })
map('n', '<leader>pj', ':JiraLink', { silent = false, desc = 'Create a [j]ira link in markdown' })

-- Gitlab shortcuts
map('n', '<leader>glo', function()
  require('custom.lib.gitlab').open_git_remote()
end, { desc = '[O]pen [G]itab remote for project' })

map('n', '<leader>glm', function()
  require('custom.lib.gitlab').open_git_mr()
end, { desc = '[O]pen [G]itlab mr for branch' })

map('n', '<leader>glc', function()
  require('custom.lib.gitlab').generate_chat_message_for_mr()
end, { desc = 'Generate a sharing message for MR' })
