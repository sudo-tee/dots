return {

  {
    'rebelot/kanagawa.nvim',
    enabled = true,
    priority = 1000, -- make sure to load this before all the other start plugins
    opts = {
      compile = true,
      colors = {
        theme = {
          all = {
            ui = {
              bg_gutter = 'none',
            },
          },
        },
      },
    },
    config = function(_, opts)
      opts.overrides = function(colors)
        local theme = colors.theme

        return {
          DiagnosticSignInfo = { bg = 'none' },
          NormalFloat = { bg = 'none' },
          FloatBorder = { bg = 'none' },
          FloatTitle = { bg = 'none' },
          -- Save an hlgroup with dark background and dimmed foreground
          -- so that you can use it where your still want darker windows.
          -- E.g.: autocmd TermOpen * setlocal winhighlight=Normal:NormalDark
          NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },

          -- Popular plugins that open floats will link to NormalFloat by default;
          -- set their background accordingly if you wish to keep them dark and borderless
          LazyNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
          MasonNormal = { bg = theme.ui.bg_m3, fg = theme.ui.fg_dim },
          WinSeparator = { fg = '#393836' },
          -- Mini Status line
          MiniStatuslineModeVisual = { fg = '#15161e', bg = '#bb9af7' },
          MiniStatuslineModeCommand = { fg = '#15161e', bg = '#e0af68' },
          MiniStatuslineModeNormal = { fg = '#15161e', bg = '#7aa2f7' },
          MiniStatuslineModeOther = { fg = '#15161e', bg = '#1abc9c' },
          MiniStatuslineModeReplace = { fg = '#15161e', bg = '#f7768e' },
          MiniStatuslineModeInsert = { fg = '#15161e', bg = '#9ece6a' },
          CustomRecordingStatus = { fg = '#ff9e3b', bg = theme.ui.bg_m3 },
          CustomUpdatesStatus = { fg = '#1abc9c', bg = theme.ui.bg_m3 },

          CustomDiagnosticError = { fg = '#e82424', bg = theme.ui.bg_m3 },
          CustomDiagnosticWarn = { fg = '#ff9a3b', bg = theme.ui.bg_m3 },
          CustomDiagnosticInfo = { fg = '#659584', bg = theme.ui.bg_m3 },
          CustomDiagnosticHint = { fg = '#6a9589', bg = theme.ui.bg_m3 },
          -- mini tabline
          MiniTablineModifiedVisible = { fg = '#bada55', bg = '#2a2a37' },
          MiniTablineModifiedCurrent = { fg = '#bada55', bg = '#2a2a37' },
          MiniTablineModifiedHidden = { fg = '#556327', bg = '#16161d' },
        }
      end
      require('kanagawa').setup(opts)
      vim.cmd.colorscheme('kanagawa-wave')
    end,
  },
}
