return {
  {
    "EdenEast/nightfox.nvim",
    opts = {
      palettes = {
        carbonfox = {
          sel0 = "#4663b9",
        },
      },
    },

    config = function(_, opts)
      require("nightfox").setup(opts)
      -- vim.cmd("colorscheme carbonfox")
    end,
  },
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night",
      on_colors = function(colors)
        colors.bg_visual = "#4663b9"
        colors.border = "#363b55"
      end,
      on_highlights = function(hl)
        hl.IlluminatedWordRead = {
          bg = "#33273f",
        }
        hl.IlluminatedWordText = {
          bg = "#33273f",
        }
        hl.IlluminatedWordWrite = {
          bg = "#33273f",
        }
      end,
    },
  },
}
