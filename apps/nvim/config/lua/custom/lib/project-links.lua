---@alias ProjectLink {[1]: string, [2]: string, [3]?: boolean} # [label, url, hidden?]

local M = {}

---@module 'custom.lib.utils'
local u = lazy_require('custom.lib.utils')

---@module 'custom.lib.gitlab'
local gitlab = lazy_require('custom.lib.gitlab')

---@module 'custom.lib.jira'
local jira = lazy_require('custom.lib.jira')

---@module 'custom.lib.wezterm'
local wezterm = lazy_require('custom.lib.wezterm')

---@module 'custom.lib.git'
local git = lazy_require('custom.lib.git')

---@type table<string, ProjectLink[]>
vim.g.project_links = vim.g.project_links or {}

---Creates a function that opens a URL and copies it to clipboard
---@param url string
---@return function
local open_url = function(url)
  return function()
    wezterm.open_url(url)
    vim.fn.setreg('+', url)
  end
end

---Format a link with fixed width label
---@param label string
---@param url string
---@return string
local function format_link(label, url)
  return u.fixed_width(label, 10) .. ' | ' .. url
end

---Get all project related links
---@return {text: string, action: function}[] # Array of [formatted_link, callback] pairs
local function get_project_links()
  local links = {}

  local project_links = vim.g.project_links or {}
  for _, link in pairs(project_links) do
    local label, url, hidden = unpack(link)
    if not hidden then
      table.insert(links, { text = format_link(label, url), action = open_url(url) })
    end
  end

  local repo_url = M.get_url_by_label('Repo') or M.get_url_by_label('Gitlab')
  if #repo_url == 0 then
    repo_url = git.get_repo_url()
    table.insert(links, { text = format_link('Repo', repo_url), action = open_url(repo_url) })
  end

  return links
end

---Get Jira issue link for current branch
---@return {text: string, action: function}[] # Array of [formatted_link, callback] pairs
local function get_issue_link()
  local links = {}

  local ticket = jira.get_ticket_from_branch()
  local issue_link = jira.get_issue_link(ticket)
  if issue_link then
    table.insert(links, { text = format_link(ticket, issue_link), action = open_url(issue_link) })
  end
  return links
end

---Get GitLab merge request link for current branch
---@return {text: string, action: function}[] # Array of [formatted_link, callback] pairs
local function get_mr_link()
  local links = {}
  local branch = git.current_branch()

  local mr_url = gitlab.get_current_mr_url(branch)
  if mr_url then
    table.insert(links, { text = format_link('MR', mr_url), action = open_url(mr_url) })
  else
    table.insert(links, { text = format_link('MR', '-- CREATE NEW MR --'), action = gitlab.open_git_mr })
  end
  return links
end

---Get all available links (project, issue, and MR links)
---@return {text: string, action: function}[] # Array of [formatted_link, callback] pairs
function M.get_links()
  return u.concat(get_project_links(), get_issue_link(), get_mr_link())
end

---Get URL for a given link label
---@param label string The label to search for
---@param default? string Default value if not found
---@return string url The URL or default value
function M.get_url_by_label(label, default)
  local links = vim.g.project_links or {}

  for _, value in ipairs(links) do
    if label == value[1] then
      return value[2]
    end
  end

  return default or ''
end

return M
