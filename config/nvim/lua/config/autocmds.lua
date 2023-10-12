-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
--
local augroup = vim.api.nvim_create_augroup("focus_cmds", { clear = true })

-- Disable mouse when not in focus so it never ends in visual mode when clicking the neovim window
--
-- FocusGained autocommand
vim.api.nvim_create_autocmd("FocusGained", {
  group = augroup,
  pattern = "*",
  callback = function()
    vim.defer_fn(function()
      vim.api.nvim_set_option("mouse", "a")
    end, 500)
  end,
})

-- FocusLost autocommand
vim.api.nvim_create_autocmd("FocusLost", {
  group = augroup,
  pattern = "*",
  callback = function()
    vim.api.nvim_set_option("mouse", "")
  end,
})

-- Define the function to set buffer option
local function set_buf_option(filetypes, option, value)
  for _, ft in ipairs(filetypes) do
    for _, buf in ipairs(vim.fn.getbufinfo({ filetype = ft })) do
      vim.api.nvim_buf_set_option(buf.bufnr, option, value)
    end
  end
end

-- Define the autocommand function
function _G.setup_git_buffer_settings()
  set_buf_option({ "gitcommit", "gitrebase", "gitconfig", "gitsendmail" }, "bufhidden", "delete")
end

local gitGrp = vim.api.nvim_create_augroup("GitSettings", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = "gitcommit,gitrebase,gitconfig,gitsendmail",
  command = "silent! lua _G.setup_git_buffer_settings()",
  group = gitGrp,
})

vim.cmd([[autocmd CursorHold <buffer> lua vim.diagnostic.open_float({focusable = false})]])

-- Use `<ESC>` to conveniently close special windows
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "fugitive",
    "lspinfo",
    "man",
    "qf",
    "startuptime",
    "lazy",
    "checkhealth",
  },
  callback = function()
    vim.keymap.set({ "n" }, "<ESC>", "<cmd>close<CR>", { silent = true, buffer = true })
  end,
})
