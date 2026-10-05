-- Explicit plugin index: inclusion is separate from each plugin's own setup.
return {
  require("plugins.colorscheme"),
  require("plugins.which-key"),
  require("plugins.flash"),
  require("plugins.snacks"),
  require("plugins.bufferline"),
  require("plugins.lualine"),
  require("plugins.noice"),
  require("plugins.persistence"),
  require("plugins.treesitter"),
  require("plugins.blink"),
  require("plugins.lsp"),
  require("plugins.jupytext"),
  require("plugins.molten"),
}
