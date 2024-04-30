return {
  single_file_support = false,
  root_dir = require('lspconfig.util').root_pattern('.git'),
  keys = {},
  on_attach = function(_opts, buff)
    local map = function(mode, keys, func, desc)
      vim.keymap.set(mode, keys, func, { buffer = buff, desc = 'LSP: ' .. desc })
    end

    map('n', '<leader>ci', function()
      require('vtsls').commands.add_missing_imports(0)
    end, 'Add missing [i]mports')

    map('n', '<leader>cA', function()
      require('vtsls').commands.fix_all(0)
    end, 'Fix [a]ll diagnostics')
  end,
  settings = {
    vtsls = {
      experimental = {
        completion = {
          enableServerSideFuzzyMatch = true,
        },
      },
    },
    javascript = {
      format = {
        enabled = false,
      },
    },
    typescript = {
      format = {
        enabled = false,
      },
    },
  },
}
