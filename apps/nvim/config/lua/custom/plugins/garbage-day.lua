return {
  {
    'zeioth/garbage-day.nvim',
    enabled = false,
    dependencies = 'neovim/nvim-lspconfig',
    event = 'LspAttach',
    opts = {
      excluded_lsp_clients = { 'eslint', 'vtsls', 'copilot' },
    },
  },
}
