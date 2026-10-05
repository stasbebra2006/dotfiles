-- Jupytext updates the existing notebook rather than rebuilding away its outputs.
return {
  "GCBallesteros/jupytext.nvim",
  commit = "c8baf3ad344c59b3abd461ecc17fc16ec44d0f7b",
  -- BufReadCmd must exist before the first .ipynb file is opened.
  lazy = false,
  config = function()
    require("jupytext").setup({
      -- Keep %magics executable and identical to the source Molten imports.
      style = "hydrogen",
      output_extension = "py",
      force_ft = "python",
    })
  end,
}
