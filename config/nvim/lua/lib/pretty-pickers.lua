-- Modifes telescope pickers with path after file like vscode
-- @see https://github.com/nvim-telescope/telescope.nvim/issues/2014

local M = {}

local function get_icon_width()
  local plenary_strings = require("plenary.strings")
  local dev_icons = require("nvim-web-devicons")
  return plenary_strings.strdisplaywidth(dev_icons.get_icon("fname", { default = true }))
end

local function get_path_and_tail(file_name)
  local utils = require("telescope.utils")
  local path_tail = utils.path_tail(file_name)

  local path = require("plenary.strings").truncate(file_name, #file_name - #path_tail, "")

  local display_path = utils.transform_path({
    path_display = { "truncate" },
  }, path)

  return path_tail, display_path
end

function M.file_picker_options(options)
  local make_entry = require("telescope.make_entry")
  local entry_display = require("telescope.pickers.entry_display")

  options = options or {}
  assert(type(options) == "table", "Incorrect argument format. options must be a table")

  local original_entry_maker = make_entry.gen_from_file(options)

  options.entry_maker = function(line)
    local utils = require("telescope.utils")
    local original_entry = original_entry_maker(line)

    local displayer = entry_display.create({
      separator = " ", -- Telescope will use this separator between each entry item
      items = {
        { width = get_icon_width() },
        { width = nil },
        { remaining = true },
      },
    })

    original_entry.display = function(entry)
      local tail, display_path = get_path_and_tail(entry.value)

      local display_tail = tail .. " "

      local icon, icon_highlight = utils.get_devicons(tail)

      return displayer({
        { icon, icon_highlight },
        display_tail,
        { display_path, "TelescopeResultsComment" },
      })
    end

    return original_entry
  end

  return options
end

function M.grep_picker_options(options)
  local entry_display = require("telescope.pickers.entry_display")
  local make_entry = require("telescope.make_entry")

  options = options or {}
  assert(type(options) == "table", "Incorrect argument format. options must be a table")

  local original_entry_maker = make_entry.gen_from_vimgrep(options)

  options.entry_maker = function(line)
    local utils = require("telescope.utils")
    local original_entry = original_entry_maker(line)

    local displayer = entry_display.create({
      separator = " ", -- Telescope will use this separator between each entry item
      items = {
        { width = get_icon_width() },
        { width = nil },
        { width = nil }, -- Maximum path size, keep it short
        { remaining = true },
      },
    })

    original_entry.display = function(entry)
      local tail, display_path = get_path_and_tail(entry.filename)

      local icon, icon_highlight = utils.get_devicons(tail)

      local coordinates = ""

      if not options.disable_coordinates then
        if entry.lnum then
          if entry.col then
            coordinates = string.format(" -> %s:%s", entry.lnum, entry.col)
          else
            coordinates = string.format(" -> %s", entry.lnum)
          end
        end
      end

      tail = tail .. coordinates

      local display_tail = tail .. " "

      local text = options.file_encoding and vim.iconv(entry.text, options.file_encoding, "utf8") or entry.text

      return displayer({
        { icon, icon_highlight },
        display_tail,
        { display_path, "TelescopeResultsComment" },
        text,
      })
    end

    return original_entry
  end

  return options
end

function M.buffer_picker_options(options)
  local utils = require("telescope.utils")
  local make_enty = require("telescope.make_entry")
  local entry_display = require("telescope.pickers.entry_display")

  options = options or {}
  assert(type(options) == "table", "Options must be a table.")

  local original_entry_maker = make_enty.gen_from_buffer(options)

  options.entry_maker = function(line)
    local original_entry = original_entry_maker(line)

    local displayer = entry_display.create({
      separator = " ",
      items = {
        { width = get_icon_width() },
        { width = nil },
        { width = nil },
        { remaining = true },
      },
    })

    original_entry.display = function(entry)
      local tail, path = get_path_and_tail(entry.filename)
      local display_tail = tail .. " "
      local icon, icon_highlight = utils.get_devicons(tail)

      return displayer({
        { icon, icon_highlight },
        display_tail,
        { "(" .. entry.bufnr .. ")", "TelescopeResultsNumber" },
        { path, "TelescopeResultsComment" },
      })
    end

    return original_entry
  end

  require("telescope.builtin").buffers(options)
end

M.buffers = function(options)
  M.buffer_picker_options({ options = options })
end

M.find_files = function(options)
  require("telescope.builtin").find_files(M.file_picker_options(options))
end

M.git_files = function(options)
  require("telescope.builtin").git_files(M.file_picker_options(options))
end

M.oldfiles = function(options)
  require("telescope.builtin").git_files(M.file_picker_options(options))
end

M.live_grep = function(options)
  require("telescope.builtin").live_grep(M.grep_picker_options(options))
end

M.grep_string = function(options)
  require("telescope.builtin").grep_string(M.grep_picker_options(options))
end

return M
