-- Control diagnostic rendering only; LSP clients still own diagnostic production.
-- Virtual lines are the current deliberate preference over virtual text.
vim.diagnostic.config({
  underline = true,
  update_in_insert = false,
  virtual_text = false,
  virtual_lines = true,
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = " ",
      [vim.diagnostic.severity.HINT] = " ",
    },
  },
  float = true,
})
