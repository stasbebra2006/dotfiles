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
| `config.options` | Enable line numbers and define which workspace state sessions save. |
| `config.diagnostics` | Show underlines, severity-sorted signs, and virtual lines; defer updates during insert mode. |
| `config.keymaps` | Map file navigation, buffer operations, session controls, and explicit Python formatting. |
| `config.lazy` | Bootstrap lazy.nvim and load the explicit plugin index. |
| `languages` | Validate active language containers and build a deterministic server registry. |
| `languages.python` | Declare Pyright for type analysis and Ruff for linting, formatting, and import actions. |
| `plugins.blink` | Provide insert-mode completion from LSP, file paths, and buffer words. |
| `plugins.snacks` | Provide the persistent file sidebar, startup dashboard, and search pickers. |
| `plugins.bufferline` | Display file buffers as tabs and close them without disrupting splits. |
| `plugins.persistence` | Save file workspaces on exit and restore them only when requested. |
| `plugins.treesitter` | Install the pinned Python grammar and enable native Tree-sitter highlighting. |
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
Blink is an LSP dependency, so its built-in Neovim 0.11+ capability registration
runs before the connector enables servers.

The Python container declares Pyright and Ruff, retaining `nvim-lspconfig`'s
maintained commands, filetypes, and root markers. Local overrides disable
Pyright's organize-imports action and Ruff's hover, so Ruff owns import actions
and Pyright owns hover. Pyright's type analysis remains enabled.

On a fresh profile, Mason installation is asynchronous. Opening a Python file
before the first installation finishes may require reopening the file or
restarting Neovim once. Later starts are unaffected.

## Completion

`plugins/blink.lua` pins `blink.cmp` to release `v1.10.2`, using its prebuilt
Rust fuzzy matcher. No local Rust build, LuaSnip, or snippet collection is needed.

The popup opens automatically while typing. Sources are LSP suggestions, file
paths, and buffer words. Navigation does not insert a preview, and nothing is
preselected: Enter accepts only an explicitly selected item.

| Key | Action |
| --- | --- |
| `Ctrl-Space` | Open completion; with the menu open, show or hide selected-item documentation. |
| `Ctrl-n` / `Ctrl-p` | Select the next / previous suggestion. |
| `Enter` | Accept the selected suggestion; otherwise insert a normal newline. |
| `Ctrl-e` | Close the popup. |
| `Tab` | Keep native indentation; not a completion or snippet mapping. |

Command-line completion stays native. Ghost text is not enabled.

## Files, search, and buffer tabs

`plugins/snacks.lua` pins Snacks to `v2.31.0` and enables its explorer, picker,
and dashboard. `plugins/bufferline.lua` pins Bufferline to `v4.9.1`.
The shared icon dependency is `nvim-web-devicons` at `v0.100`.

Start `nvim-own` without a file to see the dashboard. Its keys are `f` for files,
`g` for text search, `r` for recent files, `n` for a new file, `s` to restore the
current project's session, and `q` to quit.
File and text actions reuse the normal mappings rather than a separate picker
configuration.

Open Neovim from the project directory, or change it with `:cd`: the sidebar,
file search, and project-text search explicitly use the current working
directory. File finding uses the installed search tools; text search uses
`ripgrep`. The explorer replaces netrw, including when opening a directory.

| Key | Action |
| --- | --- |
| `Space e` | File sidebar. |
| `Space f f` | Fuzzy-find files in the working directory. |
| `Space f g` | Search text in the working directory. |
| `Shift-h` / `Shift-l` | Previous / next buffer from the editor. |
| `Space b d` | Close the current buffer, preserving the window layout. |

In the sidebar, Enter or `l` opens a file or expands a directory; `h` collapses
a directory. The sidebar stays visible when opening files.

The top strip represents file buffers, not Neovim tabpages. Closing a tab or
using `Space b d` prompts before discarding unsaved edits. Which-key names the
`Space f` and `Space b` groups as find and buffers.

## Sessions

`plugins/persistence.lua` pins `folke/persistence.nvim` to `v3.1.0`, matching
LazyVim's session mechanism. Opening a real file activates automatic saving on
exit. An empty dashboard does not overwrite a saved workspace.

Sessions live under `~/.local/state/nvim-own/sessions/`, separate from LazyVim.
They are keyed by the working directory and are branch-aware at Git project
roots. Launch from the project directory to restore that project's workspace.

Restore is manual: use dashboard `s` or the mappings below. There is no
startup autorestore. Session contents follow the LazyVim option policy: file
buffers, working directory, tabpages, window sizes, help, globals, and folds,
without replaying configuration options or plugin mappings.

| Key | Action |
| --- | --- |
| `Space q s` | Restore the current directory's session. |
| `Space q S` | Choose a saved session. |
| `Space q l` | Restore the most recently saved session. |
| `Space q d` | Stop saving for this Neovim process; do not replace the session on exit. |

Which-key labels `Space q` as sessions. Sessions restore the workspace, not
unsaved file contents: save your changes before exiting.

## Python highlighting, linting, and formatting

`plugins/treesitter.lua` pins nvim-treesitter's maintained `main` API to commit
`e289100ff98969e118c702199d88b764ce9e7fdf`. The plugin is eager-loaded; its build
installs or refreshes the matching Python parser and queries under
`~/.local/share/nvim-own/site/`. A Python `FileType` autocmd starts Neovim's
native Tree-sitter highlighter. This does not enable Tree-sitter indentation
or change editing options.

Building the parser requires a C compiler, `curl`, `tar`, and tree-sitter CLI
0.26.1 or newer. This workstation has CLI 0.26.9. The plugin requires Neovim
0.12 or newer; the separate `nvim-own` nightly already meets that requirement.

Mason provisions the native `ruff` server alongside Pyright. Ruff 0.16.10
was installed for this setup. Ruff reports lint diagnostics automatically
while Pyright continues handling types, completion, and navigation. Ruff
uses its normal project/global configuration discovery; no local rule set
or formatter style is forced here.

| Key | Action |
| --- | --- |
| `Space c f` | Format the current Python buffer using Ruff, leaving changes unsaved. |

Which-key labels `Space c` as code. Formatting is manual: no format-on-save,
automatic lint fixes, or automatic import organization. Ruff formatting is
selected explicitly rather than asking every attached LSP to format.
