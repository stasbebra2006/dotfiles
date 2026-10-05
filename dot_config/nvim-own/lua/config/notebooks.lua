local M = {}

-- Cell markers belong to Jupytext, not Molten: resolve the current code range.
function M.run_cell()
  local marker = vim.fn.search("^# %%", "bcnW")
  if marker == 0 then
    vim.notify("No # %% cell; run a line or visual selection instead", vim.log.levels.WARN)
    return
  end
  local header = vim.fn.getline(marker)
  if header:find("[markdown]", 1, true) or header:find("[raw]", 1, true) then
    vim.notify("This is a text cell, not a code cell", vim.log.levels.INFO)
    return
  end

  local following = vim.fn.search("^# %%", "nW")
  local first = marker + 1
  local last = following > 0 and following - 1 or vim.api.nvim_buf_line_count(0)
  while last >= first and vim.fn.getline(last):match("^%s*$") do
    last = last - 1
  end
  if first <= last then
    -- Molten's range API uses one-based lines and includes both endpoints.
    vim.fn.MoltenEvaluateRange(first, last)
  end
end

return M
