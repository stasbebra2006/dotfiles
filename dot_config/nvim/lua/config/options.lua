-- Native editor options that do not depend on plugins.
require("config.comments")

vim.opt.number = true
vim.opt.cursorline = true
vim.opt.cursorlineopt = "both"
-- Keep touchpad gestures granular instead of jumping several lines at once.
vim.opt.mousescroll = "ver:1,hor:1"
-- Scroll wrapped text by screen rows rather than whole buffer lines.
vim.opt.smoothscroll = true
-- Copy explicit yanks separately so deletes and changes stay local to Vim.
vim.opt.clipboard = ""
-- Share the statusline across splits instead of giving the sidebar its own.
vim.opt.laststatus = 3

-- Hide end-of-buffer markers in unused screen space.
vim.opt.fillchars:append({ eob = " " })

-- Restore files and layouts, not stale configuration options or plugin mappings.
vim.opt.sessionoptions = {
  "buffers",
  "curdir",
  "tabpages",
  "winsize",
  "help",
  "globals",
  "skiprtp",
  "folds",
}
