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

local function undo_tree()
  local tree = vim.fn.undotree()

  if not tree.entries or #tree.entries == 0 then
    vim.notify('No undo history', vim.log.levels.INFO)
    return
  end

  local current_bufnr = vim.api.nvim_get_current_buf()
  local current_seq = tree.seq_cur
  local saved_view = vim.fn.winsaveview()
  local cursor = vim.api.nvim_win_get_cursor(0)

  -- Get buffer content for a given sequence
  local function get_buffer_content(seq)
    seq = seq or ''
    vim.cmd('silent! undo ' .. seq)
    local lines = vim.api.nvim_buf_get_lines(current_bufnr, 0, -1, false)
    return table.concat(lines, '\n')
  end

  -- Get the diff between the current buffer and the state of a given sequence
  local function get_diff(entry)
    local buffer_after = get_buffer_content(entry.seq)
    local buffer_before = get_buffer_content()
    return vim.split(vim.diff(buffer_before, buffer_after, { ctxlen = vim.o.scrolloff }), '\n')
  end

  local items = {}

  local function format_relative_time(timestamp)
    local now = os.time()
    local diff = now - timestamp

    if diff < 60 then
      return diff .. 's ago'
    elseif diff < 3600 then
      return math.floor(diff / 60) .. 'm ago'
    elseif diff < 86400 then
      return math.floor(diff / 3600) .. 'h ago'
    else
      return math.floor(diff / 86400) .. 'd ago'
    end
  end

  local function traverse_entry(entry, level, index)
    local indent = string.rep('  ', level)
    local icon = level == 0 and '├╴' or (index == 1 and '├╴' or '├╴')
    local time = format_relative_time(entry.time)
    local text = string.format(
      '%s %s ◉ %s - %s  %s',
      indent,
      icon,
      entry.seq,
      time,
      entry.seq == tree.seq_cur and '(current)' or ''
    )
    table.insert(items, {
      time = entry.time,
      seq = entry.seq,
      text = text,
      -- diff = get_diff(entry),
    })

    if entry.alt then
      for idx, child in ipairs(entry.alt) do
        traverse_entry(child, level + 1, idx)
      end
    end
  end

  for index, entry in ipairs(tree.entries) do
    traverse_entry(entry, 0, index)
  end

  table.sort(items, function(a, b)
    return a.time > b.time
  end)

  vim.cmd('silent! undo ' .. current_seq)
  vim.fn.winrestview(saved_view)
  vim.api.nvim_win_set_cursor(0, cursor)

  ---@type snacks.picker.preview
  local previewer = function(ctx)
    vim.schedule(function()
      vim.api.nvim_buf_call(current_bufnr, function()
        local diff = get_diff(ctx.item)
        -- vim.print('⭕ ❱ picker.lua:133 ❱ ƒ(anonymous) ❱ diff =', diff)
        vim.api.nvim_buf_set_lines(ctx.buf, 0, -1, false, diff)
        vim.bo[ctx.buf].filetype = 'diff'
        vim.cmd('silent undo ' .. current_seq)
      end)
    end)
  end

  Snacks.picker.pick({
    items = items,
    title = ' Undo Tree ',
    format = function(item)
      return { { item.text } }
    end,
    preview = previewer,
    confirm = function(picker, item)
      vim.cmd('silent undo ' .. current_seq)
    end,
  })
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
  'folke/snacks.nvim',
  lazy = false,

  -- stylua: ignore
  keys = {
    -- Files and search
    { "<C-p>",      pick("smart"),                                    desc = "Find Files" },
    { "<leader>sf", pick("smart"),                                    desc = "Find Files" },
    { "<leader>sn", pick("files", { cwd = vim.fn.stdpath("config") }),desc = "Find Neovim Config Files" },
    { '<leader>sb', pick("buffers"),                                  desc = 'Buffers' },
    { '<leader>so', pick("recent"),                                   desc = 'Recent' },
    { '<leader>sB', pick("grep_buffers"),                             desc = 'Grep Buffers' },
    { '<leader>sg', pick("grep"),                                     desc = 'Grep' },
    { '<leader>sw', pick("grep_word"),                                desc = 'Current [W]ord' },
    { '<leader>/',  pick("lines"),                                    desc = 'Buffers Lines' },
    { '<leader>po', pick("files", {cmd = 'find-overlays'}),           desc = 'Project Overlay' },
    { '<leader>sk', pick("keymaps"),                                  desc = 'Keymaps' },
    { '<leader>sh', pick("help"),                                     desc = 'Help' },
    { '<leader>sd', pick("diagnostics"),                              desc = 'Diagnostics' },
    { '<leader>sp', plugin_files,                                     desc = 'Plugin Files' },
    { '<leader>su', undo_tree,                                     desc = 'Undo tree' },

    -- Git
    { "<leader>gcl", pick("git_log"),                                 desc = "Git Log" },
    { "<leader>gcf", pick("git_log_file"),                            desc = "Git Log File" },
    { "<leader>gcL", pick("git_log_line"),                            desc = "Git Log Line" },
    { "<leader>gss", pick("git_status"),                              desc = "Git Status" },
    { "<leader>sM",  pick("marks"),                                   desc = "Marks" },

    -- LSP
    { "gd",         pick("lsp_definitions"),                          desc = "Goto Definition" },
    { "gR",         pick("lsp_references"),                           desc = "References", nowait = true },
    { "gI",         pick("lsp_implementations"),                      desc = "Goto Implementation" },
    { "gy",         pick("lsp_type_definitions"),                     desc = "Goto T[y]pe Definition" },
    { "<leader>sy", pick("lsp_symbols"),                              desc = "LSP Symbols" },

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
        file = {
          filename_first = true,
        },
      },
      sources = {
        recent = {
          filter = {
            cwd = true,
          },
        },
        files = {},
      },
    },
  },
}
