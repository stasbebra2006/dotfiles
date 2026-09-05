-- Keep the learning profile's startup sequence explicit.
-- Set the leader before any loaded module can define leader mappings.
vim.g.mapleader = " "

-- === Native editor behavior ===
require("config.options")
require("config.diagnostics")
require("config.keymaps")

-- === Plugin system ===
require("config.lazy")

-- === Language tooling ===
-- Mason has initialized first, so its isolated bin directory is already on PATH.
require("config.lsp")
