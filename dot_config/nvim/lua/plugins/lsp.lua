-- LSP is the runtime feature; Mason is supporting installation infrastructure.
return {
  "neovim/nvim-lspconfig",
  lazy = false,
  dependencies = {
    "mason-org/mason.nvim",
    "mason-org/mason-lspconfig.nvim",
    -- Blink registers completion capabilities before the connector enables servers.
    "saghen/blink.cmp",
  },
  config = function()
    local languages = require("languages")

    -- Mason installs tools inside this profile's data directory and exposes
    -- their executables on PATH.
    require("mason").setup()

    -- Server names come from the language containers. mason-lspconfig translates
    -- them to Mason package names and installs missing servers. Activation stays
    -- explicit in config.lsp, so an installed but undeclared server cannot start.
    require("mason-lspconfig").setup({
      ensure_installed = languages.server_names,
      automatic_enable = false,
    })

    require("config.lsp").setup(languages)
  end,
}
