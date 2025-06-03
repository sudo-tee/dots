-- Stand-alone Mini plugins with custom configs

return {
  { 'echasnovski/mini.bufremove' },
  {
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
    'echasnovski/mini.clue',
    version = false,
    config = function()
      require('custom.plugins.mini.clue').setup()
    end,
  },
  {
    'echasnovski/mini.hipatterns',
    version = false,
    config = function()
      require('custom.plugins.mini.hipatterns').setup()
    end,
  },
  {
    'echasnovski/mini.operators',
    version = false,
    config = function()
      require('custom.plugins.mini.operators').setup()
    end,
  },
  {
    'echasnovski/mini.statusline',
    version = false,
    config = function()
      require('custom.plugins.mini.statusline').setup()
    end,
  },
  {
    'echasnovski/mini.surround',
    version = false,
    config = function()
      require('custom.plugins.mini.surround').setup()
    end,
  },
  {
    'echasnovski/mini.tabline',
    version = false,
    config = function()
      require('custom.plugins.mini.tabline').setup()
    end,
  },
  {
    'echasnovski/mini.icons',
    version = false,
    config = function()
      require('custom.plugins.mini.icons').setup()
    end,
  },
}
