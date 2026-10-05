-- Keep the learning profile's startup sequence explicit.
-- Set the leader before any loaded module can define leader mappings.
vim.g.mapleader = " "

-- Remote-plugin discovery needs its host before lazy.nvim's first installation.
vim.g.python3_host_prog = vim.fn.stdpath("data") .. "/notebook-venv/bin/python"

-- === Native editor behavior ===
require("config.options")
require("config.diagnostics")
require("config.keymaps")

-- Native local theme; picker selections do not change this startup default.
vim.cmd.colorscheme("mocha-custom")

-- === Plugins and language tooling ===
-- The eager LSP plugin spec connects language declarations after its dependencies load.
require("config.lazy")
