# nvim-own

A personal Neovim configuration built one understood piece at a time. Use LazyVim
as a reference and keep normal `nvim` available as the fallback; this profile does
not import its configuration framework.

## How we work

- Explain the immediate problem and exact proposed code before implementing a new
  learning step. Introduce one unfamiliar mechanism at a time, then observe it work.
- Prefer direct Lua, explicit plugin registration, and visible `setup()` calls.
- Use normal Neovim to edit the config and `nvim-own` to test it separately.
- Preserve user-owned buffers and tmux windows. Refresh externally edited files
  only when doing so will not discard unsaved work.
- Keep authored changes in chezmoi source. Applying, committing, and pushing are
  separate actions, performed when requested.
- When a real need exposes a topic, consult the relevant notes and current
  sources, compare meaningful options and tradeoffs, recommend one, then choose
  the implementation together before editing.

## Working references

- [Upstream notes](nvim-own-notes.md): reusable Kickstart and LazyVim findings.
- [Directions](nvim-own-roadmap.md): possible areas, without commitment or order.
- [Decisions](nvim-own-decisions.md): accepted choices and their rationale.

## Profile and files

The [wrapper](../dot_local/bin/executable_nvim-own) sets `NVIM_APPNAME=nvim-own`
and runs `~/.local/opt/nvim-unstable`, forwarding its arguments. It isolates the
config, data, state, and cache directories and selects the nightly core.

As of 2026-09-08, that local symlink selects `0.13.0-dev-1558+g8d5ebdf986`,
installed from the official nightly archive into
`~/.local/opt/nvim-0.13-nightly-8d5ebdf986/`. The archive checksum was verified.
This installation is updated manually, outside pacman; another machine needs
its own nightly installation and symlink. The previous nightly directory is
retained for rollback. Normal `nvim` still runs pacman's stable 0.12.5.
See [the diagnostic comparison](nvim-own-diagnostics.md) for the reason.

| Purpose | Location |
| --- | --- |
| Authored source | `dot_config/nvim-own/` in this repository |
| Live configuration | `~/.config/nvim-own/` |
| Downloaded plugins and Mason tools | `~/.local/share/nvim-own/` |
| Generated state and cache | `~/.local/state/nvim-own/`, `~/.cache/nvim-own/` |

Source and live authored files matched when checked on 2026-09-08. The live
`lazy-lock.json` exists but is not managed in source. `docs/` is repository-only
and excluded from chezmoi deployment.

## Startup and current behavior

[init.lua](../dot_config/nvim-own/init.lua) sets Space as the leader, then loads:

| Module | Responsibility |
| --- | --- |
| `config.options` | Enable line numbers. |
| `config.diagnostics` | Underlines, severity-sorted signs, virtual lines instead of virtual text; defer display updates during insert mode. |
| `config.keymaps` | Map `Space e` to netrw's `:Explore`, the temporary explorer. |
| `config.lazy` | Bootstrap lazy.nvim, add it to the runtime path, and load the explicit plugin index. |
| `config.lsp` | Configure and enable native Pyright support for Python buffers, using `.git` as a root marker. |

[lua/plugins/init.lua](../dot_config/nvim-own/lua/plugins/init.lua) lists only
which-key (`helix` preset) and Mason, each with its own explicit setup callback.
Mason initializes before the LSP configuration so its executable directory is on
Neovim's `PATH`. Mason installs tools; Neovim's LSP client starts and talks to them.
The Pyright command is `pyright-langserver --stdio`; no custom interpreter
selection or server settings have been added.

Lua `require()` loads a module and returns its value. Here, each plugin module
returns one specification table, and the index collects those tables for
`lazy.setup()`. lazy.nvim is the plugin manager; LazyVim is a separate distribution.

## Open decisions

- Decide whether to track `lazy-lock.json` for reproducible plugin revisions.
- Revisit a `:checktime` autocmd only when disk-refresh behavior becomes relevant;
  it was deliberately deferred after the lifecycle investigation.

Possible future areas live in the [directions](nvim-own-roadmap.md). They are
context to use when a need appears, not a preselected next feature.
