return {
  "mrjones2014/smart-splits.nvim",
  lazy = false,
  opts = {
    ignored_filetypes = { "nofile", "quickfix", "prompt", "NvimTree" },
  },
  keys = {
    -- 1. Smart Directional Resizing (Control + Arrow Keys)
    { "<C-Left>", function() require("smart-splits").resize_left() end, desc = "Resize split left" },
    { "<C-Down>", function() require("smart-splits").resize_down() end, desc = "Resize split down" },
    { "<C-Up>", function() require("smart-splits").resize_up() end, desc = "Resize split up" },
    { "<C-Right>", function() require("smart-splits").resize_right() end, desc = "Resize split right" },

    -- 2. Smart Directional Navigation (Control + h/j/k/l)
    { "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Go to left window" },
    { "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Go to bottom window" },
    { "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Go to top window" },
    { "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Go to right window" },
  },
}
