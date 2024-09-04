local M = {}
---@class PaletteColors
M.palette = {

  -- Bg Shades
  sumiInk0 = "#16161D",
  sumiInk1 = "#181820",
  sumiInk2 = "#1a1a22",
  sumiInk3 = "#1F1F28",
  sumiInk4 = "#2A2A37",
  sumiInk5 = "#363646",
  sumiInk6 = "#54546D", --fg

  -- Popup and Floats
  waveBlue1 = "#223249",
  waveBlue2 = "#2D4F67",

  -- Diff and Git
  winterGreen = "#2B3328",
  winterYellow = "#49443C",
  winterRed = "#43242B",
  winterBlue = "#252535",
  autumnGreen = "#76946A",
  autumnRed = "#C34043",
  autumnYellow = "#DCA561",

  -- Diag
  samuraiRed = "#E82424",
  roninYellow = "#FF9E3B",
  waveAqua1 = "#6A9589",
  dragonBlue = "#658594",

  -- Fg and Comments
  oldWhite = "#C8C093",
  fujiWhite = "#DCD7BA",
  fujiGray = "#727169",

  oniViolet = "#957FB8",
  oniViolet2 = "#b8b4d0",
  crystalBlue = "#7E9CD8",
  springViolet1 = "#938AA9",
  springViolet2 = "#9CABCA",
  springBlue = "#7FB4CA",
  lightBlue = "#A3D4D5",
  waveAqua2 = "#7AA89F",

  waveAqua4 = "#7AA880",
  waveAqua5 = "#6CAF95",
  waveAqua3 = "#68AD99",

  springGreen = "#98BB6C",
  boatYellow1 = "#938056",
  boatYellow2 = "#C0A36E",
  carpYellow = "#E6C384",

  sakuraPink = "#D27E99",
  waveRed = "#E46876",
  peachRed = "#FF5D62",
  surimiOrange = "#FFA066",
  katanaGray = "#717C7C",

  dragonBlack0 = "#0d0c0c",
  dragonBlack1 = "#12120f",
  dragonBlack2 = "#1D1C19",
  dragonBlack3 = "#181616",
  dragonBlack4 = "#282727",
  dragonBlack5 = "#393836",
  dragonBlack6 = "#625e5a",

  dragonWhite = "#c5c9c5",
  dragonGreen = "#87a987",
  dragonGreen2 = "#8a9a7b",
  dragonPink = "#a292a3",
  dragonOrange = "#b6927b",
  dragonOrange2 = "#b98d7b",
  dragonGray = "#a6a69c",
  dragonGray2 = "#9e9b93",
  dragonGray3 = "#7a8382",
  dragonBlue2 = "#8ba4b0",
  dragonViolet = "#8992a7",
  dragonRed = "#c4746e",
  dragonAqua = "#8ea4a2",
  dragonAsh = "#737c73",
  dragonTeal = "#949fb5",
  dragonYellow = "#c4b28a", --"#a99c8b",
  -- "#8a9aa3",

  lotusInk1 = "#545464",
  lotusInk2 = "#43436c",
  lotusGray = "#dcd7ba",
  lotusGray2 = "#716e61",
  lotusGray3 = "#8a8980",
  lotusWhite0 = "#d5cea3",
  lotusWhite1 = "#dcd5ac",
  lotusWhite2 = "#e5ddb0",
  lotusWhite3 = "#f2ecbc",
  lotusWhite4 = "#e7dba0",
  lotusWhite5 = "#e4d794",
  lotusViolet1 = "#a09cac",
  lotusViolet2 = "#766b90",
  lotusViolet3 = "#c9cbd1",
  lotusViolet4 = "#624c83",
  lotusBlue1 = "#c7d7e0",
  lotusBlue2 = "#b5cbd2",
  lotusBlue3 = "#9fb5c9",
  lotusBlue4 = "#4d699b",
  lotusBlue5 = "#5d57a3",
  lotusGreen = "#6f894e",
  lotusGreen2 = "#6e915f",
  lotusGreen3 = "#b7d0ae",
  lotusPink = "#b35b79",
  lotusOrange = "#cc6d00",
  lotusOrange2 = "#e98a00",
  lotusYellow = "#77713f",
  lotusYellow2 = "#836f4a",
  lotusYellow3 = "#de9800",
  lotusYellow4 = "#f9d791",
  lotusRed = "#c84053",
  lotusRed2 = "#d7474b",
  lotusRed3 = "#e82424",
  lotusRed4 = "#d9a594",
  lotusAqua = "#597b75",
  lotusAqua2 = "#5e857a",
  lotusTeal1 = "#4e8ca2",
  lotusTeal2 = "#6693bf",
  lotusTeal3 = "#5a7785",
  lotusCyan = "#d7e3d8",
}

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
  ws_colors = {
    "#7e9cd8",
    "#7AA880",
    "#b8b4d0",
    "#98BB6C",
    "#D27E99",
    "#43436c",
    "#766b90",
    "#DCA561",
    "#6693bf",
    "#d9a594",
    "#f9d791",
    "#FFA066",
    "#c4746e",
    "#b7d0ae",
    "#957FB8",
    "#DCD7BA",
    "#C0A36E",
    "#8ba4b0",
    "#4d699b",
    "#d7e3d8",
  },
}

local colorCache = {}
local colorIndex = 1

function M.getWorkspaceColor(inputString, defaultColor)
  defaultColor = defaultColor or M.workspace_background
  if colorCache[inputString] then
    return colorCache[inputString]
  end

  if colorIndex > #M.custom.ws_colors then
    return defaultColor
  end

  local color = M.custom.ws_colors[colorIndex]

  colorIndex = colorIndex + 1

  colorCache[inputString] = { bg = color, fg = M.getForegroundColor(color) }

  return { bg = color, fg = M.getForegroundColor(color) }
end

function M.getForegroundColor(bgColor)
  local r = tonumber(string.sub(bgColor, 2, 3), 16)
  local g = tonumber(string.sub(bgColor, 4, 5), 16)
  local b = tonumber(string.sub(bgColor, 6, 7), 16)

  local luminance = 0.299 * r + 0.587 * g + 0.114 * b

  if luminance > 128 then
    return M.custom.workspace_foreground
  else
    return M.kanagawa.foreground
  end
end

return M
