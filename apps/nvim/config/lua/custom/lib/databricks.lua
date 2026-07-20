local M = {}
local CACHE = vim.fn.expand('~/.claude/claude-budget-cache.json')
local STATUS_JS = vim.fn.expand('~/.claude/claude-status.js')

function M.get_cost()
  local f = io.open(CACHE, 'r')
  if not f then
    return 'N/A'
  end
  local ok, data = pcall(vim.fn.json_decode, f:read('*a'))
  f:close()
  if ok and data and data.data then
    return string.format('$%.2f', data.data.spent)
  end
  return 'N/A'
end

function M.refresh_cost()
  vim.fn.jobstart({ 'node', STATUS_JS, '--refresh-cache' }, { detach = true })
  vim.g.databricks_cost = M.get_cost()
end

function M.setup()
  if vim.env.ENABLE_DATABRICKS_COST_NVIM ~= '1' then
    return
  end
  M.refresh_cost()
  vim.fn.timer_start(300000, M.refresh_cost, { ['repeat'] = -1 })
end

return M
