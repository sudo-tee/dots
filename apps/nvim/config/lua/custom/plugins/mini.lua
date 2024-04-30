return { -- Collection of various small independent plugins/modules
  {
    'echasnovski/mini.nvim',
    lazy = true,
    event = 'VeryLazy',
    config = function()
      require('custom.plugins.mini.ai')
      require('custom.plugins.mini.comment')
      require('custom.plugins.mini.statusline')
      require('custom.plugins.mini.surround')
      require('custom.plugins.mini.tabline')
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
}
