return { -- Autoformat
  'stevearc/conform.nvim',
  lazy = true,
  event = 'VeryLazy',
  opts = {
    notify_on_error = false,
    format_on_save = {
      timeout_ms = 700,
      lsp_fallback = true,
    },
    formatters_by_ft = {
      lua = { 'stylua' },
      -- Conform can also run multiple formatters sequentially
      -- python = { "isort", "black" },
      --
      -- You can use a sub-list to tell conform to run *until* a formatter
      -- is found.
      javascriptreact = { { 'prettierd', 'prettier' } },
      typescriptreact = { { 'prettierd', 'prettier' } },
      javascript = { { 'prettierd', 'prettier' } },
      typescript = { { 'prettierd', 'prettier' } },
      scss = { { 'prettierd', 'prettier' } },
      sh = { 'shfmt' },
    },
    formatters = {
      injected = { options = { ignore_errors = true } },
      shfmt = {
        prepend_args = { '-i', '2' },
      },
    },
  },
}
