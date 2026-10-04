-- Explicit plugin index: inclusion is separate from each plugin's own setup.
return {
  require("plugins.which-key"),
  require("plugins.snacks"),
  require("plugins.bufferline"),
  require("plugins.persistence"),
  require("plugins.treesitter"),
  require("plugins.blink"),
  require("plugins.lsp"),
}
