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
native behavior and the local colorscheme, then starts the explicit plugin graph:

| Module | Responsibility |
| --- | --- |
| `config.options` | Enable line numbers, hide end-of-buffer (`~`) markers, share one global statusline across splits, and define which workspace state sessions save. |
| `config.diagnostics` | Show underlines, severity-sorted signs, and virtual lines; defer updates during insert mode. |
| `config.keymaps` | Map window/file navigation, Flash jumps, buffer operations, session controls, colorscheme selection, language formatting, and buffer-local notebook controls. |
| `config.lazy` | Bootstrap lazy.nvim and load the explicit plugin index. |
| `config.notebooks` | Resolve the current `# %%` code cell and send its range to Molten. |
| `languages` | Validate active language containers and build a deterministic server registry. |
| `languages.python` | Declare Pyright for type analysis and Ruff for linting, formatting, and import actions. |
| `languages.c_cpp` | Declare the shared clangd server for C/C++ completion, diagnostics, navigation, and formatting. |
| `plugins.colorscheme` | Install and configure optional Tokyo Night and Catppuccin themes. |
| `plugins.blink` | Provide insert-mode completion from LSP, file paths, and buffer words. |
| `plugins.flash` | Provide labeled jumps, remote operators, and Tree-sitter selections. |
| `plugins.snacks` | Provide the persistent file sidebar, startup dashboard, search pickers, and notebook image placements. |
| `plugins.bufferline` | Display file buffers as tabs and close them without disrupting splits. |
| `plugins.lualine` | Render the global statusline with colors derived from the active theme. |
| `plugins.noice` | Render centered command popups and messages without reserving a bottom command row. |
| `plugins.persistence` | Save file workspaces on exit and restore them only when requested. |
| `plugins.treesitter` | Install the pinned Python, C, and C++ grammars and enable native Tree-sitter highlighting. |
| `plugins.lsp` | Provision declared servers through Mason, then invoke the runtime connector. |
| `config.lsp` | Configure and explicitly enable every declared server. |
| `plugins.jupytext` | Open Python notebooks as Hydrogen-style text and update notebook inputs on write. |
| `plugins.molten` | Run cells through Jupyter kernels, import saved outputs, and provide bounded previews and focusable output windows. |

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

## Colorschemes

`mocha-custom` is the startup default, selected in `init.lua` before plugins load.
Its native `colors/mocha-custom.lua` entry preserves the LazyVim profile's
`previous-custom` palette and highlight overrides: Neovim's default dark UI
with custom Catppuccin-style syntax colors. It also restores the dark background
when switching back from a light theme. The LazyVim profile is unchanged.

`plugins/colorscheme.lua` pins Tokyo Night to `v4.14.1` and Catppuccin to
`v2.0.0`. Both load on selection; Catppuccin detects installed plugins for its
integrations. The custom theme itself needs neither plugin.

Press `Space u C` (uppercase `C`) to open Snacks' colorscheme picker, matching
LazyVim's mapping. Type to filter and use the arrow keys to browse live previews.
Enter keeps the selected theme for this Neovim process. Escape leaves insert
mode; Escape again closes the picker and restores the previous theme.

Available plugin variants include `tokyonight-moon`, `tokyonight-night`,
`tokyonight-storm`, `tokyonight-day`, `catppuccin-mocha`,
`catppuccin-macchiato`, `catppuccin-frappe`, and `catppuccin-latte`.
The local `mocha-custom` theme and built-in Neovim themes also appear.
Catppuccin v2 calls its automatic-flavour
entry `catppuccin-nvim`; plain `catppuccin` is Neovim's bundled theme.

Picker selections are not saved across restarts. To change the startup default,
edit the `vim.cmd.colorscheme(...)` call in `init.lua`.
No separate theme-switching plugin or state file is used.

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

Command-line completion stays Neovim-native; Noice renders its UI, not Blink.
Ghost text is not enabled.

## Statusline

`plugins/lualine.lua` pins Lualine to commit
`221ce6b2d999187044529f49da6554a92f740a96` and loads it on `VeryLazy`.
Its standard sections show mode, Git branch and diff, diagnostics, filename,
encoding, file format/type, progress, and cursor position.

`config/options.lua` sets `laststatus = 3`; Lualine also enables `globalstatus`.
There is one statusline across the editor, not a separate bar for the Snacks
sidebar or each split. It reflects the focused window and is disabled on the
Snacks dashboard. Bufferline's top file tabs remain separate.

`theme = "auto"` derives the statusline colors from the active colorscheme,
including `mocha-custom`, and updates them when the colorscheme picker changes it.

## Command line and messages

`plugins/noice.lua` pins Noice to `v4.10.0`, with NUI `0.4.0` for rendering,
and loads it on `VeryLazy`. Press `:` for a centered command popup. Enter
executes the command, Escape cancels, and Tab uses native command completion.
The `bottom_search` preset keeps `/` and `?` search input at the bottom.

