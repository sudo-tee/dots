local DEFAULT_PRINT_TAG = "🧭"
local function get_print_tag()
  local tag = DEFAULT_PRINT_TAG
  if vim.g.debug_tag then
    tag = DEFAULT_PRINT_TAG .. " " .. vim.g.debug_tag
  end
  return tag
end

local function is_function(node_type)
  local valid_types = {
    function_declaration = true,
    method_definition = true,
    function_definition = true,
    ["function"] = true,
    arrow_function = true,
  }

  return valid_types[node_type] ~= nil
end

local function get_current_function_name()
  local node = vim.treesitter.get_node()

  while node do
    if is_function(node:type()) then
      local name = node:field("name")
      if name and #name >= 1 then
        return vim.treesitter.get_node_text(name[1], vim.api.nvim_get_current_buf())
      end
      return "anonymous"
    end
    node = node:parent()
  end
end

return {
  "sudo-tee/printer.nvim",
  -- dir = "~/Projects/_nvim/printer.nvim",
  event = { "VeryLazy" },
  keys = {
    { mode = "n", "gP", "<Plug>(printer_print)iw" },
    {
      "<localleader>dc",
      function()
        vim.fn.setreg([["]], DEFAULT_PRINT_TAG)
      end,
      desc = "Copy debug prefix",
      silent = false,
    },
    {
      "<localleader>px",
      ":g/" .. DEFAULT_PRINT_TAG .. "/norm va(o$O_d",
      desc = "Delete prints for buffer",
      silent = false,
    },
    {
      "<localleader>ps",
      function()
        require("telescope.builtin").live_grep({ default_text = DEFAULT_PRINT_TAG })
      end,
      desc = "Find all debug print for project",
      silent = false,
    },
  },
  opts = {
    keymap = "gp",
    behavior = "insert_below",
    formatters = {
      lua = function(text_inside, text_var)
        if not text_var then
          return string.format('print("%s")', text_inside)
        end
        return string.format('print("%s =" , vim.inspect(%s))', text_inside, text_var)
      end,
    },
    -- function which modifies the text inside string in the print statement, by default it adds the path and line number
    add_to_inside = function(text)
      local fn = get_current_function_name()
      local file = vim.fn.expand("%:t")
      local line = vim.fn.line(".")

      local sections = { get_print_tag(), ("%s:%s"):format(file, line) }

      if fn then
        table.insert(sections, ("ƒ(%s)"):format(fn))
      end

      table.insert(sections, ("%s"):format(text or ""))

      return table.concat(sections, " ❱ ")
    end,
  },
}
