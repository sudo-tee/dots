return {
  "williamboman/mason.nvim",
  opts = function(_, opts)
    vim.tbl_deep_extend(opts.ensure_installed, { "prettierd", "bash-language-server", "json-ls" })
  end,
}
