-- Insert-mode completion; language modules still own their server declarations.
return {
  "saghen/blink.cmp",
  -- A release tag provides the prebuilt Rust matcher without a local build.
  version = "v1.10.2",
  config = function()
    require("blink.cmp").setup({
      -- No preset: leave Tab and unrelated insert-mode keys alone.
      keymap = {
        preset = "none",
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-e>"] = { "hide", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
      },
      completion = {
        -- Navigation never inserts a preview; Enter needs an explicit selection.
        list = { selection = { preselect = false, auto_insert = false } },
      },
      sources = { default = { "lsp", "path", "buffer" } },
      -- This step changes the coding popup, not command-line completion.
      cmdline = { enabled = false },
      fuzzy = { implementation = "rust" },
    })
  end,
}
