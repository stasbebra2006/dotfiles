-- Shares the active file, cursor, and selection with OMP in the same cwd.
return {
  "rauls-kjarners/omp.nvim",
  commit = "a538777ecdd76f9632550672f998706221459adf",
  lazy = false,
  config = function()
    require("omp").setup()
  end,
}
