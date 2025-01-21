---@module 'snacks'

local function notes()
  local notes_path = os.getenv('HOME') .. '/Projects/notes'
  Snacks.picker.files({ cwd = notes_path })
end

local function grep_notes()
  local notes_path = os.getenv('HOME') .. '/Projects/notes'
  Snacks.picker.grep({ cwd = notes_path })
end

local function project_links()
  local pl = require('custom.lib.project-links')
  local links = pl.get_links()

  vim.ui.select(links, {
    prompt = ' Project links ',
    format_item = function(item)
      return item.text
    end,
  }, function(item)
    item.action()
  end)
end

local function marks(opts)
  return function()
    ---@type snacks.picker.Config
    opts = vim.tbl_deep_extend('force', {
      actions = {
        delmark = {
          ---@param picker snacks.Picker
          ---@param item snacks.picker.Item
          function(picker, item)
            picker:close()
            require('custom.lib.marks').delete_mark(item.buf, item.label)
            Snacks.picker.marks(picker.opts)
          end,
        },
      },
      win = {
        input = {
          keys = {
            ['<c-x>'] = { 'delmark', mode = { 'n', 'i' } },
          },
        },
      },
    }, opts or {})

    Snacks.picker.marks(opts)
  end
end

local function merge_requests()
  local glab = require('custom.lib.gitlab')
  local mr_list = glab.get_mr_links()

  if not mr_list then
    vim.notify('No merge requests found', vim.log.levels.INFO, { title = 'Merge requests' })
    return
  end

  vim.ui.select(mr_list, {
    prompt = ' Merge requests ',
    format_item = function(item)
      return item.text
    end,
  }, function(item)
    item.action()
  end)
end

local function plugin_files()
  local lazypath = vim.fn.stdpath('data') .. '/lazy/'
  Snacks.picker.files({ cwd = lazypath })
end

---@param method string picker name
---@param opts? snacks.picker.Config
local function pick(method, opts)
  return function()
    Snacks.picker[method](opts)
  end
end

return {
  {
    'folke/snacks.nvim',
    lazy = false,

  -- stylua: ignore
  keys = {
    -- Files and search
    { "<C-p>",      pick("smart"),                                    desc = "Find Files" },
    { "<leader>sf", pick("smart"),                                    desc = "Find Files" },
    { "<leader>sn", pick("files", { cwd = vim.fn.stdpath("config") }),desc = "Find Neovim Config Files" },
    { '<leader>sb', pick("buffers"),                                  desc = 'Buffers' },
    { '<leader>sB', pick("grep_buffers"),                             desc = 'Grep Buffers' },
    { '<leader>so', pick("recent"),                                   desc = 'Recent' },
    { '<leader>sg', pick("grep"),                                     desc = 'Grep' },
    { '<leader>sw', pick("grep_word"),                                desc = 'Current [W]ord' },
    { '<leader>/',  pick("lines"),                                    desc = 'Buffers Lines' },
    { '<leader>po', pick("files", {cmd = 'find-overlays'}),           desc = 'Project Overlay' },
    { '<leader>sk', pick("keymaps"),                                  desc = 'Keymaps' },
    { '<leader>sh', pick("help"),                                     desc = 'Help' },
    { '<leader>sd', pick("diagnostics"),                              desc = 'Diagnostics' },
    { '<leader>sp', plugin_files,                                     desc = 'Plugin Files' },
    { '<leader>su', pick("undo"),                                     desc = 'Undo tree' },
    { '<leader>sH', pick("highlights"),                               desc = 'Highlights' },
    { '<leader>ss', pick("pickers"),                                  desc = 'Pickers' },
    { '<leader>sr', pick("registers"),                                desc = 'Registers' },

    -- Git
    { "<leader>gcl", pick("git_log"),                                 desc = "Git Log" },
    { "<leader>gcf", pick("git_log_file"),                            desc = "Git Log File" },
    { "<leader>gcL", pick("git_log_line"),                            desc = "Git Log Line" },
    { "<leader>gss", pick("git_status"),                              desc = "Git Status" },
    { "<leader>gco", pick("git_branches"),                            desc = "Git Branches" },

    -- Marks
    { "<leader>sm",  marks(),                                         desc = "Marks" },
    { "<leader>sM",  marks({["local"] = false}),                      desc = "Global Marks" },

    -- LSP
    { "gd",         pick("lsp_definitions"),                          desc = "Goto Definition" },
    { "gR",         pick("lsp_references"),                           desc = "References", nowait = true },
    { "gI",         pick("lsp_implementations"),                      desc = "Goto Implementation" },
    { "gy",         pick("lsp_type_definitions"),                     desc = "Goto T[y]pe Definition" },
    { "<leader>sy", pick("lsp_symbols"),                              desc = "LSP Symbols" },
    { "<leader>sY", pick("lsp_workspace_symbols"),                    desc = "LSP Workspace Symbols" },

    -- Notes
    { '<leader>nn', notes,                                            desc = 'Notes' },
    { '<leader>ng', grep_notes,                                       desc = 'Grep Notes' },

    -- Project
    { '<leader>pl', project_links,                                    desc = 'Project links'},
    { '<leader>pm', merge_requests,                                   desc = 'Project merge requests'},


  },
    ---@type snacks.Config
    opts = {
      picker = {
        enabled = true,
        layout = 'telescope',
        ui_select = true,
        formatters = {
          file = { filename_first = true },
        },
        sources = {
          smart = { filter = { cwd = true } },
        },
      },
    },
  },
}
