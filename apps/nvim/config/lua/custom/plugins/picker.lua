---@module 'snacks'

local function notes()
  Snacks.picker.files({ cwd = os.getenv('HOME') .. '/Projects/notes' })
end

local function grep_notes()
  Snacks.picker.grep({ cwd = os.getenv('HOME') .. '/Projects/notes' })
end

local function plugin_files()
  Snacks.picker.files({ cwd = vim.fn.stdpath('data') .. '/lazy/' })
end

local function nvim_plugin_files()
  Snacks.picker.files({ cwd = vim.fn.stdpath('config') .. '/' })
end

local function select_items(title, items)
  vim.ui.select(items, {
    prompt = title,
    format_item = function(item)
      return item.text
    end,
  }, function(item)
    item.action()
  end)
end

local function merge_requests()
  local mr = require('custom.lib.merge-requests')
  select_items(' Merge requests ', mr.get_merge_requests())
end

local function project_links()
  local pl = require('custom.lib.project-links')
  select_items(' Project links ', pl.get_links())
end

local function cmd_action(cmd, field, on_done)
  return function(picker, item)
    picker:close()
    vim.cmd(cmd .. ' ' .. item[field])
    return on_done and on_done(picker.opts)
  end
end

---@param opts? snacks.picker.Config
---@param only_user_marks? boolean Only display marks placed by the user
local function marks(opts, only_user_marks)
  return function()
    local marks_finder = function(_opts)
      local vim_marks = Snacks.picker.config.finder('vim_marks')(_opts, {})

      return only_user_marks
          and vim.tbl_filter(function(item)
            return item.label:match('^[%a]')
          end, vim_marks)
        or vim_marks
    end

    ---@type snacks.picker.marks.Config
    local mark_opts = vim.tbl_deep_extend('force', {
      finder = marks_finder,
      actions = { delmark = cmd_action('delmark', 'label', Snacks.picker.pick) },
      win = {
        input = {
          keys = {
            ['<c-x>'] = { 'delmark', mode = { 'n', 'i' } },
          },
        },
      },
    }, opts or {})

    Snacks.picker.marks(mark_opts)
  end
end

---@param method string picker name
---@param opts? snacks.picker.Config
local function pick(method, opts)
  return function()
    Snacks.picker[method](opts)
  end
end

return {
  'folke/snacks.nvim',
  lazy = false,
  -- stylua: ignore
  keys = {
    -- Files and search
    { "<C-p>",      pick("smart"),                          desc = "Find Files" },
    { "<leader>sf", pick("smart"),                          desc = "Find Files" },
    { "<leader>sn", nvim_plugin_files,                      desc = "Find Neovim Plugin Files" },
    { '<leader>sb', pick("buffers"),                        desc = 'Buffers' },
    { '<leader>sB', pick("grep_buffers"),                   desc = 'Grep Buffers' },
    { '<leader>so', pick("recent"),                         desc = 'Recent' },
    { '<leader>sg', pick("grep"),                           desc = 'Grep' },
    { '<leader>sw', pick("grep_word"),                      desc = 'Current [W]ord' },
    { '<leader>/',  pick("lines"),                          desc = 'Buffers Lines' },
    { '<leader>po', pick("files", {cmd = 'find-overlays'}), desc = 'Project Overlay' },
    { '<leader>sk', pick("keymaps"),                        desc = 'Keymaps' },
    { '<leader>sh', pick("help"),                           desc = 'Help' },
    { '<leader>sd', pick("diagnostics"),                    desc = 'Diagnostics' },
    { '<leader>sp', plugin_files,                           desc = 'Plugin Files' },
    { '<leader>su', pick("undo"),                           desc = 'Undo tree' },
    { '<leader>sH', pick("highlights"),                     desc = 'Highlights' },
    { '<leader>ss', pick("pickers"),                        desc = 'Pickers' },
    { '<leader>sr', pick("registers"),                      desc = 'Registers' },

    -- Git
    { "<leader>gcl", pick("git_log"),                       desc = "Git Log" },
    { "<leader>gcf", pick("git_log_file"),                  desc = "Git Log File" },
    { "<leader>gcL", pick("git_log_line"),                  desc = "Git Log Line" },
    { "<leader>gss", pick("git_status"),                    desc = "Git Status" },
    { "<leader>gco", pick("git_branches"),                  desc = "Git Branches" },

    -- Marks
    { "<leader>sm",  marks({}, true),                       desc = "User Marks" },
    { "<leader>sM",  marks(),                               desc = "All Marks" },

    -- LSP
    { "gd",         pick("lsp_definitions"),                desc = "Goto Definition" },
    { "gR",         pick("lsp_references"),                 desc = "References", nowait = true },
    { "gI",         pick("lsp_implementations"),            desc = "Goto Implementation" },
    { "gy",         pick("lsp_type_definitions"),           desc = "Goto T[y]pe Definition" },
    { "<leader>sy", pick("lsp_symbols"),                    desc = "LSP Symbols" },
    { "<leader>sY", pick("lsp_workspace_symbols"),          desc = "LSP Workspace Symbols" },

    -- Notes
    { '<leader>nn', notes,                                  desc = 'Notes' },
    { '<leader>ng', grep_notes,                             desc = 'Grep Notes' },

    -- Project
    { '<leader>pl', project_links,                          desc = 'Project links'},
    { '<leader>pm', merge_requests,                         desc = 'Project merge requests'},
  },
  ---@type snacks.Config
  opts = {
    picker = {
      layout = { preset = 'telescope', cycle = true },
      ui_select = true,
      formatters = {
        file = { filename_first = true },
      },
      sources = {
        smart = { filter = { cwd = true } },
      },
    },
  },
}
