local M = {}

---@module 'custom.lib.utils'
local u = lazy_require('custom.lib.utils')

---@module 'custom.lib.gitlab'
local gitlab = lazy_require('custom.lib.gitlab')

---@module 'custom.lib.jira'
local jira = lazy_require('custom.lib.jira')

---@module 'custom.lib.wezterm'
local wezterm = lazy_require('custom.lib.wezterm')

local open_url = function(url)
  return function()
    wezterm.open_url(url)
    vim.fn.setreg('+', url)
  end
end

local function format_link(label, url)
  return (string.format('%s| %s', u.rpad(label, 7), url))
end

local function get_project_links()
  local links = {}

  for _, link in pairs(vim.g.project_links or {}) do
    table.insert(links, { format_link(link[1], link[2]), open_url(link[2]) })
  end
  return links
end

local function get_issue_link()
  local links = {}

  local issue_link = jira.get_issue_link()
  if issue_link then
    table.insert(links, { format_link('Issue', issue_link), open_url(issue_link) })
  end
  return links
end

local function get_mr_link()
  local links = {}

  local mr_url = gitlab.get_current_mr_url()
  if mr_url then
    table.insert(links, { format_link('MR', mr_url), open_url(mr_url) })
  else
    table.insert(links, { format_link('MR', '-- CREATE NEW MR --'), gitlab.open_git_mr })
  end
  return links
end

function M.get_links()
  return u.concat(get_project_links(), get_issue_link(), get_mr_link())
end

function M.get_url_by_label(label, default)
  local links = vim.g.project_links or {}

  local _, result = u.find(function(value)
    local _label = value[1]
    return label == _label
  end, links)

  if result and result[2] then
    return result[2]
  end
  return default or ''
end

return M
