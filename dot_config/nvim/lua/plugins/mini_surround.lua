-- Match VS Code's surround mappings while leaving s/S available for Flash.
return {
  "nvim-mini/mini.surround",
  commit = "9fd5ebef2b34cc4ac3c0f1811a6726ea6d92fa91",
  lazy = false,
  config = function()
    require("mini.surround").setup({
      mappings = {
        add = "gsa",
        delete = "gsd",
        find = "gsf",
        find_left = "gsF",
        highlight = "gsh",
        replace = "gsr",
        update_n_lines = "gsn",
      },
    })
  end,
}
