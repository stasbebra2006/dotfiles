-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Define custom highlights (fixes picker contrast + applies Catppuccin colors ONLY to code text/syntax)
local function set_custom_hl()
  -- ===================================================================
  -- 1. SNACKS PICKER CONTRAST FIXES
  -- ===================================================================
  -- Link directory path highlight to 'Directory' (usually bright blue/cyan) for high readability
  vim.api.nvim_set_hl(0, "SnacksPickerDir", { link = "Directory" })
  -- Use the standard cursor-line highlight for the selected picker row
  vim.api.nvim_set_hl(0, "SnacksPickerListCursorLine", { link = "CursorLine" })
  -- Use the same red Flash jump labels as the VS Code Neovim setup
  vim.api.nvim_set_hl(0, "FlashLabel", { fg = "#ffffff", bg = "#b94a48", bold = true })

  -- ===================================================================
  -- 2. CATPPUCCIN SYNTAX COLORS (FOR CODE TEXT ONLY - NO UI OVERRIDES)
  -- ===================================================================
  local colors = {
    rosewater = "#f5e0dc",
    flamingo = "#f2cdcd",
    pink = "#f5c2e7",
    mauve = "#cba6f7",
    red = "#f38ba8",
    maroon = "#eba0ac",
    peach = "#fab387",
    yellow = "#f9e2af",
    green = "#a6e3a1",
    teal = "#94e2d5",
    sky = "#89dceb",
    sapphire = "#74c7ec",
    blue = "#89b4fa",
    lavender = "#b4befe",
    text = "#cdd6f4",
    subtext1 = "#bac2de",
    subtext0 = "#a6adc8",
    overlay2 = "#9399b2",
    overlay1 = "#7f849c",
    overlay0 = "#6c7086",
    surface2 = "#585b70",
    surface1 = "#45475a",
    surface0 = "#313244",
  }

  -- Standard Vim Syntax Groups (Applies to all code buffers)
  vim.api.nvim_set_hl(0, "Comment", { fg = colors.surface2, italic = true })
  vim.api.nvim_set_hl(0, "Constant", { fg = colors.peach })
  vim.api.nvim_set_hl(0, "String", { fg = colors.green })
  vim.api.nvim_set_hl(0, "Character", { fg = colors.green })
  vim.api.nvim_set_hl(0, "Number", { fg = colors.peach })
  vim.api.nvim_set_hl(0, "Boolean", { fg = colors.peach })
  vim.api.nvim_set_hl(0, "Float", { fg = colors.peach })
  vim.api.nvim_set_hl(0, "Identifier", { fg = colors.text })
  vim.api.nvim_set_hl(0, "Function", { fg = colors.blue })
  vim.api.nvim_set_hl(0, "Statement", { fg = colors.mauve })
  vim.api.nvim_set_hl(0, "Conditional", { fg = colors.mauve })
  vim.api.nvim_set_hl(0, "Repeat", { fg = colors.mauve })
  vim.api.nvim_set_hl(0, "Label", { fg = colors.mauve })
  vim.api.nvim_set_hl(0, "Operator", { fg = colors.sky })
  vim.api.nvim_set_hl(0, "Keyword", { fg = colors.mauve })
  vim.api.nvim_set_hl(0, "Exception", { fg = colors.mauve })
  vim.api.nvim_set_hl(0, "PreProc", { fg = colors.yellow })
  vim.api.nvim_set_hl(0, "Include", { fg = colors.mauve })
  vim.api.nvim_set_hl(0, "Define", { fg = colors.mauve })
  vim.api.nvim_set_hl(0, "Macro", { fg = colors.yellow })
  vim.api.nvim_set_hl(0, "PreCondit", { fg = colors.yellow })
  vim.api.nvim_set_hl(0, "Type", { fg = colors.yellow })
  vim.api.nvim_set_hl(0, "StorageClass", { fg = colors.yellow })
  vim.api.nvim_set_hl(0, "Structure", { fg = colors.yellow })
  vim.api.nvim_set_hl(0, "Typedef", { fg = colors.yellow })
  vim.api.nvim_set_hl(0, "Special", { fg = colors.pink })
  vim.api.nvim_set_hl(0, "SpecialChar", { fg = colors.pink })
  vim.api.nvim_set_hl(0, "Tag", { fg = colors.yellow })
  vim.api.nvim_set_hl(0, "Delimiter", { fg = colors.teal })
  vim.api.nvim_set_hl(0, "SpecialComment", { fg = colors.surface2 })
  vim.api.nvim_set_hl(0, "Debug", { fg = colors.yellow })
  vim.api.nvim_set_hl(0, "Error", { fg = colors.red })
  vim.api.nvim_set_hl(0, "Todo", { fg = colors.yellow })

  -- Modern Tree-sitter Code Syntax Captures
  vim.api.nvim_set_hl(0, "@comment", { fg = colors.surface2, italic = true })
  vim.api.nvim_set_hl(0, "@operator", { fg = colors.sky })
  vim.api.nvim_set_hl(0, "@punctuation.delimiter", { fg = colors.teal })
  vim.api.nvim_set_hl(0, "@punctuation.bracket", { fg = colors.overlay2 })
  vim.api.nvim_set_hl(0, "@punctuation.special", { fg = colors.pink })
  vim.api.nvim_set_hl(0, "@string", { fg = colors.green })
  vim.api.nvim_set_hl(0, "@string.regex", { fg = colors.pink })
  vim.api.nvim_set_hl(0, "@string.escape", { fg = colors.pink })
  vim.api.nvim_set_hl(0, "@character", { fg = colors.green })
  vim.api.nvim_set_hl(0, "@character.special", { fg = colors.pink })
  vim.api.nvim_set_hl(0, "@boolean", { fg = colors.peach })
  vim.api.nvim_set_hl(0, "@number", { fg = colors.peach })
  vim.api.nvim_set_hl(0, "@float", { fg = colors.peach })
  vim.api.nvim_set_hl(0, "@function", { fg = colors.blue })
  vim.api.nvim_set_hl(0, "@function.builtin", { fg = colors.blue })
  vim.api.nvim_set_hl(0, "@function.call", { fg = colors.blue })
  vim.api.nvim_set_hl(0, "@method", { fg = colors.blue })
  vim.api.nvim_set_hl(0, "@method.call", { fg = colors.blue })
  vim.api.nvim_set_hl(0, "@constructor", { fg = colors.yellow })
  vim.api.nvim_set_hl(0, "@parameter", { fg = colors.maroon, italic = true })
  vim.api.nvim_set_hl(0, "@keyword", { fg = colors.mauve })
  vim.api.nvim_set_hl(0, "@keyword.function", { fg = colors.mauve })
  vim.api.nvim_set_hl(0, "@keyword.return", { fg = colors.mauve })
  vim.api.nvim_set_hl(0, "@conditional", { fg = colors.mauve })
  vim.api.nvim_set_hl(0, "@repeat", { fg = colors.mauve })
  vim.api.nvim_set_hl(0, "@label", { fg = colors.mauve })
  vim.api.nvim_set_hl(0, "@type", { fg = colors.yellow })
  vim.api.nvim_set_hl(0, "@type.builtin", { fg = colors.yellow })
  vim.api.nvim_set_hl(0, "@class", { fg = colors.yellow })
  vim.api.nvim_set_hl(0, "@attribute", { fg = colors.blue })
  vim.api.nvim_set_hl(0, "@variable", { fg = colors.text })
  vim.api.nvim_set_hl(0, "@variable.builtin", { fg = colors.mauve })
  vim.api.nvim_set_hl(0, "@variable.member", { fg = colors.text })
end

-- Re-apply custom highlights when colorscheme changes
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = set_custom_hl,
})

-- Run immediately to apply to current session
set_custom_hl()

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
