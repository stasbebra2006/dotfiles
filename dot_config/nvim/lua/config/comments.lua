-- Open a plain line with o/O, even when the current line is a comment.
vim.opt.formatoptions:remove("o")

-- Filetype plugins can restore their own buffer-local formatting options.
vim.api.nvim_create_autocmd({ "FileType", "BufEnter" }, {
  group = vim.api.nvim_create_augroup("NoOpenLineComment", { clear = true }),
  callback = function()
    vim.opt_local.formatoptions:remove("o")
  end,
})
