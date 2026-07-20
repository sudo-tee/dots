-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

vim.o.path = '.,,**'

vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, for help with jumping.
--  Experiment for yourself to see if you like it!
-- vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.opt.clipboard = '' -- use the osc52 plugin

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250
vim.opt.timeoutlen = 500

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace in the editor.
--  See :help 'list'
--  and :help 'listchars'
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true

vim.opt.laststatus = 3

vim.opt.cmdheight = 0

-- display mini bufferline
vim.opt.showtabline = 2

vim.opt.completeopt = 'menu,menuone,noselect'

-- Confirm to save changes before exiting modified buffer
vim.opt.confirm = true

vim.opt.autowrite = true

-- Dont show mode since we have a statusline
vim.opt.showmode = false

vim.opt.wrap = false

-- Position cursor anywhere in visual block
vim.opt.virtualedit = 'block'

-- Dont show the default intro message
vim.opt.shortmess:append('I')

-- Wrap arrow keys
vim.opt.whichwrap:append('<,>,[,]')

-- Add characters to set used to identify words
vim.opt.iskeyword:append({ '-' })

-- set exrc to enable local .nvim.lua files
vim.opt.exrc = true

vim.opt.spelllang = { 'en' }

vim.opt.termguicolors = true
vim.opt.autoread = true

vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'

-- Allow misspellings
vim.cmd.cnoreabbrev('qw', 'wq')
vim.cmd.cnoreabbrev('W', 'w')
vim.cmd.cnoreabbrev('Wq', 'wq')
vim.cmd.cnoreabbrev('WQ', 'wq')
vim.cmd.cnoreabbrev('Qa', 'qa')
vim.cmd.cnoreabbrev('Bd', 'bd')
vim.cmd.cnoreabbrev('bD', 'bd')
vim.cmd.cnoreabbrev('bD', 'bd')
vim.cmd.cnoreabbrev('Q', 'q')
vim.cmd.cnoreabbrev('H', 'h')

if vim.fn.executable('nvr') == 1 then
  local nvr = 'nvr --servername ' .. vim.v.servername .. ' '

  vim.env.GIT_EDITOR = nvr .. " +'setl bh=wipe' --remote-wait"
  vim.env.EDITOR = nvr .. '-l --remote' -- (Optional)
  vim.env.VISUAL = nvr .. '-l --remote' -- (Optional)
end

vim.g.disable_copilot = os.getenv('DISABLE_COPILOT') == 'true'

vim.g.notes_dir = os.getenv('HOME') .. '/Projects/notes/WorkDocs/scratch'
vim.g.have_nerd_font = true
