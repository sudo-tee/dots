local BORDER_STYLE =
  { border = "rounded", winhighlight = "Normal:Normal,FloatBorder:DiagnosticInfo,CursorLine:Visual,Search:None" }
return {

  -- lazyvim.plugins.coding
  {
    "nvim-cmp",
    opts = function(_, opts)
      local bordered = require("cmp.config.window").bordered
      return vim.tbl_deep_extend("force", opts, {
        window = {
          completion = bordered(BORDER_STYLE),
          documentation = bordered(BORDER_STYLE),
        },
      })
    end,
  },
  -- lazyvim.plugins.editor
  {
    "which-key.nvim",
    opts = { window = { border = BORDER_STYLE } },
  },
  {
    "gitsigns.nvim",
    opts = { preview_config = { border = BORDER_STYLE } },
  },
  -- lazyvim.plugins.lsp
  {
    "nvim-lspconfig",
    opts = function(_, opts)
      -- Set LspInfo border
      require("lspconfig.ui.windows").default_options.border = BORDER_STYLE
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "rounded",
      })

      vim.diagnostic.open_float = (function(orig)
        return function(opts)
          opts = opts or {}
          opts.border = "rounded"
          opts.header = false

          orig(opts)
        end
      end)(vim.diagnostic.open_float)

      return vim.tbl_deep_extend("force", opts, {
        diagnostics = {
          virtual_text = false,
        },
      })
    end,
  },
  {
    "mason.nvim",
    opts = {
      ui = { border = BORDER_STYLE },
    },
  },
  -- lazyvim.plugins.ui
  {
    "noice.nvim",
    opts = {
      presets = { lsp_doc_border = true },
    },
  },
  {
    "gitsigns.nvim",
    opts = {
      preview_config = {
        border = "rounded",
      },
    },
  },
}
