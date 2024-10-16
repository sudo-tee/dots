return {
  'MagicDuck/grug-far.nvim',
  dependencies = {
    {
      'zbirenbaum/copilot.lua',
      opts = {
        filetypes = {
          ['grug-far'] = false,
          ['grug-far-history'] = false,
          ['grug-far-help'] = false,
        },
      },
    },
  },

  ---@module 'grug-far'
  ---@type GrugFarOptions
  opts = {
    keymaps = {
      openLocation = { n = '<enter>' },
      openNextLocation = { n = '<S-Down>' },
      openPrevLocation = { n = '<S-Up>' },
      gotoLocation = { n = '<leader><enter>' },
      close = { n = 'q' },
    },
  },
  keys = {
    {
      '<leader>rr',
      function()
        require('grug-far').open()
      end,
      desc = '[S]earch and [R]eplace',
    },
    {
      '<leader>rR',
      function()
        require('grug-far').open({ prefills = { paths = vim.fn.expand('%') } })
      end,
      desc = '[S]earch and [R]eplace',
    },
    {
      '<leader>rr',
      function()
        require('grug-far').with_visual_selection({ prefills = { paths = vim.fn.expand('%') } })
      end,
      desc = '[S]earch and [R]eplace (Visual Selection)',
      mode = 'v',
    },
    {
      '<leader>rw',
      function()
        require('grug-far').open({ prefills = { search = vim.fn.expand('<cword>') } })
      end,
      desc = '[S]earch and [R]eplace word',
    },
    {
      '<leader>rW',
      function()
        require('grug-far').open({ prefills = { search = vim.fn.expand('<cword>'), { paths = vim.fn.expand('%') } } })
      end,
      desc = '[S]earch and [R]eplace word in file',
    },
    {
      '<leader>rW',
      function()
        require('grug-far').with_visual_selection({ prefills = { { paths = vim.fn.expand('%') } } })
      end,
      desc = '[S]earch and [R]eplace in file (Visual Selection)',
    },
  },

  config = function(_, opts)
    require('grug-far').setup(opts)
  end,
}
