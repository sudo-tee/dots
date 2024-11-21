return {
  -- 'sudo-tee/changesets.nvim',
  dir = '/home/francis/Projects/_nvim/changesets.nvim/',
  dependencies = { 'neovim/nvim-lspconfig', 'nvim-telescope/telescope.nvim' },
  ---@module 'changesets'
  ---@type changesets.Opts
  opts = {
    changed_packages_marker = '✨',
    get_default_text = function()
      return require('custom.lib.jira').format_ticket_as_markdown_link() or ''
    end,
  },
  keys = {
    {
      '<leader>pkx',
      function()
        require('changesets').create()
      end,
      mode = 'n',
      desc = 'Create a changeset',
    },
    {
      '<leader>pka',
      function()
        require('changesets').add_package()
      end,
      mode = 'n',
      desc = 'Add a package to changeset',
      ft = 'markdown',
    },
  },
}
