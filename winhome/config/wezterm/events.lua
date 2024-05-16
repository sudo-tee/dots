local wezterm = require("wezterm")

local u = require("lib.utils")
local user_commands = require("user-commands")
local colors = require("lib.colors")
local prog_icons = require("lib.icons")

local key_tables = require("key-tables")

wezterm.on("user-var-changed", function(window, pane, name, value)
  if name == "uc" then
    local cmd_context = wezterm.json_parse(value)

    wezterm.log_info("User Command received ::", cmd_context)
    user_commands[cmd_context.c](window, pane, cmd_context)
    return
  end
end)

wezterm.on("update-status", function(window, pane)
  local workspace = window:active_workspace()

  local cwd_dir = pane:get_current_working_dir()
  local cwd = cwd_dir and u.basename(cwd_dir.path) or ""

  local key_table = window:active_key_table()
  if key_table then
    local details = key_tables.details[key_table] or { title = key_table, legend = "" }

    key_table = (" %s "):format(table.concat({ wezterm.nerdfonts.fa_keyboard_o, details.title, details.legend }, " "))
  end

  window:set_left_status(wezterm.format({
    { Attribute = { Intensity = "Bold" } },
    { Foreground = { Color = colors.custom.workspace_background } },
    { Background = { Color = colors.custom.workspace_foreground } },
    { Text = " " .. wezterm.nerdfonts.dev_terminal_badge .. " " },

    { Background = { Color = colors.custom.workspace_background } },
    { Foreground = { Color = colors.custom.workspace_foreground } },
    { Text = " " .. workspace .. " " },
  }))

  window:set_right_status(wezterm.format({
    { Attribute = { Intensity = "Normal" } },
    { Foreground = { Color = colors.custom.workspace_background } },
    { Background = { Color = colors.custom.workspace_foreground } },
    { Text = key_table or "" },
    { Text = " | " },
    { Text = wezterm.nerdfonts.md_folder .. "  " .. cwd },
    { Text = " " },
  }))
end)

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  ---@param tab_info TabInformation
  local function tab_title(tab_info)
    local title = tab_info.tab_title
    local pane = tab_info.active_pane

    if title and #title > 0 then
      return title
    end

    local prog = pane.user_vars.PROG or pane.user_vars.WEZTERM_PROG or ""
    if prog:len() > 0 then
      local icon = prog_icons[prog] or prog_icons["default_prog"]
      return icon .. " " .. prog
    end

    local cwd = pane.current_working_dir
    if cwd then
      return prog_icons["working_dir"] .. " " .. u.basename(cwd.path)
    end

    return tab_info.active_pane.title
  end

  local zoom_indicator = ""
  if tab.active_pane.is_zoomed then
    zoom_indicator = " " .. wezterm.nerdfonts.cod_screen_full
  end

  return {
    { Foreground = { Color = colors.custom.zoom_indicator } },
    { Text = zoom_indicator },
    "ResetAttributes",
    { Text = " " .. tab_title(tab) .. " |" },
  }
end)
