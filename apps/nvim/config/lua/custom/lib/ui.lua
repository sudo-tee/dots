local M = {}

--- vim.ui.input emulation in a float
---@param opts table: usual opts like in vim.ui.input()
---@param callback function: callback to invoke
M.ui_input = function(opts, callback)
  local buf = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_open_win(buf, true, {
    relative = 'cursor',
    style = 'minimal',
    border = 'rounded',
    row = 1,
    col = 1,
    width = opts.width or 20,
    height = 1,
    title = opts.prompt,
  })

  vim.keymap.set('n', 'q', ':bd!<CR>', { buffer = true, silent = true })
  vim.keymap.set('n', '<ESC>', ':bd!<CR>', { buffer = true, silent = true })
  vim.keymap.set('n', '<C-c>', ':bd!<CR>', { buffer = true, silent = true })

  if opts.default then
    vim.api.nvim_put({ opts.default }, '', true, true)
  end
  vim.cmd([[startinsert!]])

  vim.keymap.set('i', '<CR>', function()
    local content = vim.api.nvim_get_current_line()
    -- if opts.prompt then content = content:gsub(opts.prompt, '') end
    vim.cmd([[bd | stopinsert!]])
    callback(vim.trim(content))
  end, { buffer = true, silent = true })
end

M.rename = function()
  local rename_old = vim.fn.expand('<cword>')
  M.ui_input({ prompt = 'rename (' .. rename_old .. ')', width = 30 }, function(input)
    vim.lsp.buf.rename(vim.trim(input))
    vim.notify(rename_old .. ' -> ' .. input)
  end)
end

return M
