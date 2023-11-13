return {
  "ThePrimeagen/refactoring.nvim",
  enabled = false,
  keys = {
    {
      "<leader>rp",
      function()
        require("refactoring").debug.printf({ below = false })
      end,
    },
    {
      "<leader>rv",
      function()
        require("refactoring").debug.print_var()
      end,
    },
    {
      "<leader>rc",
      function()
        require("refactoring").debug.cleanup({})
      end,
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
}
