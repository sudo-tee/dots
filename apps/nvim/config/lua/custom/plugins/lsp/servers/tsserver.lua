return {
  settings = {
    documentformatting = false,
  },
  root_dir = require('lspconfig.util').root_pattern('.git'),
  on_exit = function()
    require('custom.lib.utils').auto_restart_lsp('tsserver')
  end,
}
