local cmd = vim.api.nvim_create_user_command

cmd('R', function(command)
  require('FTerm').scratch({ cmd = command.args })
end, { nargs = '*' })

-- start profiling
cmd('StartProfile', function()
  vim.cmd([[profile start profile.log]])
  vim.cmd([[profile func *]])
  vim.cmd([[profile file *]])
  require('plenary.profile').start('profile-lua.log')
  vim.notify('Profilling ...')
end, {})

cmd('StopProfile', function()
  vim.cmd('profile stop')
  require('plenary.profile').stop()
  vim.notify('End of profilling, opening results')
  vim.cmd('e profile.log')
  vim.cmd('e profile-lua.log')
end, {})

local is_profiling = false
cmd('ToggleProfile', function()
  if is_profiling then
    vim.cmd('StopProfile')
    is_profiling = false
  else
    vim.cmd('StartProfile')
    is_profiling = true
  end
end, {})

cmd('JiraLink', function(ticket)
  require('custom.lib.jira').create_jira_link(ticket.fargs[1])
end, { nargs = '*' })
