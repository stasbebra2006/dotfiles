-- Popup commands and visible messages, without replacing native LSP behavior.
return {
  "folke/noice.nvim",
  version = "v4.10.0",
  event = "VeryLazy",
  dependencies = {
    { "MunifTanjim/nui.nvim", version = "0.4.0" },
  },
  config = function()
    require("noice").setup({
      cmdline = { view = "cmdline_popup" },
      views = {
        cmdline_popup = {
          position = { row = "50%", col = "50%" },
        },
      },
      -- Handling messages removes the reserved native command row, not the messages.
      messages = { enabled = true },
      presets = { bottom_search = true },
      notify = { enabled = false },
      lsp = {
        progress = { enabled = false },
        hover = { enabled = false },
        signature = { enabled = false },
        message = { enabled = false },
      },
    })
  end,
}
