local M = {}

function M.get_issue_link()
  local jira_issue = M.get_ticket_from_branch()

  if jira_issue then
    return vim.g.project_links["Jira"] .. jira_issue
  end

  return nil
end

function M.match_jira_ticket(branch_name)
  local jira_ticket = string.match(branch_name, "%u+%-%d+")
  return jira_ticket
end

function M.get_ticket_from_branch()
  local cmd_output = vim.fn.system("git branch --show-current"):gsub("\n", "")
  return M.match_jira_ticket(cmd_output)
end

function M.create_jira_link(ticket)
  ticket = ticket or M.get_ticket_from_branch()

  if not ticket then
    print("Please provide a jira ticket")
    return
  end
  local jira_url = "https://my-jira-url/browse/"
  local links = vim.g.project_links

  if links and links["Jira"] then
    jira_url = links["Jira"]
  end

  local link = string.format("[%s](%s%s)", ticket, jira_url, ticket)

  local cursor_pos = vim.api.nvim_win_get_cursor(0)

  vim.api.nvim_put({ link }, "c", true, true)
  vim.api.nvim_win_set_cursor(0, cursor_pos)
end

return M
