return {
  {
    "monkoose/matchparen.nvim",
    opts = {
      on_startup = true, -- Should it be enabled by default
      hl_group = "MatchParen", -- highlight group of the matched brackets
      augroup_name = "matchparen", -- almost no reason to touch this unless there is already augroup with such name
      debounce_time = 100, -- debounce time in milliseconds for rehighlighting of brackets.
    },
  },
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
        ["<leader>p"] = { name = "+project" },
        ["<leader>m"] = { name = "+macros" },
        ["<leader>j"] = { name = "+jump" },
        ["<leader>r"] = { name = "+replace" },
        ["<localleader>j"] = { name = "+jira" },
        ["<localleader>d"] = { name = "+debug-print" },
      },
    },
  },
}
