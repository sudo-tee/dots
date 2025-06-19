return {
  root_dir = require('lspconfig.util').root_pattern(
    'package.json',
    '.eslintrc.json',
    '.eslintrc.js',
    '.eslintrc',
    '.oxlintrc.json',
    '.oxlintrc.js',
    '.oxlintrc'
  ),
  on_attach = function(client, bufnr)
    local u = require('custom.lib.utils')
    local map = function(mode, keys, func, desc)
      vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
    end

    map('n', '<leader>cF', u.cmd('OxcFixAll'), '[F]ix all lint issues')
  end,
}
