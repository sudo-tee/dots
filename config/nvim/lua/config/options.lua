-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
vim.g.maplocalleader = "\\"

vim.opt.cmdheight = 0
vim.opt.autowrite = true -- Enable auto write
vim.opt.clipboard = "" -- Don't Sync with system clipboard
vim.opt.conceallevel = 0
vim.opt.scrolloff = math.floor(0.5 * vim.o.lines)

-- keep the buffer centered on screen the best it can

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

if vim.fn.executable("nvr") == 1 then
  local nvr = "nvr --servername " .. vim.v.servername .. " "

  vim.env.GIT_EDITOR = nvr .. " +'setl bh=delete' --remote-wait"
  vim.env.EDITOR = nvr .. "-l --remote" -- (Optional)
  vim.env.VISUAL = nvr .. "-l --remote" -- (Optional)
end
