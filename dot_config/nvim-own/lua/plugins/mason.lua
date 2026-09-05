-- Mason installs external tools; config/lsp.lua separately owns LSP clients.
return {
  "mason-org/mason.nvim",
  config = function()
    -- Defaults use nvim-own's isolated data root and prepend Mason's bin to PATH.
    require("mason").setup()
  end,
}
