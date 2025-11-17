-- Stand-alone Mini plugins with custom configs

return {
  {
    event = 'VeryLazy',
    'nvim-mini/mini.bufremove',
  },
  {
    event = 'VeryLazy',
    'nvim-mini/mini.ai',
    dependencies = {
      'nvim-mini/mini.extra',
    },
    version = false,
    config = function()
      require('custom.plugins.mini.ai').setup()
    end,
  },
  {
    event = 'VeryLazy',
    'nvim-mini/mini.clue',
    version = false,
    config = function()
      require('custom.plugins.mini.clue').setup()
    end,
  },
  {
    event = 'VeryLazy',
    'nvim-mini/mini.hipatterns',
    version = false,
    config = function()
      require('custom.plugins.mini.hipatterns').setup()
    end,
  },
  {
    event = 'VeryLazy',
    'nvim-mini/mini.operators',
    version = false,
    config = function()
      require('custom.plugins.mini.operators').setup()
    end,
  },
  {
    event = 'VeryLazy',
    'nvim-mini/mini.statusline',
    version = false,
    config = function()
      require('custom.plugins.mini.statusline').setup()
    end,
  },
  {
    event = 'VeryLazy',
    'nvim-mini/mini.surround',
    version = false,
    config = function()
      require('custom.plugins.mini.surround').setup()
    end,
  },
  {
    event = 'VeryLazy',
    'nvim-mini/mini.tabline',
    version = false,
    config = function()
      require('custom.plugins.mini.tabline').setup()
    end,
  },
  {
    event = 'VeryLazy',
    'nvim-mini/mini.icons',
    version = false,
    config = function()
      require('custom.plugins.mini.icons').setup()
    end,
  },
}
