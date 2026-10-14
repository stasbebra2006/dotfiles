-- Copy only explicit yanks to the system clipboard.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("YankToSystemClipboard", { clear = true }),
  callback = function()
    if vim.v.event.operator == "y" and vim.v.event.regname ~= "_" then
      vim.fn.setreg("+", vim.v.event.regcontents, vim.v.event.regtype)
    end
  end,
})

-- Highlight on yank (from LazyVim).
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
  callback = function()
    if vim.fn.has("nvim-0.13") == 1 then
      vim.hl.hl_op()
    else
      (vim.hl or vim.highlight).on_yank()
    end
  end,
})
