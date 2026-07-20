local command = vim.api.nvim_create_user_command
return {

  {
    dependencies = {
      'copilotlsp-nvim/copilot-lsp',
      init = function()
        vim.g.copilot_nes_debounce = 500
      end,
    },
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
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    enable = false,
    lazy = true,
    event = 'VeryLazy',
    build = 'make tiktoken', -- Only on MacOS or Linux
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
      'CopilotChatFixDiag',
    },
    dependencies = {
      { 'zbirenbaum/copilot.lua' }, -- or github/copilot.vim
      { 'nvim-lua/plenary.nvim' }, -- for curl, log wrapper
      { 'nvim-treesitter/nvim-treesitter' },
      { 'folke/snacks.nvim' },
    },
    ---@type CopilotChat.config
    opts = {
      -- model = 'claude-3.5-sonnet', -- :( not enable by company
      model = 'gpt-4.1',
      -- model = 'o3-mini',
      -- temperature = 0.2,
      sticky = {
        '#files',
        '#buffers',
      },
      context = { 'buffer', 'file' },
      providers = {
        github_models = {
          disabled = true,
        },
      },
      debug = false,
      insert_at_end = true,
      highlight_headers = false,
      question_header = '#   User ',
      answer_header = '#   Copilot ',
      error_header = '# > [!ERROR] Error ',
      prompts = {
        Tests = {
          prompt = '/COPILOT_GENERATE Please generate tests for my code using vitest. The test should be wrapped in a `describe` block. Each test case should be in an `it` block. Generate all the test cases',
        },
      },
    },
    -- stylua: ignore
    keys = {
      {                      '<leader>ccc', '<cmd>CopilotChatCommitMessageFloat<cr>', desc = 'Commit message', },
      { mode = { 'n', 'v' }, '<leader>ccp', '<cmd>CopilotChat<cr>',                   desc = 'Prompt' },
      { mode = { 'n', 'v' }, '<leader>cco', '<cmd>CopilotChatOptimize<cr>',           desc = 'Optimize' },
      { mode = { 'n', 'v' }, '<leader>cct', '<cmd>CopilotChatTests<cr>',              desc = 'Tests' },
      { mode = { 'n' },      '<leader>ccq', '<cmd>CopilotChatQuick<cr>',              desc = 'Quick chat' },
      { mode = { 'n', 'v' }, '<leader>ccd', '<cmd>CopilotChatFixDiag<cr>',            desc = 'Fix diagnostic' },
      { mode = { 'n', 'v' }, "<leader>ccx", '<cmd>CopilotChatActions<cr>',            desc = "CopilotChat - Prompt actions", },

    },
    -- See Commands section for default commands if you want to lazy load on them
    config = function(_, opts)
      if vim.g.disable_copilot then
        return
      end

      require('CopilotChat').setup(opts)

      local select = require('CopilotChat.select')

      command('CopilotChatFixDiag', function()
        local selection = function(source)
          return select.visual(source) or select.line(source)
        end

        require('CopilotChat').ask('/Fix diagnostics', { selection = selection })
      end, { range = true })

      command('CopilotChatActions', function()
        local actions = require('CopilotChat.actions')
        require('CopilotChat.integrations.snacks').pick(actions.prompt_actions())
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
    end,
  },
}
