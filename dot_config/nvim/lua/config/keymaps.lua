-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Reveal current file in explorer
vim.keymap.set("n", "<leader>er", function()
  Snacks.explorer.reveal()
end, { desc = "Explorer Reveal File" })

-- Focus explorer
vim.keymap.set("n", "<leader>ef", function()
  Snacks.explorer({ toggle = false })
end, { desc = "Explorer Focus" })

-- Copy absolute path
vim.keymap.set("n", "<leader>cp", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  vim.notify('Copied: ' .. path)
end, { desc = "Copy Absolute Path" })

-- Copy filename
vim.keymap.set("n", "<leader>cn", function()
  local name = vim.fn.expand("%:t")
  vim.fn.setreg("+", name)
  vim.notify('Copied: ' .. name)
end, { desc = "Copy Filename" })

-- Terminal at current file directory
vim.keymap.set("n", "<leader>fT", function()
  Snacks.terminal(nil, { cwd = vim.fn.expand("%:p:h") })
end, { desc = "Terminal (File Dir)" })

-- Escape terminal mode
vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], { desc = "Escape Terminal Mode" })

-- Open dashboard (greeting window)
vim.keymap.set("n", "<leader>db", function()
  Snacks.dashboard.open()
end, { desc = "Open Dashboard" })

-- Cycle through buffers
vim.keymap.set("n", "<C-Tab>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "<C-S-Tab>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous Buffer" })

-- Move buffers left/right
vim.keymap.set("n", "<leader>bH", "<cmd>BufferLineMovePrev<cr>", { desc = "Move Buffer Left" })
vim.keymap.set("n", "<leader>bL", "<cmd>BufferLineMoveNext<cr>", { desc = "Move Buffer Right" })
