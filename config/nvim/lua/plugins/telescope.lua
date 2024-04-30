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
          require("lib.pretty-pickers").live_grep({
            cwd = false,
            glob_pattern = "!{*.spec.*,*.test.*,*.md,pnpm-lock.yaml}",
          })
        end,
        desc = "Grep (root dir)",
      },
      {
        "<leader>ss",
        function()
          require("lib.pretty-pickers").lsp_document_symbols()
        end,
        desc = "Document symbols",
      },
      {
        "<leader>sS",
        function()
          require("lib.pretty-pickers").lsp_dynamic_workspace_symbols()
        end,
        desc = "Workspace symbols",
      },
      {
        "<leader>fp",
        function()
          require("lib.pretty-pickers").find_files({
            cwd = require("lazy.core.config").options.root,
            prompt_title = "Plugin files",
          })
        end,
        desc = "Find Plugin File",
      },
      {
        "<leader>f*",
        function()
          require("lib.pretty-pickers").grep_string()
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
          require("lib.pretty-pickers").find_files({
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
          require("lib.pretty-pickers").oldfiles({ cwd = vim.loop.cwd() })
        end,
        desc = "Last files",
      },
      {
        "<C-p>",
        function()
          require("lib.pretty-pickers").find_files({ hidden = true })
        end,
        desc = "Find files",
      },
      {
        "<leader>po",
        function()
          require("lib.pretty-pickers").find_files({
            hidden = true,
            find_command = { "find-overlays" },
            prompt_title = "Project overlays",
          })
        end,
        desc = "Project overlays",
      },
      {
        "<leader>pl",
        function()
          local pl = require("lib.project-links")

          local menu = require("lib.select-menu").create_select_menu("Project links", pl.get_links())
          menu()
        end,
        desc = "Project links",
      },
      {
        "<leader>fb",
        function()
          require("lib.pretty-pickers").buffers()
        end,
        desc = "Open buffers",
      },
      {
        "<leader>sw",
        function()
          require("lib.pretty-pickers").grep_string({ cwd = false, word_match = "-w" })
        end,
        desc = "Word (cwd)",
      },
      {
        "<leader>sW",
        function()
          require("lib.pretty-pickers").grep_string({ word_match = "-w" })
        end,
        desc = "Word (root dir)",
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
        hidden = false,
        path_display = { "truncate" },
        sorting_strategy = "ascending",
        layout_config = {
          horizontal = { prompt_position = "top", preview_width = 0.55 },
          vertical = { mirror = false },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
        -- file_ignore_patterns = {
        --   "%.png",
        --   "%.jpg",
        --   "%.gif",
        --   "%.exe",
        --   "%.svg",
        --   "%.ico",
        --   "%.o",
        --   "%.a",
        --   "%.out",
        --   "%.class",
        --   "%.pdf",
        --   "%.mkv",
        --   "%.mp4",
        --   "%.zip",
        --   "package-lock.json",
        --   "yarn.lock",
        --   "pnpm-lock.yml",
        --   "pnpm-lock.yaml",
        -- },
        mappings = {
          i = {
            ["<a-p>"] = paste_from_register,
            ["<a-d>"] = open_with_diff_view,
            ["<c-p>"] = function()
              require("lib.pretty-pickers").find_files({ hidden = true })
            end,
            ["<a-a>"] = function()
              require("lib.pretty-pickers").find_files({ hidden = true, no_ignore = true, prompt_title = "All files" })
            end,
            ["<a-l>"] = function()
              require("lib.pretty-pickers").oldfiles({ only_cwd = true })
            end,
            ["<a-o>"] = function()
              require("lib.pretty-pickers").find_files({
                hidden = true,
                find_command = { "find-overlays" },
                prompt_title = "Project overlays",
              })
            end,
            ["<c-h>"] = "which_key",
            ["<esc>"] = "close",
            ["<a-Down>"] = function(buff)
              require("telescope.actions").cycle_history_next(buff)
            end,
            ["<a-Up>"] = function(buff)
              require("telescope.actions").cycle_history_prev(buff)
            end,
          },
        },
      },
      pickers = {
        lsp_references = { path_display = { "tail" } },
        find_files = {
          cwd = false,
          -- find_command = {
          --   "rg",
          --   "--files",
          --   "--no-ignore-vcs",
          --   "--hidden",
          --   "--follow",
          --   "--glob",
          --   "!**/{.git,.bzr,.svn,.hg,CVS,node_modules,dist,deps,build,.cache,.next,out,e2e,icons,fonts,.gitlab,dotbot}/*",
          -- },
          find_command = {
            "fd",
            "-cnever",
            "-tf",
            "-i",
            "--hidden",
            "--follow",
            "--strip-cwd-prefix",
            "--exclude",
            ".git",
            "--exclude",
            "node_modules",
            "--exclude",
            "dist",
            "--exclude",
            "build",
            "--exclude",
            "icons",
            "--exclude",
            "e2e",
            "--exclude",
            "dotbot",
            "--exclude",
            ".gitlab",
            "--exclude",
            ".turbo",
            "--exclude",
            ".cache",
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
      },
    },
    config = function(_, opts)
      require("telescope").load_extension("fzf")
      require("telescope").setup(opts)
      require("telescope").load_extension("undo")
      require("telescope").load_extension("git_signs")
    end,
  },
}
