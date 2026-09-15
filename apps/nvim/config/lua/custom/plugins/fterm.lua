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
      local terminal
      terminal = require('FTerm'):new({
        cmd = 'source ~/.zshrc && ' .. expanded_args,
        auto_close = true,
        on_exit = function(_, exit_code)
          if exit_code ~= 0 and (not terminal.win or not vim.api.nvim_win_is_valid(terminal.win)) then
            vim.schedule(function()
              terminal:open()
            end)
          end
        end,
      })
      terminal:open()
      if vim.api.nvim_buf_is_valid(terminal.buf) then
        vim.api.nvim_create_autocmd('BufEnter', {
          buffer = terminal.buf,
          callback = function()
            if terminal.terminal and vim.fn.jobwait({ terminal.terminal }, 0)[1] == -1 then
              vim.cmd.startinsert()
            end
          end,
        })
      end
    end, { nargs = '*', bang = true })
  end,
}
