require('mini.statusline').setup({
  set_vim_settings = false,
  content = {
    active = function()
      local search = MiniStatusline.section_searchcount({ trunc_width = 75 })
      local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
      local macro = MiniStatusline.macro()
      local git = MiniStatusline.section_git({ trunc_width = 75 })
      local diagnostics = MiniStatusline.section_diagnostics({ trunc_width = 75 })
      local filename = MiniStatusline.section_filename({ trunc_width = 140 })
      local fileinfo = MiniStatusline.section_fileinfo({ trunc_width = 120 })
      local updates = MiniStatusline.updates()

      local location = MiniStatusline.section_location({ trunc_width = 75 })

      -- Usage of `MiniStatusline.combine_groups()` ensures highlighting and
      -- correct padding with spaces between groups (accounts for 'missing'
      -- sections, etc.)
      return MiniStatusline.combine_groups({
        { hl = 'IncSearch', strings = { search } },
        { hl = mode_hl, strings = { mode } },
        { hl = 'MiniStatuslineDevinfo', strings = { git, diagnostics } },
        '%<', -- Mark general truncate point
        { hl = 'MiniStatuslineFilename', strings = { filename } },
        '%=', -- End left alignment
        { hl = 'CustomRecordingStatus', strings = { macro } },
        { hl = 'CustomUpdatesStatus', strings = { updates } },
        { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
        { hl = mode_hl, strings = { location } },
      })
    end,
  },
})

MiniStatusline.macro = function(_)
  local reg = vim.fn.reg_recording()
  local macro = reg ~= '' and string.format('Recording @%s', reg) or ''

  return macro
end

MiniStatusline.updates = function(_)
  if require('lazy.status').has_updates() then
    return require('lazy.status').updates()
  end
end
---@diagnostic disable-next-line: duplicate-set-field
MiniStatusline.section_location = function(_)
  -- Use virtual column number to allow update when past last column
  return '%l:%v'
end
