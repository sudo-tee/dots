vim.cmd('command! Gc  :Sh git commit')
vim.cmd('command! Grc :Sh GIT_EDITOR=true git rebase --continue')
vim.cmd('command! Gca :Sh git commit --amend')
vim.cmd('command! Gaf :Sh git commit --amend --no-edit && git push --force-with-lease')
vim.cmd('command! Gp  :Sh git push')
vim.cmd('command! Gpl :Sh git push --force-with-lease')
vim.cmd('command! Grim :Sh git rim')
vim.cmd('command! Grbm :Sh git rbm')
vim.cmd('command! -nargs=?  Gri :R git rebase -i <args>')

return {
  { 'tpope/vim-fugitive', event = 'VeryLazy', cmd = { 'G' } },
  {
    'rbong/vim-flog',
    event = 'VeryLazy',
    cmd = { 'Flog', 'FlogSplit' },
    keys = {
      { '<leader>gfl', '<cmd>Flog<cr>', desc = 'Open Git log graph' },
    },
  },
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    event = 'VeryLazy',
    opts = {
      signs = {
        add = { text = '█' },
        change = { text = '█' },
        delete = { text = '' },
        topdelete = { text = '' },
        changedelete = { text = '█' },
        untracked = { text = '█' },
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- stylua: ignore start
        map("n", "]h", gs.next_hunk, "Next Hunk")
        map("n", "[h", gs.prev_hunk, "Prev Hunk")
        map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },
  {
    'sindrets/diffview.nvim',
    branch = 'main',
    lazy = true,
    cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
    keys = {
      { '<leader>gd', '<cmd>DiffviewOpen<CR>', desc = 'Git Diff View' },
      {
        '<leader>gmd',
        function()
          vim.cmd('DiffviewOpen origin/' .. require('custom.lib.utils').git_default_branch() .. '...HEAD')
        end,
        desc = 'Git Diff MAIN',
      },
      { '<leader>gfh', '<cmd>DiffviewFileHistory<CR>', desc = 'Git Diff File History' },
    },
    opts = function()
      local actions = require('diffview.actions')

      return {
        enhanced_diff_hl = true, -- See ':h diffview-config-enhanced_diff_hl'
        keymaps = {
          view = {
            { 'n', 'q', '<cmd>DiffviewClose<CR>', { desc = 'Close' } },
            { 'n', '<A-q>', '<cmd>DiffviewClose<CR>', { desc = 'Close' } },
            { 'n', '<Leader>rc', '<cmd>Grc<CR>', { desc = 'Git Rebase Continue' } },
            { 'n', '<Leader>rm', '<cmd>Grm<CR>', { desc = 'Git Rebase master/main' } },
            { 'n', '<Leader>\\', actions.cycle_layout },
          },
          file_panel = {
            { 'n', 'q', '<cmd>DiffviewClose<CR>', { desc = 'Close' } },
            { 'n', '<A-q>', '<cmd>DiffviewClose<CR>', { desc = 'Close' } },
            { 'n', 'c', '<cmd>Gc<CR>', { desc = 'Git Commit' } },
            { 'n', 'A', '<cmd>Gca<CR>', { desc = 'Git Commit Amend' } },
            { 'n', 'p', '<cmd>Gp<CR>', { desc = 'Git Push' } },
            { 'n', 'F', '<cmd>Gpl<CR>', { desc = 'Git Push Force (with lease)' } },
            { 'n', '<Leader>rc', '<cmd>Grc<CR>', { desc = 'Git Rebase Continue' } },
            { 'n', '<Leader>rm', '<cmd>Grm<CR>', { desc = 'Git Rebase master/main' } },
            { 'n', 'h', actions.prev_entry({ desc = 'Previuos entry' }) },
            { 'n', '<Leader>\\', actions.cycle_layout },
          },
          file_history_panel = {
            { 'n', 'q', '<cmd>DiffviewClose<CR>' },
            { 'n', '<A-q>', '<cmd>DiffviewClose<CR>' },
            { 'n', '<Leader>\\', actions.cycle_layout },
          },
        },
      }
    end,
  },
}
