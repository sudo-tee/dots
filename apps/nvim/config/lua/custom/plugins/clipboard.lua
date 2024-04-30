local function copy(lines, _)
  require('osc52').copy(table.concat(lines, '\n'))
end

local function paste()
  return { vim.fn.split(vim.fn.getreg(''), '\n'), vim.fn.getregtype('') }
end

vim.g.clipboard = {
  name = 'osc52',
  copy = { ['+'] = copy, ['*'] = copy },
  paste = { ['+'] = paste, ['*'] = paste },
  cache_enabled = 1,
}

return {
  'ojroques/nvim-osc52',
  event = 'VeryLazy',
  opts = {
    max_length = 0, -- Maximum length of selection (0 for no limit)
    silent = true, -- Disable message on successful copy
    trim = false, -- Trim surrounding whitespaces before copy
  },
}
