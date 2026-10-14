-- Show the visible portion of the file at the right edge of editor windows.
return {
  "petertriho/nvim-scrollbar",
  enabled = false,
  commit = "f8e87b96cd6362ef8579be456afee3b38fd7e2a8",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    -- Scrolling and inactivity are handled below instead of persistent rendering.
    autocmd = { render = {}, clear = {} },
    hide_if_all_visible = true,
    handle = {
      color = "#6c7086",
      blend = 20,
    },
    excluded_buftypes = { "terminal", "nofile", "prompt", "quickfix" },
    handlers = {
      handle = true,
      cursor = false,
      diagnostic = false,
      gitsigns = false,
      search = false,
      ale = false,
    },
  },
  config = function(_, opts)
    local scrollbar = require("scrollbar")
    scrollbar.setup(opts)
    -- Remove the old persistent handlers when reloading an open session.
    for _, name in ipairs({ "scrollbar_render", "scrollbar_clear" }) do
      pcall(vim.api.nvim_del_augroup_by_name, name)
    end

    local namespace = vim.api.nvim_get_namespaces().Scrollbar
    local pending = {}
    local function hide(buf)
      pending[buf] = nil
      if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_is_loaded(buf) then
        vim.api.nvim_buf_clear_namespace(buf, namespace, 0, -1)
      end
    end

    local group = vim.api.nvim_create_augroup("AutoHideScrollbar", { clear = true })
    vim.api.nvim_create_autocmd("WinScrolled", {
      group = group,
      callback = function()
        local change = vim.v.event[tostring(vim.api.nvim_get_current_win())]
        if not change or (change.topline == 0 and change.topfill == 0 and change.leftcol == 0) then
          return
        end
        local buf = vim.api.nvim_get_current_buf()
        scrollbar.render()
        local ticket = {}
        pending[buf] = ticket
        vim.defer_fn(function()
          if pending[buf] == ticket then
            hide(buf)
          end
        end, 700)
      end,
    })
    vim.api.nvim_create_autocmd({ "BufWinLeave", "WinLeave", "BufWipeout" }, {
      group = group,
      callback = function(ev)
        hide(ev.buf)
      end,
    })
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      hide(buf)
    end
  end,
}
