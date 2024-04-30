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

function M.rpad(s, l, c)
  local res = s .. string.rep(c or " ", l - #s)

  return res, res ~= s
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
  local unlisted = M.get_bufs_unlisted()

  return (total_wins - #unlisted) > 1
end

function M.get_bufs_unlisted()
  local bufs_loaded = {}

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local winnr = vim.fn.bufwinnr(bufnr)
    local listed = vim.bo[bufnr].buflisted
    if vim.api.nvim_buf_is_loaded(bufnr) and winnr >= 1 and listed == false then
      local inf = vim.fn.getbufinfo(bufnr)
      table.insert(bufs_loaded, {
        type = vim.bo[bufnr].filetype,
        name = inf[1].name,
        listed = listed,
        win = winnr,
      })
    end
  end

  return bufs_loaded
end

function M.smart_close()
  if M.has_float_window() then
    return M.close_float_windows()
  end

  if M.is_buffer_in_split() then
    vim.cmd("quit")
    return
  end

  require("mini.bufremove").delete(0, false)
end

function M.read_file(path)
  local open = io.open
  local file = open(path, "rb") -- r read mode and b binary mode
  if not file then
    return nil
  end
  local content = file:read("*a") -- *a or *all reads the whole file
  file:close()
  return content
end

function M.git_default_branch()
  local handle = io.popen("basename $(git symbolic-ref refs/remotes/origin/HEAD) | tr -d '\n\r'")
  local result = handle:read("*a")
  handle:close()
  return result
end

return M
