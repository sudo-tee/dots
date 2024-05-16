require("lib.globals")
require("events")

---@type Wezterm
local wezterm = require("wezterm")

local key_tables = require("key-tables")
local keys = require("keymaps")
local colors = require("lib.colors")

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
  cursor_blink_ease_in = "Constant",
  cursor_blink_ease_out = "Constant",
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
  key_tables = key_tables.key_tables,
  keys = keys,
}
