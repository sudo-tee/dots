local command = vim.api.nvim_create_user_command

return {
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    lazy = true,
    build = ':Copilot auth',
    opts = {
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
    enabled = false,
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
    event = 'VeryLazy',
    cmd = {
      'CopilotChatTests',
      'CopilotChat',
      'CopilotChatActions',
      'CopilotChatHelpActions',
      'CopilotChatOptimize',
      'CopilotChatPrompt',
      'CopilotChatCommitStaged',
      'CopilotChatCommitMessageFloat',
      'CopilotChatModels',
      'CopilotChatModel',
    },
    branch = 'canary',
    dependencies = {
      { 'zbirenbaum/copilot.lua' }, -- or github/copilot.vim
      { 'nvim-lua/plenary.nvim' }, -- for curl, log wrapper
    },
    opts = {
      model = 'gpt-4o-2024-08-06',
      temperature = 0.2,
      context = 'buffers',
      debug = false,
      question_header = '  User ',
      answer_header = '  Copilot ',
      error_header = '## Error ',
      prompts = {
        Tests = {
          prompt = '/COPILOT_GENERATE Please generate tests for my code using vitest. The test should be wrapped in a `describe` block. Each test case should be in an `it` block. Generate all the test cases',
        },
      },
    },
    -- stylua: ignore
    keys = {
      { mode = {'n'},        '<leader>cch', '<cmd>CopilotChatHelpActions<cr>',        desc = '[H]elp actions', },
      { mode = { 'n', 'v' }, '<leader>cca', '<cmd>CopilotChatActions<cr>',            desc = '[A]ctions' },
      {                      '<leader>ccc', '<cmd>CopilotChatCommitMessageFloat<cr>', desc = '[C]ommit message', },
      { mode = { 'n', 'v' }, '<leader>ccp', '<cmd>CopilotChat<cr>',                   desc = '[P]rompt' },
      { mode = { 'n', 'v' }, '<leader>cco', '<cmd>CopilotChatOptimize<cr>',           desc = '[O]ptimize' },
      { mode = { 'n', 'v' }, '<leader>cct', '<cmd>CopilotChatTests<cr>',              desc = '[T]ests' },
      { mode = { 'n' },      '<leader>ccq', '<cmd>CopilotChatQuick<cr>',             desc = '[]ests' },
    },
    -- See Commands section for default commands if you want to lazy load on them
    config = function(_, opts)
      if vim.g.disable_copilot then
        return
      end

      require('CopilotChat').setup(opts)

      local telescope = require('CopilotChat.integrations.telescope')
      local actions = require('CopilotChat.actions')
      local select = require('CopilotChat.select')

      command('CopilotChatActions', function()
        local selection = function(source)
          return select.visual(source) or select.buffer(source)
        end
        telescope.pick(actions.prompt_actions({ selection = selection }))
      end, { range = true })

      command('CopilotChatQuick', function()
        local input = vim.fn.input('Quick Chat: ')
        if input == '' then
          return
        end

        local selection = function(source)
          return select.visual(source) or select.buffer(source)
        end

        require('CopilotChat').ask(input, { selection = selection })
      end, { range = true })

      command('CopilotChatHelpActions', function()
        telescope.pick(actions.help_actions())
      end, { range = true })

      command('CopilotChatCommitMessageFloat', function()
        local chat = require('CopilotChat')
        chat.ask(chat.config.prompts.CommitStaged.prompt, {
          clear_chat_on_new_prompt = true,
          window = {
            layout = 'float',
            title = 'Generate commit message',
            zindex = 50,
            width = 0.6,
            border = 'rounded',
          },
          selection = chat.config.prompts.CommitStaged.selection,
        })
      end, {})
    end,
  },
}
