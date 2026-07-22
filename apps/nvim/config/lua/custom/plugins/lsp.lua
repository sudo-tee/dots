return {
  { -- LSP Configuration & Plugins

    'neovim/nvim-lspconfig',
    event = 'VeryLazy',
    dependencies = {
      'folke/lazydev.nvim',
      'mason-org/mason.nvim',
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'b0o/schemastore.nvim',
    },
    opts = {
      capabilities = {
        workspace = {
          fileOperations = {
            didRename = true,
            willRename = true,
          },
        },
      },
      ---@type vim.diagnostic.Opts
      diagnostics = {
        float = {
          border = 'rounded',
        },
        underline = true,
        update_in_insert = false,
        virtual_text = {
          current_line = true,
        },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = '',
            [vim.diagnostic.severity.WARN] = '',
            [vim.diagnostic.severity.HINT] = '󰌵',
            [vim.diagnostic.severity.INFO] = '󰋼',
          },
        },
      },
    },
    config = function(_, opts)
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('sudo_tee/lsp-attach', { clear = true }),
        callback = function(event)
          local hover = function()
            vim.lsp.buf.hover({ border = 'rounded' })
          end
          local signature_help = function()
            vim.lsp.buf.signature_help({ border = 'rounded' })
          end

          local map = function(mode, keys, func, desc)
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          -- stylua: ignore start
          map('n', '<leader>rn', vim.lsp.buf.rename,                               '[R]e[n]ame')
          map('n', '<F2>',       vim.lsp.buf.rename,                               '[R]e[n]ame')
          map('n', '<leader>ca', vim.lsp.buf.code_action,                          '[C]ode [A]ction')
          map('n', 'K',          hover,                                            'Hover Documentation')
          map('n', 'gK',         signature_help,                                   'Signatiure Help')
          map('i', '<M-k>',      signature_help,                                   'Signatiure Help')
          map('n', 'gD',         vim.lsp.buf.declaration,                          '[G]oto [D]eclaration')
          -- stylua: ignore end

          vim.schedule(function()
            vim.diagnostic.config(vim.deepcopy(opts.diagnostics))
          end)
        end,
      })

      local capabilities =
        vim.tbl_deep_extend('force', {}, vim.lsp.protocol.make_client_capabilities(), opts.capabilities or {})

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        -- clangd = {},
        -- gopls = {},
        -- pyright = {},
        tsgo = require('custom.plugins.lsp.servers.tsgo'),
        eslint = require('custom.plugins.lsp.servers.eslint'),
        -- lua_ls = require('custom.plugins.lsp.servers.luals'),
        emmylua_ls = require('custom.plugins.lsp.servers.emmylua_ls'),
        graphql = require('custom.plugins.lsp.servers.graphql'),
        jsonls = require('custom.plugins.lsp.servers.jsonls'),
        cssls = {},
        bashls = {},
        marksman = {},
        -- cssmodules_ls = {},
        -- oxlint = require('custom.plugins.lsp.servers.oxlint'),
      }

      for server_name, config in pairs(servers) do
        if server_name ~= 'emmylua_ls' and server_name ~= 'cssls' then
          require('lspconfig')[server_name].setup(config)
        end
        vim.lsp.config(server_name, config)
        vim.lsp.enable({ 'emmylua_ls' })
      end
      -- Ensure the servers and tools above are installed
      --  To check the current status of installed tools and/or manually install
      --  other tools, you can run
      --    :Mason
      --
      --  You can press `g?` for help in this menu
      require('mason').setup()

      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua',
        'eslint',
        -- 'oxlint',
        'prettier',
        'prettierd',
        'shellcheck',
        'shfmt',
        'codelldb',
        'vue-language-server',
      })
      require('mason-tool-installer').setup({ ensure_installed = ensure_installed })

      require('mason-lspconfig').setup({
        ensure_installed = {},
        automatic_installation = false,
        automatic_enable = true,
      })

      vim.api.nvim_command('MasonToolsInstall')
    end,
  },
}
