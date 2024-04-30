local command = vim.api.nvim_create_user_command

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
    cmd = {
      'CopilotChatTests',
      'CopilotChat',
      'CopilotChatActions',
      'CopilotChatHelpActions',
      'CopilotChatOptimize',
      'CopilotChatPrompt',
      'CopilotChatCommitStaged',
      'CopilotChatCommitMessageFloat',
    },
    branch = 'canary',
    dependencies = {
      { 'zbirenbaum/copilot.lua' }, -- or github/copilot.vim
      { 'nvim-lua/plenary.nvim' }, -- for curl, log wrapper
    },
    opts = {
      debug = false,
      question_header = '## User ',
      answer_header = '## Copilot ',
      error_header = '## Error ',
    },
    -- stylua: ignore
    keys = {
      { mode = {'n'},        '<leader>cch', '<cmd>CopilotChatHelpActions<cr>',        desc = '[H]elp actions', },
      { mode = { 'n', 'v' }, '<leader>cca', '<cmd>CopilotChatActions<cr>',            desc = '[A]ctions' },
      {                      '<leader>ccc', '<cmd>CopilotChatCommitMessageFloat<cr>', desc = '[C]ommit message', },
      { mode = { 'n', 'v' }, '<leader>ccp', '<cmd>CopilotChat<cr>',                   desc = '[P]rompt' },
      { mode = { 'n', 'v' }, '<leader>cco', '<cmd>CopilotChatOptimize<cr>',           desc = '[O]ptimize' },
      { mode = { 'n', 'v' }, '<leader>cct', '<cmd>CopilotChatTests<cr>',              desc = '[T]ests' },
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
