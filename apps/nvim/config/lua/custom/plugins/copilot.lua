return {

  {
    dependencies = {
      'copilotlsp-nvim/copilot-lsp',
      init = function()
        vim.g.copilot_nes_debounce = 500
      end,
    },
    disabled = function()
      return vim.g.disable_copilot
    end,

    'zbirenbaum/copilot.lua',
    -- branch = 'create-pull-request/update-copilot-lsp',
    cmd = 'Copilot',
    event = 'InsertEnter',
    lazy = true,
    build = ':Copilot auth',
    ---@type CopilotConfig
    opts = {
      -- copilot_node_command = vim.fn.expand('$HOME') .. '/.local/share/fnm/node-versions/v24.5.0/installation/bin/node', -- Node.js version must be > 22
      -- copilot_node_command = '/home/francis/node-caged-extract/node-caged-node',
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = '<M-l>',
          accept_word = '<M-w>',
          accept_line = '<M-o>',
          next = '<M-]>',
          prev = '<M-[>',
          dismiss = '<M-BS>',
        },
      },
      nes = {
        enabled = false,
        keymap = {
          accept_and_goto = '<leader>cn',
          accept = '<M-a>',
          dismiss = '<Esc>',
        },
      },
      panel = {
        enabled = false,
        keymap = {
          open = '<M-/>',
        },
      },
      filetypes = {
        markdown = true,
        help = true,
        lua = true,
      },
    },
    config = function(_, opts)
      if vim.g.disable_copilot then
        return
      end
      require('copilot').setup(opts)
    end,
  },
}
