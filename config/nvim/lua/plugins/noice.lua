return {
  "folke/noice.nvim",
  opts = {
    cmdline = {
      format = {
        shell = { pattern = "^:%s*R ", icon = "$", lang = "bash" },
        task = { pattern = "^:%s*T ", icon = "🌟", lang = "task" },
      },
    },
    presets = {
      bottom_search = true, -- use a classic bottom cmdline for search
      command_palette = true, -- position the cmdline and popupmenu together
      long_message_to_split = true, -- long messages will be sent to a split
      inc_rename = false, -- enables an input dialog for inc-rename.nvim
      lsp_doc_border = true, -- add a border to hover docs and signature help
    },
    routes = {
      {
        view = "mini",
        filter = {
          any = {
            { event = "msg_show", find = "written" },
            { event = "msg_show", find = "%d+ lines, %d+ bytes" },
            { event = "msg_show", find = "%d+ fewer lines" },
            { event = "msg_show", find = "%d+ more lines" },
            { event = "msg_show", find = "%d+ more lines" },
            { event = "msg_show", find = "%d+L, %d+B" },
            { event = "msg_show", find = "^Hunk %d+ of %d" },
            { event = "msg_show", find = "%d+ change" },
            { event = "msg_show", find = "%d+ line" },
            { event = "msg_show", find = "%d+ more line" },
            { event = "notify", find = "Config Change" },
            { event = "notify", find = "Config file" },
          },
        },
      },
    },
  },
}
