return {
  {
    "zeioth/garbage-day.nvim",
    dependencies = "neovim/nvim-lspconfig",
    event = "VeryLazy",
    opts = {
      "eslint",
    },
  },
  {
    "hinell/lsp-timeout.nvim",
    event = "VeryLazy",
    enabled = false,
    dependencies = { "neovim/nvim-lspconfig" },
    init = function()
      vim.g.lspTimeoutConfig = {
        stopTimeout = 1000 * 60 * 5, -- ms, timeout before stopping all LSPs
        startTimeout = 1000 * 10, -- ms, timeout before restart
        silent = true, -- true to suppress notifications
      }
    end,
  },
}
