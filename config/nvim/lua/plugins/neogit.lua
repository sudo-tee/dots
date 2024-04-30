return {
  {
    "NeogitOrg/neogit",
    dependencies = "nvim-lua/plenary.nvim",
    cmd = { "Neogit" },
    opts = {
      commit_popup = {
        kind = "split_above",
      },
    },
  },
}
