local diag = vim.diagnostic

local M = {}
function M.prev(severity)
  return function()
    diag.goto_prev(severity and { severity = diag.severity[severity] } or {})
  end
end

function M.next(severity)
  return function()
    diag.goto_next(severity and { severity = diag.severity[severity] } or {})
  end
end

function M.float()
  diag.open_float({ header = '', border = 'rounded' })
end

return M
