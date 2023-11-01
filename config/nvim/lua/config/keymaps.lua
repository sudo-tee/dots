-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- Don't yank on delete char
map("n", "x", '"_x')
map("n", "X", '"_X')
map("v", "x", '"_x')
map("v", "X", '"_X')

-- Easier line-wise movement
map({ "n", "v" }, "gh", "g^")
map({ "n", "v" }, "gl", "g$")
map({ "n", "v" }, "g<Left>", "g^")
map({ "n", "v" }, "g<Right>", "g$")

-- Yank absolute path
map("n", "<Leader>fY", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify(path, vim.log.levels.INFO, { title = "Yanked absolute path" })
end, { desc = "Yank absolute path" })

-- Yank buffer's relative path to clipboard
map("n", "<Leader>fy", function()
  local path = vim.fn.expand("%:~:.")
  vim.fn.setreg("+", path)
  vim.notify(path, vim.log.levels.INFO, { title = "Yanked relative path" })
end, { desc = "Yank relative path" })

-- Use tab for indenting in visual/select mode
map("x", "<Tab>", ">gv|", { desc = "Indent Left" })
map("x", "<S-Tab>", "<gv", { desc = "Indent Right" })

-- Use tab for indenting in insert
map("i", "<Tab>", ">gv|", { desc = "Indent Left" })
map("i", "<S-Tab>", "<gv", { desc = "Indent Right" })

-- Start an external command with a single bang
map("n", "!", ":R ", { desc = "Execute Shell Command in the floating term" })

-- Duplicate lines without affecting PRIMARY and CLIPBOARD selections.
map("n", "<Leader>d", 'm`""Y""P``', { desc = "Duplicate line" })
map("x", "<Leader>d", '""Y""Pgv', { desc = "Duplicate selection" })
map("n", "<S-A-Down>", 'm`""Y""P``', { desc = "Duplicate line" })
map("x", "<S-A-Down>", '""Y""Pgv', { desc = "Duplicate selection" })

-- Move Lines
map("n", "<A-Down>", ":m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-Up>", ":m .-2<CR>==", { desc = "Move line up" })
map("v", "<A-Down>", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "<A-Up>", ":m '<-2<CR>gv=gv", { desc = "Move line down" })
map("i", "<A-Down>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move line down" })
map("i", "<A-Up>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move line up" })

-- Insert lines stay in normal mode
map("n", "<Leader>o", "o<Esc>", { desc = "Insert new line in normal mode" })
map("n", "<Leader>O", "O<Esc>", { desc = "Insert new line before in normal mode" })

-- LSP
map("n", "<F2>", vim.lsp.buf.rename, { desc = "Rename symbol" })
map("n", "gA", vim.lsp.buf.code_action, { desc = "Code actions" })
map("n", "<S-l>", "<cmd>lua vim.diagnostic.open_float()<CR>", { desc = "Open diagnostic in float window" })

-- Select all
map("n", "<localleader>a", "ggVG", { desc = "Select all" })

-- Motion to move but keep cursor centered
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll down" })
map("n", "<C-o>", "<C-o>zz", { desc = "Previous position" })
map("n", "<C-i>", "<C-i>zz", { desc = "Next position" })
map("n", "<C-f>", "<C-f>zz", { desc = "Scroll forward" })
map("n", "<C-b>", "<C-b>zz", { desc = "Scroll backward" })
map("n", "n", "nzzzv", { desc = "Next search results" })
map("n", "N", "Nzzzv", { desc = "Prev search results" })
map("n", "G", "Gzz")
map("n", "gg", "ggzz")
map("n", "]m", "]mzz")
map("n", "[m", "[mzz")
map("n", "{", "{zz")
map("n", "}", "}zz")
map("n", "*", "*zz")
map("n", "%", "%zz")

-- Macros
-- Disable default macro key the plugin will set it up to <F4>
-- map("n", "q", "<Nop>")
map("n", "<leader>fm", function()
  require("lib.macros").find_defined_macro()
end, { desc = "Find predefined macros" })

-- buffers navigation
map("n", "<M-Right>", ":bn<cr>", { desc = "Next buffer" })
map("n", "<M-Left>", ":bp<cr>", { desc = "Previous buffer" })

map("n", "<C-x>", function()
  require("mini.bufremove").delete(0, false)
end, { desc = "Delete Buffer" })

--buffers swap
map("n", "<leader>b<Left>", function()
  require("smart-splits").swap_buf_left()
end)
map("n", "<leader>b<Down>", function()
  require("smart-splits").swap_buf_down()
end)
map("n", "<leader>b<Up>", function()
  require("smart-splits").swap_buf_up()
end)
map("n", "<leader>b<Right>", function()
  require("smart-splits").swap_buf_right()
end)

-- in terminal mode fast switch to normal mode
map("t", "<C-o>", "<C-\\><C-n>")

-- Wezterm session switch
-- map({ "n", "i", "v" }, "<C-\\>", "<cmd>Ws<cr>")

-- Map arrow keys for wildmenu completion
vim.api.nvim_set_keymap("c", "<Down>", 'v:lua.get_wildmenu_key("<right>", "<down>")', { expr = true })
vim.api.nvim_set_keymap("c", "<Up>", 'v:lua.get_wildmenu_key("<left>", "<up>")', { expr = true })

function _G.get_wildmenu_key(key_wildmenu, key_regular)
  return vim.fn.wildmenumode() ~= 0 and key_wildmenu or key_regular
end

-- Gitlab shortcuts
map("n", "<leader>glo", function()
  require("lib.gitlab").open_git_remote()
end, { desc = "Open Git remote for project" })

map("n", "<leader>glm", function()
  require("lib.gitlab").open_git_mr()
end, { desc = "Open Git mr for branch" })

map("n", "<leader>glc", function()
  require("lib.gitlab").generate_chat_message_for_mr()
end, { desc = "Generate a sharing message for MR" })

-- Close any floating window
map({ "n", "i", "t" }, "<A-q>", function()
  local utils = require("lib.utils")
  if utils.has_float_window() then
    return utils.close_float_windows()
  end

  if utils.is_buffer_in_split() then
    vim.cmd("quit")
    return
  end

  require("mini.bufremove").delete(0, false)
end, { desc = "Close floating windows" })

-- Replace word under cursor across entire buffer
map(
  "n",
  "<leader>rw",
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { silent = false, desc = "Replace all instances of word under cursor" }
)
-- replace all instances selected with shift + *
map("n", "<Leader>rz", [[:%s///g<Left><Left>]], { silent = false, desc = "Replace all * search" })
map("n", "g*", "*Ncgn", { desc = "Change word with . repeat" })

map("x", "<Leader>rz", ":s///g<Left><Left>", { silent = false, desc = "Replace selected * search " })

-- Put vim command output into buffer
map("n", "g!", ":put=execute('')<Left><Left>", { silent = false, desc = "Paste Command" })

-- Helper to create a jira link
map("v", "<localleader>jl", ':JiraLink <C-R>"<CR>', { silent = false, desc = "Create a jira link in markdown" })

map("n", "<localleader>jl", ":JiraLink ", { silent = false, desc = "Create a jira link in markdown" })
map("n", "<localleader>jl", ":JiraLink ", { silent = false, noremap = true, desc = "Create a jira link in markdown" })

map("n", "<leader>uz", ":ToggleProfile<cr>", { silent = false, noremap = true, desc = "Start a profilling session" })
