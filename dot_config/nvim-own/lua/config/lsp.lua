-- Mason owns executable installation; this file owns the Pyright client recipe.
vim.lsp.config("pyright", {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  -- .git defines the workspace boundary; it does not select an interpreter.
  root_markers = { ".git" },
})

-- Enable the recipe now; a server starts only after a matching buffer opens.
vim.lsp.enable("pyright")
