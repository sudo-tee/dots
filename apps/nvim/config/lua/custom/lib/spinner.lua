---@class Spinner
---@field private frames string[]
---@field private current_frame number
---@field private interval number
---@field private last_update number
---@field public themes table<string, string[]>
local Spinner = {}
Spinner.__index = Spinner

Spinner.themes = {
  dots = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
  dots2 = { '⣾', '⣽', '⣻', '⢿', '⡿', '⣟', '⣯', '⣷' },
  tetris = { '▛', '▜', '▟', '▙' },
  earth = { '🌍', '🌎', '🌏' },
  moon = { '🌑', '🌒', '🌓', '🌔', '🌕', '🌖', '🌗', '🌘' },
  grid = { '▖', '▘', '▝', '▗' },
  fancy = {
    '⣾⣽⣻⢿⡿⣟⣯⣷',
    '⣽⣻⢿⡿⣟⣯⣷⣾',
    '⣻⢿⡿⣟⣯⣷⣾⣽',
    '⢿⡿⣟⣯⣷⣾⣽⣻',
    '⡿⣟⣯⣷⣾⣽⣻⢿',
    '⣟⣯⣷⣾⣽⣻⢿⡿',
    '⣯⣷⣾⣽⣻⢿⡿⣟',
    '⣷⣾⣽⣻⢿⡿⣟⣯',
  },
  bars = {
    '▰▱▱▱▱▱▱',
    '▰▰▱▱▱▱▱',
    '▰▰▰▱▱▱▱',
    '▰▰▰▰▱▱▱',
    '▰▰▰▰▰▱▱',
    '▰▰▰▰▰▰▱',
    '▰▰▰▰▰▰▰',
    '▰▱▱▱▱▱▱',
  },
  jump = {
    '⚈⚆⚇⚉',
    '⚆⚇⚉⚈',
    '⚇⚉⚈⚆',
    '⚉⚈⚆⚇',
  },
}

---Create a new spinner
---@param frames? string[] Optional custom frames, defaults to braille pattern
---@param interval? number Optional interval between frame updates, defaults to 150ms
---@return Spinner
function Spinner.new(frames, interval)
  local self = setmetatable({
    frames = frames or Spinner.themes.dots,
    current_frame = 1,
    interval = interval or 150,
    last_update = 0,
  }, { __index = Spinner })
  return self
end

function Spinner:next()
  local current_time = vim.uv.now()
  if (current_time - self.last_update) >= self.interval then
    self.current_frame = (self.current_frame % #self.frames) + 1
    self.last_update = current_time
  end
  return self:current()
end

function Spinner:current()
  return self.frames[self.current_frame]
end

function Spinner:reset()
  self.current_frame = 1
  self.last_update = 0
end

return Spinner
