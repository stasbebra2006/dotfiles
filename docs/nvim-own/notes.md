# nvim-own: upstream notes

[Project guide](README.md) · [Directions](roadmap.md) ·
[Decisions](decisions.md)

These findings refer to the recorded upstream revisions below unless dated
otherwise. Preserve them as evidence to revisit, not as an implementation plan
or a forced choice between two configurations.

## Local comparison set

| Role | Path |
| --- | --- |
| Authored `nvim-own` | `~/.local/share/chezmoi/dot_config/nvim-own/` |
| Authored normal LazyVim config | `~/.local/share/chezmoi/dot_config/nvim/` |
| Deployed normal config | `~/.config/nvim/` |
| Installed LazyVim framework | `~/.local/share/nvim/lazy/LazyVim/` |
| Authored Kickstart profile | `~/.local/share/chezmoi/dot_config/nvim-kickstart/` |
| Deployed Kickstart profile | `~/.config/nvim-kickstart/` |

During ordinary work, use local `:help` and the three authored profiles. The
normal config's lockfile identifies the LazyVim revision whose disposable
installed checkout supplies inherited behavior. Deployed directories are
runtime state, not editing surfaces. The Kickstart profile is a managed source
snapshot, never a Git repository or runtime dependency. Refresh upstream code
only deliberately, then replace the reviewed snapshot and record its full
revision.

## Reference roles

**Kickstart.nvim** optimizes for teaching: explicit sections and execution
order, public APIs, `:help` pointers, and complete examples before abstraction.
The recorded Kickstart snapshot uses `vim.pack`; that is not a reason to replace
our lazy.nvim setup.

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

- The recorded Kickstart snapshot makes installation and build hooks visible
  with `vim.pack.add`, `PackChanged`, and direct `setup()` calls.
- LazyVim uses lazy.nvim `event`, `cmd`, `keys`, and `ft` triggers, dependencies,
  composed specs, and guarded integration.
- Keep our explicit lazy.nvim specs. Add lazy loading only when its ownership and
  timing remain clear or it solves a measured startup/lifecycle problem.

### LSP and external tools

- Kickstart demonstrates `LspAttach`, native `vim.lsp.config()`/`enable()`,
  Mason installation helpers, and capability-dependent behavior.
- LazyVim demonstrates per-server composition, buffer-local mappings, root
  handling, capability integration, and picker/formatting interactions.
- When extending `nvim-own`, distinguish Neovim defaults, client behavior,
  server settings, executable installation, workspace root, and Python
  interpreter selection.

### Tree-sitter

- The recorded Kickstart revision uses the newer API from nvim-treesitter's
  `main` branch for parser installation, `FileType` attachment, highlighting,
  and optional indentation.
- LazyVim treats Tree-sitter as an integrated core layer with language and
  feature extensions.
- Recheck current APIs and version requirements. Evaluate parser ownership,
  highlighting, indentation, text objects, and fallback behavior separately.

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

- The recorded Kickstart snapshot recommends tracking `nvim-pack-lock.json`,
  though its upstream template ignores that file for repository maintenance.
- The normal LazyVim-based profile has an authored `lazy-lock.json`; the
  `nvim-own` live lockfile remains unmanaged.
- Plugin lockfiles, Mason package versions, and the selected Neovim binary are
  separate reproducibility concerns.

## Recorded reference revisions

- LazyVim:
  `c10948c50b18fae7f256433afdef09e432410480`; the authored `lazy-lock.json`
  and clean installed checkout matched when verified on 2026-09-09.
- Kickstart.nvim:
  `748f67f49dd9fed47686d1d15e8566d2cba8ed35`; the managed profile was copied
  from a clean checkout of
  [nvim-lua/kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim) on
  2026-09-09.

A recorded revision remains valid historical evidence; do not call it current
without an explicit fetch. Recheck only the relevant reference when a decision
depends on newer behavior.
