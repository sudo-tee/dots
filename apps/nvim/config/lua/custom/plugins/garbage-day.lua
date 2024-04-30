return {
  {
    'zeioth/garbage-day.nvim',
    dependencies = 'neovim/nvim-lspconfig',
    event = 'LspAttach',
    opts = {
      'eslint',
    },
  },
}
