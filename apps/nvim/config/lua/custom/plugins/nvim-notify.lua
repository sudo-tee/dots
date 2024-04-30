return {
  'rcarriga/nvim-notify',
  lazy = true,
  event = 'VeryLazy',
  config = function()
    require('notify').setup({
      stages = 'static',
      timeout = 2000,
    })
    vim.notify = require('notify')
  end,
}
