return {
  {
    'nvim-neotest/neotest',
    lazy = true,
    dependencies = {
      {
        'nvim-neotest/nvim-nio',
        'nvim-treesitter/nvim-treesitter',
        'nvim-neotest/neotest-jest',
        'sudo-tee/neotest-vitest',
        'nvim-neotest/neotest-plenary',
      },
    },
     -- stylua: ignore
    keys = {
      { "<leader>tt", function()
        require("neotest").run.run(vim.fn.expand("%"))
        require("neotest").summary.open()
      end, desc = "[T]est [F]ile"
      },
      { "<leader>tT", function() require("neotest").run.run(vim.uv.cwd()) end, desc = "[T]est [A]ll Files" },
      { "<leader>tn", function() require("neotest").run.run() end, desc = "[T]est [N]earest" },
      { "<leader>tl", function() require("neotest").run.run_last() end, desc = "[T]est [L]ast" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "[T]oggle [S]ummary" },
      { "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end, desc = "Show [T]est [O]utput" },
      { "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "[T]oggle [O]utput Panel" },
      { "<leader>tS", function() require("neotest").run.stop() end, desc = "[T]est [S]top" },
    },
    config = function()
      local jest_config = {
        env = { CI = true },
        jestCommand = vim.g.jest_command or 'nr test',
      }

      local vitest_config = {
        env = { CI = true },
        vitestCommand = vim.g.vitest_command or 'nr test',
        vitestConfigFile = vim.g.vitest_config_file or nil,
        filter_dir = function(name, rel_path, root)
          return name ~= 'node_modules'
        end,
        cwd = function(file)
          local util = require('neotest-vitest.util')
          if string.find(file, '/packages/') then
            return string.match(file, '(.-/[^/]+/)src')
          end

          if string.find(file, '/plugins/') then
            return string.match(file, '(.-/[^/]+/)src')
          end

          if string.find(file, '/apps/') then
            return string.match(file, '(.-/[^/]+/)src')
          end

          local cwd = vim.fn.getcwd()
          if util.path.exists(cwd .. '/package.json') then
            return vim.fn.getcwd()
          end

          local current_path = vim.fs.dirname(file)
          return current_path
        end,
      }

      require('neotest').setup({
        adapters = {
          require('neotest-jest')(jest_config),
          require('neotest-vitest')(vitest_config),
        },
      })
    end,
  },
}
