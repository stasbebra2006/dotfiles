-- Keep deletes and changes in Vim's internal registers while copying yanks
-- to the system clipboard.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("YankToSystemClipboard", { clear = true }),
  callback = function()
    if vim.v.event.operator == "y" then
      vim.fn.setreg("+", vim.v.event.regcontents, vim.v.event.regtype)
    end
  end,
})
