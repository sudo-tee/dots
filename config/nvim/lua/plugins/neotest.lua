return {
  -- { dir = "~/Projects/_nvim/neotest-vitest" },
  {
    "nvim-neotest/neotest",
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter",
        "nvim-neotest/neotest-jest",
        "sudo-tee/neotest-vitest",
        "nvim-neotest/neotest-vim-test",
        "vim-test/vim-test",
        "nvim-neotest/neotest-plenary",
      },
    },
    keys = {
      {
        "<leader>tl",
        function()
          -- package.loaded["neotest"] = nil
          require("neotest").run.run_last()
        end,
        desc = "Run Last test",
      },
    },
    opts = {
      discovery = {
        -- enabled = false,
      },
      -- Can be a list of adapters like what neotest expects,
      -- or a table of adapter names, mapped to adapter configs.
      -- The adapter will then be automatically loaded with the config.
      adapters = {
        ["neotest-jest"] = {
          env = { CI = true },
          jestCommand = function()
            if vim.g.jest_command then
              return vim.g.jest_command
            end
            return "jest"
          end,
        },
        ["neotest-vitest"] = {
          env = { CI = true },
          vitestCommand = function()
            if vim.g.vitest_command then
              return vim.g.vitest_command
            end
            return "vitest"
          end,
          -- vitestCommand = "nr test",
          vitestConfigFile = function(path)
            local util = require("neotest-vitest.util")
            local vitestConfigPattern = util.root_pattern("{vitest,vite}.config.{fb.ts,fb.js,js,ts}")
            local rootPath = vitestConfigPattern(path)

            if not rootPath then
              return nil
            end

            local possible_files = {
              "vite.config.fb.ts",
              "vitest.config.fb.ts",
              "vitest.config.ts",
              "vitest.config.js",
              "vite.config.ts",
              "vite.config.js",
            }

            for _, filename in ipairs(possible_files) do
              local filepath = util.path.join(rootPath, filename)
              if util.path.exists(filepath) then
                return filepath
              end
            end
          end,
          cwd = function(file)
            local util = require("neotest-vitest.util")
            if string.find(file, "/packages/") then
              return string.match(file, "(.-/[^/]+/)src")
            end

            if string.find(file, "/apps/") then
              return string.match(file, "(.-/[^/]+/)src")
            end

            local cwd = vim.fn.getcwd()
            if util.path.exists(cwd .. "/package.json") then
              return vim.fn.getcwd()
            end

            local current_path = vim.fs.dirname(file)
            return current_path
          end,
        },
      },
    },
  },
}
