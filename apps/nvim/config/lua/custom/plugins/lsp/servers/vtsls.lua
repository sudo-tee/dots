return {
  filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact' },
  single_file_support = true,
  root_dir = require('lspconfig.util').root_pattern('.git'),
  on_attach = function(_opts, buff)
    local map = function(mode, keys, func, desc)
      vim.keymap.set(mode, keys, func, { buffer = buff, desc = 'LSP: ' .. desc })
    end

    map('n', '<leader>ci', function()
      require('vtsls').commands.add_missing_imports(0)
    end, 'Add missing [i]mports')

    map('n', '<leader>cx', function()
      require('vtsls').commands.source_actions(0)
    end, 'Sources actions')

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
  before_init = function(params, config)
    -- local vuePluginConfig = {
    --   name = '@vue/typescript-plugin',
    --   location = vim.fn.expand('$MASON/packages/vue-language-server/node_modules/@vue/language-server'),
    --   languages = { 'vue' },
    --   configNamespace = 'typescript',
    --   enableForWorkspaceTypeScriptVersions = true,
    -- }
    -- table.insert(config.settings.vtsls.tsserver.globalPlugins, vuePluginConfig)
  end,
  settings = {
    vtsls = {
      enableMoveToFileCodeAction = true,
      experimental = {
        completion = {
          enableServerSideFuzzyMatch = true,
          entriesLimit = 200,
        },
      },
      tsserver = {
        globalPlugins = {},
      },
    },
    javascript = {
      inlayHints = {
        parameterNames = {
          enabled = 'all',
          suppressWhenArgumentMatchesName = true,
        },
        parameterTypes = {
          enabled = true,
        },
        variableTypes = {
          enabled = true,
          suppressWhenTypeMatchesName = true,
        },
        propertyDeclarationTypes = {
          enabled = true,
        },
        functionLikeReturnTypes = {
          enabled = true,
        },
        enumMemberValues = {
          enabled = true,
        },
        includeCompletionsForImportStatements = true,
      },
      importModuleSpecifierPreference = 'non-relative',
      updateImportsOnFileMove = 'always',
      -- preferGoToSourceDefinition = true,
      format = {
        enabled = false,
      },
    },
    typescript = {
      inlayHints = {
        parameterNames = {
          enabled = 'all',
          suppressWhenArgumentMatchesName = true,
        },
        parameterTypes = {
          enabled = true,
        },
        variableTypes = {
          enabled = true,
          suppressWhenTypeMatchesName = true,
        },
        propertyDeclarationTypes = {
          enabled = true,
        },
        functionLikeReturnTypes = {
          enabled = true,
        },
        enumMemberValues = {
          enabled = true,
        },
        includeCompletionsForImportStatements = true,
      },
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
