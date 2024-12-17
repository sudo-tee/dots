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
      'CopilotChatFixDiagnostic',
    },
    branch = 'canary',
    dependencies = {
      { 'zbirenbaum/copilot.lua' }, -- or github/copilot.vim
      { 'nvim-lua/plenary.nvim' }, -- for curl, log wrapper
      { 'nvim-treesitter/nvim-treesitter' },
    },
    opts = {
      model = 'claude-3.5-sonnet',
      temperature = 0.2,
      context = 'buffers',
      debug = false,
      insert_at_end = true,
      highlight_headers = false,
      question_header = '  User ',
      answer_header = '  Copilot ',
      error_header = '> [!ERROR] Error',
      prompts = {
        Tests = {
          prompt = '/COPILOT_GENERATE Please generate tests for my code using vitest. The test should be wrapped in a `describe` block. Each test case should be in an `it` block. Generate all the test cases',
        },
      },
    },
    -- stylua: ignore
    keys = {
      { mode = {'n'},        '<leader>cch', '<cmd>CopilotChatHelpActions<cr>',        desc = 'Help actions', },
      { mode = { 'n', 'v' }, '<leader>cca', '<cmd>CopilotChatActions<cr>',            desc = 'Actions' },
      {                      '<leader>ccc', '<cmd>CopilotChatCommitMessageFloat<cr>', desc = 'Commit message', },
      { mode = { 'n', 'v' }, '<leader>ccp', '<cmd>CopilotChat<cr>',                   desc = 'Prompt' },
      { mode = { 'n', 'v' }, '<leader>cco', '<cmd>CopilotChatOptimize<cr>',           desc = 'Optimize' },
      { mode = { 'n', 'v' }, '<leader>cct', '<cmd>CopilotChatTests<cr>',              desc = 'Tests' },
      { mode = { 'n' },      '<leader>ccq', '<cmd>CopilotChatQuick<cr>',              desc = 'Quick chat' },
      { mode = { 'n', 'v' }, '<leader>ccd', '<cmd>CopilotChatFixDiagnostic<cr>',      desc = 'Fix diagnostic' },
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
