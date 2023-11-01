vim.cmd("command! Gd  :DiffviewOpen")
vim.cmd("command! Gdx :DiffviewClose")
vim.cmd("command! Gdr :DiffviewRefresh")
vim.cmd("command! Gc  :R git commit")
vim.cmd("command! Grc :R GIT_EDITOR=true git rebase --continue")
vim.cmd("command! Gca :R git commit --amend")
vim.cmd("command! Gaf :R git commit --amend --no-edit && git push --force-with-lease")
vim.cmd("command! Gp  :R git push")
vim.cmd("command! Gpl :R git push --force-with-lease")
vim.cmd("command! Grm :R git_rebase_current_branch")
vim.cmd("command! -nargs=?  Gri :R git rebase -i <args>")
vim.cmd("command! Gtrack :R git push -u origin $(git symbolic-ref --short -q HEAD)")

local rebase_interactive_hash = function()
  local lib = require("diffview.lib")
  local view = lib.get_current_view()
  if view then
    if view.panel:is_focused() then
      local item = view.panel:get_item_at_cursor()
      if item then
        vim.cmd("Gri " .. item.commit.hash)
        print(item.commit.hash)
      end
    end
  end
end

return {
  { "tpope/vim-fugitive" },
  -- {
  --   "rbong/vim-flog",
  --   cmd = { "Flog", "FlogSplit" },
  --   keys = {
  --     { "<leader>gfl", "<cmd>Flog<cr>", desc = { "Open Git log graph" } },
  --   },
  -- },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "▐" },
        change = { text = "▐" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▐" },
        untracked = { text = "▐" },
      },
    },
  },
  {
    "sindrets/diffview.nvim",
    branch = "main",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Git Diff View" },
      { "<leader>gfh", "<cmd>DiffviewFileHistory<CR>", desc = "Git Diff File History" },
    },
    opts = function()
      local actions = require("diffview.actions")

      return {
        enhanced_diff_hl = true, -- See ':h diffview-config-enhanced_diff_hl'
        keymaps = {
          view = {
            { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Close" } },
            { "n", "<A-q>", "<cmd>DiffviewClose<CR>", { desc = "Close" } },
            { "n", "<Tab>", actions.select_next_entry },
            { "n", "<S-Tab>", actions.select_prev_entry },
            { "n", "<Leader>a", actions.focus_files },
            { "n", "<Leader>e", actions.toggle_files },
            { "n", "<Leader>rc", "<cmd>Grc<CR>", { desc = "Git Rebase Continue" } },
            { "n", "<Leader>rm", "<cmd>Grm<CR>", { desc = "Git Rebase master/main" } },
          },
          file_panel = {
            { "n", "q", "<cmd>DiffviewClose<CR>", { desc = "Close" } },
            { "n", "<A-q>", "<cmd>DiffviewClose<CR>", { desc = "Close" } },
            { "n", "c", "<cmd>Gc<CR>", { desc = "Git Commit" } },
            { "n", "ac", "<cmd>Gca<CR>", { desc = "Git Commit Amend" } },
            { "n", "AF", "<cmd>Gaf<CR>", { desc = "Git Commit Amend + Force" } },
            { "n", "p", "<cmd>Gp<CR>", { desc = "Git Push" } },
            { "n", "F", "<cmd>Gpl<CR>", { desc = "Git Push Force (with lease)" } },
            { "n", "<Leader>rc", "<cmd>Grc<CR>", { desc = "Git Rebase Continue" } },
            { "n", "<Leader>rm", "<cmd>Grm<CR>", { desc = "Git Rebase master/main" } },
            { "n", "h", actions.prev_entry({ desc = "Previuos entry" }) },
          },
          file_history_panel = {
            { "n", "q", "<cmd>DiffviewClose<CR>" },
            { "n", "<A-q>", "<cmd>DiffviewClose<CR>" },
            { "n", "o", actions.focus_entry },
            { "n", "O", actions.options },
            { "n", "<Leader>ri", rebase_interactive_hash, { desc = "Git Rebase interactive" } },
          },
        },
      }
    end,
  },
}