Noice handles messages as well as command input. Its UI attachment sets
`cmdheight` to zero, so the global statusline reaches the bottom edge without
an idle command row. Messages and errors remain visible in compact notifications;
`:Noice` opens message history and `:Noice errors` opens recorded errors.
The notification view falls back to Noice's built-in mini view; no separate
notification plugin is required.

This configuration does not replace native LSP hover, signature help, progress,
server messages, or `vim.notify`. Do not separately force `cmdheight = 0` in
native options: Noice owns the command/message UI.

## Flash navigation

`plugins/flash.lua` pins `folke/flash.nvim` to commit
`5f0f270fdc7c5b0c21d903ee85b9cb06f2ac636a` and loads it on `VeryLazy`.
This maintained revision supports Neovim 0.13's internal search state; the
`v2.1.0` release accesses removed symbols and fails on this profile's nightly.
Mappings remain in `config/keymaps.lua`.

| Key | Modes | Action |
| --- | --- | --- |
| `s` | Normal, visual, operator-pending | Jump to a labeled search match. |
| `S` | Normal, visual, operator-pending | Select a labeled Tree-sitter node. |
| `r` | Operator-pending | Perform an operator at a remote location, then return. |
| `R` | Visual, operator-pending | Search and select a Tree-sitter node. |

Press `s`, type a few characters, then press the displayed target label.
Escape cancels without moving the cursor. `S` and `R` require a parser for the
current language; Python, C, and C++ have parsers. In normal mode, `s` and `S`
replace the native substitute commands.

For a remote yank, press `yr`, search and choose a label, then use `iw` at the
target. Flash copies that word and restores the original cursor position.
Normal-mode `r` remains the native replace-character command.

Flash's default enhanced `f`/`t`/`F`/`T` motions and `;`/`,` repeats are enabled.
Its regular `/`/`?` search integration remains disabled. No `Ctrl-s` toggle is
mapped: that key stays reserved for the tmux prefix.

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
| `Ctrl-h` | Move to the left window (normal mode). |
| `Ctrl-j` | Move to the lower window (normal mode). |
| `Ctrl-k` | Move to the upper window (normal mode). |
| `Ctrl-l` | Move to the right window (normal mode). |
| `Shift-h` / `Shift-l` | Previous / next buffer from the editor. |
| `Space b d` | Close the current buffer, preserving the window layout. |

In the sidebar, Enter or `l` opens a file or expands a directory; `h` collapses
a directory. The sidebar stays visible when opening files.

`Ctrl-h/j/k/l` navigates Neovim windows, including the sidebar, not buffer tabs
or tmux panes. The explorer relinquishes its normal-mode `Ctrl-j/k` list
bindings so the global window mappings can run. Its filter keeps `Ctrl-j/k`
list movement in insert mode; other pickers retain their normal list controls.

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
installs or refreshes the matching Python, C, and C++ parsers and queries under
`~/.local/share/nvim-own/site/`. Their `FileType` autocmd starts Neovim's native
Tree-sitter highlighter. This does not enable Tree-sitter indentation or change
editing options.

Building the parsers requires a C compiler, `curl`, `tar`, and tree-sitter CLI
0.26.1 or newer. This Mac has CLI 0.27.0. The plugin requires Neovim 0.12 or
newer; the separate `nvim-own` nightly already meets that requirement.

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

## C and C++

`languages/c_cpp.lua` declares one `clangd` server for both `c` and `cpp`
buffers, including headers detected as either filetype. A shared language
container avoids declaring the same server twice in the registry.
The existing Mason setup provisions clangd inside `nvim-own`; this setup
installed clangd 23.1.0. Mason exposes its binary to Neovim without replacing
the system compiler.

`--background-index` enables project-wide navigation and completion.
`--clang-tidy` enables static-analysis checks. Clangd discovers project
`.clangd`, `.clang-tidy`, and `.clang-format` configuration; this profile does
not impose a global formatting style or language standard.

On this Mac, Apple Command Line Tools already provide Clang/Clang++ 21.0.0
and Make. CMake 4.4.4 and standalone clang-format 23.1.2 were installed with
Homebrew. The editor uses clangd's built-in clang-format engine, not another
formatting plugin.

| Key or command | Action |
| --- | --- |
| `Space c f` | Format the current C/C++ buffer with clangd, leaving changes unsaved. |
| `K` | Show native LSP hover information. |
| `Ctrl-]` | Jump to a definition through native LSP tag navigation. |
| `:LspClangdSwitchSourceHeader` | Open the matching source or header. |

Formatting remains manual; there is no format-on-save. Python continues using
Ruff through the same `Space c f` mapping. C/C++ Tree-sitter highlighting and
Flash's `S` selection use the newly installed `c` and `cpp` parsers.

### Project compilation flags

