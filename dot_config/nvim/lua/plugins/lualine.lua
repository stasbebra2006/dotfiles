-- One statusline for the editor, including when the file sidebar is open.
return {
  "nvim-lualine/lualine.nvim",
  commit = "221ce6b2d999187044529f49da6554a92f740a96",
  event = "VeryLazy",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("lualine").setup({
      options = {
        theme = "auto",
        globalstatus = true,
        disabled_filetypes = {
          statusline = { "snacks_dashboard" },
        },
      },
    })
  end,
}
