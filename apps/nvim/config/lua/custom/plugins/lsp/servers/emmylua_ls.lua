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

-- Ugly hack to make it work with lazydev
-- EmmyLua does not sent the workspace/didChangeConfiguration on initialization
-- so we need to do it manually on the first attach
local first_attach = true
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client.name ~= 'emmylua_ls' then
      return
    end
    if first_attach then
      first_attach = false
      -- set runtime path
      vim.defer_fn(function()
        client.notify('workspace/didChangeConfiguration', {
          settings = { Lua = {} },
        })
        vim.defer_fn(function()
          vim.cmd('edit')
        end, 100)
      end, 400)
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
        ignoreGlobs = {
          '**/*_spec.lua', -- to avoid some weird type defs in a plugin
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
