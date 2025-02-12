return { -- Collection of various small independent plugins/modules
  {
    'echasnovski/mini.nvim',
    lazy = true,
    event = 'VeryLazy',
    config = function()
      require('custom.plugins.mini.ai').setup()
      require('custom.plugins.mini.statusline').setup()
      require('custom.plugins.mini.surround').setup()
      require('custom.plugins.mini.tabline').setup()
      require('custom.plugins.mini.hipatterns').setup()
      require('custom.plugins.mini.operators').setup()

      require('mini.icons').setup({
        extension = {
          ['spec.ts'] = { glyph = '󰤒', hl = 'MiniIconsGreen' },
          ['test.ts'] = { glyph = '󰤒', hl = 'MiniIconsGreen' },
        },
      })
      MiniIcons.mock_nvim_web_devicons()

      require('custom.plugins.mini.clue').setup()
    end,
  },
}
