-- VS Code startup path: init.lua skips LazyVim, so this module owns the host integration.
local vscode = require("vscode")
local M = {}
local unpack_fn = table.unpack or unpack
local function pack(...)
  return { n = select("#", ...), ... }
end

-- === Transient Escape routing ===
local escape_capture = {
  depth = 0,
  flash_visible = false,
  operator_pending = false,
}
local last_escape_capture

local function set_context(name, value)
  pcall(vscode.call, "setContext", { args = { name, value } }, 1000)
end

local function update_escape_capture()
  local active = escape_capture.depth > 0 or escape_capture.flash_visible or escape_capture.operator_pending
  if active == last_escape_capture then
    return
  end
  last_escape_capture = active
  set_context("neovim.transientActive", active)
end

local function with_escape_capture(callback)
  escape_capture.depth = escape_capture.depth + 1
  update_escape_capture()

  local result = pack(pcall(callback))

  escape_capture.depth = math.max(escape_capture.depth - 1, 0)
  update_escape_capture()

  if not result[1] then
    error(result[2])
  end
  return unpack_fn(result, 2, result.n)
end

-- Clear context left behind by a previous config reload before installing handlers.
set_context("neovim.transientActive", false)
last_escape_capture = false

-- === Optional native plugin reuse ===
local flash_path = vim.fn.stdpath("data") .. "/lazy/flash.nvim"
local has_flash = vim.uv.fs_stat(flash_path) ~= nil
local flash_char
if has_flash then
  vim.opt.runtimepath:prepend(flash_path)
  require("flash").setup({
    highlight = {
      backdrop = true,
    },
  })
  vim.api.nvim_set_hl(0, "FlashLabel", { fg = "#ffffff", bg = "#b94a48", bold = true })
  vim.api.nvim_set_hl(0, "FlashMatch", { fg = "#d4d4d4", bg = "#264f78" })
  vim.api.nvim_set_hl(0, "FlashCurrent", { fg = "#ffffff", bg = "#8f3a3a", bold = true })

  -- Flash owns f/F/t/T. Its character mode waits in Lua, so VSCode Neovim
  -- still reports Normal mode and VS Code would otherwise steal notebook Esc.
  flash_char = require("flash.plugins.char")
  if not flash_char._vscode_escape_capture_wrapped then
    local original_jump = flash_char.jump
    flash_char.jump = function(...)
      local args = pack(...)
      escape_capture.depth = escape_capture.depth + 1
      update_escape_capture()

      local result = pack(pcall(original_jump, unpack_fn(args, 1, args.n)))

      local visible_ok, visible = pcall(flash_char.visible)
      escape_capture.flash_visible = visible_ok and visible or false
      escape_capture.depth = math.max(escape_capture.depth - 1, 0)
      update_escape_capture()

      if not result[1] then
        error(result[2])
      end
      return unpack_fn(result, 2, result.n)
    end
    flash_char._vscode_escape_capture_wrapped = true
  end
end

local surround_path = vim.fn.stdpath("data") .. "/lazy/mini.surround"
if vim.uv.fs_stat(surround_path) then
  vim.opt.runtimepath:prepend(surround_path)
  local mini_surround = require("mini.surround")
  mini_surround.setup({
    mappings = {
      add = "gsa",
      delete = "gsd",
      find = "gsf",
      find_left = "gsF",
      highlight = "gsh",
      replace = "gsr",
      update_n_lines = "gsn",
    },
  })

  -- These actions can call getcharstr() while Neovim still looks like it is
  -- in Normal mode to VS Code. Keep notebook Esc routed to Neovim until the
  -- action has accepted or cancelled its input.
  if not mini_surround._vscode_escape_capture_wrapped then
    for _, method in ipairs({ "add", "delete", "find", "highlight", "replace", "update_n_lines" }) do
      local original = mini_surround[method]
      mini_surround[method] = function(...)
        local args = pack(...)
        return with_escape_capture(function()
          return original(unpack_fn(args, 1, args.n))
        end)
      end
    end
    mini_surround._vscode_escape_capture_wrapped = true
  end

  vim.keymap.set("n", "ds", mini_surround.delete, { desc = "Delete surrounding" })
end

local treesitter_path = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter"
if vim.uv.fs_stat(treesitter_path) then
  vim.opt.runtimepath:prepend(treesitter_path)
end

