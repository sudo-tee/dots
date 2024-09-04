---@type Wezterm
---@diagnostic disable-next-line: assign-type-mismatch
local wezterm = require("wezterm")

local TextBuilder = {}
TextBuilder.__index = TextBuilder

function TextBuilder.new(text)
  local self = setmetatable({}, TextBuilder)
  self.text = text
  self.format_items = {}
  return self
end

function TextBuilder:fg(color)
  local color_type = (string.sub(color, 1, 1) == "#") and "Color" or "AnsiColor"
  table.insert(self.format_items, { Foreground = { [color_type] = color } })
  return self
end

function TextBuilder:bg(color)
  local color_type = (string.sub(color, 1, 1) == "#") and "Color" or "AnsiColor"
  table.insert(self.format_items, { Background = { [color_type] = color } })
  return self
end

function TextBuilder:intensity(intensity)
  table.insert(self.format_items, { Attribute = { Intensity = intensity } })
  return self
end

function TextBuilder:underline(underline)
  table.insert(self.format_items, { Attribute = { Underline = underline } })
  return self
end

function TextBuilder:italic(italic)
  italic = italic ~= nil and italic or true
  table.insert(self.format_items, { Attribute = { Italic = italic } })
  return self
end

function TextBuilder:attrs(attrs)
  for k, v in pairs(attrs) do
    table.insert(self.format_items, { Attribute = { [k] = v } })
  end
  return self
end

function TextBuilder:reset()
  table.insert(self.format_items, "ResetAttributes")
  return self
end

function TextBuilder:append(text)
  self.text = self.text .. text
  return self
end

function TextBuilder:merge(format_items, reset)
  local result = self:items()

  if reset then
    table.insert(result, "ResetAttributes")
  end

  for _, item in ipairs(format_items:items() or {}) do
    table.insert(result, item)
  end

  self.format_items = result

  return self
end

function TextBuilder:items()
  local result = {}
  for _, item in ipairs(self.format_items) do
    table.insert(result, item)
  end

  if self.text then
    table.insert(result, { Text = self.text })
    self.text = nil
  end

  return result
end

function TextBuilder:format()
  return wezterm.format(self:items())
end

return TextBuilder
