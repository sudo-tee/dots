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

local function merge_requests()
  local mr_list = require('custom.lib.gitlab').get_mr_list()
  local select_menu = require('custom.lib.select-menu')

  if not mr_list then
    vim.notify('No merge requests found', vim.log.levels.INFO, { title = 'Merge requests' })
    return
  end

  local links = {}
  for _, mr in ipairs(mr_list) do
    table.insert(links, {
      u.fixed_width(mr.detailed_merge_status, 14) .. ' | ' .. mr.title,
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
      commit = '32e23af',
      dependencies = {
        'kkharji/sqlite.lua',
        { 'nvim-telescope/telescope-fzy-native.nvim' },
      },
      opts = {
        match_algorithm = 'fzy',
      },
    },
  },
  cmd = { 'Telescope' },
  -- stylua: ignore
  keys = {

    -- [S]earch
    { '<leader>sb',       u.cmd('Telescope buffers'),      desc = '[B]uffers' },
    { '<leader><leader>', u.cmd('Telescope buffers'),      desc = '[ ] buffers' },
    { '<C-p>'     ,       u.cmd('Telescope smart_open'),   desc = '[F]iles' },
    { '<leader>sh',       u.cmd('Telescope help_tags'),    desc = '[H]elp' },
    { '<leader>sk',       u.cmd('Telescope keymaps'),      desc = '[K]eymaps' },
    { '<leader>sf',       u.cmd('Telescope find_files'),   desc = '[F]iles' },
    { '<leader>ss',       u.cmd('Telescope builtin'),      desc = '[S]elect Telescope' },
    { '<leader>sw',       u.cmd('Telescope grep_string'),  desc = 'Current [W]ord' },
    { '<leader>sg',       u.cmd('Telescope live_grep'),    desc = 'by [G]rep' },
    { '<leader>sd',       u.cmd('Telescope diagnostics'),  desc = '[D]iagnostics' },
    { '<leader>sl',       u.cmd('Telescope resume'),       desc = 'resume [l]ast picker' },
    { '<leader>sM',       u.cmd('Telescope marks'),        desc = 'all [M]ark' },
    { '<leader>so',       u.cmd('Telescope oldfiles'),     desc = '[O]ld Files' },
    { '<leader>sp',       plugin_files,                    desc = '[P]lugin Files' },
    { '<leader>sn',       neovim_files,                    desc = '[N]eovim files' },
    { '<leader>s/',       grep_open_files,                 desc = '[/] in Open Files' },
    { '<leader>po',       find_project_overlay,            desc = '[P]roject [O]verlay' },
    { '<leader>/' ,       current_buffer_fuzzy,            desc = '[/] Fuzzily search in current buffer' },

    -- [P]roject
    { '<leader>pl',       project_links ,                  desc = '[P]roject [l]links'},
    { '<leader>pm',       merge_requests ,                 desc = '[P]roject [m]erge requests'},

    -- [G]it
    { '<leader>gbb',      u.cmd('Telescope git_bcommits'), desc = '[B]commits' },
    { '<leader>gbc',      u.cmd('Telescope git_branches'), desc = '[C]heckout' },
    { '<leader>gfc',      u.cmd('Telescope git_bcommits'), desc = '[C]ommits' },
    { '<leader>gcl',      u.cmd('Telescope git_commits'),  desc = '[L]og' },

  },
  opts = {
    defaults = {
      cwd = vim.loop.cwd(),
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
    opts.extensions = {
      ['smart_open'] = {
        match_algorithm = 'fzy',
        cwd_only = true,
      },
    }

    require('telescope').setup(opts)

    -- Enable telescope extensions, if they are installed
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'smart_open')
  end,
}
