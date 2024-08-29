local u = require('custom.lib.utils')

--- Highlight the path part of the file as comment
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'TelescopeResults',
  callback = function(ctx)
    vim.api.nvim_buf_call(ctx.buf, function()
      vim.fn.matchadd('TelescopeParent', '\t\t.*$')
      vim.api.nvim_set_hl(0, 'TelescopeParent', { link = 'Comment' })
    end)
  end,
})

local function find_project_overlay()
  require('telescope.builtin').find_files({
    hidden = true,
    find_command = { 'find-overlays' },
    prompt_title = 'Project overlays',
  })
end

local function current_buffer_fuzzy()
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown({
    winblend = 10,
    previewer = false,
  }))
end

local function grep_open_files()
  require('telescope.builtin').live_grep({
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  })
end

local function neovim_files()
  require('telescope.builtin').find_files({ cwd = vim.fn.stdpath('config') })
end

local function plugin_files()
  local lazypath = vim.fn.stdpath('data') .. '/lazy/'
  require('telescope.builtin').find_files({ cwd = lazypath, file_ignore_patterns = { '.git' } })
end

local function project_links()
  local pl = require('custom.lib.project-links')
  local select_menu = require('custom.lib.select-menu')
  local menu = select_menu.create_select_menu('Project links', pl.get_links(), { add_numbers = true })
  menu()
end

local function notes()
  local notes_path = os.getenv('HOME') .. '/Projects/notes'
  require('telescope.builtin').find_files({ cwd = notes_path, file_ignore_patterns = { '.git', '.obsidian' } })
end

local function grep_notes()
  local notes_path = os.getenv('HOME') .. '/Projects/notes'
  require('telescope.builtin').live_grep({ cwd = notes_path, file_ignore_patterns = { '.git', '.obsidian' } })
end

local function merge_requests()
  local glab = require('custom.lib.gitlab')
  local mr_list = glab.get_mr_list()
  local select_menu = require('custom.lib.select-menu')

  if not mr_list then
    vim.notify('No merge requests found', vim.log.levels.INFO, { title = 'Merge requests' })
    return
  end

  local links = {}
  for _, mr in ipairs(mr_list) do
    local status_icon = glab.status_icons[mr.detailed_merge_status] or '❔'
    table.insert(links, {
      status_icon .. u.fixed_width(mr.detailed_merge_status, 11) .. ' | ' .. mr.title .. ' (' .. mr.user_notes_count .. ')',

      u.open_url_callback(mr.web_url),
    })
  end

  local menu = select_menu.create_select_menu('Active merge requests', links, { add_numbers = true })
  menu()
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
  lazy = true,
  dependencies = {
    'nvim-lua/plenary.nvim',
    { -- If encountering errors, see telescope-fzf-native README for install instructions
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
    },
    { 'stevearc/dressing.nvim', opts = {} },
    { 'nvim-tree/nvim-web-devicons' },

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
    { '<leader>sb',       u.cmd('Telescope buffers'),      desc = 'Buffers' },
    { '<leader><leader>', u.cmd('Telescope buffers'),      desc = 'Buffers' },
    { '<C-p>'     ,       u.cmd('Telescope smart_open'),   desc = 'Files' },
    { '<leader>sh',       u.cmd('Telescope help_tags'),    desc = 'Help' },
    { '<leader>sk',       u.cmd('Telescope keymaps'),      desc = 'Keymaps' },
    { '<leader>sf',       u.cmd('Telescope find_files'),   desc = 'Files' },
    { '<leader>ss',       u.cmd('Telescope builtin'),      desc = 'Select Telescope' },
    { '<leader>sw',       u.cmd('Telescope grep_string'),  desc = 'Current [W]ord' },
    { '<leader>sg',       u.cmd('Telescope live_grep'),    desc = 'Grep' },
    { '<leader>sd',       u.cmd('Telescope diagnostics'),  desc = 'Diagnostics' },
    { '<leader>sl',       u.cmd('Telescope resume'),       desc = 'Resume last picker' },
    { '<leader>sM',       u.cmd('Telescope marks'),        desc = 'Marks' },
    { '<leader>so',       u.cmd('Telescope oldfiles'),     desc = 'Old Files' },
    { '<leader>sh',       u.cmd('Telescope undo'),         desc = 'File History' },
    { '<leader>sp',       plugin_files,                    desc = 'Plugin Files' },
    { '<leader>sn',       neovim_files,                    desc = 'Neovim files' },
    { '<leader>s/',       grep_open_files,                 desc = 'Grep Open Files' },
    { '<leader>po',       find_project_overlay,            desc = 'Project Overlay' },
    { '<leader>/' ,       current_buffer_fuzzy,            desc = 'Fuzzily search in current buffer' },

    -- [P]roject
    { '<leader>pl',       project_links ,                  desc = 'Project links'},
    { '<leader>pm',       merge_requests ,                 desc = 'Project merge requests'},

    -- [G]it
    { '<leader>gbb',      u.cmd('Telescope git_bcommits'), desc = 'Bcommits' },
    { '<leader>gbc',      u.cmd('Telescope git_branches'), desc = 'Checkout' },
    { '<leader>gfc',      u.cmd('Telescope git_bcommits'), desc = 'Commits' },
    { '<leader>gcl',      u.cmd('Telescope git_commits'),  desc = 'Log' },

    -- [N]otes
    { '<leader>nn',       notes,                           desc = 'Notes' },
    { '<leader>ng',       grep_notes,                      desc = 'Grep Notes' },

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
            ['<C-y>'] = require('telescope-undo.actions').yank_additions,
            ['<C-Y>'] = require('telescope-undo.actions').yank_deletions,
            ['<C-cr>'] = require('telescope-undo.actions').restore,
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
