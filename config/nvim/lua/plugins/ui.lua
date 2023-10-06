return {
  {
    "echasnovski/mini.indentscope",
    opts = function()
      return {
        symbol = "│",
        options = { try_as_border = true },
        draw = {
          delay = 200,
          animation = require("mini.indentscope").gen_animation.none(),
        },
      }
    end,
  },
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["<leader>m"] = { name = "+macros" },
        ["<leader>j"] = { name = "+jump" },
        ["<leader>r"] = { name = "+replace" },
        ["<localleader>j"] = { name = "+jira" },
        ["<localleader>d"] = { name = "+debug-print" },
      },
    },
  },
}
