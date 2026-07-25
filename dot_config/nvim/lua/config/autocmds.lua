-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Keep plugin-defined highlights aligned with either local colorscheme after
-- LazyVim finishes loading or a scheme is selected again.
local local_theme_group = vim.api.nvim_create_augroup("LocalColorschemes", { clear = true })
local local_themes = {
  ["previous-custom"] = "previous_custom.theme",
  ["vscode-clean"] = "vscode_clean.theme",
}

local function refresh_local_theme()
  local theme = local_themes[vim.g.colors_name]
  if theme then
    require(theme).apply()
  end
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = local_theme_group,
  pattern = { "previous-custom", "vscode-clean" },
  callback = function()
    vim.schedule(refresh_local_theme)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = local_theme_group,
  pattern = "markdown.gh",
  callback = function()
    vim.schedule(function()
      if vim.g.colors_name == "vscode-clean" then
        vim.api.nvim_set_hl(0, "SnacksGhPurple", { fg = require("vscode_clean.palette").blue })
      end
    end)
  end,
})

refresh_local_theme()

-- Automatically reload files when they change on disk
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = vim.api.nvim_create_augroup("AutoReload", { clear = true }),
  callback = function()
    if vim.fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
})

-- ===================================================================
-- 3. AUTO-RESTART LSP ON PACKAGE LOCKFILE CHANGES (e.g. uv add, npm install)
-- ===================================================================
local active_watchers = {}

local function stop_lockfile_watchers()
  for _, w in ipairs(active_watchers) do
    pcall(function()
      w:stop()
    end)
  end
  active_watchers = {}
end

local function start_lockfile_watchers()
  stop_lockfile_watchers()

  local root_patterns = { ".git", "pyproject.toml", "uv.lock", "poetry.lock", "package.json" }
  local path = vim.api.nvim_buf_get_name(0)
  if path == "" then
    path = (vim.uv or vim.loop).cwd()
  end

  local root_files = vim.fs.find(root_patterns, { upward = true, path = path })
  local root = #root_files > 0 and vim.fs.dirname(root_files[1]) or nil
  if not root then
    return
  end

  local lockfiles = { "uv.lock", "poetry.lock", "requirements.txt", "package-lock.json", "pnpm-lock.yaml", "yarn.lock" }
  local uv = vim.uv or vim.loop

  for _, lockfile in ipairs(lockfiles) do
    local file_path = root .. "/" .. lockfile
    if uv.fs_stat(file_path) then
      local w = uv.new_fs_event()
      if w then
        local timer = nil
        w:start(file_path, {}, vim.schedule_wrap(function(err, filename, events)
          if err then
            return
          end
          if timer then
            timer:stop()
          end
          -- Debounce by 1000ms to allow file writes to settle
          timer = vim.defer_fn(function()
            local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
            local active_clients = get_clients()
            if #active_clients > 0 then
              if vim.fn.exists(":LspRestart") == 2 then
                vim.cmd("LspRestart")
              elseif vim.fn.exists(":lsp") == 2 then
                pcall(vim.cmd, "lsp restart")
              else
                -- Fallback to pure Lua LSP restart
                for _, client in ipairs(active_clients) do
                  pcall(function() client.stop() end)
                end
                vim.defer_fn(function()
                  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
                    if vim.api.nvim_buf_is_loaded(bufnr) then
                      local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
                      if ft and ft ~= "" then
                        vim.api.nvim_exec_autocmds("FileType", { buf = bufnr, modeline = false })
                      end
                    end
                  end
                end, 500)
              end
              vim.notify("LSP restarted automatically (detected change in " .. lockfile .. ")", vim.log.levels.INFO)
            end
          end, 1000)
        end))
        table.insert(active_watchers, w)
      end
    end
  end
end

-- Watch lockfiles when Neovim starts or changes directories
vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
  group = vim.api.nvim_create_augroup("LspLockfileWatcher", { clear = true }),
  callback = function()
    -- Small delay to let project initialization complete
    vim.defer_fn(start_lockfile_watchers, 1000)
  end,
})

-- Safely clean up watchers when Neovim exits
vim.api.nvim_create_autocmd("VimLeavePre", {
  group = vim.api.nvim_create_augroup("LspLockfileWatcherCleanup", { clear = true }),
  callback = stop_lockfile_watchers,
})

-- Keep deletes and changes in Vim's internal registers while copying yanks
-- to the system clipboard.
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("YankToSystemClipboard", { clear = true }),
  callback = function()
    if vim.v.event.operator == "y" then
      vim.fn.setreg("+", vim.v.event.regcontents, vim.v.event.regtype)
    end
  end,
})
