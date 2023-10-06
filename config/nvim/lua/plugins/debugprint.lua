local debugTag = "[🧭]"

return {
  "andrewferrier/debugprint.nvim",
  keys = {
    {
      "<localleader>dd",
      function()
        return require("debugprint").debugprint()
      end,
      desc = "debug print",
      expr = true,
    },
    {
      mode = { "v", "n" },
      "<localleader>dq",
      function()
        return require("debugprint").debugprint({ variable = true })
      end,
      desc = "debug print with variables",
      expr = true,
    },
    {
      "<localleader>dx",
      function()
        return require("debugprint").deleteprints()
      end,
      desc = "remove all debug print for buffer",
    },
    {
      "<localleader>ds",
      ":g/" .. debugTag .. "/norm va(o$O_d",
      desc = "delete all debug print for buffer",
      silent = false,
    },
    {
      "<localleader>dt",
      function()
        require("telescope.builtin").live_grep({ default_text = debugTag })
      end,
      desc = "delete all debug print for buffer",
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
