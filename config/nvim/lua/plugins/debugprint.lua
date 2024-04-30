local debugTag = "[🧭]"

return {
  "andrewferrier/debugprint.nvim",
  keys = {
    {
      "<localleader>dd",
      function()
        return require("debugprint").debugprint()
      end,
      desc = "Debug print",
      expr = true,
    },
    {
      mode = { "v", "n" },
      "<localleader>dq",
      function()
        return require("debugprint").debugprint({ variable = true })
      end,
      desc = "Debug print with variables",
      expr = true,
    },
    {
      "<localleader>ds",
      function()
        return require("debugprint").deleteprints()
      end,
      desc = "Remove all debug print for buffer",
    },
    {
      "<localleader>dx",
      ":g/" .. debugTag .. "/norm va(o$O_d",
      desc = "Delete prints for buffer",
      silent = false,
    },
    {
      "<localleader>dt",
      function()
        require("telescope.builtin").live_grep({ default_text = debugTag })
      end,
      desc = "Find all debug print for project",
      silent = false,
    },
    {
      "<localleader>dc",
      function()
        vim.fn.setreg("+", debugTag)
        vim.fn.setreg("*", debugTag)
      end,
      desc = "Copy debug prefix",
      silent = false,
    },
  },
  opts = { create_keymaps = false, print_tag = debugTag },

  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
}
