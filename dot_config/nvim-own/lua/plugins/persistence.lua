-- Save after opening a real file; restoring remains an explicit user action.
return {
  "folke/persistence.nvim",
  version = "v3.1.0",
  event = "BufReadPre",
  config = function()
    -- Defaults save under nvim-own's state directory, keyed by cwd and Git branch.
    -- An empty dashboard session does not overwrite a previously saved workspace.
    require("persistence").setup({})
  end,
}
