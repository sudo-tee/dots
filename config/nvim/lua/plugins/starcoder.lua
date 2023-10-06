return {
  "huggingface/hfcc.nvim",
  cmd = { "StarCoder" },
  enabled = false,
  opts = {
    accept_keymap = "<C-A>",
    dismiss_keymap = "<C-M-Tab>",
    api_token = "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",
    model = "bigcode/starcoder",
    query_params = {
      max_new_tokens = 200,
    },
  },
}
