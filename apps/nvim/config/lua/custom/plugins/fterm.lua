return {
  'numToStr/FTerm.nvim',
  lazy = true,
  event = 'VeryLazy',
  cmd = { 'FTerm' },
  opts = {
    autoinsert = 1,
    direction_cmd = 'botright',
    shell = 'zsh',
  },
  -- stylua: ignore
  keys = {
    {'<M-t>', function() require('FTerm').open() end, { desc = 'Open FTerm' }},
  },
  init = function()
    vim.api.nvim_create_user_command('Sh', function(command)
      require('FTerm').scratch({ cmd = 'source ~/.zshrc && ' .. command.args })
    end, { nargs = '*' })
  end,
}
