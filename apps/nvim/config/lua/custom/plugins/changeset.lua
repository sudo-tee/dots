return {
  'sudo-tee/changesets.nvim',
  -- dir = '/home/francis/Projects/_nvim/changesets.nvim/',
  dependencies = { 'neovim/nvim-lspconfig', 'nvim-telescope/telescope.nvim' },
  ---@module 'changesets'
  ---@type changesets.Opts
  opts = {
    get_default_text = function()
      local link = require('custom.lib.jira').format_ticket_as_markdown_link()
      return link or ''
    end,
  },
  keys = {
    {
      '<leader>cxx',
      function()
        require('changesets').create()
      end,
      mode = 'n',
      desc = 'Create a changeset',
    },
    {
      '<leader>cxa',
      function()
        require('changesets').add_package()
      end,
      mode = 'n',
      desc = 'Add a package to the changeset in the current buffer',
    },
  },
}
