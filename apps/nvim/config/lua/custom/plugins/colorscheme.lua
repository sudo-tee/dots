---@module 'kanagawa'
return {
  {
    'rebelot/kanagawa.nvim',
    enabled = true,
    event = 'VimEnter',
    priority = 1000, -- make sure to load this before all the other start plugins
    ---@type KanagawaConfig
    opts = {
      compile = true,
      dimInactive = true,
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
      ---@type fun(colors: KanagawaColorsSpec): table<string, table>
      opts.overrides = function(colors)
        ---@type ThemeColors

        local theme = colors.theme

        return {
          ['@markup.link.url.markdown_inline'] = { link = 'Special' }, -- (url)
          ['@markup.link.label.markdown_inline'] = { link = 'WarningMsg' }, -- [label]
          ['@markup.italic.markdown_inline'] = { link = 'Exception' }, -- *italic*
          ['@markup.raw.markdown_inline'] = { link = 'String' }, -- `code`
          ['@markup.list.markdown'] = { link = 'Function' }, -- + list
          ['@markup.quote.markdown'] = { link = 'Error' }, -- > blockcode
          ['@markup.list.checked.markdown'] = { link = 'WarningMsg' }, -- - [X] checked list item
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
          MiniStatuslineCustomRecordingStatus = { fg = '#ffffff', bg = '#e82424' },
          MiniStatuslineCustomUpdatesStatus = { fg = '#1abc9c', bg = theme.ui.bg_m3 },

          MiniStatuslineCopilot = { fg = '#1abc9c', bg = theme.ui.bg_m3 },
          MiniStatuslineCopilotDisabled = { fg = '#997370', bg = theme.ui.bg_m3 },
          MiniStatuslineCopilotOffline = { fg = '#997370', bg = theme.ui.bg_m3 },
          MiniStatuslineCopilotIdle = { fg = '#54546d', bg = theme.ui.bg_m3 },
          MiniStatuslineCopilotNormal = { fg = '#7aa2f7', bg = theme.ui.bg_m3 },
          MiniStatuslineCopilotInProgress = { fg = '#9ece6a', bg = theme.ui.bg_m3 },
          MiniStatuslineCopilotWarning = { fg = '#ff9a3b', bg = theme.ui.bg_m3 },
          MiniStatuslineCustomDiagnosticError = { fg = '#e82424', bg = '#393836' },
          MiniStatuslineCustomDiagnosticWarn = { fg = '#ff9a3b', bg = '#393836' },
          MiniStatuslineCustomDiagnosticInfo = { fg = '#659584', bg = '#393836' },
          MiniStatuslineCustomDiagnosticHint = { fg = '#6a9589', bg = '#393836' },
          MiniStatuslineCustomDiagnostic = { fg = '#D7D7BA', bg = '#393836' },
          MiniStatuslineCustomNotes = { fg = '#6a9589', bg = theme.ui.bg_m3 },

          -- mini tabline
          MiniTablineModifiedVisible = { fg = '#bada55', bg = '#2a2a37' },
          MiniTablineModifiedCurrent = { fg = '#bada55', bg = '#2a2a37' },
          MiniTablineModifiedHidden = { fg = '#556327', bg = '#16161d' },

          -- Gitgraph
          GitGraphBranchMsg = { fg = '#D7D7BA' },
          GitGraphTimestamp = { fg = '#727169' },

          BlinkCmpMenu = { bg = theme.ui.bg_m3 },
          BlinkCmpMenuBorder = { bg = theme.ui.bg_m3, fg = '#54546d' },
          BlinkCmpDocBorder = { bg = theme.ui.bg_m3, fg = '#54546d' },

          AvanteSidebarWinSeparator = { bg = theme.ui.bg_dim, fg = '#393836' },
          AvanteSidebarWinHorizontalSeparator = { bg = theme.ui.bg_dim, fg = '#393836' },

          CopilotSuggestion = { link = 'Comment' },
        }
      end
      require('kanagawa').setup(opts)
      vim.cmd.colorscheme('kanagawa-wave')
    end,
  },
}
