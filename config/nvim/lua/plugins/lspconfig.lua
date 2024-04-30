return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "jose-elias-alvarez/typescript.nvim",
    init = function()
      require("lazyvim.util").on_attach(function(_, buffer)
        vim.keymap.set("n", "<leader>co", "TypescriptOrganizeImports", { buffer = buffer, desc = "Organize Imports" })
        vim.keymap.set("n", "<leader>cR", "TypescriptRenameFile", { desc = "Rename File", buffer = buffer })
      end)
    end,
  },
  opts = {
    ---@type lspconfig.options
    servers = {
      -- tsserver will be automatically installed with mason and loaded with lspconfig
      tsserver = {},
    },
    -- you can do any additional lsp server setup here
    -- return true if you don't want this server to be setup with lspconfig
    ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
    setup = {
      tsserver = function(_, opts)
        opts.root_dir = require("lspconfig.util").root_pattern(".git")
      end,
      -- Specify * to use this function as a fallback for any server
      -- ["*"] = function(server, opts) end,
    },
  },
}
