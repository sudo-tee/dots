return {
  {
    "pmizio/typescript-tools.nvim",
    enabled = false,
    event = "VeryLazy",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = function(_, opts)
      opts.root_dir = require("lspconfig.util").root_pattern(".git")
    end,
  },
}
