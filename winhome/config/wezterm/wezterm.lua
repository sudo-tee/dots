local wezterm = require("wezterm")
local actions = require("actions")

local act = wezterm.action
local u = require("lib.utils")
local smart_splits = require("lib.smart-splits")
local user_commands = require("user-commands")
local colors = require("lib.colors")

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
    { Text = " | " },
    { Text = wezterm.nerdfonts.md_folder .. "  " .. cwd },
    { Text = " " },
  }))
end)

local prog_icons = {
  nvim = wezterm.nerdfonts.custom_neovim,
  ["t watch"] = wezterm.nerdfonts.dev_nodejs_small,
  ["nr dev"] = wezterm.nerdfonts.dev_nodejs_small,
  ["nr start"] = wezterm.nerdfonts.dev_nodejs_small,
  ["ni"] = wezterm.nerdfonts.dev_npm,
  ["title"] = wezterm.nerdfonts.md_format_title,
  ["working_dir"] = wezterm.nerdfonts.oct_terminal,
  ["default_prog"] = wezterm.nerdfonts.md_application,
}

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
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

return {
  max_fps = 144,
  window_decorations = "RESIZE",
  use_fancy_tab_bar = false,
  tab_max_width = 24,
  status_update_interval = 2000,
  default_domain = "WSL:Ubuntu",
  -- default_domain = "dev",
  show_tab_index_in_tab_bar = false,
  show_new_tab_button_in_tab_bar = false,
  enable_scroll_bar = false,
  window_close_confirmation = "NeverPrompt",
  exit_behavior = "Close",
  font = wezterm.font("Rec Mono Duotone", { weight = "Regular", stretch = "Normal", style = "Normal" }),
  -- font = wezterm.font("UbuntuMono Nerd Font", { weight = "Regular", stretch = "Normal", style = "Normal" }),
  warn_about_missing_glyphs = false,
  font_size = 10.7,
  front_end = "WebGpu",
  webgpu_power_preference = "HighPerformance",
  colors = colors.kanagawa,
  ssh_domains = {
    {
      name = "dev",
      remote_address = "dev",
      username = "francis",
      connect_automatically = true,
      multiplexing = "None",
    },
  },
  window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },
  keys = {
    {
      mods = "ALT",
      key = [[\]],
      action = wezterm.action_callback(actions.split_pane("Right")),
    },
    {
      mods = "ALT",
      key = [[-]],
      action = wezterm.action_callback(actions.split_pane("Bottom")),
    },
    {
      key = "T",
      mods = "ALT",
      action = wezterm.action_callback(actions.create_new_tab),
    },
    {
      key = "Z",
      mods = "ALT",
      action = act.TogglePaneZoomState,
    },
    {
      key = "LeftArrow",
      mods = "SHIFT|ALT",
      action = act.ActivateTabRelative(-1),
    },
    {
      key = "RightArrow",
      mods = "SHIFT|ALT",
      action = act.ActivateTabRelative(1),
    },
    -- WORKSPACE Management
    {
      key = "K",
      mods = "ALT",
      action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }),
    },
    {
      key = "J",
      mods = "ALT",
      action = wezterm.action_callback(actions.switch_to_open_workspace),
    },
    {
      key = "O",
      mods = "ALT",
      action = wezterm.action_callback(actions.open_project_workspace),
    },
    {
      key = "N",
      mods = "ALT",
      action = wezterm.action_callback(actions.create_new_workspace),
    },
    {
      key = "Delete",
      mods = "ALT|SHIFT",
      action = wezterm.action_callback(actions.kill_current_wokspace),
    },
    -- move between split panes
    smart_splits.split_nav("move", "h"),
    smart_splits.split_nav("move", "j"),
    smart_splits.split_nav("move", "k"),
    smart_splits.split_nav("move", "l"),
    smart_splits.split_nav("move", "LeftArrow"),
    smart_splits.split_nav("move", "DownArrow"),
    smart_splits.split_nav("move", "UpArrow"),
    smart_splits.split_nav("move", "RightArrow"),

    -- resize panes
    smart_splits.split_nav("resize", "h"),
    smart_splits.split_nav("resize", "j"),
    smart_splits.split_nav("resize", "k"),
    smart_splits.split_nav("resize", "l"),
    smart_splits.split_nav("resize", "LeftArrow"),
    smart_splits.split_nav("resize", "DownArrow"),
    smart_splits.split_nav("resize", "UpArrow"),
    smart_splits.split_nav("resize", "RightArrow"),
  },
}