local treesitter_textobjects_path = vim.fn.stdpath("data") .. "/lazy/nvim-treesitter-textobjects"
if vim.uv.fs_stat(treesitter_textobjects_path) then
  vim.opt.runtimepath:prepend(treesitter_textobjects_path)
end

local mini_ai_path = vim.fn.stdpath("data") .. "/lazy/mini.ai"
if vim.uv.fs_stat(mini_ai_path) then
  vim.opt.runtimepath:prepend(mini_ai_path)
  local ai = require("mini.ai")
  ai.setup({
    n_lines = 500,
    custom_textobjects = {
      f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
      u = ai.gen_spec.function_call(),
      U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }),
      e = {
        { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
        "^().*()$",
      },
      ["="] = ai.gen_spec.treesitter({ a = "@assignment.outer", i = "@assignment.inner" }),
    },
  })
end

-- === VS Code commands and editor MRU ===
local function action(command)
  return function()
    vscode.call(command)
  end
end

local editor_mru_update_script = [[
const storeKey = "__lazyvimEditorMru";

function getTabUri(tab) {
  const input = tab && tab.input;
  return input && (input.uri || input.modified || input.notebook || input.original);
}

const group = vscode.window.tabGroups.activeTabGroup;
const tab = group && group.activeTab;
const uri = getTabUri(tab);
if (!uri) {
  return false;
}

const current = { key: uri.toString(), uri, viewColumn: group.viewColumn };
let mru = globalThis[storeKey];
if (!Array.isArray(mru)) {
  mru = [];
}

if (!mru[0] || mru[0].key !== current.key) {
  mru = [current, ...mru.filter((item) => item && item.key !== current.key)].slice(0, 2);
  globalThis[storeKey] = mru;
}

return true;
]]

local editor_mru_toggle_script = [[
const storeKey = "__lazyvimEditorMru";

function getTabUri(tab) {
  const input = tab && tab.input;
  return input && (input.uri || input.modified || input.notebook || input.original);
}

function toItem(tab, group) {
  const uri = getTabUri(tab);
  if (!uri) {
    return undefined;
  }

  return { key: uri.toString(), uri, viewColumn: group.viewColumn };
}

const activeGroup = vscode.window.tabGroups.activeTabGroup;
const current = toItem(activeGroup && activeGroup.activeTab, activeGroup);
if (!current) {
  return false;
}

let mru = globalThis[storeKey];
if (!Array.isArray(mru)) {
  mru = [];
}

if (!mru[0] || mru[0].key !== current.key) {
  mru = [current, ...mru.filter((item) => item && item.key !== current.key)].slice(0, 2);
}

const target = mru.find((item) => item && item.key !== current.key);
if (!target) {
  globalThis[storeKey] = mru;
  return false;
}

const liveTabs = vscode.window.tabGroups.all.flatMap((group) =>
  group.tabs
    .map((tab) => ({ tab, group, item: toItem(tab, group) }))
    .filter((entry) => entry.item)
);
const liveTarget = liveTabs.find((entry) => entry.item.key === target.key);
if (!liveTarget) {
  globalThis[storeKey] = mru.filter((item) => item && item.key !== target.key);
  return false;
}

await vscode.commands.executeCommand("vscode.open", liveTarget.item.uri, {
  viewColumn: liveTarget.item.viewColumn,
  preserveFocus: false,
  preview: false,
});

globalThis[storeKey] = [liveTarget.item, current];
return true;
]]

local function track_editor_mru()
  vscode.eval_async(editor_mru_update_script)
end

function M.toggle_last_two_editors()
  local ok, toggled = pcall(vscode.eval, editor_mru_toggle_script, nil, 1000)
  if not ok or not toggled then
    vscode.call("workbench.action.openPreviousRecentlyUsedEditor")
  end
end

-- === Host options and autocmds ===
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.opt.clipboard = "unnamedplus"
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.timeout = false
vim.opt.ttimeout = true
vim.opt.ttimeoutlen = 50

vim.api.nvim_create_autocmd({ "VimEnter", "BufEnter" }, {
  group = vim.api.nvim_create_augroup("vscode_editor_mru", { clear = true }),
  callback = track_editor_mru,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("vscode_highlight_yank", { clear = true }),
  callback = function()
    if vim.fn.has("nvim-0.13") == 1 and vim.hl and vim.hl.hl_op then
      vim.hl.hl_op()
    else
      (vim.hl or vim.highlight).on_yank()
    end
  end,
})

