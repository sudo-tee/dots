local M = {}

M.reload = function(...)
  return require("plenary.reload").reload_module(...)
end

M.re_require = function(name)
  M.reload(name)
  return require(name)
end

function M.starts_with(str, start)
  return str:sub(1, #start) == start
end

M.close_float_windows = function()
  local closed_windows = {}
  vim.schedule(function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_is_valid(win) then
        local config = vim.api.nvim_win_get_config(win)
        if config.relative ~= "" then
          vim.api.nvim_win_close(win, false)
          table.insert(closed_windows, win)
        end
      end
    end
  end)
end

M.read_file = function(path)
  local open = io.open
  local file = open(path, "rb") -- r read mode and b binary mode
  if not file then
    return nil
  end
  local content = file:read("*a") -- *a or *all reads the whole file
  file:close()
  return content
end

return M
