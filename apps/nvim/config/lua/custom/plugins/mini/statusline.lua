local M = {}
local cache = {
  plugin_updates = nil,
  diagnostic = nil,
}

M.setup = function()
  require('mini.statusline').setup({
    use_icons = true,
    set_vim_settings = false,
    content = {
      active = function()
        local search = MiniStatusline.section_searchcount({ trunc_width = 75 })
        local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
        local macro = MiniStatusline.macro()
        local git = MiniStatusline.section_git({ trunc_width = 75 })
        local lsp = MiniStatusline.section_lsp({ trunc_width = 75 })
        local diagnostics = MiniStatusline.custom_diagnostics()
        local notes = MiniStatusline.section_notes()
        local filename = MiniStatusline.section_filename({ trunc_width = 80 })
        local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 75 })
        local lazy_updates = MiniStatusline.updates()
        local location = MiniStatusline.section_location({ trunc_width = 75 })
        local copilot_status = MiniStatusline.copilot_status()

        local groups = {
          { hl = 'MiniStatuslineCustomRecordingStatus', strings = { macro } },
          { hl = 'IncSearch', strings = { search } },
          { hl = mode_hl, strings = { mode } },
          { hl = 'MiniStatuslineDevinfo', strings = { git } },
          unpack(diagnostics) or '',
          { hl = 'MiniStatuslineCustomNotes', strings = { notes } },
          '%<', -- Mark general truncate point
          { hl = 'MiniStatuslineFilename', strings = { filename } },
          '%=', -- End left alignment
          { hl = 'MiniStatuslineCustomUpdatesStatus', strings = { lazy_updates } },
          { hl = 'MiniStatuslineCopilot' .. copilot_status, strings = { '' } },
          { hl = 'MiniStatuslineFileinfo', strings = { lsp, fileinfo } },
          { hl = mode_hl, strings = { location } },
        }

        return MiniStatusline.combine_groups(groups)
      end,
    },
  })

  MiniStatusline.section_filename = (function()
    local utils = require('custom.lib.utils')
    local cached_filename = nil

    local function update_filename_cache()
      if vim.bo.buftype == 'terminal' then
        cached_filename = '%t'
      else
        cached_filename = '%f%m%r'
      end
    end

    update_filename_cache()

    vim.api.nvim_create_autocmd({
      'BufEnter',
      'BufFilePost',
      'BufWritePost',
      'FileChangedShellPost',
      'TermOpen',
    }, {
      group = utils.augroup('custom_statusline_filename'),

      callback = update_filename_cache,
    })

    return function()
      return cached_filename
    end
  end)()

  MiniStatusline.copilot_status = function()
    if vim.g.disable_copilot then
      return 'Disabled'
    end

    if package.loaded['copilot'] == nil then
      return 'Offline'
    end

    local status = require('copilot.status').data.status
    if status == '' then
      return 'Idle'
    end

    return status
  end

  local diagnostic_levels = {
    { name = 'ERROR', sign = ' ' },
    { name = 'WARN', sign = ' ' },
    { name = 'INFO', sign = '󰋼 ' },
    { name = 'HINT', sign = '󰌵 ' },
  }

  MiniStatusline.custom_diagnostics = (function()
    local utils = require('custom.lib.utils')

    -- Update cache when diagnostics change
    vim.api.nvim_create_autocmd({ 'DiagnosticChanged', 'LSPAttach' }, {
      group = utils.augroup('custom_statusline_diagnostics'),
      callback = function()
        cache.diagnostic = {}
        for _, level in ipairs(diagnostic_levels) do
          local n = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity[level.name] })
          if n > 0 then
            table.insert(
              cache.diagnostic,
              { hl = 'MiniStatuslineCustomDiagnostic' .. level.name, strings = { level.sign .. n } }
            )
          end
        end
      end,
    })

    -- Return cached result
    return function()
      return cache.diagnostic or {}
    end
  end)()

  MiniStatusline.macro = function(_)
    local reg = vim.fn.reg_recording()
    local macro = reg ~= '' and string.format('󰑊  REC @%s', reg) or ''

    return macro
  end

  ---@diagnostic disable-next-line: duplicate-set-field
  MiniStatusline.section_location = function()
    -- Use virtual column number to allow update when past last column
    return '%2l:%-2v'
  end

  local note_exists_cache = {}
  local project_name

  ---@TODO Add a Custom auto_cmmand when note is created
  MiniStatusline.section_notes = function()
    local utils = require('custom.lib.utils')
    local notes_path = vim.g.notes_dir
    project_name = project_name or vim.uv.cwd():match('[^/\\]+$') or ''

    local bufname = vim.api.nvim_buf_get_name(0)
    local filename = bufname:match('[^/\\]+$')
    if not filename or filename == '' then
      return ''
    end

    -- Early return if cached result exists
    if note_exists_cache[filename] ~= nil then
      return note_exists_cache[filename]
    end

    local file_path = bufname:match('^(.*)/[^/]*$') or ''
    local note_filename = string.format('%s-%s.md', filename, utils.string_hash(file_path))
    local path = utils.path_join(notes_path, project_name, note_filename)

    -- Cache and return result
    local result = vim.fn.filereadable(path) == 1 and '' or ''
    note_exists_cache[filename] = result
    return result
  end

  MiniStatusline.updates = (function(_)
    local utils = require('custom.lib.utils')

    vim.api.nvim_create_autocmd('User', {
      group = utils.augroup('status_line_plugin_updates', { clear = true }),
      pattern = { 'LazyCheck', 'LazyUpdate' },
      callback = function()
        cache.plugin_updates = require('lazy.status').updates() or ''
        vim.cmd('redrawstatus')
      end,
    })

    return function()
      if cache.plugin_updates == nil then
        cache.plugin_updates = require('lazy.status').updates() or ''
      end
      return cache.plugin_updates or ''
    end
  end)()
end

return M
