if vim.g.vscode then
  -- VS Code has a separate lightweight configuration and skips LazyVim startup.
  require("config.vscode")
  return
end

-- Bootstrap lazy.nvim before importing LazyVim and local plugin specifications.
require("config.lazy")
