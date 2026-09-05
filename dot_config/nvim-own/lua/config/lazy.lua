-- === Bootstrap lazy.nvim ===
-- NVIM_APPNAME keeps the downloaded manager inside nvim-own's isolated data root.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local result = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    lazyrepo,
    lazypath,
  })

  if vim.v.shell_error ~= 0 then
    error("Failed to clone lazy.nvim:\n" .. result)
  end
end

-- Make the downloaded manager discoverable before requiring its Lua module.
vim.opt.rtp:prepend(lazypath)

-- === Explicit plugin registration ===
-- The index selects plugins; each plugin module owns its declaration and setup.
local plugins = require("plugins")

require("lazy").setup(plugins)
