if vim.g.vscode then
  require("config.vscode")
  return
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