-- === Flash cleanup and Escape handling ===
local function clear_flash()
  if not has_flash then
    return
  end

  pcall(function()
    local char = require("flash.plugins.char")
    if char.state then
      char.state:hide()
    end
  end)

  pcall(function()
    local search = require("flash.plugins.search")
    if search.state then
      search.state:hide()
      search.state = nil
    end
  end)

  pcall(function()
    for _, state in pairs(require("flash.repeat")._states or {}) do
      if state then
        state:hide()
      end
    end
  end)

  escape_capture.flash_visible = false
  update_escape_capture()
end

local function flash_action(kind)
  return function()
    return with_escape_capture(function()
      require("flash")[kind]()
    end)
  end
end

vim.api.nvim_create_autocmd("ModeChanged", {
  group = vim.api.nvim_create_augroup("vscode_escape_capture", { clear = true }),
  callback = function()
    -- mode() values beginning with "no" cover operator-pending commands and
    -- native character waits such as f/F/t/T/r. The extension collapses them
    -- to its public "normal" context, so retain the more precise state here.
    escape_capture.operator_pending = vim.v.event.new_mode:sub(1, 2) == "no"
    update_escape_capture()
  end,
})

if flash_char then
  vim.api.nvim_create_autocmd("CursorMoved", {
    group = vim.api.nvim_create_augroup("vscode_flash_char_context", { clear = true }),
    callback = function()
      -- flash.nvim may hide its persistent f/F/t/T highlights on a later
      -- cursor movement. Refresh after its own CursorMoved handler has run.
      vim.schedule(function()
        local ok, visible = pcall(flash_char.visible)
        escape_capture.flash_visible = ok and visible or false
        update_escape_capture()
      end)
    end,
  })
end

vim.api.nvim_create_autocmd({ "ModeChanged", "BufLeave", "WinLeave", "InsertEnter" }, {
  group = vim.api.nvim_create_augroup("vscode_flash_cleanup", { clear = true }),
  callback = clear_flash,
})

vim.keymap.set({ "n", "x", "o" }, "<esc>", function()
  clear_flash()
  vim.cmd("nohlsearch")
  return "<esc>"
end, { expr = true, desc = "Escape and clear Flash/search highlights" })

-- === VS Code keymaps ===
-- --- Search and explorer ---
vim.keymap.set({ "n", "x" }, "<leader><space>", action("workbench.action.quickOpen"), { desc = "Find Files" })
vim.keymap.set({ "n", "x" }, "<leader>ff", action("workbench.action.quickOpen"), { desc = "Find Files" })
vim.keymap.set({ "n", "x" }, "<leader>fg", action("workbench.action.findInFiles"), { desc = "Grep Files" })
vim.keymap.set({ "n", "x" }, "<leader>/", action("workbench.action.findInFiles"), { desc = "Grep Files" })
vim.keymap.set("n", "<leader>sk", action("workbench.action.showCommands"), { desc = "Command Palette" })
vim.keymap.set("n", "<leader>ss", action("workbench.action.gotoSymbol"), { desc = "Document Symbols" })
vim.keymap.set("n", "<leader>sS", action("workbench.action.showAllSymbols"), { desc = "Workspace Symbols" })

vim.keymap.set("n", "<leader>e", action("workbench.action.toggleSidebarVisibility"), { desc = "Explorer Toggle" })
vim.keymap.set("n", "<leader>E", action("workbench.files.action.focusFilesExplorer"), { desc = "Explorer Focus" })
vim.keymap.set("n", "<leader>fe", action("workbench.files.action.showActiveFileInExplorer"), { desc = "Explorer Reveal File" })
vim.keymap.set("n", "<leader>fr", action("workbench.action.openRecent"), { desc = "Recent Projects" })

