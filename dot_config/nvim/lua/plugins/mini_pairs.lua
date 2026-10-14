-- Close brackets and quotes while typing, with the cursor inside the pair.
return {
  "nvim-mini/mini.pairs",
  commit = "4a014143fcb4e9df26198ccb3ecff3b9e77a048c",
  lazy = false,
  -- Install the newline fallback before Blink's buffer-local completion mapping.
  priority = 900,
  config = function()
    require("mini.pairs").setup({})
    -- Also provide this fallback when enabling pairs in an existing session.
    vim.keymap.set("i", "<CR>", "v:lua.MiniPairs.cr()", {
      expr = true,
      replace_keycodes = false,
      desc = "MiniPairs newline",
    })
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("PairsInCode", { clear = true }),
      pattern = "snacks_picker_input",
      callback = function(ev)
        vim.b[ev.buf].minipairs_disable = true
      end,
    })
  end,
}
