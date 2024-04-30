local M = {}

M.open_git_remote = function()
  local cmd_output = vim.fn.system("git config --get remote.origin.url 2> /dev/null"):gsub("\n", "")
  local remote_url = cmd_output:gsub(":", "/"):gsub("git@", "https://")

  if string.len(remote_url) == 0 then
    print("Not in a git repository")
    return
  end
  local wez = require("lib/wezterm")
  print("Opening git remote url:", remote_url)
  vim.fn.setreg("+", remote_url)
  vim.api.nvim_command("silent! !xdg-open '" .. vim.fn.shellescape(remote_url) .. "'")
  wez.send_user_command("open")
end

M.open_git_mr = function()
  print("Opening MR for branch")

  local cmd_output = vim.fn.system("glab api -X GET projects/:id/merge_requests  --field source_branch=:branch")
  local success, json = pcall(vim.json.decode, cmd_output)

  if not success or json == nil or json[1] == nil then
    local utils = require("lib/utils")
    local wez = require("lib/wezterm")
    print("Creating a new MR for branch")

    vim.api.nvim_command("silent! !glab mr new -f -w")

    -- hack xdg-open writes to a tmp file the url
    local content = utils.read_file("/tmp/xdg-open-url")
    wez.send_user_command("open")

    vim.fn.setreg("+", content)
    return
  else
    local web_url = json[1].web_url
    print(web_url)
    vim.fn.setreg("+", web_url)
  end
end

M.generate_chat_message_for_mr = function()
  local cmd_output = vim.fn.system("glab api -X GET projects/:id/merge_requests  --field source_branch=:branch")

  if cmd_output == nil or string.len(cmd_output) == 0 then
    print("No merge request found")
    return
  end

  local success, json = pcall(vim.json.decode, cmd_output)

  if not success then
    print("Error decoding JSON")
    return
  end

  local cwd = vim.loop.cwd()

  local project_folder = string.match(cwd, "[^/]+$")
  local title = json[1].title
  local web_url = json[1].web_url

  local message = string.format("Ⓜ MR (%s) | %s \n%s", project_folder, title, web_url)
  print("⚡ MR message copied to clipboard!")
  vim.fn.setreg("+", message)
end

return M
