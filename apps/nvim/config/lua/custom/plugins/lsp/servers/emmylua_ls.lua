vim.api.nvim_create_user_command('LL', function()
  local client = vim.lsp.get_clients({ name = 'emmylua_ls' })[1]
  if client then
    client:notify('workspace/didChangeConfiguration', {
      settings = { Lua = {} },
    })
  else
    print('EmmyLua LSP client not found')
  end
  vim.defer_fn(function()
    vim.cmd('edit')
  end, 100)
end, {})

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client.name ~= 'emmylua_ls' then
      return
    end
  end,
})

return {
  cmd = { 'emmylua_ls' },
  filetypes = { 'lua' },
  root_markers = {
    '.emmyrc.json',
    '.luarc.json',
    'luarc.json',
    '.git',
  },
  settings = {
    Lua = {
      runtime = {
        version = 'LuaJIT',
      },
      workspace = {
        library = {
          vim.env.VIMRUNTIME,
          vim.fn.stdpath('data') .. '/lazy/lazy.nvim',
          vim.fn.stdpath('data') .. '/lazy/snacks.nvim',
        },
        ignoreGlobs = {
          '**/*_spec.lua',
        },
      },
      diagnostics = {
        enable = true,
        globals = {
          'vim',
          'Snacks',
          'it',
          'describe',
          'before_each',
          'after_each',
        },
        disable = {
          'unnecessary-if', -- buggy rule
        },
      },
      completion = {
        enable = true,
        -- callSnippet = true,
        callSnippet = 'Replace',
      },
      signature = {
        detailSignatureHelper = true,
      },
      strict = {
        typeCall = true,
      },
      hint = {
        metaCallHint = false,
      },
    },
  },
}
