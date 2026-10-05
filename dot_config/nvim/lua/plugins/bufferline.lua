-- Display open file buffers as tabs; Neovim tabpages remain separate layouts.
return {
  "akinsho/bufferline.nvim",
  version = "v4.9.1",
  dependencies = { "folke/snacks.nvim", "nvim-tree/nvim-web-devicons" },
  config = function()
    local function close_buffer(bufnr)
      -- Preserve splits and prompt before discarding an unsaved buffer.
      require("snacks").bufdelete(bufnr)
    end

    require("bufferline").setup({
      options = {
        mode = "buffers",
        close_command = close_buffer,
        right_mouse_command = close_buffer,
        -- Keep file tabs aligned with the editor, not above the sidebar.
        offsets = { { filetype = "snacks_layout_box" } },
      },
    })
  end,
}
