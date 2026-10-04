-- Native editor options that do not depend on plugins.
vim.opt.number = true

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
