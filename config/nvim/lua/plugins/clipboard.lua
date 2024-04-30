local function copy(lines, _)
  require("osc52").copy(table.concat(lines, "\n"))
end

local function paste()
  return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
end

vim.g.clipboard = {
  name = "osc52",
  copy = { ["+"] = copy, ["*"] = copy },
  paste = { ["+"] = paste, ["*"] = paste },
}
-- Copy to clipboard
vim.keymap.set("n", "<Leader>y", function()
  local content = vim.fn.getreg('"')
  vim.fn.setreg("+", content)
end, { silent = true, desc = "Sync to system clipboard" })

return {
  "ojroques/nvim-osc52",
  event = "VeryLazy",
  opts = {
    max_length = 0, -- Maximum length of selection (0 for no limit)
    silent = false, -- Disable message on successful copy
    trim = false, -- Trim surrounding whitespaces before copy
  },
}
