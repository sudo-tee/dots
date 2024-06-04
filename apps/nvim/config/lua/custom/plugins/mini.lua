return { -- Collection of various small independent plugins/modules
  {
    'echasnovski/mini.nvim',
    lazy = true,
    event = 'LazyFile',
    config = function()
      require('custom.plugins.mini.ai').setup()
      require('custom.plugins.mini.statusline').setup()
      require('custom.plugins.mini.surround').setup()
      require('custom.plugins.mini.tabline').setup()
      require('custom.plugins.mini.hipatterns').setup()
      require('custom.plugins.mini.operators').setup()
    end,
  },
}
