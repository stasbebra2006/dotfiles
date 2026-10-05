-- One language container owns that language's LSP servers and their overrides.
return {
  name = "python",

  servers = {
    -- Pyright keeps type analysis, completion, and navigation; Ruff owns imports.
    pyright = {
      settings = {
        pyright = { disableOrganizeImports = true },
      },
    },
    ruff = {
      on_attach = function(client)
        -- Prefer Pyright's documentation when both servers support hover.
        client.server_capabilities.hoverProvider = false
      end,
    },
  },
}
