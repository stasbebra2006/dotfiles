-- which-key presents mappings; config/keymaps.lua owns the mapped commands.
return {
  "folke/which-key.nvim",
  config = function()
    -- Keep setup visible for learning; helix is the chosen presentation preset.
    require("which-key").setup({
      preset = "helix",
    })
  end,
}
