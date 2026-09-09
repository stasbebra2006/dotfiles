# nvim-own: upstream notes

[Project guide](nvim-own.md) · [Directions](nvim-own-roadmap.md) ·
[Decisions](nvim-own-decisions.md)

These notes preserve useful upstream findings until a related need appears.
They are evidence to revisit, not an implementation plan or a choice between
only two configurations.

## How to use the references

- Check native Neovim first when it may already provide the behavior.
- Use Kickstart for a readable, complete example of the mechanism.
- Use LazyVim for integration, lifecycle, and UX edge cases.
- Use current plugin documentation as the authority for plugin APIs.
- Recheck the relevant source before implementing; snapshots age.

## Reference roles

**Kickstart.nvim** optimizes for teaching: explicit sections and execution
order, public APIs, `:help` pointers, and complete examples before abstraction.
Its current use of `vim.pack` is not a reason to replace our lazy.nvim setup.

**LazyVim** optimizes for an integrated editor: coherent namespaces,
lazy-loading and spec composition, buffer lifecycle, capability checks,
root-versus-cwd behavior, fallbacks, and opt-in alternatives. Borrow the
lessons, not its framework or internal helpers.

Features overlap. The useful difference is emphasis, not ownership.

## Topic notes

### Keymaps and which-key

- Kickstart's compact groups include `<leader>s` Search, `<leader>t` Toggle,
  `<leader>h` Git Hunk, and bare `gr` LSP Actions.
- LazyVim's broader domains include buffers (`b`), code (`c`), files (`f`),
  Git/hunks (`g`/`gh`), search (`s`), UI/toggles (`u`), windows (`w`), and
  diagnostics/quickfix (`x`).
- Before adding mappings, inspect effective native and plugin mappings; require
  `desc`, and keep server-dependent mappings buffer-local when appropriate.
- Local decision: use incremental-hybrid groups; see D-001 in the decision log.

### Native options and autocommands

- Kickstart demonstrates a small explicit baseline, split navigation,
  diagnostic navigation, and `TextYankPost` highlighting.
- LazyVim shows broader policies such as persistent undo, search behavior,
  split placement, `checktime`, last-position restore, and filetype-local rules.
- When relevant, compare global versus local scope, default behavior, event
  timing, and whether the convenience has surprising side effects.

### Plugin lifecycle

- Kickstart currently makes installation and build hooks visible with
  `vim.pack.add`, `PackChanged`, and direct `setup()` calls.
- LazyVim uses lazy.nvim `event`, `cmd`, `keys`, and `ft` triggers, dependencies,
  composed specs, and guarded integration.
- Keep our explicit lazy.nvim specs. Add lazy loading only when its ownership and
  timing remain clear or it solves a measured startup/lifecycle problem.

### LSP and external tools

- Kickstart demonstrates `LspAttach`, native `vim.lsp.config()`/`enable()`,
  Mason installation helpers, and capability-dependent behavior.
- LazyVim demonstrates per-server composition, buffer-local mappings, root
  handling, capability integration, and picker/formatting interactions.
- Our baseline is direct Pyright plus Mason. Before extending it, distinguish
  Neovim defaults, client behavior, server settings, executable installation,
  workspace root, and Python interpreter selection.

### Tree-sitter

- Kickstart's inspected version uses the newer nvim-treesitter `main` API,
  parser installation, `FileType` attachment, highlighting, and optional
  indentation.
- LazyVim treats Tree-sitter as an integrated core layer with language and
  feature extensions.
- Recheck current APIs and version requirements. Evaluate parser ownership,
  highlighting, indentation, text objects, and failure fallback separately.

### Search, pickers, and explorers

- Kickstart uses Telescope for help, files, grep, buffers, diagnostics, and LSP
  results; neo-tree remains an optional example.
- LazyVim exposes root-versus-cwd actions and supports picker/explorer
  alternatives through its core and extras.
- When current netrw and native search become limiting, compare task coverage,
  root semantics, dependencies, preview/layout, and mapping cost.

### Completion, formatting, and linting

- Kickstart demonstrates Blink with LuaSnip and Conform with explicit manual or
  save-time formatting choices.
- LazyVim demonstrates engine alternatives and coordination among completion,
  LSP capabilities, formatters, linters, Mason, and project settings.
- Decide each concern separately: source/engine, insert-mode behavior, external
  tool ownership, manual versus automatic invocation, and visible failures.

### Git and UI

- Kickstart provides direct gitsigns hunk actions plus small examples for
  statusline, colorscheme, comments, and mini.nvim modules.
- LazyVim demonstrates nested Git namespaces and coordinated buffers,
  notifications, diagnostics, statusline, explorer, and session behavior.
- Add only behavior that solves a real workflow; avoid importing a UI stack as
  a baseline.

### Reproducibility

- Kickstart recommends tracking its `nvim-pack-lock.json` even though its own
  template ignores it for upstream maintenance.
- Our live `lazy-lock.json`, Mason packages, and selected nightly binary are
  separate version/install concerns. None is automatically reproduced merely
  because the Lua configuration is managed.

## Source snapshots

- Kickstart.nvim `f7b845d` (2026-09-06):
  [repository](https://github.com/nvim-lua/kickstart.nvim),
  [`init.lua`](https://github.com/nvim-lua/kickstart.nvim/blob/f7b845d8b6df409b0392ca117d092d5dffd2b538/init.lua).
- LazyVim 16.0.1, `9997009` (2026-09-08):
  [repository](https://github.com/LazyVim/LazyVim),
  [keymaps](https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/config/keymaps.lua),
  [plugin groups](https://github.com/LazyVim/LazyVim/blob/999700997f72227187d49d8b92667183dc7fc809/lua/lazyvim/plugins/editor.lua).
