-- Keep the learning profile's startup sequence explicit.
-- Set the leader before any loaded module can define leader mappings.
vim.g.mapleader = " "

-- === Native editor behavior ===
require("config.options")
require("config.diagnostics")
require("config.keymaps")

-- === Plugins and language tooling ===
-- The eager LSP plugin spec connects language declarations after its dependencies load.
require("config.lazy")
