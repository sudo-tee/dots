local M = {}

M.setup = function()
  local mini_icons = require('mini.icons')
  mini_icons.setup({
    extension = {
      ['spec.ts'] = { glyph = '󰤒', hl = 'MiniIconsGreen' },
      ['test.ts'] = { glyph = '󰤒', hl = 'MiniIconsGreen' },
      ['spec.tsx'] = { glyph = '󰤒', hl = 'MiniIconsGreen' },
      ['test.tsx'] = { glyph = '󰤒', hl = 'MiniIconsGreen' },
    },
  })
  if mini_icons.mock_nvim_web_devicons then
    mini_icons.mock_nvim_web_devicons()
  end
end

return M
