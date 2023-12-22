local debug_tag = "🧭"
local function get_print_tag()
  local print_tag = debug_tag
  if vim.g.debug_tag then
    print_tag = debug_tag .. vim.g.debug_tag
  end
  return print_tag .. " ❱ "
end

vim.keymap.set("n", "gP", "<Plug>(printer_print)iw")
local function get_current_function_name()
  local bufnr = vim.api.nvim_get_current_buf()

  local current_node = vim.treesitter.get_node()
  if not current_node then
    return ""
  end

  local expr = current_node
  while expr do
    if
      expr:type() == "function_declaration"
      or expr:type() == "method_definition"
      or expr:type() == "function_definition"
    then
      break
    end
    expr = expr:parent()
  end

  if not expr then
    return ""
  end

  local name = expr:field("name")

  if not name or #name < 1 then
    return "(anonymous)"
  end

  return vim.treesitter.get_node_text(name[1], bufnr)
end

return {
  dir = "~/Projects/_nvim/printer.nvim",
  event = { "VeryLazy" },
  opts = {
    keymap = "gp", -- Plugin doesn't have any keymaps by default
    behavior = "insert_below", -- how operator should behave
    -- "insert_below" will insert the text below the cursor
    --  "yank" will not insert but instead put text into the default '"' register
    formatters = {
      -- you can define your formatters for specific filetypes
      -- by assigning function that takes two strings
      -- one text modified by 'add_to_inside' function
      -- second the variable (thing) you want to print out
      -- see examples in lua/formatters.lua
      javascript = function(inside, variable)
        print("🧭 ❱ [print.lua:58] ❱  ❱ javascript:")
        if variable == "" then
          return string.format('console.warn("%s")', inside)
        end
        return string.format('console.warn("%s:", %s)', inside, variable)
      end,
      typescript = function(inside, variable)
        print("🧭 ❱ [print.lua:58] ❱  ❱ typescript:")
        if variable == "" then
          return string.format('console.warn("%s")', inside)
        end
        return string.format('console.warn("%s:", %s)', inside, variable)
      end,
      lua = function(inside, variable)
        print("🧭 ❱ [print.lua:72] ❱ (anonymous) ❱ lua")
        if variable == "" then
          return string.format('print("%s")', inside)
        end
        return string.format('print("%s:", vim.inspect(%s))', inside, variable)
      end,
    },
    -- function which modifies the text inside string in the print statement, by default it adds the path and line number
    add_to_inside = function(text)
      local fn = get_current_function_name()
      return string.format("%s[%s:%s] ❱ %s ❱ %s", get_print_tag(), vim.fn.expand("%:t"), vim.fn.line("."), fn, text)
    end,
    -- to turn off default behaviour and add nothing
    -- add_to_inside = function(text)
    --     return text
    -- end,
  },
}
