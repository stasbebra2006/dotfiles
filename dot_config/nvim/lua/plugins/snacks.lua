-- Native navigation and visual guides for this profile.
return {
  "folke/snacks.nvim",
  version = "v2.31.0",
  lazy = false,
  priority = 1000,
  dependencies = {
    { "nvim-tree/nvim-web-devicons", version = "v0.100" },
  },
  config = function()
    require("snacks").setup({
      -- The default explorer is a persistent left sidebar and replaces netrw.
      explorer = { enabled = true },
      -- Match LazyVim's indent guides and animated current-block highlight.
      indent = { enabled = true },
      picker = {
        enabled = true,
        sources = {
          explorer = {
            actions = {
              explorer_yank = function(picker)
                -- Snacks writes registers directly without TextYankPost.
                require("snacks.explorer.actions").actions.explorer_yank(picker)
                local register = vim.v.register
                if register ~= "_" then
                  vim.fn.setreg("+", vim.fn.getreg(register, 1, true), vim.fn.getregtype(register))
                end
              end,
            },
            win = {
              -- In normal mode, inherit the global Ctrl-j/k window mappings.
              list = { keys = { ["<c-j>"] = false, ["<c-k>"] = false } },
              input = {
                keys = {
                  ["<c-j>"] = { "list_down", mode = "i" },
                  ["<c-k>"] = { "list_up", mode = "i" },
                },
              },
            },
          },
        },
      },
      dashboard = {
        enabled = true,
        preset = {
          -- Reuse the normal search mappings so dashboard actions stay consistent.
          keys = {
            { key = "f", desc = "Find file", action = "<leader>ff" },
            { key = "g", desc = "Search text", action = "<leader>fg" },
            {
              key = "r",
              desc = "Recent files",
              action = function()
                require("snacks").picker.recent()
              end,
            },
            { key = "n", desc = "New file", action = ":enew | startinsert" },
            { key = "s", desc = "Restore session", action = "<leader>qs" },
            { key = "q", desc = "Quit", action = ":qa" },
          },
        },
      },
    })
  end,
}
