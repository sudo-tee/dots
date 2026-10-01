local M = {}
local GATEWAY_URL = vim.env.AI_GATEWAY_URL or 'http://127.0.0.1:4000'

-- Sums today's costUsd from the local ai-gateway GET /usage response, or nil on failure.
local function parse_gateway_usage(body)
  local ok, days = pcall(vim.json.decode, body)
  if not ok or type(days) ~= 'table' then
    return nil
  end
  local total = 0
  for _, day in ipairs(days) do
    total = total + (tonumber(day.costUsd) or 0)
  end
  return total
end

function M.get_cost()
  return vim.g.databricks_cost or 'N/A'
end

function M.refresh_cost()
  vim.system({ 'curl', '-sf', '-m', '3', GATEWAY_URL .. '/usage' }, { text = true }, function(res)
    local total = res.code == 0 and parse_gateway_usage(res.stdout) or nil
    vim.schedule(function()
      vim.g.databricks_cost = total and string.format('$%.2f', total) or 'N/A'
    end)
  end)
end

function M.setup()
  if vim.env.ENABLE_DATABRICKS_COST_NVIM ~= '1' then
    return
  end
  M.refresh_cost()
  vim.fn.timer_start(300000, M.refresh_cost, { ['repeat'] = -1 })
end

return M
