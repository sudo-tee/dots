local opts = {}
-- Copy to clipboard only when yanking
vim.keymap.set('n', '<Leader>y', function()
  local content = vim.fn.getreg('"')
  vim.fn.setreg('+', content)
end, { silent = true, desc = 'Sync to system clipboard' })

vim.g.is_wsl = vim.fn.has('unix') and vim.fn.has('wsl') and vim.fn.executable('win32yank.exe') == 1 and vim.loop.os_uname().sysname == 'Linux'

-- disable clipboard is to slow
vim.g.is_wsl = false
-- If wsl is detected
if vim.g.is_wsl then
  vim.opt.clipboard = 'unnamedplus'
  vim.g.clipboard = {
    name = 'win32yank_nvim',
    copy = {
      ['+'] = 'win32yank.exe -i --crlf',
      ['*'] = 'win32yank.exe -i --crlf',
    },
    paste = {
      ['+'] = 'win32yank.exe -o --lf',
      ['*'] = 'win32yank.exe -o --lf',
    },
    cache_enabled = 0,
  }
else
  vim.opt.clipboard = '' -- don't sync with system clipboard
  vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
      if vim.v.event.operator == 'y' and vim.v.event.regname == '' then
        require('osc52').copy_register('+')
      end
    end,
  })

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

  opts = {
    'ojroques/nvim-osc52',
    event = 'VeryLazy',
    opts = {
      max_length = 0, -- Maximum length of selection (0 for no limit)
      silent = true, -- Disable message on successful copy
      trim = false, -- Trim surrounding whitespaces before copy
    },
  }
end

return opts
