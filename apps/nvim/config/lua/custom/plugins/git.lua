---@module 'custom.lib.utils'
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
  vim.cmd('DiffviewOpen origin/' .. git.default_branch() .. '...HEAD --imply-local')
end, {})

cmd('GitDiffBranch', function(args)
  vim.cmd('DiffviewOpen origin/' .. args.fargs[1] .. '...HEAD --imply-local')
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

  vim.cmd('CodeDiff ' .. first_commit_hash .. '~1..' .. last_commit_hash)
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
  {
    'esmuellert/codediff.nvim',
    -- dir = '~/Projects/_nvim/codediff.nvim',
    cmd = 'CodeDiff',
    keys = {
      -- stylua: ignore start
      -- { '<leader>gg',  u.cmd('CodeDiff'),                                   desc = 'Status' },
      -- { '<leader>gdm', u.cmd('GitDiffMain'),                                desc = 'Diff MAIN' },
      -- { '<leader>gfh', u.cmd('CodeDiff history %'),                         desc = 'File History' },
      -- { '<leader>gfH', u.cmd('CodeDiff history'),                           desc = 'File History' },
      -- { '<leader>glh', u.cmd('.CodeDiff history %'),                        desc = 'Line History' },
      -- { '<leader>gvh', "<Esc><Cmd>'<,'>CodeDiff history <CR>",              desc = 'Range History', mode="v" },
      -- stylua: ignore end
    },
    opts = {
      explorer = {
        view_mode = 'tree', -- "list" or "tree"
        indent_markers = false, -- Show indent markers in tree view (│, ├, └)
      },
    },
    config = function(_, opts)
      u.ft_map('codediff-explorer', function(event, map)
        map('n', 'c', u.cmd('Gc'), { desc = 'Git Commit' })
        map('n', 'a', u.cmd('Gca'), { desc = 'Git Commit Amend' })
        map('n', 'A', u.cmd('Gan'), { desc = 'Git Commit Amend No Edit' })
        map('n', 'p', u.cmd('Gp'), { desc = 'Git Push' })
        map('n', 'F', u.cmd('Gpl'), { desc = 'Git Push Force (with lease)' })
      end)

      require('codediff').setup(opts)
    end,
  },
  { 'tpope/vim-fugitive', lazy = true, cmd = { 'G', 'Gwrite', 'Gdiff', 'Gedit' } },
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
          vim.cmd(':CodeDiff ' .. commit.hash .. '~1...' .. commit.hash)
        end,
        on_select_range_commit = function(from, to)
          vim.cmd(':CodeDiff ' .. from.hash .. '~1..' .. to.hash)
        end,
      },
    },
    keys = {
      {
        '<leader>gL',
        function()
          require('gitgraph').draw({}, { all = true, max_count = 5000 })
        end,
        desc = 'GitGraph All',
      },
      {
        '<leader>gB',
        function()
          require('gitgraph').draw({}, { all = false, max_count = 5000 })
        end,
        desc = 'GitGraph Branch',
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
    'lewis6991/gitsigns.nvim',
    lazy = true,
    event = 'LazyFile',
    opts = {
      signs = {
        add = { text = '▌' },
        change = { text = '▌' },
        delete = { text = '' },
        topdelete = { text = '' },
        changedelete = { text = '▌' },
        untracked = { text = '▌' },
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
    'dlyongemallo/diffview.nvim',
    enabled = true,
    lazy = true,
    cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
    keys = {
      -- stylua: ignore start
      { '<leader>gg',  u.cmd('DiffviewOpen'),                               desc = 'Status' },
      { '<leader>gdm', u.cmd('GitDiffMain'),                                desc = 'Diff MAIN' },
      { '<leader>gfh', u.cmd('DiffviewFileHistory --follow %'),             desc = 'File History' },
      { '<leader>gfH', u.cmd('DiffviewFileHistory'),                        desc = 'File History' },
      { '<leader>glh', u.cmd('.DiffviewFileHistory --follow %'),            desc = 'Line History' },
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
            { 'n', 'q',          u.cmd('DiffviewClose'),  { desc = 'Close' } },
            { 'n', '<A-q>',      u.cmd('DiffviewClose'),  { desc = 'Close' } },
            { 'n', '<Leader>l',  actions.cycle_layout,    { desc = 'Cycle layout' } },
            { 'n', '-',          u.cmd("StageHunk"),      { desc = 'Stage hunk' } },
            { 'v', '-',          u.cmd("StageVisualHunk"),{ desc = 'Stage hunk' } },
          },
          file_panel = {
            { 'n', 'q',          u.cmd('DiffviewClose'), { desc = 'Close' } },
            { 'n', '<A-q>',      u.cmd('DiffviewClose'), { desc = 'Close' } },
            { 'n', 'c',          u.cmd('Gc'),            { desc = 'Git Commit' } },
            { 'n', 'a',          u.cmd('Gca'),           { desc = 'Git Commit Amend' } },
            { 'n', 'A',          u.cmd('Gan'),           { desc = 'Git Commit Amend No Edit' } },
            { 'n', 'p',          u.cmd('Gp'),            { desc = 'Git Push' } },
            { 'n', 'F',          u.cmd('Gpl'),           { desc = 'Git Push Force (with lease)' } },
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
