-- Optional themes load when selected; init.lua selects the local startup theme.
return {
  {
    "folke/tokyonight.nvim",
    version = "v4.14.1",
    lazy = true,
    config = function()
      require("tokyonight").setup({})
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    version = "v2.0.0",
    lazy = true,
    config = function()
      require("catppuccin").setup({ auto_integrations = true })
    end,
  },
}
