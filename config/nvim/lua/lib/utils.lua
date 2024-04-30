local M = {}

M.reload = function(...)
  return require("plenary.reload").reload_module(...)
end

M.re_require = function(name)
  M.reload(name)
  return require(name)
end

function M.first_to_upper(str)
  return (str:gsub("^%l", string.upper))
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

M.has_float_window = function(filter)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) then
      local config = vim.api.nvim_win_get_config(win)

      if config.relative ~= "" then
        local win_info = vim.fn.getwininfo(win)
        local bufnr = win_info[1].bufnr
        local first_line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]

        if not filter or string.find(first_line, filter) then
          return true
        end
      end
    end
  end
  return false
end

function M.is_buffer_in_split()
  local total_wins = vim.fn.tabpagewinnr(vim.fn.tabpagenr(), "$")

  return total_wins > 1
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
