return {
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    lazy = true,
    build = ':Copilot auth',
    opts = {
      suggestion = { enabled = true, auto_trigger = true },
      panel = {
        enabled = true,
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
  {
    'zbirenbaum/copilot-cmp',
    lazy = true,
    event = 'VeryLazy',
    ebabled = false,
    dependencies = 'copilot.lua',
    opts = {},
    config = function(_, opts)
      if vim.g.disable_copilot then
        return
      end
      require('copilot_cmp').setup(opts)
    end,
  },
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    lazy = true,
    even = 'VeryLazy',
    cmd = { 'CopilotChat', 'CopilotChatActions', 'CopilotChatOptimize', 'CopilotChatPrompt', 'CopilotChatCommitStaged' },
    branch = 'canary',
    dependencies = {
      { 'zbirenbaum/copilot.lua' }, -- or github/copilot.vim
      { 'nvim-lua/plenary.nvim' }, -- for curl, log wrapper
    },
    opts = {
      debug = false, -- Enable debugging
    },
    keys = {
      {
        '<leader>cch',
        function()
          local actions = require('CopilotChat.actions')
          require('CopilotChat.integrations.telescope').pick(actions.help_actions())
        end,
        desc = '[C]opilot[C]hat - [H]elp actions',
      },
      {
        mode = { 'v', 'n' },
        '<leader>cca',
        '<cmd>CopilotChatActions<cr>',
        desc = '[C]opilot[C]hat - [P]rompt actions',
      },
      {
        '<leader>ccc',
        function()
          local chat = require('CopilotChat')
          chat.ask(chat.config.prompts.CommitStaged.prompt, {
            clear_chat_on_new_prompt = true,
            window = {
              layout = 'float',
              title = 'Generate commit message',
              zindex = 50,
              width = 0.6,
            },
            selection = chat.config.prompts.CommitStaged.selection,
          })
        end,
        desc = '[C]opilot[C]hat - [C]ommit message',
      },
      { mode = { 'n', 'v' }, '<leader>ccp', ':CopilotChat', desc = '[C]opilot[C]hat - [P]rompt' },
      { mode = { 'n', 'v' }, '<leader>cco', ':CopilotChatOptimize', desc = '[C]opilot[C]hat - [P]rompt' },
    },
    -- See Commands section for default commands if you want to lazy load on them
    config = function(_, opts)
      if vim.g.disable_copilot then
        return
      end

      vim.api.nvim_create_user_command('CopilotChatActions', function()
        local actions = require('CopilotChat.actions')
        local selection = function(source)
          return require('CopilotChat.select').visual(source) or require('CopilotChat.select').buffer(source)
        end
        require('CopilotChat.integrations.telescope').pick(actions.prompt_actions({ selection = selection }))
      end, { range = true })

      require('CopilotChat').setup(opts)
    end,
  },
}
