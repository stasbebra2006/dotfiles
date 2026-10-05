-- Flash supplies labeled jumps and Tree-sitter selections; keymaps live in config/keymaps.lua.
return {
  "folke/flash.nvim",
  -- This maintained revision supports Neovim 0.13's changed internal search state.
  commit = "5f0f270fdc7c5b0c21d903ee85b9cb06f2ac636a",
  event = "VeryLazy",
  config = function()
    require("flash").setup({})
  end,
}
