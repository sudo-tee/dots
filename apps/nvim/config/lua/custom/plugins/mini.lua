return { -- Collection of various small independent plugins/modules
  {
    'echasnovski/mini.nvim',
    event = 'VeryLazy',
    config = function()
      require('custom.plugins.mini.ai')
      require('custom.plugins.mini.comment')
      require('custom.plugins.mini.notify')
      require('custom.plugins.mini.statusline')
      require('custom.plugins.mini.surround')

      require('mini.jump2d').setup({ mappings = {
        start_jumping = '',
      } })

      vim.keymap.set('n', '<CR>', ':lua MiniJump2d.start(MiniJump2d.builtin_opts.single_character)<cr>')
      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
}
