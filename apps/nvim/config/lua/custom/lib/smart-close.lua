local M = {}

local function ignore_float_filter(filetype, content)
  if content:find('Loading workspace') then
    return true
  end

  if filetype == 'mininotify' then
    return true
  end

  if filetype:match('^opencode') then
    return true
  end

  -- ui2 (extui) cmdline window is always present
  if filetype == 'cmd' then
    return true
  end
end

local function is_ignored_float(win, ignore_float)
  if vim.api.nvim_win_get_config(win).hide then
    return true
  end

  local bufnr = vim.api.nvim_win_get_buf(win)
  local file_type = vim.bo[bufnr].filetype
  local first_line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ''
  return ignore_float(file_type, first_line)
end

M.close_float_windows = function(ignore_float)
  ignore_float = ignore_float or ignore_float_filter
  local current_win = vim.api.nvim_get_current_win()
  local closed_windows = {}
  vim.schedule(function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_is_valid(win) then
        local config = vim.api.nvim_win_get_config(win)
        if config.relative ~= '' and (win == current_win or not is_ignored_float(win, ignore_float)) then
          vim.api.nvim_win_close(win, false)
          table.insert(closed_windows, win)
        end
      end
    end
  end)
end

function M.has_float_window(ignore_float)
  ignore_float = ignore_float or ignore_float_filter

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_is_valid(win) then
      local config = vim.api.nvim_win_get_config(win)

      if config.relative ~= '' and not is_ignored_float(win, ignore_float) then
        return true
      end
    end
  end
  return false
end

function M.is_buffer_in_split()
  local total_wins = vim.fn.tabpagewinnr(vim.fn.tabpagenr(), '$')
  local unlisted = M.get_bufs_unlisted()

  return (total_wins - #unlisted) > 1
end

function M.get_bufs_unlisted()
  local bufs_loaded = {}

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    local winnr = vim.fn.bufwinnr(bufnr)
    local listed = vim.bo[bufnr].buflisted
    local loaded = vim.api.nvim_buf_is_loaded(bufnr)

    if loaded and winnr >= 1 and listed == false then
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

function M.close()
  if M.has_float_window(ignore_float_filter) then
    return M.close_float_windows(ignore_float_filter)
  end

  if M.is_buffer_in_split() then
    vim.cmd('quit')
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local listed = vim.bo[bufnr].buflisted
  if not listed then
    vim.cmd('quit')
    return
  end

  require('mini.bufremove').delete(0, false)
end

return M
