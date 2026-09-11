-- One language container owns that language's LSP servers and their overrides.
return {
  name = "python",

  servers = {
    -- The empty override selects nvim-lspconfig's maintained Pyright recipe.
    -- Add settings here only when Python work exposes a concrete need.
    pyright = {},
  },
}
