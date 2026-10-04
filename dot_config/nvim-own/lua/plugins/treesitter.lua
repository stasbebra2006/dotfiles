-- Use the maintained API and freeze the parser/query revision with the plugin.
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  commit = "e289100ff98969e118c702199d88b764ce9e7fdf",
  lazy = false,
  build = function()
    -- Install on a fresh profile and refresh the matching grammar on plugin changes.
    assert(
      require("nvim-treesitter").install({ "python" }, { force = true }):wait(300000),
      "Python Tree-sitter parser installation failed"
    )
  end,
  config = function()
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("NvimOwnTreesitter", { clear = true }),
      pattern = "python",
      callback = function(event)
        vim.treesitter.start(event.buf)
      end,
      desc = "Enable Python Tree-sitter highlighting",
    })
  end,
}
