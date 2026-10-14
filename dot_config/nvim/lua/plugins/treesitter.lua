-- Code buffers plus the regular expressions and shell commands shown by Noice.
local parsers = { "python", "c", "cpp", "regex", "bash" }

-- Use the maintained API and freeze the parser/query revision with the plugin.
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  commit = "e289100ff98969e118c702199d88b764ce9e7fdf",
  lazy = false,
  build = function()
    -- Install on a fresh profile and refresh the matching grammar on plugin changes.
    assert(
      require("nvim-treesitter").install(parsers, { force = true }):wait(300000),
      "Tree-sitter parser installation failed"
    )
  end,
  config = function()
    -- Provision newly declared grammars even when the pinned plugin is unchanged.
    require("nvim-treesitter").install(parsers)
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("NvimTreesitter", { clear = true }),
      pattern = { "python", "c", "cpp" },
      callback = function(event)
        vim.treesitter.start(event.buf)
      end,
      desc = "Enable Python, C, and C++ Tree-sitter highlighting",
    })
  end,
}
