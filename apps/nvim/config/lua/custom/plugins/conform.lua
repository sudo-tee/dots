return { -- Autoformat
  'stevearc/conform.nvim',
  lazy = true,
  event = 'VeryLazy',
  opts = {
    notify_on_error = false,
    default_format_opts = {
      stop_after_first = true,
    },
    formatters_by_ft = {
      lua = { 'stylua' },
      -- Conform can also run multiple formatters sequentially
      -- python = { "isort", "black" },
      --
      -- You can use a sub-list to tell conform to run *until* a formatter
      -- is found.
      javascriptreact = { 'prettierd', 'prettier' },
      typescriptreact = { 'prettierd', 'prettier' },
      javascript = { 'prettierd', 'prettier' },
      typescript = { 'prettierd', 'prettier' },
      html = { 'prettierd', 'prettier' },
      scss = { 'prettierd', 'prettier' },
      sh = { 'shfmt' },
      markdown = { 'prettierd', 'prettier' },
    },
    formatters = {
      injected = { options = { ignore_errors = true } },
      shfmt = {
        prepend_args = { '-i', '2' },
      },
    },
  },
  config = function(_, opts)
    if vim.g.format_on_save == false then
      opts.format_on_save = nil
    else
      opts.format_on_save = {
        timeout_ms = 700,
        lsp_fallback = true,
      }
    end

    require('conform').setup(opts)
  end,
}
