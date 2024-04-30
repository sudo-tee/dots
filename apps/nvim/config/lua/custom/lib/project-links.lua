local M = {}

local open_url = function(url)
  return function()
    local wez = require('custom.lib.wezterm')

    wez.open_url(url)
    vim.fn.setreg('+', url)
  end
end

function M.get_links()
  local u = require('custom.lib.utils')
  local links = {}
  local pos = 1

  for _, link in pairs(vim.g.project_links or {}) do
    links[u.rpad(pos .. '. ' .. link[1], 9) .. ' | ' .. link[2]] = open_url(link[2])
    pos = pos + 1
  end

  local issue_link = require('custom.lib.jira').get_issue_link()
  if issue_link then
    links[u.rpad(pos .. '. Issue', 9) .. ' | ' .. issue_link] = open_url(issue_link)
    pos = pos + 1
  end

  local gitlab = require('custom.lib.gitlab')
  local mr_url = gitlab.get_current_mr_url()
  if mr_url then
    links[u.rpad(pos .. '. MR', 9) .. ' | ' .. mr_url] = open_url(mr_url)
    pos = pos + 1
  else
    links[u.rpad(pos .. '. -- New MR -- ', 9)] = function()
      gitlab.open_git_mr()
    end
    pos = pos + 1
  end
  return links
end

function M.get_url_by_label(label, default)
  default = default or ''
  local utils = require('custom.lib.utils')
  local links = vim.g.project_links or {}
  local _, result = utils.find(function(value)
    local _label = value[1]
    return label == _label
  end, links)
  if result and result[2] then
    return result[2]
  end
  return default
end

return M
