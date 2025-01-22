local diag = vim.diagnostic

local M = {}
function M.prev(severity)
  return function()
    diag.jump(severity and { severity = diag.severity[severity], count = -1 } or { count = -1 })
  end
end

function M.next(severity)
  return function()
    diag.jump(severity and { severity = diag.severity[severity], count = 1 } or { count = 1 })
  end
end

function M.float()
  diag.open_float({ header = '', border = 'rounded' })
end

return M
