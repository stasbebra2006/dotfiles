-- LazyVim loads these options before lazy.nvim starts.
-- Upstream defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- === Interface ===
vim.opt.showcmd = true
vim.opt.laststatus = 3

-- === Clipboard ownership ===
-- Keep unnamed registers internal; autocmds and keymaps bridge explicit operations to +.
vim.opt.clipboard = ""

-- === Line numbers ===
vim.opt.number = true
vim.opt.relativenumber = false
