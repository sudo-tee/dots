local M = {}

function M.simple_picker(choices, name, on_select, attach_mappings, opts)
  local items_count = #choices
  local max_height = 25
  local min_height = 10
  local height_per_item = 1.75
  local height = math.ceil(math.min(math.max(items_count * height_per_item, min_height), max_height))

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local action_state = require("telescope.actions.state")
  local actions = require("telescope.actions")

  opts = opts or {}
  local create_finder = function(entries)
    return finders.new_table({
      results = entries,
      entry_maker = function(entry)
        if type(entry) == "table" then
          return { value = entry[1], display = entry[2], ordinal = entry[2] }
        else
          return { value = entry, display = entry, ordinal = entry }
        end
      end,
    })
  end

  local refresh = function(buf)
    return function(new_choices)
      local act = require("telescope.actions.state")
      local picker = act.get_current_picker(buf)
      picker:refresh(create_finder(new_choices))
    end
  end

  local get_selection = function()
    return action_state.get_selected_entry()
  end
  pickers
    .new(opts, {
      file_ignore_patterns = {},
      prompt_title = name,
      layout_strategy = "horizontal",
      layout_config = {
        prompt_position = "top",
        horizontal = {
          height = height,
          width = 0.4,
        },
      },
      finder = create_finder(choices),
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        map("i", "<CR>", function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          on_select(selection)
        end)
        if attach_mappings then
          attach_mappings(prompt_bufnr, map, refresh(prompt_bufnr), get_selection)
        end
        return true
      end,
    })
    :find()
end

return M
