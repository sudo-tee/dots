-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--
local map = vim.keymap.set

-- Paste in visual-mode without pushing to register
map("x", "p", 'p:let @+=@0<CR>:let @"=@0<CR>', { silent = true, desc = "Paste" })
map("x", "P", 'P:let @+=@0<CR>:let @"=@0<CR>', { silent = true, desc = "Paste In-place" })

-- Don't yank on delete char
map("n", "x", '"_x', { silent = true })
map("n", "X", '"_X', { silent = true })
map("v", "x", '"_x', { silent = true })
map("v", "X", '"_X', { silent = true })

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
end, { silent = true, desc = "Yank absolute path" })

-- Yank buffer's relative path to clipboard
map("n", "<Leader>fy", function()
  local path = vim.fn.expand("%:~:.")
  vim.fn.setreg("+", path)
  vim.notify(path, vim.log.levels.INFO, { title = "Yanked relative path" })
end, { silent = true, desc = "Yank relative path" })

-- Use tab for indenting in visual/select mode
map("x", "<Tab>", ">gv|", { noremap = true, desc = "Indent Left" })
map("x", "<S-Tab>", "<gv", { noremap = true, desc = "Indent Right" })

-- Use tab for indenting in insert
map("i", "<Tab>", ">gv|", { noremap = true, desc = "Indent Left" })
map("i", "<S-Tab>", "<gv", { noremap = true, desc = "Indent Right" })

-- Start an external command with a single bang
map("n", "!", ":R ", { desc = "Execute Shell Command in the floating term" })

-- Duplicate lines without affecting PRIMARY and CLIPBOARD selections.
map("n", "<Leader>d", 'm`""Y""P``', { noremap = true, desc = "Duplicate line" })
map("x", "<Leader>d", '""Y""Pgv', { noremap = true, desc = "Duplicate selection" })
map("n", "<S-A-Down>", 'm`""Y""P``', { noremap = true, desc = "Duplicate line" })
map("x", "<S-A-Down>", '""Y""Pgv', { noremap = true, desc = "Duplicate selection" })

-- Move Lines
map("n", "<A-Down>", ":m .+1<CR>==", { silent = true, desc = "Move line down" })
map("n", "<A-Up>", ":m .-2<CR>==", { silent = true, desc = "Move line up" })
map("v", "<A-Down>", ":m '>+1<CR>gv=gv", { silent = true, desc = "Move line down" })
map("v", "<A-Up>", ":m '<-2<CR>gv=gv", { silent = true, desc = "Move line down" })
map("i", "<A-Down>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move line down" })
map("i", "<A-Up>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move line up" })

-- Insert lines stay in normal mode
map("n", "<Leader>o", "o<Esc>", { silent = true, desc = "Insert new line in normal mode" })
map("n", "<Leader>O", "O<Esc>", { silent = true, desc = "Insert new line before in normal mode" })

-- LSP
map("n", "<F2>", vim.lsp.buf.rename, { noremap = true, silent = true, desc = "Rename symbol" })
map("n", "gA", vim.lsp.buf.code_action, { noremap = true, silent = true, desc = "Code actions" })
map("n", "<S-l>", "<cmd>lua vim.diagnostic.open_float()<CR>", { noremap = true, silent = true })

-- Select all
map("n", "<localleader>a", "ggVG", { silent = true, desc = "Select all" })

-- Motion to move but keep cursor centered
map("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true, desc = "Scroll down" })
map("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true, desc = "Scroll down" })
map("n", "<C-o>", "<C-o>zz", { noremap = true, silent = true, desc = "Previous position" })
map("n", "<C-i>", "<C-i>zz", { noremap = true, silent = true, desc = "Next position" })
map("n", "<C-f>", "<C-f>zz", { noremap = true, silent = true, desc = "Scroll forward" })
map("n", "<C-b>", "<C-b>zz", { noremap = true, silent = true, desc = "Scroll backward" })
map("n", "n", "nzzzv", { noremap = true, silent = true, desc = "Next search results" })
map("n", "N", "Nzzzv", { noremap = true, silent = true, desc = "Prev search results" })
map("n", "G", "Gzz", { noremap = true, silent = true })
map("n", "gg", "ggzz", { noremap = true, silent = true })
map("n", "]m", "]mzz", { noremap = true, silent = true })
map("n", "[m", "[mzz", { noremap = true, silent = true })
map("n", "{", "{zz", { noremap = true, silent = true })
map("n", "}", "}zz", { noremap = true, silent = true })
map("n", "*", "*zz", { noremap = true, silent = true })
map("n", "%", "%zz", { noremap = true, silent = true })

-- Macros
-- Disable default macro key the plugin will set it up to <F4>
-- map("n", "q", "<Nop>")
map("n", "<leader>fm", function()
  require("lib.macros").find_defined_macro()
end, { noremap = true, silent = true, desc = "Find predefined macros" })

-- resizing splits
map("n", "<leader>wr", require("smart-splits").start_resize_mode, { desc = "Toggle resize window" })

-- move between splits
map("n", "<C-j>", function()
  require("smart-splits").move_cursor_down()
end)
map("n", "<C-k>", function()
  require("smart-splits").move_cursor_up()
end)
map("n", "<C-l>", function()
  require("smart-splits").move_cursor_right()
end)
map("n", "<C-h>", function()
  require("smart-splits").move_cursor_left()
end)
map("n", "<C-Left>", function()
  require("smart-splits").move_cursor_left()
end)
map("n", "<C-Down>", function()
  require("smart-splits").move_cursor_down()
end)
map("n", "<C-Up>", function()
  require("smart-splits").move_cursor_up()
end)
map("n", "<C-Right>", function()
  require("smart-splits").move_cursor_right()
end)

-- buffers navigation
map("n", "<M-Right>", ":bn<cr>", { silent = true, noremap = true, desc = "Next buffer" })
map("n", "<M-Left>", ":bp<cr>", { silent = true, noremap = true, desc = "Previous buffer" })

map("n", "<C-x>", function()
  require("mini.bufremove").delete(0, false)
end, { silent = true, noremap = true, desc = "Delete Buffer" })

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
map("t", "<C-o>", "<C-\\><C-n>", { noremap = true })

-- Wezterm session switch
map({ "n", "i", "v" }, "<C-\\>", "<cmd>Ws<cr>")

-- Map arrow keys for wildmenu completion
vim.api.nvim_set_keymap("c", "<Down>", 'v:lua.get_wildmenu_key("<right>", "<down>")', { expr = true })
vim.api.nvim_set_keymap("c", "<Down>", 'v:lua.get_wildmenu_key("<right>", "<down>")', { expr = true })

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
  require("lib.utils").close_float_windows()
end, { noremap = true, silent = true, desc = "Close floating windows" })

-- Replace word under cursor across entire buffer
map(
  "n",
  "<leader>rw",
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { noremap = true, desc = "Replace all instances of word under cursor" }
)
-- replace all instances selected with shift + *
map("n", "<Leader>rz", [[:%s///g<Left><Left>]], { noremap = true, desc = "Replace all * search" })
vim.keymap.set("x", "<Leader>rz", ":s///g<Left><Left>", { noremap = true, desc = "Replace selected * search " })

-- Put vim command output into buffer
map("n", "g!", ":put=execute('')<Left><Left>", { desc = "Paste Command" })

-- Helper to create a jira link
map(
  "v",
  "<localleader>jl",
  ':JiraLink <C-R>"<CR>',
  { noremap = true, silent = true, desc = "Create a jira link in markdown" }
)

map("n", "<localleader>jl", ":JiraLink ", { noremap = true, desc = "Create a jira link in markdown" })
