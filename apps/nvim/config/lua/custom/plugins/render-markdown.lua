return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    enabled = true,
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      anti_conceal = { enabled = false },
      file_types = { 'markdown', 'Avante', 'copilot-chat', 'goose_output', 'opencode_output', 'AgenticChat' },
    },
    ft = { 'markdown', 'Avante', 'copilot-chat', 'goose_output', 'opencode_output', 'AgenticChat' },
  },
}
