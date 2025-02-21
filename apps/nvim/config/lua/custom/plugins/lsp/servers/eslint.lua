return {
  root_dir = require('lspconfig.util').root_pattern('package.json', '.eslintrc.json', '.eslintrc.js', '.eslintrc'),
  settings = {
    -- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
    workingDirectories = { mode = 'auto' },
  },
  on_attach = function(client, bufnr)
    local u = require('custom.lib.utils')
    local map = function(mode, keys, func, desc)
      vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
    end

    map('n', '<leader>cF', u.cmd('EslintFixAll'), '[F]ix all lint issues')
  end,
}
