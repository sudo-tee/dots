local M = {}

M.open_git_remote = function()
  local wez = require('custom.lib.wezterm')

  local cmd_output = vim.fn.system('git config --get remote.origin.url 2> /dev/null'):gsub('\n', '')
  local remote_url = cmd_output:gsub(':', '/'):gsub('git@', 'https://')

  if string.len(remote_url) == 0 then
    print('Not in a git repository')
    return
  end

  print('Opening git remote url:', remote_url)
  wez.open_url(remote_url)
  vim.fn.setreg('+', remote_url)
end

M.get_current_mr_url = function()
  local cmd_output = vim.fn.system('glab api -X GET projects/:id/merge_requests  --field source_branch=:branch')
  local success, json = pcall(vim.json.decode, cmd_output)

  if success then
    if json and json[1] then
      return json[1].web_url
    end
  end
  return nil
end

function M.create_new_mr()
  local utils = require('custom.lib.utils')
  local success, _ = pcall(vim.fn.system, 'glab mr new -f -w')
  if not success then
    return nil
  end
  return utils.read_file('/tmp/xdg-open-url') or ''
end

M.open_git_mr = function()
  local wez = require('custom.lib.wezterm')
  print('Opening MR for branch')

  local web_url = M.get_mr_url()

  if web_url == nil then
    web_url = M.create_new_mr()
  end

  wez.open_url(web_url)
  vim.fn.setreg('+', web_url)
end

function M.get_project_folder()
  local cwd = vim.loop.cwd()
  return string.match(cwd or '', '[^/]+$')
end

M.generate_chat_message_for_mr = function()
  local u = require('custom.lib.utils')
  local cmd_output = vim.fn.system('glab api -X GET projects/:id/merge_requests  --field source_branch=:branch')

  if cmd_output == nil or string.len(cmd_output) == 0 then
    vim.notify('No merge request found', vim.log.levels.INFO)
    return
  end

  local json = u.decode_json(cmd_output)
  if json == nil or not json[1] then
    return
  end

  local project_folder = M.get_project_folder()
  local title = json[1].title
  local web_url = json[1].web_url

  local message = string.format('Ⓜ MR (%s) | %s \n%s', project_folder, title, web_url)
  vim.notify('⚡ MR message copied to clipboard!', vim.log.levels.INFO)
  vim.fn.setreg('+', message)
end

return M