-- --- Buffers and source control ---
vim.keymap.set("n", "<leader>bb", M.toggle_last_two_editors, { desc = "Switch Buffer" })
vim.keymap.set("n", "<leader>bj", action("workbench.action.showAllEditorsByMostRecentlyUsed"), { desc = "Jump Buffer" })
vim.keymap.set("n", "<leader>bn", action("workbench.action.nextEditor"), { desc = "Next Buffer" })
vim.keymap.set("n", "<leader>bp", action("workbench.action.previousEditor"), { desc = "Previous Buffer" })
vim.keymap.set("n", "<leader>bH", action("workbench.action.moveEditorLeftInGroup"), { desc = "Move Buffer Left" })
vim.keymap.set("n", "<leader>bL", action("workbench.action.moveEditorRightInGroup"), { desc = "Move Buffer Right" })
vim.keymap.set("n", "<leader>bd", action("workbench.action.closeActiveEditor"), { desc = "Delete Buffer" })
vim.keymap.set("n", "<leader>bD", action("workbench.action.closeOtherEditors"), { desc = "Delete Other Buffers" })
vim.keymap.set("n", "<S-h>", action("workbench.action.previousEditor"), { desc = "Previous Buffer" })
vim.keymap.set("n", "<S-l>", action("workbench.action.nextEditor"), { desc = "Next Buffer" })

vim.keymap.set("n", "<leader>gg", action("workbench.view.scm"), { desc = "Git" })
vim.keymap.set("n", "<leader>gs", action("workbench.view.scm"), { desc = "Git Status" })

-- --- Terminal and code navigation ---
vim.keymap.set("n", "<leader>tt", action("workbench.action.terminal.toggleTerminal"), { desc = "Terminal" })
vim.keymap.set("n", "<leader>tn", action("workbench.action.terminal.new"), { desc = "New Terminal" })
vim.keymap.set("n", "<leader>tf", action("workbench.action.terminal.focus"), { desc = "Focus Terminal" })

vim.keymap.set({ "n", "x" }, "<leader>ca", action("editor.action.quickFix"), { desc = "Code Action" })
vim.keymap.set("n", "<leader>cr", action("editor.action.rename"), { desc = "Rename" })
vim.keymap.set({ "n", "x" }, "<leader>cf", action("editor.action.formatDocument"), { desc = "Format Document" })
vim.keymap.set("n", "gd", action("editor.action.revealDefinition"), { desc = "Goto Definition" })
vim.keymap.set("n", "gD", action("editor.action.peekDefinition"), { desc = "Peek Definition" })
vim.keymap.set("n", "gr", action("editor.action.goToReferences"), { desc = "References" })
vim.keymap.set("n", "K", action("editor.action.showHover"), { desc = "Hover" })

-- --- Diagnostics and windows ---
vim.keymap.set("n", "]d", action("editor.action.marker.next"), { desc = "Next Diagnostic" })
vim.keymap.set("n", "[d", action("editor.action.marker.prev"), { desc = "Previous Diagnostic" })
vim.keymap.set("n", "<leader>xx", action("workbench.actions.view.problems"), { desc = "Diagnostics" })
vim.keymap.set("n", "<leader>xl", action("workbench.actions.view.problems"), { desc = "Diagnostics List" })

vim.keymap.set("n", "<leader>wh", action("workbench.action.navigateLeft"), { desc = "Window Left" })
vim.keymap.set("n", "<leader>wj", action("workbench.action.navigateDown"), { desc = "Window Down" })
vim.keymap.set("n", "<leader>wk", action("workbench.action.navigateUp"), { desc = "Window Up" })
vim.keymap.set("n", "<leader>wl", action("workbench.action.navigateRight"), { desc = "Window Right" })
vim.keymap.set("n", "<leader>wv", action("workbench.action.splitEditorRight"), { desc = "Split Right" })
vim.keymap.set("n", "<leader>ws", action("workbench.action.splitEditorDown"), { desc = "Split Down" })

-- --- Utilities and Flash ---
vim.keymap.set("n", "<leader>cp", action("copyFilePath"), { desc = "Copy Absolute Path" })
vim.keymap.set("n", "<leader>cn", action("copyRelativeFilePath"), { desc = "Copy Relative Path" })
vim.keymap.set("n", "<leader>uz", action("workbench.action.toggleZenMode"), { desc = "Zen Mode" })
vim.keymap.set("n", "<leader>uw", action("editor.action.toggleWordWrap"), { desc = "Word Wrap" })

if has_flash then
  vim.keymap.set({ "n", "x", "o" }, "s", flash_action("jump"), { desc = "Flash" })
  vim.keymap.set({ "n", "x", "o" }, "S", flash_action("treesitter"), { desc = "Flash Treesitter" })
  vim.keymap.set("o", "r", flash_action("remote"), { desc = "Remote Flash" })
  vim.keymap.set({ "o", "x" }, "R", flash_action("treesitter_search"), { desc = "Treesitter Search" })
end

return M
