local M = {}

local open_url = function(url)
  return function()
    local wez = require("lib.wezterm")

    wez.open_url(url)
    vim.fn.setreg("+", url)
  end
end

function M.get_links()
  local u = require("lib.utils")
  local links = {}
  local pos = 1
  for k, l in pairs(vim.g.project_links or {}) do
    links[u.rpad(pos .. ". " .. k, 9) .. " | " .. l] = open_url(l)
    pos = pos + 1
  end

  local issue_link = M.get_issue_link()
  if issue_link then
    links[u.rpad(pos .. ". Issue", 9) .. " | " .. issue_link] = open_url(issue_link)
    pos = pos + 1
  end

  local mr_url = require("lib.gitlab").get_current_mr_url()
  if mr_url then
    links[u.rpad(pos .. ". Git MR", 9) .. " | " .. mr_url] = open_url(mr_url)
    pos = pos + 1
  end
  return links
end

function M.get_issue_link()
  local cmd_output = vim.fn.system("git branch --show-current"):gsub("\n", "")
  local jira_issue = M.match_jira_ticket(cmd_output)

  if jira_issue then
    return vim.g.project_links["Jira"] .. jira_issue
  end

  return nil
end

function M.match_jira_ticket(branch_name)
  local jira_ticket = string.match(branch_name, "%u+%-%d+")
  return jira_ticket
end

return M
