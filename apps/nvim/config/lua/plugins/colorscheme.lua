return {
  {
    "rebelot/kanagawa.nvim",
    opts = {
      compile = true,
      colors = {
        theme = {
          all = {
            ui = {
              bg_gutter = "none",
            },
          },
        },
      },
    },
    config = function(_, opts)
      opts.overrides = function(colors)
        local theme = colors.theme
        return {
          -- TelescopeTitle = { fg = theme.ui.special, bold = true },
          -- TelescopePromptNormal = { bg = theme.ui.bg_p1 },
          -- TelescopePromptBorder = { fg = theme.ui.bg_p1, bg = theme.ui.bg_p1 },
          -- TelescopeResultsNormal = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m1 },
          -- TelescopeResultsBorder = { fg = theme.ui.bg_m1, bg = theme.ui.bg_m1 },
          -- TelescopePreviewNormal = { bg = theme.ui.bg_dim },
          -- TelescopePreviewBorder = { bg = theme.ui.bg_dim, fg = theme.ui.bg_dim },
          DiagnosticSignInfo = { bg = "none" },
          NormalFloat = { bg = "none" },
          FloatBorder = { bg = "none" },
          FloatTitle = { bg = "none" },
          -- Save an hlgroup with dark background and dimmed foreground
          -- so that you can use it where your still want darker windows.
          -- E.g.: autocmd TermOpen * setlocal winhighlight=Normal:NormalDark
          NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },

          -- Popular plugins that open floats will link to NormalFloat by default;
          -- set their background accordingly if you wish to keep them dark and borderless
          LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
          MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
          WinSeparator = { fg = "#393836" },
        }
      end
      require("kanagawa").setup(opts)
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "kanagawa-wave",
    },
  },
  -- {
  --   "folke/tokyonight.nvim",
  --   opts = {
  --     style = "night",
  --     on_colors = function(colors)
  --       colors.bg_visual = "#4663b9"
  --       colors.border = "#363b55"
  --     end,
  --     on_highlights = function(hl)
  --       hl.IlluminatedWordRead = {
  --         bg = "#33273f",
  --       }
  --       hl.IlluminatedWordText = {
  --         bg = "#33273f",
  --       }
  --       hl.IlluminatedWordWrite = {
  --         bg = "#33273f",
  --       }
  --     end,
  --   },
  -- },
}
