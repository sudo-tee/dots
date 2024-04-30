return {
  settings = {
    diagnostics = {
      enable = false,
    },
  },
  single_file_support = false,
  root_dir = require('lspconfig.util').root_pattern('.git'),
  -- on_exit = function()
  --   require('custom.lib.utils').auto_restart_lsp('tsserver')
  -- end,
}
