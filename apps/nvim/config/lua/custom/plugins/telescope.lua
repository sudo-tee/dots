local enabled = false

if not enabled then
  return {}
end
local function paste_from_register()
  local reg = '"'
  local ctrl_r_key = vim.api.nvim_replace_termcodes('<C-R>', true, false, true)
  local quote_key = vim.api.nvim_replace_termcodes(reg, true, false, true)

  vim.api.nvim_feedkeys(ctrl_r_key .. quote_key, 'n', true)
end

local function open_with_diff_view(bufnr)
  require('telescope.actions').close(bufnr)
  local value = require('telescope.actions.state').get_selected_entry().value
  vim.cmd('DiffviewOpen ' .. value .. '~1..' .. value)
end

return { -- Fuzzy Finder (files, lsp, etc)
  'nvim-telescope/telescope.nvim',
  enabled = false,
  lazy = true,
  dependencies = {
    'nvim-lua/plenary.nvim',
    { -- If encountering errors, see telescope-fzf-native README for install instructions
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
    },
    { 'stevearc/dressing.nvim', opts = {} },
    {
      'echasnovski/mini.nvim',
    },

    {
      'danielfalk/smart-open.nvim',
      branch = '0.2.x',
      dependencies = {
        'kkharji/sqlite.lua',
        { 'nvim-telescope/telescope-fzy-native.nvim' },
      },
      opts = {
        cwd_only = true,
        match_algorithm = 'fzy',
      },
    },
    'debugloop/telescope-undo.nvim',
  },
  cmd = { 'Telescope' },
  -- stylua: ignore
  keys = {

    -- [S]earch
    -- { '<leader>sb',       u.cmd('Telescope buffers'),      desc = 'Buffers' },
    -- { '<C-p>'     ,       u.cmd('Telescope smart_open'),   desc = 'Files' },
    -- { '<leader>sh',       u.cmd('Telescope help_tags'),    desc = 'Help' },
    -- { '<leader>sk',       u.cmd('Telescope keymaps'),      desc = 'Keymaps' },
    -- { '<leader>sf',       u.cmd('Telescope find_files'),   desc = 'Files' },
    { '<leader>ss',       u.cmd('Telescope builtin'),      desc = 'Select Telescope' },
    -- { '<leader>sw',       u.cmd('Telescope grep_string'),  desc = 'Current [W]ord' },
    -- { '<leader>sg',       u.cmd('Telescope live_grep'),    desc = 'Grep' },
    -- { '<leader>sd',       u.cmd('Telescope diagnostics'),  desc = 'Diagnostics' },
    { '<leader>sl',       u.cmd('Telescope resume'),       desc = 'Resume last picker' },
    -- { '<leader>sM',       u.cmd('Telescope marks'),        desc = 'Marks' },
    -- { '<leader>so',       u.cmd('Telescope oldfiles'),     desc = 'Old Files' },
    { '<leader>sh',       u.cmd('Telescope undo'),         desc = 'File History' },
    -- { '<leader>sp',       plugin_files,                    desc = 'Plugin Files' },
    -- { '<leader>sn',       neovim_files,                    desc = 'Neovim files' },
    -- { '<leader>s/',       grep_open_files,                 desc = 'Grep Open Files' },
    -- { '<leader>po',       find_project_overlay,            desc = 'Project Overlay' },
    -- { '<leader>/' ,       current_buffer_fuzzy,            desc = 'Fuzzily search in current buffer' },

    -- [P]roject


    -- [G]it
    -- { '<leader>gbb',      u.cmd('Telescope git_bcommits'), desc = 'Bcommits' },
    -- { '<leader>gbc',      u.cmd('Telescope git_branches'), desc = 'Checkout' },
    -- { '<leader>gfc',      u.cmd('Telescope git_bcommits'), desc = 'Commits' },
    -- { '<leader>gcl',      u.cmd('Telescope git_commits'),  desc = 'Log' },

    -- [N]otes
    -- { '<leader>nn',       notes,                           desc = 'Notes' },
    -- { '<leader>ng',       grep_notes,                      desc = 'Grep Notes' },

  },
  opts = {
    defaults = {
      file_sorter = require('telescope.sorters').get_fzy_sorter,
      cwd = vim.uv.cwd(),
      path_display = {
        filename_first = {
          reverse_directories = false,
        },
      },
      mappings = {
        i = {
          ['<esc>'] = 'close',
          ['<C-Down>'] = 'cycle_history_next',
          ['<C-Up>'] = 'cycle_history_prev',
          ['<a-p>'] = paste_from_register,
        },
      },
    },
    pickers = {
      oldfiles = {
        cwd_only = true,
      },
      grep_string = {
        word_match = '-w',
      },
      git_commits = {
        mappings = {
          i = {
            ['<a-d>'] = open_with_diff_view,
          },
        },
      },
      git_bcommits = {
        mappings = {
          i = {
            ['<a-d>'] = open_with_diff_view,
          },
        },
      },
    },
  },
  config = function(_, opts)
    -- Two important keymaps to use while in telescope are:
    --  - Insert mode: <c-/>
    --  - Normal mode: ?
    --

    opts.extensions = {
      smart_open = {
        match_algorithm = 'fzy',
        cwd_only = true,
      },

      undo = {
        entry_format = '⨀ #$ID [$STAT] \t\t$TIME',
        mappings = {
          i = {
            ['<C-d>'] = require('telescope-undo.actions').yank_deletions,
            ['<C-a>'] = require('telescope-undo.actions').yank_additions,
            ['<C-r>'] = require('telescope-undo.actions').restore,
          },
        },
      },
    }

    require('telescope').setup(opts)
    pcall(require('telescope').load_extension, 'fzy')
    pcall(require('telescope').load_extension, 'smart_open')
    pcall(require('telescope').load_extension, 'undo')
  end,
}
