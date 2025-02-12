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

local function project_overlays()
  local project_name = vim.fn.getcwd():match('[^/\\]+$')
  local folder = os.getenv('HOME') .. '/dots/work/projects/' .. project_name .. '/overlays'
  Snacks.picker.files({ cwd = folder, hidden = true, ignored = true })
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
  local mr = require('custom.lib.gitlab')
  select_items(' Merge requests ', mr.get_mr_links())
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

local keys = function(keymaps)
  return {
    win = { input = { keys = keymaps }, list = { keys = keymaps } },
  }
end

---@param opts? snacks.picker.Config
---@param only_user_marks? boolean Only display marks placed by the user
local function marks(opts, only_user_marks)
  return function()
    ---@type snacks.picker.marks.Config
    local mark_opts = vim.tbl_deep_extend('force', {
      transform = function(item)
        return not only_user_marks or item.label:match('^[%a]') == item.label
      end,
      actions = { delmark = cmd_action('delmark', 'label', Snacks.picker.pick) },
      win = keys({ ['<c-x>'] = { 'delmark', mode = { 'n', 'i' } } }).win,
    }, opts or {})

    Snacks.picker.marks(mark_opts)
  end
end

---@param source string picker name
---@param opts? snacks.picker.Config
local function pick(source, opts)
  return function()
    Snacks.picker(source, opts)
  end
end

---@param type "commit"|"stash"|"branch"
---@return table
local function git_opts(type)
  return keys({
    ['<M-D>'] = { 'diff_view_' .. type, mode = { 'n', 'i' } },
  })
end

