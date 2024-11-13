return {
  enabled = true,
  'numToStr/FTerm.nvim',
  lazy = true,
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
      -- Expand any vim expansion characters in the arguments
      local expanded_args = vim.fn.expandcmd(command.args)
      require('FTerm').scratch({
        cmd = 'source ~/.zshrc && ' .. expanded_args,
      })
    end, { nargs = '*', bang = true })
  end,
}
