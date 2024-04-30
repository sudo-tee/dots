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
    {'n', '<leader>ft', function() require('FTerm').open() end, } 
  },
  init = function()
    vim.api.nvim_create_user_command('Sh', function(command)
      require('FTerm').scratch({ cmd = 'source ~/.zshrc && ' .. command.args })
    end, { nargs = '*' })
  end,
}
