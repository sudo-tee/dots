local u = require('custom.lib.utils')

---@module 'custom.lib.git'
local git = lazy_require('custom.lib.git')

local cmd = vim.api.nvim_create_user_command

vim.cmd('command! Gc  :Sh git commit')
vim.cmd('command! Grc :Sh GIT_EDITOR=true git rebase --continue')
vim.cmd('command! Gca :Sh git commit --amend')
vim.cmd('command! Gan :Sh git commit --amend --no-edit')
vim.cmd('command! Gaf :Sh git commit --amend --no-edit && git push --force-with-lease')
vim.cmd('command! Gp  :Sh git push')
vim.cmd('command! Gpl :Sh git push --force-with-lease')
vim.cmd('command! Gpr :Sh git pull --rebase')
vim.cmd('command! Grim :Sh git rim')
vim.cmd('command! Grbm :Sh git rbm')
vim.cmd('command! -nargs=?  Gri :Sh git rebase -i <args>')

cmd('GitDiffMain', function()
  vim.cmd('DiffviewOpen origin/' .. git.default_branch() .. '...HEAD')
end, {})

cmd('GitDiffBranch', function(args)
  vim.cmd('DiffviewOpen origin/' .. args.fargs[1] .. '...HEAD')
end, { nargs = '*' })

cmd('OpenCommitDiff', function()
  local commit_hash = git.find_nearest_commit_hash()
  vim.cmd('DiffviewOpen ' .. commit_hash .. '^!')
end, {})

cmd('OpenCommitRangeDiff', function()
  local last_commit_hash = git.find_nearest_commit_hash()

  -- Move to the start of the visual selection
  vim.cmd('normal! o')

  local first_commit_hash = git.find_nearest_commit_hash()

  vim.cmd('DiffviewOpen ' .. first_commit_hash .. '~1..' .. last_commit_hash)
end, { range = true })

cmd('StageHunk', function()
  require('gitsigns').stage_hunk()
end, {})

cmd('StageVisualHunk', function()
  require('gitsigns').stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
end, {})

u.map('n', '<leader>grm', u.cmd('Grbm'), { desc = 'rebase main/master' })
u.map('n', '<leader>grc', u.cmd('Grc'), { desc = 'rebase continue' })
u.map('n', '<leader>gcc', u.cmd('Gc'), { desc = 'commit' })
u.map('n', '<leader>gpr', u.cmd('Gpr'), { desc = 'pull rebase' })
u.map('n', '<leader>gpl', u.cmd('Gpl'), { desc = 'push force lease' })
u.map('n', '<leader>gpp', u.cmd('Gp'), { desc = 'push' })

