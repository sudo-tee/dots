local M = {}

M.macros = {
  {
    name = "Array Line",
    macro = 'Vgza"A,<Esc><Down>',
    description = "Wrap line in quotes + comma",
  },
}

function M.run_macro(macro_name)
  local macro = M.macros[macro_name].macro
  vim.api.nvim_exec("normal " .. macro, true)
end

function M.find_defined_macro()
  local macro_names = {}
  for _, v in pairs(M.macros) do
    table.insert(macro_names, v.name .. " ≣ " .. v.description)
  end

  vim.ui.select(macro_names, {
    prompt = "Choose a macro to copy",
  }, function(selection, idx)
    if not selection then
      return
    end
    local macro = M.macros[idx].macro
    vim.fn.setreg("a", M.transform_all_keycodes(macro))
    vim.api.nvim_echo({ { "Macro copied to register a", "Info" } }, true, {})
  end)
end

function M.transform_all_keycodes(macro_string)
  macro_string = macro_string:gsub("<(.-)>", function(key)
    return vim.api.nvim_replace_termcodes("<" .. key .. ">", true, true, true)
  end)
  return macro_string
end

return M