return {
  'folke/snacks.nvim',
  lazy = false,
  -- stylua: ignore
  keys = {
    -- Files and search
    { "<C-p>",      pick("smart"),                          desc = "Find Files" },
    { "<leader>sf", pick("smart"),                          desc = "Find Files" },
    { "<leader>sP", nvim_plugin_files,                      desc = "Find Neovim Plugin Files" },
    { '<leader>sb', pick("buffers"),                        desc = 'Buffers' },
    { '<Tab><Tab>', pick("buffers"),                        desc = 'Buffers' },
    { '<leader>sB', pick("grep_buffers"),                   desc = 'Grep Buffers' },
    { '<leader>so', pick("recent"),                         desc = 'Recent' },
    { '<leader>sg', pick("grep"),                           desc = 'Grep' },
    { '<leader>sw', pick("grep_word"),                      desc = 'Current Word / Selection' , mode={'n','v'} },
    { '<leader>/',  pick("lines"),                          desc = 'Buffers Lines' },
    { '<leader>po', project_overlays,                       desc = 'Project Overlay' },
    { '<leader>sk', pick("keymaps"),                        desc = 'Keymaps' },
    { '<leader>sh', pick("help"),                           desc = 'Help' },
    { '<leader>sd', pick("diagnostics"),                    desc = 'Diagnostics' },
    { '<leader>sp', plugin_files,                           desc = 'Plugin Files' },
    { '<leader>su', pick("undo"),                           desc = 'Undo tree' },
    { '<leader>sH', pick("highlights"),                     desc = 'Highlights' },
    { '<leader>ss', pick("pickers"),                        desc = 'Pickers' },
    { '<leader>sr', pick("registers"),                      desc = 'Registers' },
    { '<leader>sn', pick("notifications"),                  desc = 'Notifications' },
    { '<leader>e',  pick("explorer"),                       desc = 'Explorer' },

    -- Git
    { "<leader>gcl", pick("git_log",      git_opts("commit")),       desc = "Git Log" },
    { "<leader>gcf", pick("git_log_file", git_opts("commit")),       desc = "Git Log File" },
    { "<leader>gcL", pick("git_log_line", git_opts("commit")),       desc = "Git Log Line" },
    { "<leader>gss", pick("git_stash",    git_opts("stash")),        desc = "Git Stashes" },
    { "<leader>gcs", pick("git_status"),                             desc = "Git Status" },
    { "<leader>gco", pick("git_branches", git_opts("branch")),       desc = "Git Branches" },

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
    { "<leader>st", pick("treesitter"),                     desc = "Treesitter" },

    -- Notes
    { '<leader>ns', notes,                                  desc = 'Notes' },
    { '<leader>ng', grep_notes,                             desc = 'Grep Notes' },

    -- Project
    { '<leader>pl', project_links,                          desc = 'Project links'},
    { '<leader>pm', merge_requests,                         desc = 'Project merge requests'},
  },
  ---@type snacks.Config
  opts = {
    explorer = {
      replace_netrw = true,
    },
    picker = {
      win = {
        input = {
          keys = {
            ['<M-Up>'] = { 'cycle_win', mode = { 'n', 'i' } },
            ['<M-Down>'] = { 'cycle_win', mode = { 'n', 'i' } },
            ['<M-Left>'] = { 'cycle_win', mode = { 'n', 'i' } },
            ['<M-Right>'] = { 'cycle_win', mode = { 'n', 'i' } },
            ['<C-h>'] = { 'toggle_help_input', mode = { 'i' } },
            ['<M-q>'] = { 'close', mode = { 'n', 'i' } },
            ['<c-z><Left>'] = { 'layout_left', mode = { 'i', 'n' } },
            ['<c-z><Down>'] = { 'layout_bottom', mode = { 'i', 'n' } },
            ['<c-z><Up>'] = { 'layout_top', mode = { 'i', 'n' } },
            ['<c-z><Right>'] = { 'layout_right', mode = { 'i', 'n' } },
          },
        },
        list = {
          keys = {
            ['<M-Right>'] = { 'cycle_win' },
            ['<M-Left>'] = { 'cycle_win' },
            ['<M-Down>'] = { 'focus_input' },
            ['<M-Up>'] = { 'focus_input' },
            ['<M-q>'] = { 'close' },
            ['<c-z><Left>'] = { 'layout_left', mode = { 'i', 'n' } },
            ['<c-z><Down>'] = { 'layout_bottom', mode = { 'i', 'n' } },
            ['<c-z><Up>'] = { 'layout_top', mode = { 'i', 'n' } },
            ['<c-z><Right>'] = { 'layout_right', mode = { 'i', 'n' } },
          },
        },
        preview = {
          keys = {
            ['<M-Up>'] = { 'focus_input' },
            ['<M-Down>'] = { 'focus_input' },
            ['<M-Left>'] = { 'cycle_win' },
            ['<M-Right>'] = { 'cycle_win' },
            ['<M-q>'] = { 'close' },
          },
        },
      },
      layouts = {
        sidebar = { layout = { position = 'right' } },
        sidebar_right = {
          layout = {
            backdrop = false,
            width = 40,
            min_width = 40,
            height = 0,
            position = 'right',
            border = 'none',
            box = 'vertical',
            { win = 'list', border = 'none', fixbuf = true },
            {
              win = 'input',
              height = 1,
              border = 'single',
              title = '{title} {live} {flags}',
              title_pos = 'center',
            },
          },
        },
      },
      layout = { preset = 'telescope', cycle = true },
      ui_select = true,
      formatters = {
        file = { filename_first = true },
      },
      sources = {
        smart = { filter = { cwd = true } },
        explorer = {
          layout = 'sidebar_right',
        },
      },
      actions = {
        diff_view_commit = function(picker, item)
          picker:close()
          vim.cmd('DiffviewOpen ' .. item.commit .. '^!')
        end,
        diff_view_stash = function(picker, item)
          picker:close()
          return vim.cmd('DiffviewOpen ' .. item.stash .. '^!')
        end,
        diff_view_branch = function(picker, item)
          picker:close()
          vim.cmd('DiffviewOpen ' .. item.branch)
        end,
      },
    },
  },
}
