local function open_with_diff_view(prompt_bufnr)
  require("telescope.actions").close(prompt_bufnr)
  local value = require("telescope.actions.state").get_selected_entry(prompt_bufnr).value
  vim.cmd("DiffviewOpen " .. value .. "~1.." .. value)
end

local delta_git_commits = function(opts)
  local previewers = require("telescope.previewers")
  local builtin = require("telescope.builtin")
  local delta = previewers.new_termopen_previewer({
    get_command = function(entry)
      return {
        "git",
        "-c",
        "core.pager=delta",
        "-c",
        "delta.side-by-side=false",
        "diff",
        "--color-words",
        entry.value .. "^!",
      }
    end,
  })
  opts = opts or {}
  opts.previewer = {
    delta,
    previewers.git_commit_message.new(opts),
    previewers.git_commit_diff_as_was.new(opts),
  }
  builtin.git_commits(opts)
end

local delta_git_bcommits = function(opts)
  local previewers = require("telescope.previewers")
  local builtin = require("telescope.builtin")
  local delta_bcommits = previewers.new_termopen_previewer({
    get_command = function(entry)
      return {
        "git",
        "-c",
        "core.pager=delta",
        "-c",
        "delta.side-by-side=false",
        "diff",
        "--color-words",
        entry.value .. "^!",
        "--",
        entry.current_file,
      }
    end,
  })
  opts = opts or {}
  opts.previewer = {
    delta_bcommits,
    previewers.git_commit_message.new(opts),
    previewers.git_commit_diff_as_was.new(opts),
  }
  builtin.git_bcommits(opts)
end

local function paste_from_register()
  local ctrl_r_key = vim.api.nvim_replace_termcodes("<C-R>", true, false, true)
  local quote_key = vim.api.nvim_replace_termcodes('"', true, false, true)

  vim.api.nvim_feedkeys(ctrl_r_key .. quote_key, "n", true)
end

