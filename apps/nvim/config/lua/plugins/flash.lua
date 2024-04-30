return {
  "folke/flash.nvim",
  opts = {
    modes = {
      char = {
        autohide = true,
      },
      -- char = {
      --   label = { exclude = "hjkliardcn[]" },
      --   jump_labels = true,
      --   char_actions = function(motion)
      --     return {
      --       ["n"] = "right",
      --       ["N"] = "left",
      --       ["]"] = "right",
      --       ["["] = "left",
      --     }
      --   end,
      -- },
    },
  },
  keys = {
    {
      "<F12>",
      mode = { "c" },
      function()
        require("flash").toggle()
      end,
      desc = "Toggle Flash Search",
    },
    {
      "<a-f>",
      mode = { "n", "o" },
      function()
        require("flash").treesitter({
          jump = { pos = "start" },
          label = { before = true, after = false, style = "inline" },
        })
      end,
      desc = "Flash Treesitter",
    },
    {
      "<a-s>",
      mode = { "n", "o" },
      function()
        require("flash").treesitter({
          jump = { pos = "end" },
          label = { before = false, after = true, style = "inline" },
        })
      end,
      desc = "Flash Treesitter",
    },
  },
}
