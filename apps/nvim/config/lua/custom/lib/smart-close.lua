local M = {}

local function ignore_float_filter(filetype, content)
  -- this is lsp progress from noice
  if filetype == 'noice' or content:find('Loading workspace') then
    return true
  end

  if filetype == 'mininotify' then
    return true
  end
end

M.close_float_windows = function()
  local closed_windows = {}
  vim.schedule(function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_is_valid(win) then
        local config = vim.api.nvim_win_get_config(win)
        if config.relative ~= '' then
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

      if config.relative ~= '' then
        local win_info = vim.fn.getwininfo(win)
        local bufnr = win_info[1].bufnr
        local file_type = vim.bo[bufnr].filetype
        local first_line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]

        if ignore_float(file_type, first_line) then
          goto continue
        end

        return true
      end
    end
    ::continue::
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
    return M.close_float_windows()
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
