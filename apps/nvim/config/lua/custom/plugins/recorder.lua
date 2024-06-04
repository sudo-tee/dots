return {
  'chrisgrieser/nvim-recorder',
  lazy = true,
  event = 'LazyFile',
  opts = {
    mapping = {
      startStopRecording = '<F4>',
      playMacro = '<F5>',
      switchSlot = '<leader>ms',
      editMacro = '<leader>me',
      yankMacro = '<leader>my', -- also decodes it for turning macros to mappings
      addBreakPoint = '##', -- ⚠️ this should be a string you don't use in insert mode during a macro
    },
  },
}
