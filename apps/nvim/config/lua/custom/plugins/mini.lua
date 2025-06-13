-- Stand-alone Mini plugins with custom configs

return {
  {
    event = 'VeryLazy',
    'echasnovski/mini.bufremove',
  },
  {
    event = 'VeryLazy',
    'echasnovski/mini.ai',
    dependencies = {
      'echasnovski/mini.extra',
    },
    version = false,
    config = function()
      require('custom.plugins.mini.ai').setup()
    end,
  },
  {
    event = 'VeryLazy',
    'echasnovski/mini.clue',
    version = false,
    config = function()
      require('custom.plugins.mini.clue').setup()
    end,
  },
  {
    event = 'VeryLazy',
    'echasnovski/mini.hipatterns',
    version = false,
    config = function()
      require('custom.plugins.mini.hipatterns').setup()
    end,
  },
  {
    event = 'VeryLazy',
    'echasnovski/mini.operators',
    version = false,
    config = function()
      require('custom.plugins.mini.operators').setup()
    end,
  },
  {
    event = 'VeryLazy',
    'echasnovski/mini.statusline',
    version = false,
    config = function()
      require('custom.plugins.mini.statusline').setup()
    end,
  },
  {
    event = 'VeryLazy',
    'echasnovski/mini.surround',
    version = false,
    config = function()
      require('custom.plugins.mini.surround').setup()
    end,
  },
  {
    event = 'VeryLazy',
    'echasnovski/mini.tabline',
    version = false,
    config = function()
      require('custom.plugins.mini.tabline').setup()
    end,
  },
  {
    event = 'VeryLazy',
    'echasnovski/mini.icons',
    version = false,
    config = function()
      require('custom.plugins.mini.icons').setup()
    end,
  },
}
