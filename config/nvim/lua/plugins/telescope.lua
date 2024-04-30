--- @see https://github.com/nvim-telescope/telescope.nvim/issues/2014
-- Modifies telescope pickers with path after file like vscode
local function filename_first_path_display(_, path)
  local plenary_path = require("plenary.path")
  local tail = vim.fs.basename(path)
  local parent = vim.fs.dirname(path)
  if parent == "." then
    return tail
  end
  local relative_parent = plenary_path.new(parent):make_relative()
  return string.format("%s\t\t%s", tail, relative_parent)
end

--- Highlight the path part of the file as comment
vim.api.nvim_create_autocmd("FileType", {
  pattern = "TelescopeResults",
  callback = function(ctx)
    vim.api.nvim_buf_call(ctx.buf, function()
      vim.fn.matchadd("TelescopeParent", "\t\t.*$")
      vim.api.nvim_set_hl(0, "TelescopeParent", { link = "Comment" })
    end)
  end,
})

local function open_with_diff_view(bufnr)
  require("telescope.actions").close(bufnr)
  local value = require("telescope.actions.state").get_selected_entry(bufnr).value
  vim.cmd("DiffviewOpen " .. value .. "~1.." .. value)
end

local function paste_from_register(reg)
  reg = reg or '"'
  local ctrl_r_key = vim.api.nvim_replace_termcodes("<C-R>", true, false, true)
  local quote_key = vim.api.nvim_replace_termcodes(reg, true, false, true)

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
      { "<leader>fh", "<cmd>Telescope git_signs<cr>", desc = "Git hunks" },
      { "<leader>fr", "<cmd>Telescope registers<cr>", desc = "Registers" },
      { "<leader>fj", "<cmd>Telescope jumplist<cr>", desc = "Jumplist" },
      { "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Current Buffer Fuzzy" },
      { "<leader><BS>", "<cmd>Telescope resume<cr>", desc = "Resume previous search" },
      { "<leader>fu", "<cmd>Telescope undo<cr>", desc = "Undo history" },
      { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Git commits" },
      { "<leader>gbc", "<cmd>Telescope git_bcommits<cr>", desc = "Git branch commits" },
      {
        "<leader>?",
        function()
          require("telescope.builtin").live_grep({
            cwd = false,
            glob_pattern = vim.g.grep_glob_pattern or "!{*.spec.*,*.test.*,pnpm-lock.yaml}",
          })
        end,
        desc = "Grep (root dir)",
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
          require("telescope.builtin").find_files({ hidden = true })
        end,
        desc = "Find files",
      },
      {
        "<leader>po",
        function()
          require("telescope.builtin").find_files({
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
          local select_menu = require("lib.select-menu")
          local menu = select_menu.create_select_menu("Project links", pl.get_links())
          menu()
        end,
        desc = "Project links",
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
    },
    opts = {
      defaults = {
        hidden = false,
        path_display = filename_first_path_display,
        sorting_strategy = "ascending",
        layout_config = {
          horizontal = { prompt_position = "top", preview_width = 0.55 },
          vertical = { mirror = false },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
        mappings = {
          i = {
            ["<esc>"] = "close",
            ["<c-h>"] = "which_key",
            ["<a-p>"] = paste_from_register,
            ["<a-d>"] = open_with_diff_view,
          },
        },
      },
      pickers = {
        lsp_references = { path_display = { "tail" } },
        find_files = {
          cwd = false,
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
