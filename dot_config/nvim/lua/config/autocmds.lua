-- Copy only explicit yanks to the system clipboard.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("YankToSystemClipboard", { clear = true }),
  callback = function()
    if vim.v.event.operator == "y" and vim.v.event.regname ~= "_" then
      vim.fn.setreg("+", vim.v.event.regcontents, vim.v.event.regtype)
    end
  end,
})

-- Highlight on yank (from LazyVim).
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
  callback = function()
    if vim.fn.has("nvim-0.13") == 1 then
      vim.hl.hl_op()
    else
      (vim.hl or vim.highlight).on_yank()
    end
  end,
})

local function is_loclist(win)
  win = (win and win ~= 0) and win or vim.api.nvim_get_current_win()
  return (vim.fn.getwininfo(win)[1] or {}).loclist == 1
end

local function remove_qf_items(visual)
  local win = vim.api.nvim_get_current_win()
  local loc = is_loclist(win)
  local info = loc and vim.fn.getloclist(0, { all = true }) or vim.fn.getqflist({ all = true })
  local items = info.items or {}
  if #items == 0 then
    return
  end

  local start_line, end_line
  if visual then
    local l1, l2 = vim.fn.line("v"), vim.fn.line(".")
    start_line, end_line = math.min(l1, l2), math.max(l1, l2)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
  else
    start_line = vim.fn.line(".")
    end_line = start_line + vim.v.count1 - 1
  end

  if start_line > #items then
    return
  end
  end_line = math.min(#items, end_line)

  for i = end_line, start_line, -1 do
    table.remove(items, i)
  end

  local idx = info.idx or 0
  if #items == 0 then
    idx = 0
  elseif idx > end_line then
    idx = idx - (end_line - start_line + 1)
  elseif idx >= start_line then
    idx = math.min(start_line, #items)
  end

  local replacement = { items = items, title = info.title, idx = idx }
  if loc then
    vim.fn.setloclist(0, {}, "r", replacement)
  else
    vim.fn.setqflist({}, "r", replacement)
  end

  if #items > 0 then
    pcall(vim.api.nvim_win_set_cursor, win, { math.min(start_line, #items), 0 })
  end
end

-- Allow removing checked entries and closing with q in quickfix/location windows.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("QuickfixActions", { clear = true }),
  pattern = "qf",
  callback = function(ev)
    vim.keymap.set("n", "dd", function()
      remove_qf_items(false)
    end, { buffer = ev.buf, silent = true, desc = "Remove quickfix item" })

    vim.keymap.set("x", "d", function()
      remove_qf_items(true)
    end, { buffer = ev.buf, silent = true, desc = "Remove selected quickfix items" })

    vim.keymap.set("n", "q", function()
      vim.cmd(is_loclist() and "lclose" or "cclose")
    end, { buffer = ev.buf, silent = true, desc = "Close quickfix window" })
  end,
})
