vim.opt.clipboard = "unnamedplus" -- Sync with system clipboard

vim.g.is_wsl = vim.fn.has("unix")
  and vim.fn.has("wsl")
  and vim.fn.executable("win32yank.exe") == 1
  and vim.loop.os_uname().sysname == "Linux"

-- If wsl is detected
if vim.g.is_wsl then
  vim.g.clipboard = {
    name = "win32yank_nvim",
    copy = {
      ["+"] = "win32yank.exe -i --crlf",
      ["*"] = "win32yank.exe -i --crlf",
    },
    paste = {
      ["+"] = "win32yank.exe -o --lf",
      ["*"] = "win32yank.exe -o --lf",
    },
    cache_enabled = 1,
  }
else
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.clipboard.osc52").copy,
      ["*"] = require("vim.clipboard.osc52").copy,
    },
    paste = {
      ["+"] = require("vim.clipboard.osc52").paste,
      ["*"] = require("vim.clipboard.osc52").paste,
    },
  }
end

return {}
