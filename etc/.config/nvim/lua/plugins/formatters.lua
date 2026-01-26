-- ~/.config/nvim/lua/plugins/formatters.lua
return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      javascript = { "prettier" },
      typescript = { "prettier" },
      python = { "black" },
      lua = { "stylua" },
    },
    format_on_save = {
      lsp_fallback = true,
      timeout_ms = 500,
    },
    formatters = {
      black = {
        prepend_args = { "--line-length", "120", "--skip-magic-trailing-comma" },
      },
    },
  },
}
