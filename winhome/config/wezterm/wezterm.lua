require("lib.globals")
require("events")

local keys = require("keymaps")
local colors = require("lib.colors")
local workspace_switcher = require("lib.workspace-switcher")
local workspace_manager = require("lib.workspace-manager")
local smart_splits = require("lib.smart-splits")

local projects = require("lib.projects")

-- This table will hold the configuration.
--- @class Config
local c = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  c = wezterm.config_builder()
end

c.max_fps = 144
c.window_decorations = "RESIZE"
c.use_fancy_tab_bar = false
c.tab_max_width = 24
c.status_update_interval = 2000
c.default_domain = "WSL:Ubuntu"
c.show_tab_index_in_tab_bar = false
c.show_new_tab_button_in_tab_bar = false
c.enable_scroll_bar = false
c.window_close_confirmation = "NeverPrompt"
c.exit_behavior = "Close"
c.font = wezterm.font("Rec Mono Duotone", { weight = "Regular", stretch = "Normal", style = "Normal" })
c.adjust_window_size_when_changing_font_size = false
c.freetype_load_flags = "NO_HINTING"
c.warn_about_missing_glyphs = false
c.font_size = 10.7
c.front_end = "WebGpu"
c.webgpu_power_preference = "HighPerformance"
c.colors = colors.kanagawa
c.cursor_blink_ease_in = "Constant"
c.cursor_blink_ease_out = "Constant"
c.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}
c.key_tables = {}
c.keys = keys

-- setup custom plugins options
smart_splits.setup(c)

workspace_switcher.setup(c, { get_projects = projects.get_projects })
workspace_manager.setup(c, { get_layout = projects.get_layout })

return c
