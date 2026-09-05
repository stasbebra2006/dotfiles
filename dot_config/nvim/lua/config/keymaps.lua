-- LazyVim loads this file on VeryLazy after its default mappings.
-- Upstream defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

-- === Clipboard-aware paste ===
-- Use the system clipboard only when no explicit register was selected.
local function paste_command(command)
  local register = vim.v.register == '"' and "+" or vim.v.register
  return '"' .. register .. command
end

vim.keymap.set("n", "p", function()
  return paste_command("p")
end, { expr = true, desc = "Paste Clipboard After" })

vim.keymap.set("n", "P", function()
  return paste_command("P")
end, { expr = true, desc = "Paste Clipboard Before" })

-- === Explorer ===
vim.keymap.set("n", "<leader>er", function()
  Snacks.explorer.reveal()
end, { desc = "Explorer Reveal File" })

vim.keymap.set("n", "<leader>ef", function()
  Snacks.explorer({ toggle = false })
end, { desc = "Explorer Focus" })

-- === Path copying ===
vim.keymap.set("n", "<leader>cp", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify('Copied: ' .. path)
end, { desc = "Copy Absolute Path" })

vim.keymap.set("n", "<leader>cn", function()
  local name = vim.fn.expand("%:t")
  vim.fn.setreg("+", name)
  vim.notify('Copied: ' .. name)
end, { desc = "Copy Filename" })

-- Build a project-relative Python import and normalize src/ and __init__.py.
vim.keymap.set("n", "<leader>ci", function()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" or not file:match("%.py$") then
    vim.notify("Current buffer is not a Python file", vim.log.levels.WARN)
    return
  end

  local root = LazyVim.root({ buf = 0, normalize = true })
  local relative = vim.fs.relpath(root, file)
  if relative == nil or relative:match("^%.%.") then
    vim.notify("Current file is outside the project root", vim.log.levels.WARN)
    return
  end

  local import_path = relative
    :gsub("\\", "/")
    :gsub("^src/", "")
    :gsub("%.py$", "")
    :gsub("/__init__$", "")
    :gsub("/", ".")

  vim.fn.setreg("+", import_path)
  vim.notify("Copied import path: " .. import_path)
end, { desc = "Copy Python Import Path" })

-- === Terminal and dashboard ===
vim.keymap.set("n", "<leader>fT", function()
  Snacks.terminal(nil, { cwd = vim.fn.expand("%:p:h") })
end, { desc = "Terminal (File Dir)" })

vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], { desc = "Escape Terminal Mode" })

vim.keymap.set("n", "<leader>db", function()
  Snacks.dashboard.open()
end, { desc = "Open Dashboard" })

-- === Buffer navigation ===
vim.keymap.set("n", "<C-Tab>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "<C-S-Tab>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous Buffer" })

vim.keymap.set("n", "<leader>bH", "<cmd>BufferLineMovePrev<cr>", { desc = "Move Buffer Left" })
vim.keymap.set("n", "<leader>bL", "<cmd>BufferLineMoveNext<cr>", { desc = "Move Buffer Right" })