return {
  { 'tpope/vim-fugitive', lazy = true, cmd = { 'G', 'Gwrite', 'Gdiff', 'Gedit' } },
  {
    'SuperBo/fugit2.nvim',
    opts = {
      width = 90,
      libgit2_path = '/home/linuxbrew/.linuxbrew/Cellar/libgit2/1.8.1/lib/libgit2.so',
      external_diffview = true,
    },
    dependencies = {
      'MunifTanjim/nui.nvim',
      'nvim-tree/nvim-web-devicons',
      'nvim-lua/plenary.nvim',
    },
    build = function() end,
    cmd = { 'Fugit2', 'Fugit2Diff', 'Fugit2Graph' },
    keys = {
      { '<leader>gS', mode = 'n', '<cmd>Fugit2<cr>', desc = 'Status' },
      { '<leader>gG', mode = 'n', '<cmd>Fugit2Graph<cr>', desc = 'Graph' },
    },
    config = function(_, opts)
      u.ft_map({ 'fugit2*', 'diff' }, function(_, map)
        map('n', '<leader>d', u.cmd('OpenCommitDiff'))
        map('v', '<leader>d', u.cmd('OpenCommitRangeDiff'))
        map('n', '<C-Right>', 'l', { noremap = false })
        map('n', '<C-Left>', 'h', { noremap = false })
      end)

      require('fugit2').setup(opts)
    end,
  },
  {
    'isakbm/gitgraph.nvim',
    opts = {
      symbols = {
        merge_commit = '◉',
        commit = '○',
      },
      format = {
        timestamp = '%H:%M:%S %d-%m-%Y',
        fields = { 'hash', 'timestamp', 'author', 'branch_name', 'tag' },
      },
      hooks = {
        on_select_commit = function(commit)
          vim.cmd(':DiffviewOpen ' .. commit.hash .. '^!')
        end,
        on_select_range_commit = function(from, to)
          vim.cmd(':DiffviewOpen ' .. from.hash .. '~1..' .. to.hash)
        end,
      },
    },
    keys = {
      {
        '<leader>gL',
        function()
          require('gitgraph').draw({}, { all = true, max_count = 5000 })
        end,
        desc = 'GitGraph - Draw',
      },
      {
        '<leader>gB',
        function()
          require('gitgraph').draw({}, { all = false, max_count = 5000 })
        end,
        desc = 'GitGraph - Draw',
      },
    },
    config = function(_, opts)
      u.ft_map('gitgraph', function(_, map)
        map('n', 'q', u.cmd('bd!'))
        map('n', '<leader>B', function()
          vim.cmd('bd!')
          require('gitgraph').draw({}, { all = false, max_count = 5000 })
        end)
        map('n', '<leader>A', function()
          vim.cmd('bd!')
          require('gitgraph').draw({}, { all = true, max_count = 5000 })
        end)
      end)

      require('gitgraph').setup(opts)
    end,
  },

  {
    'rbong/vim-flog',
    dependencies = {
      'tpope/vim-fugitive',
      'sindrets/diffview.nvim',
    },
    lazy = true,
    cmd = { 'Flog', 'FlogSplit' },
    keys = {
      { '<leader>gF', u.cmd('Flog'), desc = 'Graph' },
    },
    opts = function()
      vim.g.flog_default_opts = {
        date = 'format:%Y-%m-%d %H:%M',
      }
      vim.g.flog_use_internal_lua = true
      ---@TODO: need a patched font
      ---https://github.com/rbong/flog-symbols
      -- vim.g.flog_enable_extended_chars = 1
    end,
    config = function()
      u.ft_map('floggraph', function(_, map)
        map('n', '<leader>d', u.cmd('OpenCommitDiff'))
        map('v', '<leader>d', u.cmd('OpenCommitRangeDiff'))
      end)
    end,
  },
  {
    'lewis6991/gitsigns.nvim',
    lazy = true,
    event = 'LazyFile',
    opts = {
      signs = {
        add = { text = '█' },
        change = { text = '█' },
        delete = { text = '' },
        topdelete = { text = '' },
        changedelete = { text = '█' },
        untracked = { text = '█' },
      },
      preview_config = {
        border = 'rounded',
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- stylua: ignore start
        map("n",          "]h",          gs.next_hunk,                                  "[N]ext [H]unk")
        map("n",          "[h",          gs.prev_hunk,                                  "[P]rev [H]unk")
        map({ "n", "v" }, "<leader>ghs", gs.stage_hunk,                                 "[S]tage [H]unk")
        map({ "n", "v" }, "<leader>ghr", gs.reset_hunk,                                 "[R]eset [H]unk")
        map("n",          "<leader>ghS", gs.stage_buffer,                               "[S]tage Buffer")
        map("n",          "<leader>ghu", gs.undo_stage_hunk,                            "[U]ndo Stage Hunk")
        map("n",          "<leader>ghR", gs.reset_buffer,                               "[R]eset Buffer")
        map("n",          "<leader>ghp", gs.preview_hunk,                               "[P]review [H]unk")
        map("n",          "<leader>ghb", function() gs.blame_line({ full = true }) end, "[B]lame Line")
        map('n',          "<leader>ghB", gs.toggle_current_line_blame,                  "[B]lame Line (Toggle)")
        map("n",          "<leader>ghd", gs.diffthis,                                   "[D]iff This")
        map("n",          "<leader>ghD", function() gs.diffthis("~") end,               "[G]it [D]iff This ~")
        map({ "o", "x" }, "ih",          ":<C-U>Gitsigns select_hunk<CR>",              "Select [H]unk")
        -- stylua: ignore end
      end,
    },
  },
  {
    'sindrets/diffview.nvim',
    lazy = true,
    cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
    keys = {
      -- stylua: ignore start
      { '<leader>gg',  u.cmd('DiffviewOpen'),                               desc = 'Status' },
      { '<leader>gdm', u.cmd('GitDiffMain'),                                desc = 'Diff MAIN' },
      { '<leader>gfh', u.cmd('DiffviewFileHistory'),                        desc = 'File History' },
      { '<leader>gfH', u.cmd('DiffviewFileHistory --follow %'),             desc = 'File History' },
      { '<leader>glh', u.cmd('.DiffviewFileHistory --follow %'), desc = 'Line History' },
      { '<leader>gvh', "<Esc><Cmd>'<,'>DiffviewFileHistory --follow %<CR>", desc = 'Range History', mode="v" },
      -- stylua: ignore end
    },
    init = function()
      vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
        group = u.augroup('diffview/refresh'),
        callback = function()
          local view = require('diffview.lib').get_current_view()
          if view then
            vim.cmd('DiffviewRefresh')
          end
        end,
      })
    end,
    opts = function()
      local actions = require('diffview.actions')

      return {
        enhanced_diff_hl = true, -- See ':h diffview-config-enhanced_diff_hl',
        view = {
          merge_tool = {
            layout = 'diff3_mixed',
            disable_diagnostics = true,
          },
        },
        keymaps = {
          -- stylua: ignore start
          view = {
            { 'n', 'q',          u.cmd('DiffviewClose'), { desc = 'Close' } },
            { 'n', '<A-q>',      u.cmd('DiffviewClose'), { desc = 'Close' } },
            { 'n', '<Leader>l',  actions.cycle_layout,   { desc = 'Cycle layout' } },
            { 'n', '-',  u.cmd("StageHunk"),   { desc = 'Stage hunk' } },
            { 'v', '-',  u.cmd("StageVisualHunk"),   { desc = 'Stage hunk' } },
          },
          file_panel = {
            { 'n', 'q',          u.cmd('DiffviewClose'), { desc = 'Close' } },
            { 'n', '<A-q>',      u.cmd('DiffviewClose'), { desc = 'Close' } },
            { 'n', 'c',          u.cmd('Gc'),            { desc = 'Git Commit' } },
            { 'n', 'a',          u.cmd('Gca'),           { desc = 'Git Commit Amend' } },
            { 'n', 'A',          u.cmd('Gan'),           { desc = 'Git Commit Amend No Edit' } },
            { 'n', 'p',          u.cmd('Gp'),            { desc = 'Git Push' } },
            { 'n', 'F',          u.cmd('Gpl'),           { desc = 'Git Push Force (with lease)' } },
            { 'n', '<Leader>rc', u.cmd('Grc'),           { desc = 'Git Rebase Continue' } },
            { 'n', '<Leader>rm', u.cmd('Grm'),           { desc = 'Git Rebase master/main' } },
            { 'n', 'h',          actions.prev_entry,     { desc = 'Previuos entry' } },
            { 'n', '<Leader>l', actions.cycle_layout,   { desc = 'Cycle layout' } },
          },
          file_history_panel = {
            { 'n', 'q',          u.cmd('DiffviewClose'),  { desc = 'Close' }},
            { 'n', '<A-q>',      u.cmd('DiffviewClose'),  { desc = 'Close' }},
            { 'n', '<Leader>l',  actions.cycle_layout,    { desc = 'Cycle layout' } },
            { "n", "<Leader>d",  actions.open_in_diffview,{ desc = "Open in Diffview" } },

          },
          -- stylua: ignore end
        },
      }
    end,
  },
}
