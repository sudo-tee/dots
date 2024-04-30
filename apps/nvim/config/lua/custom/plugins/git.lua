---@module 'custom.lib.utils'
local u = lazy_require('custom.lib.utils')
local cmd = vim.api.nvim_create_user_command

vim.cmd('command! Gc  :Sh git commit')
vim.cmd('command! Grc :Sh GIT_EDITOR=true git rebase --continue')
vim.cmd('command! Gca :Sh git commit --amend')
vim.cmd('command! Gaf :Sh git commit --amend --no-edit && git push --force-with-lease')
vim.cmd('command! Gp  :Sh git push')
vim.cmd('command! Gpl :Sh git push --force-with-lease')
vim.cmd('command! Grim :Sh git rim')
vim.cmd('command! Grbm :Sh git rbm')
vim.cmd('command! -nargs=?  Gri :R git rebase -i <args>')

cmd('GitDiffMain', function()
  vim.cmd('DiffviewOpen origin/' .. require('custom.lib.utils').git_default_branch() .. '...HEAD')
end, {})

return {
  { 'tpope/vim-fugitive', lazy = true, event = 'VeryLazy', cmd = { 'G' } },
  {
    'rbong/vim-flog',
    lazy = true,
    event = 'VeryLazy',
    cmd = { 'Flog', 'FlogSplit' },
    keys = {
      { '<leader>glg', u.cmd('Flog'), desc = '[G]it [l]og [g]raph' },
    },
  },
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    lazy = true,
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
        map("n",          "]h",          gs.next_hunk,                                  "[N]ext [H]unk")
        map("n",          "[h",          gs.prev_hunk,                                  "[P]rev [H]unk")
        map({ "n", "v" }, "<leader>ghs", u.cmd('Gitsigns stage_hunk'),                  "[S]tage [H]unk")
        map({ "n", "v" }, "<leader>ghr", u.cmd('Gitsigns reset_hunk'),                  "[R]eset [H]unk")
        map("n",          "<leader>ghS", gs.stage_buffer,                               "[S]tage Buffer")
        map("n",          "<leader>ghu", gs.undo_stage_hunk,                            "[U]ndo Stage Hunk")
        map("n",          "<leader>ghR", gs.reset_buffer,                               "[R]eset Buffer")
        map("n",          "<leader>ghp", gs.preview_hunk_inline,                        "[P]review [H]unk Inline")
        map("n",          "<leader>ghb", function() gs.blame_line({ full = true }) end, "[B]lame Line")
        map("n",          "<leader>ghd", gs.diffthis,                                   "[D]iff This")
        map("n",          "<leader>ghD", function() gs.diffthis("~") end,               "[G]it [D]iff This ~")
        map({ "o", "x" }, "ih",          ":<C-U>Gitsigns select_hunk<CR>",              "Select [H]unk")
        -- stylua: ignore end
      end,
    },
  },
  {
    'sindrets/diffview.nvim',
    branch = 'main',
    lazy = true,
    cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
    keys = {
      -- stylua: ignore start
      { '<leader>gd',  u.cmd('DiffviewOpen'),        desc = '[G]it [D]iff View' },
      { '<leader>gmd', u.cmd('GitDiffMain'),         desc = '[G]it [D]iff [M]AIN' },
      { '<leader>gfh', u.cmd('DiffviewFileHistory'), desc = '[G]it [F]ile [H]istory' },
      -- stylua: ignore end
    },
    opts = function()
      local actions = require('diffview.actions')

      return {
        enhanced_diff_hl = true, -- See ':h diffview-config-enhanced_diff_hl'
        keymaps = {
          -- stylua: ignore start
          view = {
            { 'n', 'q',          u.cmd('DiffviewClose'), { desc = 'Close' } },
            { 'n', '<A-q>',      u.cmd('DiffviewClose'), { desc = 'Close' } },
            { 'n', '<Leader>rc', u.cmd('Grc'),           { desc = 'Git Rebase Continue' } },
            { 'n', '<Leader>rm', u.cmd('Grm'),           { desc = 'Git Rebase master/main' } },
            { 'n', '<Leader>\\', actions.cycle_layout,   { desc = 'Cycle layout' } },
          },
          file_panel = {
            { 'n', 'q',          u.cmd('DiffviewClose'), { desc = 'Close' } },
            { 'n', '<A-q>',      u.cmd('DiffviewClose'), { desc = 'Close' } },
            { 'n', 'c',          u.cmd('Gc'),            { desc = 'Git Commit' } },
            { 'n', 'A',          u.cmd('Gca'),           { desc = 'Git Commit Amend' } },
            { 'n', 'p',          u.cmd('Gp'),            { desc = 'Git Push' } },
            { 'n', 'F',          u.cmd('Gpl'),           { desc = 'Git Push Force (with lease)' } },
            { 'n', '<Leader>rc', u.cmd('Grc'),           { desc = 'Git Rebase Continue' } },
            { 'n', '<Leader>rm', u.cmd('Grm'),           { desc = 'Git Rebase master/main' } },
            { 'n', 'h',          actions.prev_entry,     { desc = 'Previuos entry' } },
            { 'n', '<Leader>\\', actions.cycle_layout,   { desc = 'Cycle layout' } },
          },
          file_history_panel = {
            { 'n', 'q',          u.cmd('DiffviewClose'), { desc = 'Close' }},
            { 'n', '<A-q>',      u.cmd('DiffviewClose'), { desc = 'Close' }},
            { 'n', '<Leader>\\', actions.cycle_layout,   { desc = 'Cycle layout' } },
          },
          -- stylua: ignore end
        },
      }
    end,
  },
}
