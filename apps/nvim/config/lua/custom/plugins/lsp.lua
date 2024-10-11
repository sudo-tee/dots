local u = require('custom.lib.utils')
local rust = require('custom.plugins.lsp.servers.rust-analyzer')

return {
  {
    'mrcjkb/rustaceanvim',
    version = '^4', -- Recommended
    ft = { 'rust' },
    opts = {
      server = rust.server,
    },
    config = rust.config,
  },
  { -- LSP Configuration & Plugins

    'neovim/nvim-lspconfig',
    event = 'VeryLazy',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      {
        'yioneko/nvim-vtsls',
        handlers = {},
      },
      'b0o/schemastore.nvim',
    },
    opts = {
      ---@type vim.diagnostic.Opts
      diagnostics = {
        float = {
          border = 'rounded',
        },
        underline = true,
        update_in_insert = false,
        virtual_text = false,
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
      require('lspconfig.ui.windows').default_options.border = 'rounded'
      vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = 'rounded',
      })

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('sudo_tee/lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(mode, keys, func, desc)
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          -- stylua: ignore start
          map('n', 'gd',         u.cmd('Telescope lsp_definitions'),               '[G]oto [D]efinition')
          map('n', 'gr',         u.cmd('Telescope lsp_references'),                '[G]oto [R]eferences')
          map('n', 'gI',         u.cmd('Telescope lsp_implementations'),           '[G]oto [I]mplementation')
          map('n', 'gy',         u.cmd('Telescope lsp_type_definitions'),          'T[y]pe Definition')
          map('n', '<leader>sy', u.cmd('Telescope lsp_document_symbols'),          'Document [Sy]mbols')
          map('n', '<leader>sY', u.cmd('Telescope lsp_dynamic_workspace_symbols'), 'Workspace [Sy]mbols')
          map('n', '<leader>rn', vim.lsp.buf.rename,                               '[R]e[n]ame')
          map('n', '<F2>',       vim.lsp.buf.rename,                               '[R]e[n]ame')
          map('n', '<leader>ca', vim.lsp.buf.code_action,                          '[C]ode [A]ction')
          map('n', 'K',          vim.lsp.buf.hover,                                'Hover Documentation')
          map('n', 'gK',         vim.lsp.buf.signature_help,                       'Signatiure Help')
          map('i', '<M-k>',      vim.lsp.buf.signature_help,                       'Signatiure Help')
          map('n', 'gD',         vim.lsp.buf.declaration,                          '[G]oto [D]eclaration')
          -- stylua: ignore end

          vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            local highlight_augroup = vim.api.nvim_create_augroup('sudo_tee/document-highlight', { clear = false })

            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              group = highlight_augroup,
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              group = highlight_augroup,
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('sudo_tee/lsp-detatch', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = 'sudo_tee/document-highlight', buffer = event2.buf })
              end,
            })
          end
        end,
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP Specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      -- capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

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
        -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
        --
        -- Some languages (like typescript) have entire language plugins that can be useful:
        --    https://github.com/pmizio/typescript-tools.nvim
        --
        -- But for many setups, the LSP (`tsserver`) will work just fine
        -- tsserver = require('custom.plugins.lsp.servers.tsserver'),
        rust_analyzer = {},
        volar = {},
        vtsls = require('custom.plugins.lsp.servers.vtsls'),
        eslint = require('custom.plugins.lsp.servers.eslint'),
        lua_ls = require('custom.plugins.lsp.servers.luals'),
        graphql = require('custom.plugins.lsp.servers.graphql'),
        jsonls = require('custom.plugins.lsp.servers.jsonls'),
        -- cssls = {},
        bashls = {},
        marksman = {},
      }

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
        'prettier',
        'prettierd',
        'shellcheck',
        'shfmt',
        'codelldb',
        'vue-language-server',
      })
      require('mason-tool-installer').setup({ ensure_installed = ensure_installed })

      require('mason-lspconfig').setup({
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}

            if server_name == 'rust_analyzer' then
              return true
            end

            require('lspconfig')[server_name].setup({
              cmd = server.cmd,
              settings = server.settings,
              filetypes = server.filetypes,
              capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {}),
              root_dir = server.root_dir,
              single_file_support = server.single_file_support,
              before_init = server.before_init,
              on_init = server.on_init,
              on_attach = server.on_attach,
              on_exit = server.on_exit,
            })
          end,
        },
      })

      vim.api.nvim_command('MasonToolsInstall')
    end,
  },
}
