return {
  enable = false,
  'carlos-algms/agentic.nvim',

  event = 'VeryLazy',

  opts = {
    provider = 'opencode-acp', -- default provider
  },

  -- these are just suggested keymaps; customize as desired
  keys = {
    {
      '<C-\\>',
      function()
        require('agentic').toggle()
      end,
      mode = { 'n', 'v', 'i' },
      desc = 'Toggle Agentic Chat',
    },
    {
      "<C-'>",
      function()
        require('agentic').add_selection_or_file_to_context()
      end,
      mode = { 'n', 'v' },
      desc = 'Add file or selection to Agentic to Context',
    },
    {
      '<C-,>',
      function()
        require('agentic').new_session()
      end,
      mode = { 'n', 'v', 'i' },
      desc = 'New Agentic Session',
    },
  },
}
