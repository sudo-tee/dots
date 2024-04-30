-- Copy to clipboard only when yanking
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    if vim.v.event.operator == "y" and vim.v.event.regname == "" then
      require("osc52").copy_register("+")
    end
  end,
})

vim.keymap.set("n", "<Leader>y", function()
  local content = vim.fn.getreg('"')
  vim.fn.setreg("+", content)
end, { silent = true, desc = "Sync to system clipboard" })

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
end

return {
  "ojroques/nvim-osc52",
  event = "VeryLazy",
  opts = {
    max_length = 0, -- Maximum length of selection (0 for no limit)
    silent = true, -- Disable message on successful copy
    trim = false, -- Trim surrounding whitespaces before copy
  },
}
