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

  for _, link in pairs(vim.g.project_links or {}) do
    links[u.rpad(pos .. ". " .. link[1], 9) .. " | " .. link[2]] = open_url(link[2])
    pos = pos + 1
  end

  local issue_link = require("lib.jira").get_issue_link()
  if issue_link then
    links[u.rpad(pos .. ". Issue", 9) .. " | " .. issue_link] = open_url(issue_link)
    pos = pos + 1
  end

  local mr_url = require("lib.gitlab").get_current_mr_url()
  if mr_url then
    links[u.rpad(pos .. ". MR", 9) .. " | " .. mr_url] = open_url(mr_url)
    pos = pos + 1
  end
  return links
end

return M
