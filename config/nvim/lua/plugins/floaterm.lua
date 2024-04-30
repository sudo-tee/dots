return {
  { "numToStr/FTerm.nvim" },
  {
    "rebelot/terminal.nvim",
    event = "VeryLazy",
    command = { "TermRun" },
    keys = {
      {
        "<leader>zo",
        function()
          print("Sssss")
          local term_map = require("terminal.mappings")
          term_map.toggle({ open_cmd = "enew" })
        end,
      },
    },
  },
}
