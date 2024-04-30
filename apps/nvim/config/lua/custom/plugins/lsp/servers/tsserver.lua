return {
  settings = {
    diagnostics = {
      enable = false,
    },
  },
  single_file_support = false,
  root_dir = require('lspconfig.util').root_pattern('.git'),
}
