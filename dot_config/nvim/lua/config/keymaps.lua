-- Native window navigation; insert-mode editing keys remain unchanged.
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Clear search highlighting while preserving Escape's normal behavior.
vim.keymap.set({ "n", "i", "s" }, "<Esc>", "<Cmd>nohlsearch<CR><Esc>", {
  desc = "Escape and clear search highlighting",
})

-- Resolve plugin modules only when a mapping runs, after lazy.nvim has loaded them.
vim.keymap.set("n", "<leader>ao", function()
  require("snacks").terminal.toggle({ "env", "-u", "NO_COLOR", "omp" }, {
    cwd = vim.fn.getcwd(),
    win = {
      position = "float",
      width = 0.9,
      height = 0.85,
      border = "rounded",
      title = " OMP ",
      title_pos = "center",
      keys = {
        term_normal = false,
        hide_omp = { "<Esc>", "hide", mode = { "n", "t" }, desc = "Hide OMP" },
      },
    },
  })
end, { desc = "Toggle Oh My Pi" })

vim.keymap.set("n", "ds", "gsd", { remap = true, desc = "Delete surrounding" })

vim.keymap.set({ "n", "x", "o" }, "s", function()
  require("flash").jump()
end, { desc = "Flash" })

vim.keymap.set({ "n", "x", "o" }, "S", function()
  require("flash").treesitter()
end, { desc = "Flash Tree-sitter" })

vim.keymap.set("o", "r", function()
  require("flash").remote()
end, { desc = "Remote Flash" })

vim.keymap.set({ "o", "x" }, "R", function()
  require("flash").treesitter_search()
end, { desc = "Flash Tree-sitter search" })

vim.keymap.set("n", "<leader>e", function()
  require("snacks").explorer({ cwd = vim.fn.getcwd() })
end, { desc = "File explorer" })

vim.keymap.set("n", "<leader>ff", function()
  require("snacks").picker.files({ cwd = vim.fn.getcwd() })
end, { desc = "Find files" })

vim.keymap.set("n", "<leader>fg", function()
  require("snacks").picker.grep({ cwd = vim.fn.getcwd() })
end, { desc = "Search project text" })

vim.keymap.set("n", "<leader>uC", function()
  require("snacks").picker.colorschemes()
end, { desc = "Colorschemes" })

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
  -- Select only the language-owned formatters; do not write or run lint fixes.
  vim.lsp.buf.format({
    filter = function(client)
      return client.name == "ruff" or client.name == "clangd"
    end,
  })
end, { desc = "Format buffer" })
