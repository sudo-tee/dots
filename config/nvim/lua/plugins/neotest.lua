return {
  -- { dir = "~/Projects/neotest-vitest" },
  {
    "nvim-neotest/neotest",
    -- version = "v3.3.0",
    dependencies = {
      {
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
      -- Can be a list of adapters like what neotest expects,
      -- or a table of adapter names, mapped to adapter configs.
      -- The adapter will then be automatically loaded with the config.
      adapters = {
        ["neotest-vitest"] = {
          env = { CI = true },
          -- vitestCommand = "pnpm test",
          vitestConfigFile = function(path)
            local util = require("neotest-vitest.util")
            local vitestConfigPattern = util.root_pattern("{vitest,vite}.config.{local.fb.ts,local.fb.ts,js,ts}")
            local rootPath = vitestConfigPattern(path)

            if not rootPath then
              return nil
            end

            local possible_files = {
              "vitest.config.local.fb.ts",
              -- "vitest.config.local.fb.js",
              -- "vite.config.local.fb.ts",
              -- "vite.config.local.fb.js",
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
          cwd = function(path)
            local file = vim.fn.expand("%:p")
            if string.find(file, "/packages/") then
              return string.match(file, "(.-/[^/]+/)src")
            end
            if string.find(file, "/apps/") then
              return string.match(file, "(.-/[^/]+/)src")
            end
            return vim.fn.getcwd()
          end,
        },
        -- ["neotest-vim-test"] = {},
        -- ["neotest-jest"] = {},
      },
    },
    -- config = function(_, opts)
    --   local neotest_ns = vim.api.nvim_create_namespace("neotest")
    --   vim.diagnostic.config({
    --     virtual_text = {
    --       format = function(diagnostic)
    --         -- Replace newline and tab characters with space for more compact diagnostics
    --         local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
    --         return message
    --       end,
    --     },
    --   }, neotest_ns)
    --
    --   if opts.adapters then
    --     local adapters = {}
    --     for name, config in pairs(opts.adapters or {}) do
    --       if type(name) == "number" then
    --         adapters[#adapters + 1] = config
    --       elseif config ~= false then
    --         local adapter = require(name)
    --         if type(config) == "table" and not vim.tbl_isempty(config) then
    --           adapter = adapter(config)
    --         end
    --         adapters[#adapters + 1] = adapter
    --       end
    --     end
    --     opts.adapters = adapters
    --   end
    --
    --   require("neotest").setup(opts)
    -- end,
  },
}
