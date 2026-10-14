-- Control diagnostic rendering only; LSP clients still own diagnostic production.
-- Show diagnostic messages beside the code on the same line.
vim.diagnostic.config({
  underline = true,
  update_in_insert = false,
  virtual_text = true,
  virtual_lines = false,
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
