-- [[ Basic Autocommands ]]
--  See :help lua-guide-autocommands
local augroup = require('custom.lib.utils').augroup

-->> "RUN ONCE" ON FILE OPEN COMMANDS <<--
-- prevent comment from being inserted when entering new line in existing comment
vim.api.nvim_create_autocmd('BufWinEnter', {
  callback = function()
    vim.opt_local.formatoptions:remove({ 'r', 'o' })
  end,
})

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
    'AvanteInput',
  },
  callback = function(args)
    vim.keymap.set('n', 'q', '<cmd>quit<cr>', { buffer = args.buf })
    vim.keymap.set({ 'n' }, '<ESC>', '<cmd>close<CR>', { silent = true, buffer = true })
  end,
})

local function ensure_dir_exists(dir)
  if not vim.fn.isdirectory(dir) then
    vim.fn.mkdir(dir, 'p')
  end
end

---@param subFolder string -- subdirectory (e.g., 'shada', 'session')
---@param prefix string   -- prefix for filename
---@param suffix string   -- file extension or suffix
---@return string|nil
local function get_nvim_data_file(subFolder, prefix, suffix)
  local git = require('custom.lib.git')
  local utils = require('custom.lib.utils')
  local root = git.get_git_root(vim.fn.getcwd())
  if not root then
    return nil
  end
  local folder_hash = utils.string_hash(root)
  local dir = vim.fn.stdpath('data') .. '/' .. subFolder
  ensure_dir_exists(dir)
  local fname = string.format('%s/%s_%s%s', dir, prefix, folder_hash, suffix)
  return vim.fn.fnameescape(fname)
end

-- Set project-specific shada file
local function set_project_shada()
  local shada_file = get_nvim_data_file('shada', 'shada', '.shada')
  if shada_file then
    vim.go.shadafile = shada_file
  else
    vim.go.shadafile = vim.fn.fnameescape(vim.fn.stdpath('data') .. '/shada/main.shada')
  end
  if vim.fn.filereadable(vim.go.shadafile) == 1 then
    vim.cmd('rshada ' .. vim.go.shadafile)
  end
end

-- Get project-specific session file
local function get_project_session(prefix)
  prefix = prefix or ''
  local session_file = get_nvim_data_file('session', prefix .. '_session', '.vim')
  return session_file
end

vim.api.nvim_create_autocmd('User', {
  group = augroup('SessionSave', { clear = true }),
  pattern = 'RestartPre',
  callback = function()
    local bufs = vim.api.nvim_list_bufs()
    for _, bufnr in ipairs(bufs) do
      local bopts = vim.bo[bufnr]
      local should_delete = not vim.api.nvim_buf_is_loaded(bufnr) or not bopts.buflisted or bopts.filetype == 'qf'

      if should_delete then
        vim.api.nvim_buf_delete(bufnr, { force = true })
      end
    end

    local session_file = get_project_session('restart_')
    if session_file then
      vim.cmd('mksession! ' .. session_file)
    end
  end,
})

vim.api.nvim_create_autocmd('VimEnter', {
  group = augroup('SessionLoad', { clear = true }),
  pattern = '*',
  callback = function()
    vim.defer_fn(function()
      local session_file = get_project_session('restart_')
      if session_file and vim.fn.filereadable(session_file) == 1 then
        vim.cmd('source ' .. session_file)
        vim.fn.system('rm ' .. session_file)
      end
    end, 100)
  end,
})

vim.api.nvim_create_autocmd({ 'DirChanged', 'VimEnter' }, {
  group = augroup('ProjectShada', { clear = true }),
  pattern = '*',
  callback = set_project_shada,
})

-- syntax highlighting for dotenv files
vim.api.nvim_create_autocmd('BufRead', {
  group = augroup('DotenvFt', { clear = true }),
  pattern = { '.env', '.env.*', '.env.*.*' },
  callback = function()
    vim.bo.filetype = 'ini'
  end,
})
