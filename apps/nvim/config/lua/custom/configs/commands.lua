local command = vim.api.nvim_create_user_command

local function replace_text(text, replacement)
  replacement = replacement or ''
  local move_between_slashes = vim.api.nvim_replace_termcodes('<Left><Left>', true, true, true)
  vim.api.nvim_feedkeys(':%s/' .. text .. '/' .. replacement .. '/g' .. move_between_slashes, 'n', false)
end

command('ReplaceSelection', function()
  vim.api.nvim_exec2('normal! "ay', {})
  local selected_text = vim.fn.getreg('a')

  replace_text(selected_text)
end, {})

command('ReplaceWord', function()
  local selected_text = vim.fn.expand('<cword>')

  replace_text(selected_text)
end, {})

-- jit profiler + inferno flamegraph
local function toggle_profile(out)
  if not _G.jit_profile then
    out = out or '/tmp/tmp/profile.log'
    _G.jit_profile_out = out
    vim.fn.mkdir(vim.fs.dirname(out), 'p')
    -- G option for https://github.com/jonhoo/inferno
    require('jit.p').start('10,i1,s,m0,G', out)
    vim.notify('profile started: ' .. out)
  else
    require('jit.p').stop()
    local profile_out = _G.jit_profile_out or out or '/tmp/tmp/profile.log'
    _G.jit_profile_out = nil
    local svg = vim.fn.fnamemodify(profile_out, ':r') .. '.svg'
    vim.fn.system(('inferno-flamegraph %s > %s'):format(profile_out, svg))
    vim.system({ vim.env.BROWSER or 'xdg-open', svg })
    vim.notify('profile stopped: ' .. svg)
  end
  _G.jit_profile = not _G.jit_profile
end

command('ToggleProfile', function(opts)
  local out = opts.args ~= '' and opts.args or nil
  toggle_profile(out)
end, { nargs = '?' })

command('JiraLink', function(ticket)
  require('custom.lib.jira').create_jira_link(ticket.fargs[1])
end, { nargs = '*' })

command('Restart', function()
  require('custom.lib.utils').restart()
end, {})
