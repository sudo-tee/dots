local M = {}

local u = require('custom.lib.utils')

local gen_extra_spec = u.lazy_bind(function(name)
  return require('mini.extra').gen_ai_spec[name]()
end)

local custom_textobjects = {
  g = { 'Whole Buffer', gen_extra_spec('buffer') },
  i = { 'Indent', gen_extra_spec('indent') },
  N = { 'Number', gen_extra_spec('number') },
  c = {
    'Word with case',
    u.lazy_return({
      {
        '%u[%l%d]+%f[^%l%d]',
        '%f[%S][%l%d]+%f[^%l%d]',
        '%f[%P][%l%d]+%f[^%l%d]',
        '^[%l%d]+%f[^%l%d]',
      },
      '^().*()$',
    }),
  },
}

M.setup = function()
  local textobjects = vim.tbl_map(function(value)
    return value[2]()
  end, custom_textobjects)

  require('mini.ai').setup({
    n_lines = 500,
    custom_textobjects = textobjects,
  })
end
return M
