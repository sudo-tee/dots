return {
  "micmine/jumpwire.nvim",
  keys = {
    {
      "<leader>jt",
      function()
        require("jumpwire").jump("test")
      end,
      desc = "Jump to alternate test",
    },
    {
      "<leader>jT",
      function()
        vim.cmd(":vs ")
        require("jumpwire").jump("test")
      end,
      desc = "Split to alternate test",
    },
    {
      "<leader>ji",
      function()
        require("jumpwire").jump("implementation")
      end,
      desc = "Jump to alternate implementation",
    },
    {
      "<leader>jI",
      function()
        vim.cmd(":vs ")
        require("jumpwire").jump("implementation")
      end,
      desc = "Split to alternate implementation",
    },
  },
  config = function(opts)
    require("jumpwire").setup({
      language = {
        ["ts"] = {
          test = { type = "fileExtension", data = "spec.ts" },
        },
        ["spec.ts"] = {
          implementation = { type = "fileExtension", data = "ts" },
        },
        ["test.ts"] = {
          implementation = { type = "fileExtension", data = "ts" },
        },
      },
    })
  end,
}
