# nvim-own

A personal Neovim configuration built one understood piece at a time. It treats
LazyVim and Kickstart as references without importing either configuration. The
existing LazyVim-based `nvim` profile remains available as a fallback.

## Design goal

Build a capable configuration without hiding behavior behind a framework.
Features grow through small modules with explicit roles: language modules
declare requirements, registries combine declarations, and connector modules
install or activate them. The path from declaration to observable effect should
remain short.

Do not pre-create layers. Add or extend one only when a real feature needs it,
and keep one source of truth for each behavior.

## How we work

- Before implementing a learning step, explain the immediate problem and exact
  proposed code. Introduce one unfamiliar mechanism at a time, trace its
  execution, then observe it work.
- Explain what expression runs, what kind of value or table-like interface it
  touches, where data goes, which code reacts, and when the effect occurs.
  Introduce architectural labels only after that path is clear.
- Study one file at a time. Answer questions about the current file without
  unsolicited recaps, and move only when the user explicitly says to.
- Prefer direct Lua, explicit plugin registration, and visible `setup()` calls.
- Use normal Neovim to edit the config and `nvim-own` to test it. Preserve
  user-owned buffers and tmux windows; never refresh a file at the cost of
  unsaved work.
- Keep authored changes in chezmoi source. Applying, committing, and pushing are
  separate actions, performed only when requested.
- When a real need exposes a topic, consult the relevant notes and current
  sources, compare meaningful options, and agree on the implementation before
  editing.

## Working references

- [Upstream notes](notes.md): revision-scoped Kickstart and LazyVim findings.
- [Directions](roadmap.md): possible work, without commitment or order.
- [Decisions](decisions.md): accepted choices and their rationale.
- [Diagnostic history](diagnostics.md): the investigation that motivated the
  nightly core.
- [Troubleshooting](troubleshooting.md): verified version-sensitive commands
  and operational gotchas.

## Profiles and files

The [wrapper](../../dot_local/bin/executable_nvim-own) sets
`NVIM_APPNAME=nvim-own` and runs `~/.local/opt/nvim-unstable`, forwarding all
arguments. This isolates the config, data, state, and cache directories.

Verified on 2026-09-11, the symlink selects
`0.13.0-dev-1558+g8d5ebdf986`, installed from the official nightly archive at
`~/.local/opt/nvim-0.13-nightly-8d5ebdf986/`. Its checksum was verified during
installation. The installation is managed manually outside pacman; another
machine needs its own binary and symlink. The previous nightly remains available
for rollback. Normal `nvim` runs pacman's stable 0.12.5.

| Purpose | Location |
| --- | --- |
| Authored source | `dot_config/nvim-own/` in this repository |
| Live configuration | `~/.config/nvim-own/` |
| Downloaded plugins and Mason tools | `~/.local/share/nvim-own/` |
| Generated state and cache | `~/.local/state/nvim-own/`, `~/.cache/nvim-own/` |

Source and live authored files matched when checked on 2026-09-11. The live
`lazy-lock.json` is not managed in source. `docs/nvim-own/` is repository-only
and excluded from chezmoi deployment.

When normal `nvim` edits this source tree, the source-only `.luarc.json` makes
LuaLS use `dot_config/nvim-own/` as its workspace root and resolve modules
through that directory's `lua/` tree. Chezmoi does not deploy this literal
hidden source file.

For comparison, the managed Kickstart snapshot at
`dot_config/nvim-kickstart/` deploys to `~/.config/nvim-kickstart/`. Its
[launcher](../../dot_local/bin/executable_nvim-kickstart) sets
`NVIM_APPNAME=nvim-kickstart` and runs system Neovim, isolated from the other
profiles.

## Startup and current behavior

[init.lua](../../dot_config/nvim-own/init.lua) sets Space as the leader, loads
native behavior, then starts the explicit plugin graph:

| Module | Responsibility |
| --- | --- |
| `config.options` | Enable line numbers. |
| `config.diagnostics` | Show underlines, severity-sorted signs, and virtual lines; defer updates during insert mode. |
| `config.keymaps` | Map `Space e` to netrw's `:Explore`. |
| `config.lazy` | Bootstrap lazy.nvim and load the explicit plugin index. |
| `languages` | Validate active language containers and build a deterministic server registry. |
| `languages.python` | Declare Pyright as Python's configured server. |
| `plugins.lsp` | Provision declared servers through Mason, then invoke the runtime connector. |
| `config.lsp` | Configure and explicitly enable every declared server. |

The table describes ownership, not one flat `require()` chain.
[lua/plugins/init.lua](../../dot_config/nvim-own/lua/plugins/init.lua) collects
ordinary plugin specification tables. Returning a specification stores its
`config` callback; lazy.nvim runs that callback after loading the plugin.

When the eager LSP specification loads, `plugins.lsp` reads the validated
language registry, initializes Mason, asks `mason-lspconfig` to install every
declared server, then passes the registry to `config.lsp`. Setting
`automatic_enable = false` leaves activation solely to `config.lsp`.

The Python container declares `pyright = {}`. This empty override deliberately
selects `nvim-lspconfig`'s maintained command, filetypes, root markers, settings,
and buffer commands.

On a fresh profile, Mason installation is asynchronous. Opening a Python file
before the first installation finishes may require reopening the file or
restarting Neovim once. Later starts are unaffected.
