-- Native editor options that do not depend on plugins.
vim.opt.number = true
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
