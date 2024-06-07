require("lib.globals")

---@type Wezterm
local wezterm = require("wezterm")

local keys = require("keymaps")
local colors = require("lib.colors")
local workspace_switcher = require("lib.workspace-switcher")
local events = require("events")
local smart_splits = require("lib.smart-splits")

-- This table will hold the configuration.
--- @class Config
local config = {}

-- this will hold custom configurations
local custom_config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.max_fps = 144
config.window_decorations = "RESIZE"
config.use_fancy_tab_bar = false
config.tab_max_width = 24
config.status_update_interval = 2000
config.default_domain = "WSL:Ubuntu"
-- default_domain = "dev"
config.show_tab_index_in_tab_bar = false
config.show_new_tab_button_in_tab_bar = false
config.enable_scroll_bar = false
config.window_close_confirmation = "NeverPrompt"
config.exit_behavior = "Close"
config.font = wezterm.font("Rec Mono Duotone", { weight = "Regular", stretch = "Normal", style = "Normal" })
config.freetype_load_flags = "NO_HINTING"
config.warn_about_missing_glyphs = false
config.font_size = 10.7
config.front_end = "WebGpu"
config.webgpu_power_preference = "HighPerformance"
config.colors = colors.kanagawa
config.cursor_blink_ease_in = "Constant"
config.cursor_blink_ease_out = "Constant"
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}
config.key_tables = {}
config.keys = keys

-- setup custom plugins and configurations
workspace_switcher.setup(config, custom_config)
smart_splits.setup(config, custom_config)
events.setup(config, custom_config)

return config
