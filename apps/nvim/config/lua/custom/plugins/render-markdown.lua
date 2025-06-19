return {
  'MeanderingProgrammer/render-markdown.nvim',
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    anti_conceal = { enabled = false },
    file_types = { 'markdown', 'Avante', 'copilot-chat', 'goose_output' },
  },
  ft = { 'markdown', 'Avante', 'copilot-chat', 'goose_output' },
}
