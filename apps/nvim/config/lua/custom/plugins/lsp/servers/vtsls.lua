return {
  single_file_support = true,
  root_dir = require('lspconfig.util').root_pattern('.git'),
  on_attach = function(_opts, buff)
    local u = require('custom.lib.utils')
    local map = function(mode, keys, func, desc)
      vim.keymap.set(mode, keys, func, { buffer = buff, desc = 'LSP: ' .. desc })
    end

    map('n', '<leader>ci', function()
      require('vtsls').commands.add_missing_imports(0)
    end, 'Add missing [i]mports')

    map('n', '<leader>cA', function()
      require('vtsls').commands.fix_all(0)
    end, 'Fix [a]ll diagnostics')

    map('n', '<leader>cTL', function()
      require('vtsls').commands.open_tsserver_log()
    end, 'Open [T]ypescript [L]ogs')

    map('n', '<leader>cr', function()
      require('vtsls').commands.restart_server()
    end, '[R]estart TS server')
  end,
  settings = {
    vtsls = {
      enableMoveToFileCodeAction = true,
      experimental = {
        completion = {
          enableServerSideFuzzyMatch = true,
        },
      },
    },
    javascript = {
      updateImportsOnFileMove = 'always',
      -- preferGoToSourceDefinition = true,
      format = {
        enabled = false,
      },
    },
    typescript = {
      updateImportsOnFileMove = 'always',
      -- preferGoToSourceDefinition = true,
      tsserver = {
        maxTsServerMemory = 8096,
        -- log = 'verbose',
        -- nodePath = '/home/francis/.local/share/node-v20.12.1-linux-x64-pointer-compression/bin/node',
      },
      format = {
        enabled = false,
      },
    },
  },
}