Clangd needs the project's include paths, defines, and language-standard flags
for accurate analysis. For a CMake project without an existing root
`compile_commands.json`, generate and expose its compilation database:

```sh
cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
ln -s build/compile_commands.json compile_commands.json
cmake --build build
```

Keep source paths consistent when generating the database, particularly when
working through directory symlinks. Set C and C++ standards independently in
the project's build configuration; do not apply a global C++ flag to C files.
The smoke project used C17 and C++20, built both executables, and exercised
standard headers, cross-file navigation, completion, diagnostics, and formatting
in an isolated `nvim-own` TUI.

## Notebook experiment — paused

The Molten/Jupytext setup is applied, but **not a completed notebook round-trip
workflow**. Cell execution, saved-output import, DataFrame completion, and table
scrolling were exercised on copies of the BI-ML1 notebooks. Exporting freshly
executed outputs failed inside Molten with
`TypeError: new_output() got multiple values for argument 'output_type'`.
The failed `Space j w` binding was removed; do not rely on `MoltenExportOutput`
until the imported-error-output case is fixed and verified.

[Checkpoint and exact removal instructions](checkpoint-2026-10-05.md) record the
installed dependencies, reproducer, original-file hashes, and resume point.
The normal LazyVim profile and original coursework notebooks were not edited.

### Installed pieces and environment

- `plugins/jupytext.lua` pins `GCBallesteros/jupytext.nvim` to
  `c8baf3ad344c59b3abd461ecc17fc16ec44d0f7b`; the Jupytext CLI is installed through
  `uv tool`. Hydrogen keeps `# %%` boundaries and IPython `%magics` intact.
  Ordinary percent mode commented the magics and prevented later saved plots
  from matching Molten's importer.
- `plugins/molten.lua` pins upstream Molten to
  `bedea63819c618e007e7c40059fc6e72d598c8df`, including its Snacks image provider.
  No pyworks, Iron, Quarto, image.nvim, or author-specific forks were installed.
- Neovim's Python host is isolated at
  `stdpath("data") .. "/notebook-venv/bin/python"`. It requires `pynvim`,
  `jupyter-client`, `nbformat`, and `pillow`; `init.lua` selects it before
  lazy.nvim can run remote-plugin discovery. After installing the host packages,
  `:UpdateRemotePlugins` registers Molten. This host is not the project kernel.
- On this Mac, the existing Conda `bi-ml1` environment supplies the actual
  notebook packages. Its Python was registered as Jupyter kernel `bi-ml1`.
  Activate the environment before starting Neovim so Pyright also sees its
  packages; choosing a Molten kernel alone does not change Pyright's interpreter.
- Snacks image support uses ImageMagick and the terminal's Kitty graphics
  protocol. The tmux configuration enables `allow-passthrough on`.
  Plot execution and image placement were exercised, but macOS screen capture
  failed, so the final Ghostty pixels were not inspected.

### Trying the verified execution workflow

Start on a copy of a notebook, with its CSV/image assets in the same directory.
Launch from that directory: the kernel's working directory comes from the
Python host at startup, not automatically from the notebook's path.
The BI-ML1 template's unfinished `...` cells are intentional; do not run all cells
or fill the coursework solutions just to test this configuration.

The Python-buffer mappings are:

| Key | Action |
| --- | --- |
| `]j`, `[j` | Next/previous `# %%` cell boundary, including Markdown cells. |
| `Space j i` | Select a kernel; for this coursework choose `bi-ml1`. Saved notebook outputs import after selection, without executing their source. |
| `Space j r` | Run the current code cell; in visual mode, run the selection. |
| `Space j l` | Run the current line. |
| `Space j o` | Open and focus the current cell's output window. |
| `Space j h` | Hide the output window from the code buffer. |
| `Space j p` | Re-import saved notebook outputs. |
| `Space j x` | Interrupt the kernel. |
| `Space j k` | Restart the kernel, keeping displayed outputs; variables must be recreated. |
| `Space j I` | Show kernel information. |

Output previews are limited to three lines. Large results and plots belong in
the manually focused output window, not a shared REPL transcript or permanent
right sidebar. In that window, use `gg`, `G`, `Ctrl-d`, and `Ctrl-u` vertically;
use `zL`/`zH` on a populated table row horizontally. Wrapping is disabled to keep
columns aligned. `:q` closes just the output window and returns to code.

Pandas can omit data before Molten receives it. For a complete text table, use
an explicit display such as `print(df.head(80).to_string(index=False))`;
scrolling cannot recover rows/columns already replaced with `...`.

`:w` updates notebook inputs through Jupytext and preserved existing output
payloads and execution counts in the tested copies. **It does not save the
fresh Molten results.** Jupytext may use an existing sibling `.py` file instead
of reconverting the `.ipynb`, so do not leave an unrelated or stale companion.
Pyright can still flag notebook-only syntax/builtins such as `%matplotlib`
and `display`; kernel execution is separate from those static diagnostics.
