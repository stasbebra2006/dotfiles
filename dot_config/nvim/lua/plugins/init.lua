-- Explicit plugin index: inclusion is separate from each plugin's own setup.
return {
  require("plugins.colorscheme"),
  require("plugins.which-key"),
  require("plugins.flash"),
  require("plugins.mini_ai"),
  require("plugins.mini_surround"),
  require("plugins.snacks"),
  require("plugins.omp"),
  require("plugins.bufferline"),
  require("plugins.lualine"),
  require("plugins.noice"),
  require("plugins.persistence"),
  require("plugins.treesitter"),
  require("plugins.treesitter_textobjects"),
  require("plugins.blink"),
  require("plugins.lsp"),
}
