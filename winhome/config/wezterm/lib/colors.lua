local M = {}

M.kanagawa = {
  tab_bar = {
    background = "#2A2A37",
    active_tab = {
      bg_color = "#1F1F28",
      fg_color = "#e0af68",
    },
  },
  foreground = "#dcd7ba",
  background = "#1F1F28",

  cursor_bg = "#c8c093",
  cursor_fg = "#0d0c0c",
  cursor_border = "#c8c093",

  selection_fg = "#c8c093",
  selection_bg = "#0d0c0c",

  scrollbar_thumb = "#16161d",
  split = "#766b90",

  ansi = {
    "#090618", -- Black
    "#c34043", -- Maroon
    "#76946a", -- Green
    "#c0a36e", -- Olive
    "#7e9cd8", -- Navy
    "#957fb8", -- Purple
    "#6a9589", -- Teal
    "#c8c093", -- Silver
  },
  brights = {
    "#727169", -- Grey
    "#e82424", -- Red
    "#98bb6c", -- Lime
    "#e6c384", -- Yellow
    "#7fb4ca", -- Blue
    "#938aa9", -- Fuchsia
    "#7aa89f", -- Aqua
    "#dcd7ba", -- White
  },
  indexed = { [16] = "#ffa066", [17] = "#ff5d62" },
}

M.custom = {
  workspace_foreground = "#223249",
  workspace_background = "#7e9cd8",
}

return M
