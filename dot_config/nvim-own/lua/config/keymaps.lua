-- Resolve plugin modules only when a mapping runs, after lazy.nvim has loaded them.
vim.keymap.set("n", "<leader>e", function()
  require("snacks").explorer({ cwd = vim.fn.getcwd() })
end, { desc = "File explorer" })

vim.keymap.set("n", "<leader>ff", function()
  require("snacks").picker.files({ cwd = vim.fn.getcwd() })
end, { desc = "Find files" })

vim.keymap.set("n", "<leader>fg", function()
  require("snacks").picker.grep({ cwd = vim.fn.getcwd() })
end, { desc = "Search project text" })

vim.keymap.set("n", "<S-h>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous buffer" })
vim.keymap.set("n", "<S-l>", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bd", function()
  require("snacks").bufdelete()
end, { desc = "Close buffer" })

vim.keymap.set("n", "<leader>qs", function()
  require("persistence").load()
end, { desc = "Restore session" })

vim.keymap.set("n", "<leader>qS", function()
  require("persistence").select()
end, { desc = "Select session" })

vim.keymap.set("n", "<leader>ql", function()
  require("persistence").load({ last = true })
end, { desc = "Restore last session" })

vim.keymap.set("n", "<leader>qd", function()
  require("persistence").stop()
end, { desc = "Don't save current session" })

vim.keymap.set("n", "<leader>cf", function()
  -- Ruff formats Python; this does not run lint fixes or write the buffer.
  vim.lsp.buf.format({ name = "ruff" })
end, { desc = "Format Python buffer (Ruff)" })
