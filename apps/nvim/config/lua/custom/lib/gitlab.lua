---@module 'custom.lib.utils'
local u = lazy_require('custom.lib.utils')

---@module 'custom.lib.git'
local git = lazy_require('custom.lib.git')

---@module 'custom.lib.wezterm'
local wezterm = lazy_require('custom.lib.wezterm')

local M = {}

M.status_icons = {
  not_approved = '🟡',
  mergeable = '✅',
  conflicts = '⛔',
  need_rebase = '🔁',
  draft_status = '📝',
  ci_must_pass = '❕',
  ci_must_still_running = '🕐',
  discussions_not_resolved = '💬',
}

M.pipeline_icons = {
  success = '🟢',
  failed = '🔴',
  running = '🕐',
  pending = '🟡',
  canceled = '🚫',
  skipped = '⏭️',
}

M.open_git_remote = function()
  local remote_url = git.get_repo_url()

  if string.len(remote_url) == 0 then
    vim.notify('Not in a git repository', vim.log.levels.WARN)
    return
  end

  print('Opening git remote url:', remote_url)
  wezterm.open_url(remote_url)
  vim.fn.setreg('+', remote_url)
end

M.get_mr_details = function()
  local cmd_output = vim.fn.system('glab api -X GET projects/:id/merge_requests  --field source_branch=:branch')
  local json = u.decode_json(cmd_output)

  if json ~= nil and json[1] then
    return json[1]
  end

  return nil
end

M.get_current_mr_url = u.memoize(function(branch)
  print('Getting current MR url for branch', branch)

  local details = M.get_mr_details()
  return details and details.web_url or nil
end)

M.create_new_mr = function()
  local success, _ = pcall(vim.fn.system, 'glab mr new -f -w')
  if not success then
    return nil
  end
  return u.read_file('/tmp/xdg-open-url') or ''
end

M.open_git_mr = function()
  local branch = git.current_branch()

  print('Opening MR for branch')

  local web_url = M.get_current_mr_url(branch) or M.create_new_mr()

  wezterm.open_url(web_url)
  vim.fn.setreg('+', web_url)
end

M.get_project_folder = function()
  local cwd = vim.loop.cwd()
  return string.match(cwd or '', '[^/]+$')
end

M.get_mr_list = function()
  local cmd_output = vim.fn.system('glab mr list --output=json --author=fbelanger')
  local json = u.decode_json(cmd_output)

  return json
end

M.generate_chat_message_for_mr = function()
  local details = M.get_mr_details()

  if details == nil then
    vim.notify('No merge request found', vim.log.levels.INFO)
    return
  end

  local project_folder = M.get_project_folder()
  local title = details.title
  local web_url = details.web_url

  local message = string.format('Ⓜ MR (%s) | %s \n%s', project_folder, title, web_url)
  vim.notify('⚡ MR message copied to clipboard!', vim.log.levels.INFO)
  vim.fn.setreg('+', message)
end

return M
