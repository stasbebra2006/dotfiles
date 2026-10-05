-- Molten runs cells; config/keymaps.lua owns execution and output controls.
return {
  "benlubas/molten-nvim",
  -- This revision includes the Snacks image provider, absent from older releases.
  commit = "bedea63819c618e007e7c40059fc6e72d598c8df",
  lazy = false,
  build = ":UpdateRemotePlugins",
  dependencies = { "folke/snacks.nvim" },
  init = function()
    vim.g.molten_image_provider = "snacks.nvim"
    vim.g.molten_auto_init_behavior = "raise"
    vim.g.molten_auto_open_output = false
    vim.g.molten_virt_text_output = true
    vim.g.molten_virt_text_max_lines = 3
    vim.g.molten_virt_text_truncate = "bottom"
    vim.g.molten_image_location = "float"
    vim.g.molten_enter_output_behavior = "open_and_enter"
    vim.g.molten_output_win_max_height = 30
    vim.g.molten_output_win_max_width = 120
    vim.g.molten_output_win_border = "rounded"
    vim.g.molten_output_show_more = true
    vim.g.molten_wrap_output = false
    vim.g.molten_tick_rate = 200
  end,
  config = function()
    -- Saved results are imported after an explicit kernel selection, not executed.
    vim.api.nvim_create_autocmd("User", {
      group = vim.api.nvim_create_augroup("nvim-own-notebook-outputs", { clear = true }),
      pattern = "MoltenInitPost",
      callback = function(event)
        if not vim.api.nvim_buf_get_name(event.buf):match("%.ipynb$") then
          return
        end
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(event.buf) then
            vim.api.nvim_buf_call(event.buf, function()
              vim.cmd("MoltenImportOutput")
            end)
          end
        end)
      end,
    })
  end,
}
