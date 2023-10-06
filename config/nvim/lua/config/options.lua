-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
vim.g.maplocalleader = "\\"

local opt = vim.opt

vim.o.background = "dark"
vim.g.is_wsl = vim.fn.has("unix")
  and vim.fn.has("wsl")
  and vim.fn.executable("win32yank.exe") == 1
  and vim.loop.os_uname().sysname == "Linux"

opt.autowrite = true -- Enable auto write
opt.clipboard = nil -- Don't Sync with system clipboard

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
end

-- keep the buffer centered on screen the best it can
vim.opt.scrolloff = math.floor(0.5 * vim.o.lines)

-- Allow misspellings
vim.cmd.cnoreabbrev("qw", "wq")
vim.cmd.cnoreabbrev("W", "w")
vim.cmd.cnoreabbrev("Wq", "wq")
vim.cmd.cnoreabbrev("WQ", "wq")
vim.cmd.cnoreabbrev("Qa", "qa")
vim.cmd.cnoreabbrev("Bd", "bd")
vim.cmd.cnoreabbrev("bD", "bd")
vim.cmd.cnoreabbrev("bD", "bd")
vim.cmd.cnoreabbrev("Q", "q")
