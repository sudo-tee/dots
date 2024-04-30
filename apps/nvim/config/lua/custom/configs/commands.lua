local command = vim.api.nvim_create_user_command

local function replace_text(text, replacement)
  replacement = replacement or ''
  local move_between_slashes = vim.api.nvim_replace_termcodes('<Left><Left>', true, true, true)
  vim.api.nvim_feedkeys(':%s/' .. text .. '/' .. replacement .. '/g' .. move_between_slashes, 'n', false)
end

command('ReplaceSelection', function()
  vim.api.nvim_exec('normal! "ay', false)
  local selected_text = vim.fn.getreg('a')

  replace_text(selected_text)
end, {})

command('ReplaceWord', function()
  local selected_text = vim.fn.expand('<cword>')

  replace_text(selected_text)
end, {})

-- start profiling
command('StartProfile', function()
  vim.cmd([[profile start profile.log]])
  vim.cmd([[profile func *]])
  vim.cmd([[profile file *]])
  require('plenary.profile').start('profile-lua.log')
  vim.notify('Profilling ...')
end, {})

command('StopProfile', function()
  vim.cmd('profile stop')
  require('plenary.profile').stop()
  vim.notify('End of profilling, opening results')
  vim.cmd('e profile.log')
  vim.cmd('e profile-lua.log')
end, {})

local is_profiling = false
command('ToggleProfile', function()
  if is_profiling then
    vim.cmd('StopProfile')
    is_profiling = false
  else
    vim.cmd('StartProfile')
    is_profiling = true
  end
end, {})

command('JiraLink', function(ticket)
  require('custom.lib.jira').create_jira_link(ticket.fargs[1])
end, { nargs = '*' })
