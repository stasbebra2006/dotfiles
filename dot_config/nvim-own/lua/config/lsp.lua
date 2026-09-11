local M = {}

-- Apply the already-validated registry. Installation belongs to plugins.lsp;
-- this connector only configures and enables Neovim LSP clients.
function M.setup(languages)
  for _, server_name in ipairs(languages.server_names) do
    vim.lsp.config(server_name, languages.servers[server_name])
    vim.lsp.enable(server_name)
  end
end

return M
