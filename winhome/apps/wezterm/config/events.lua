local u = require("lib.utils")
local user_commands = require("user-commands")
local colors = require("lib.colors")
local prog_icons = require("lib.icons")
local workspace_manager = require("lib.workspace-manager")
local icons = wezterm.nerdfonts

local WS_BG = colors.custom.workspace_background
local WS_FG = colors.custom.workspace_foreground

wezterm.on("user-var-changed", function(window, pane, name, value)
  if name == "uc" then
    local cmd_context = wezterm.json_parse(value)

    wezterm.log_info("User Command received ::", cmd_context)
    user_commands[cmd_context.c](window, pane, cmd_context)
    return
  end
end)

wezterm.on("workspace-switcher-switched", function(ev)
  if ev.is_new and ev.path then
    workspace_manager.configure_workspace(ev.name, ev.path, ev.window)
  end
end)

wezterm.on("update-status", function(window, pane)
  local workspace = window:active_workspace()
  local workspaces = wezterm.mux.get_workspace_names()

  local key_table = window:active_key_table()

  local ws_color = colors.getWorkspaceColor(workspace)

  window:set_left_status(wezterm.format({
    { Attribute = { Intensity = "Bold" } },
    { Foreground = { Color = WS_BG } },
    { Background = { Color = WS_FG } },
    { Text = " " .. icons.dev_terminal_badge .. " " },
    { Background = { Color = ws_color.bg } },
    { Foreground = { Color = ws_color.fg } },
    { Text = " 󱂬  " .. workspace .. " " },
    { Text = "Ⅰ " .. #workspaces .. " " },
  }))

  if key_table then
    wezterm.emit("update-key-table-legend/" .. key_table, window, pane)
    return
  end

  local datetime = "" .. wezterm.nerdfonts.md_clock_outline .. " " .. wezterm.strftime("%B %e, %H:%M")

  window:set_right_status(wezterm.format({
    { Foreground = { AnsiColor = "Navy" } },
    { Background = { Color = WS_FG } },
    { Text = datetime },
  }))
end)

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  ---@param tab_info TabInformation
  local function tab_title(tab_info)
    local title = tab_info.tab_title or ""
    local prog = tab_info.active_pane.user_vars.PROG or tab_info.active_pane.user_vars.WEZTERM_PROG or ""
    local cwd = tab_info.active_pane.current_working_dir

    local prog_icon = prog and prog_icons[prog] or prog_icons["default_prog"]

    if title ~= "" then
      return prog_icon .. "  " .. title
    elseif prog ~= "" then
      return prog_icon .. "  " .. prog
    elseif cwd then
      return prog_icons["working_dir"] .. "  " .. u.basename(cwd.path)
    else
      return prog_icon .. "  " .. tab_info.active_pane.title
    end
  end

  local zoom_indicator = tab.active_pane.is_zoomed and " " .. icons.cod_screen_full or ""

  return {
    { Foreground = { AnsiColor = "Maroon" } },
    { Text = zoom_indicator },
    "ResetAttributes",
    { Text = " " .. tab_title(tab) .. "  " },
  }
end)