return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
        "nvim-lua/plenary.nvim",
        "debugloop/telescope-undo.nvim",
        "molecule-man/telescope-menufacture",
        "radyz/telescope-gitsigns",
      },
    },
    branch = "master",
    keys = {
      -- add a keymap to browse plugin files
      -- stylua: ignore
      { '<leader>fh', "<cmd>Telescope git_signs<cr>", desc = "Git hunks" },
      { "<leader>fr", "<cmd>Telescope registers<cr>", desc = "Registers" },
      { "<leader>fj", "<cmd>Telescope jumplist<cr>", desc = "Jumplist" },
      { "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Current Buffer Fuzzy" },
      {
        "<leader>?",
        function()
          require("telescope").extensions.menufacture.live_grep({
            cwd = false,
            glob_pattern = "!{*.spec.*,*.test.*,*.md,pnpm-lock.yaml}",
          })
        end,
        -- function()
        --   require("telescope").extensions.menufacture.live_grep({
        --     cwd = false,
        --     glob_pattern = "!{*.spec.*,*.test.*,*.md,pnpm-lock.yaml}",
        --   })()
        --   -- require("lazyvim.util").telescope(
        --   --   "live_grep",
        --   --   { cwd = false, glob_pattern = "!{*.spec.*,*.test.*,*.md,pnpm-lock.yaml}" }
        --   -- )()
        -- end,
        desc = "Grep (root dir)",
      },
      {
        "<leader>fp",
        function()
          require("telescope.builtin").find_files({
            cwd = require("lazy.core.config").options.root,
            prompt_title = "Plugin files",
          })
        end,
        desc = "Find Plugin File",
      },
      {
        "<leader>f*",
        function()
          require("telescope").extensions.menufacture.grep_string()
        end,
        desc = "Find word under cursor",
      },
      {
        "<leader><localleader>",
        function()
          require("telescope.builtin").resume()
        end,
        desc = "Resume previous search",
      },
      {
        "<leader>fa",
        function()
          require("telescope").extensions.menufacture.find_files({
            hidden = true,
            no_ignore = true,
            prompt_title = "All files",
          })
        end,
        desc = "Find All Files",
      },
      {
        "<leader><space>",
        function()
          require("telescope.builtin").oldfiles({ cwd = vim.loop.cwd() })
        end,
        desc = "Last files",
      },
      {
        "<C-p>",
        function()
          require("telescope").extensions.menufacture.find_files({ cwd = false })
        end,
        desc = "Find files",
      },
      {
        "<leader>fl",
        function()
          require("telescope.builtin").find_files({
            hidden = true,
            find_command = { "find-overlays" },
            prompt_title = "Project overlays",
          })
        end,
        desc = "Find project overlays",
      },
      {
        "<leader>fu",
        "<cmd>Telescope undo<cr>",
        desc = "Undo history",
      },
      {
        "<leader>gc",
        delta_git_commits,
        desc = "Git commits",
      },
      {
        "<leader>gbc",
        delta_git_bcommits,
        desc = "Git branch commits",
      },
    },
    -- change some options

    opts = {
      defaults = {
        -- fzy_native = {
        --   override_generic_sorter = false,
        --   override_file_sorter = true,
        -- },

        hidden = false,
        path_display = { "smart" },
        sorting_strategy = "ascending",
        layout_config = {
          horizontal = { prompt_position = "top", preview_width = 0.55 },
          vertical = { mirror = false },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
        file_ignore_patterns = {
          ".git/",
          ".cache",
          "build/",
          "dist/",
          "fonts/",
          "icons/",
          "%.png",
          "%.jpg",
          "%.gif",
          "%.exe",
          "%.svg",
          "%.ico",
          "%.o",
          "%.a",
          "%.out",
          "%.class",
          "%.pdf",
          "%.mkv",
          "%.mp4",
          "%.zip",
          "package-lock.json",
          "yarn.lock",
          "pnpm-lock.yml",
          "pnpm-lock.yaml",
          "node_modules/.*",
          ".chageset/.*",
          "docs/.*",
          "dotbot/.*",
          "dotbot*",
        },
        mappings = {
          i = {
            ["<a-p>"] = paste_from_register,
            ["<a-d>"] = open_with_diff_view,
            ["<c-p>"] = function()
              local Util = require("lazyvim.util")
              Util.telescope("find_files", { hidden = true })()
            end,
            ["<a-a>"] = function()
              local Util = require("lazyvim.util")
              Util.telescope("find_files", { hidden = true, no_ignore = true, prompt_title = "All files" })()
            end,
            ["<a-l>"] = function()
              local Util = require("lazyvim.util")
              Util.telescope("oldfiles", { only_cwd = true })()
            end,
            ["<a-o>"] = function()
              require("telescope.builtin").find_files({
                hidden = true,
                find_command = { "find-overlays" },
                prompt_title = "Project overlays",
              })
            end,
            ["<c-h>"] = "which_key",
            ["<esc>"] = "close",
          },
        },
      },
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
        undo = {
          -- use_delta = true,
          -- -- use_custom_command = { "bash", "-c", "echo '$DIFF' | delta" },
          -- side_by_side = true,
          -- -- layout_strategy = "vertical",
          -- layout_config = {
          --   preview_height = 0.8,
          -- },
          mappings = {
            i = {
              ["<M-a>"] = function(prompt_bufnr)
                return require("telescope-undo.actions").yank_additions(prompt_bufnr)
              end,
              ["<M-d>"] = function(prompt_bufnr)
                return require("telescope-undo.actions").yank_deletions(prompt_bufnr)
              end,
              ["<M-r>"] = function(prompt_bufnr)
                return require("telescope-undo.actions").restore(prompt_bufnr)
              end,
            },
          },
        },
        menufacture = {
          mappings = {
            main_menu = { [{ "i", "n" }] = "<localleader><localleader>" },
          },
        },
      },
    },
    config = function(_, opts)
      require("telescope").load_extension("fzf")
      require("telescope").setup(opts)
      require("telescope").load_extension("undo")
      require("telescope").load_extension("menufacture")
      require("telescope").load_extension("git_signs")
    end,
  },
}
