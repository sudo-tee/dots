return {
  -- cmd = {...},
  -- filetypes { ...},
  -- capabilities = {},
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
      diagnostics = { disable = { 'missing-fields' } },
    },
  },
}
