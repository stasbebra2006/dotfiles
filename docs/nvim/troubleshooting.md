# nvim: troubleshooting

[Setup and usage](README.md)

## Check the active profile and version

`nvim` uses the selected nightly at `~/.local/opt/nvim-unstable`.
`lazy-nvim` uses the system/Homebrew core and its own configuration and plugins.
Check the actual versions before following version-sensitive commands:

```sh
nvim --version
lazy-nvim --version
```

Inside the affected editor:

```vim
:echo stdpath('config')
:echo stdpath('data')
:help :lsp-restart
:echo exists(':lsp')
:echo exists(':LspRestart')
```

Use the installed version's help and plugin source when examples disagree.

## Profile migration with a scoped apply

The one-time migration moves the former LazyVim `nvim` roots to `lazy-nvim`,
then `nvim-own` to `nvim`, including plugins, state, caches, and saved sessions.
A scoped apply of configuration files alone does not select the migration script.
On a machine still using the old names, review and explicitly apply
`.chezmoiscripts/run_once_before_rename-neovim-profiles.py.tmpl` with
`chezmoi apply --source-path` before applying the profile files. A full
`chezmoi apply` includes the before-script automatically.

Preserve live edits and inspect destination collisions first. After moving the
profiles, review the remaining diff; replacing deliberately moved managed files
may require confirmation. Restart open editors after saving their work.

### Comments or keywords remain uncolored after migration

Tree-sitter needs both a parser and its query files. Its generated query links
can retain absolute paths under the retired profile name after directories move.
The migration hook repairs recognized links to each profile's own plugin and
uses relative targets so later directory moves preserve them. It also repairs
machines whose profile migration has already completed.

Apply the updated hook:

```sh
chezmoi apply --source-path .chezmoiscripts/run_once_before_rename-neovim-profiles.py.tmpl
```

Then restart highlighting in an open code buffer with
`:lua vim.treesitter.stop(); vim.treesitter.start()`.
Use `:checkhealth nvim-treesitter` to confirm the installed languages have valid
highlight queries, and `:Inspect` on a comment to confirm the `@comment` capture.
The parser manifest includes C, C++, Python, and the regex/bash grammars used by
Noice's command UI. Startup provisions newly declared parsers asynchronously;
the build callback refreshes existing grammars when the plugin revision changes.

Verified on Arch Linux on 2026-10-16: the native Python query link still pointed
to retired `nvim-own`, and LazyVim's query links pointed into the native profile.
Applying the hook repaired both profiles without moving their already migrated
directories. Native Neovim `0.13.0-dev-1558+g8d5ebdf986` passed parser, highlight
query, and capture checks for Python, C, C++, Bash, and regex; Tree-sitter health
reported no errors with CLI `0.26.9`. Headless checks also confirmed the scrolling
options and that `Space c d` opens line diagnostics. LazyVim on Neovim `0.12.6`
loaded Python, C, Lua, and Bash queries successfully. Both profiles' generated
query links now resolve within their own data directories.

In a noninteractive agent session, apply stopped because the managed
`~/.agents/AGENTS.md` had changed since chezmoi last wrote it and no TTY was
available for confirmation. Its reviewed diff contained only the incoming
documentation guideline. Backing it up, applying that single path with
`chezmoi apply --force ~/.agents/AGENTS.md`, then rerunning normal
`chezmoi apply` completed the update; the final `chezmoi diff` was empty.
Review the actual diff before using this recovery for another machine or file.

## Page scrolling jumps instead of animating

Neovim's `smoothscroll` option controls scrolling through wrapped screen rows;
it does not animate `Ctrl-d`, `Ctrl-u`, `Ctrl-b`, or `Ctrl-f`. LazyVim enables
Snacks' scroll module by default, while the native profile had omitted it.
The native `plugins/snacks.lua` now enables `scroll = { enabled = true }`, using
the existing plugin and its default animation timings without remapping keys.
After applying, restart Neovim or run `:lua Snacks.scroll.enable()` in an
already open editor. Verified on Arch Linux on 2026-10-16: all four keys moved
the viewport through multiple animation frames in a fresh terminal UI, with no
startup errors; the module was also enabled in the running AG1 editor.

### Rendering rate

Checked on Arch Linux on 2026-10-16: the main display runs at `164.83 Hz`,
the secondary display at `60 Hz`, and the active terminal is Kitty `0.49.2`
through tmux `3.8`. Kitty's parsed configuration uses `repaint_delay 10`,
`input_delay 3`, and `sync_to_monitor yes`; its documented default repaint
cadence is roughly 100 FPS. Snacks' animation scheduler defaults to 120 FPS,
with scroll steps also depending on the distance and animation duration.
These settings do not measure frames actually presented by the compositor.
The tmux client reports RGB and synchronized-update support; the running editor
has `lazyredraw` disabled. Rendering settings were left unchanged during this
diagnostic check. See [Kitty's performance settings](https://sw.kovidgoyal.net/kitty/conf/#performance-tuning).

## Flash and Neovim nightly compatibility

Flash `v2.1.0` accesses search-state symbols removed in Neovim `0.13`.
The native profile pins `5f0f270fdc7c5b0c21d903ee85b9cb06f2ac636a`, whose
parent contains the [upstream compatibility fix](https://github.com/folke/flash.nvim/issues/495).
On 2026-10-16 the installed revision matched that pin, and both its search-state
access and a jump check passed on `0.13.0-dev-1558+g8d5ebdf986` in an isolated
terminal UI. Health checks for Noice, Blink, Mason, Mason-LSPConfig, Tree-sitter,
and the built-in LSP reported no errors. Noice warnings about not owning native
hover, signature help, or notifications reflect the deliberate configuration;
Mason warnings about missing optional language toolchains do not establish a
problem with the configured C/C++ and Python servers.

## VS Code editing plugins are missing

Start native `nvim` and run `:Lazy install`. VS Code reuses the native data
folder but does not run the plugin manager. Check that `mini.ai`,
`mini.surround`, and `nvim-treesitter-textobjects` are installed there.

The `ds` alias must remap to `gsd`. Calling `MiniSurround.delete()` directly
bypasses the mapping's input-cache reset and repeat setup.

## Opening a line continues the previous comment

The `o` flag in `formatoptions` inserts comment leaders when Normal-mode `o`
or `O` opens a line. Both native and VS Code profiles load `config.comments`,
which removes that flag initially and on `FileType`/`BufEnter` because filetype
plugins can restore it. Other formatting flags are preserved.

Verified on Arch Linux on 2026-10-17: native startup checks for Python and C++
confirmed that both `o` and `O` insert plain text below/above a comment. Loaded
the policy in the running native and VS Code sessions and confirmed their
current buffers exclude `o` from `formatoptions`.

## Escape leaves word-search highlights in VS Code notebooks

`*` searches for the cursor word. VS Code normally reserves Normal-mode
notebook Escape for leaving the cell, so the Neovim Escape mapping never ran
while only search highlights were visible. The VS Code profile now includes
`hlsearch` visibility in its existing `neovim.transientActive` context and
refreshes it after key processing. The first Escape clears highlights; a later
Escape can leave the cell. The mapping returns `<Cmd>nohlsearch<CR><Esc>` so
the command runs after expression evaluation, while retaining Flash cleanup.

Verified on Arch Linux on 2026-10-17 with Neovim `0.12.6`: an isolated check
loaded the VS Code configuration with host calls stubbed, then exercised
`*`, Escape, `n`, and Escape. Highlighting and notebook Escape capture toggled
correctly, and the search pattern and buffer text were preserved. Apply
`~/.config/nvim/lua/config/vscode.lua` and run `Neovim: Restart Extension` to
load the change in an existing VS Code session.

## Language servers

On the previously tested Neovim 0.12.5 build, the built-in command was
`:lsp restart <server-name>`; the legacy `:LspRestart` command was absent.
Check current help rather than assuming either command exists.

Restarting a server reuses its existing configuration. After changing a project
root marker such as `.luarc.json`, reopen Neovim to rediscover the root.

Mason installs missing tools asynchronously on first startup. Wait for completion
and reopen the file if a server did not attach. Inspect `:Mason` and `:MasonLog`
for failed downloads or missing system dependencies such as `unzip`.

The nightly core was selected after a project-specific Pyright regression:
Neovim 0.12.5 lost diagnostics after deleting and reopening a buffer, while the
tested 0.13 development builds retained them. A standalone file did not reproduce
it. When changing the core, verify diagnostics in a real project, including
buffer close/reopen and unsaved corrections; those old results do not establish
the behavior of a newer release.

On 2026-10-16, an isolated two-file Pyright project passed initial diagnostics,
buffer deletion/reopening with the same client, and unsaved correction/error
updates on both native `0.13.0-dev-1558+g8d5ebdf986` and system `0.12.6`, using
Pyright `1.1.413`. This smaller fixture does not prove the original affected
project is fixed; no core version was changed as part of the check.

## Lua definitions resolve into the wrong profile

The source-only [`.luarc.json`](../../dot_config/nvim/.luarc.json) makes
`dot_config/nvim/` a LuaLS workspace and resolves modules through `lua/?.lua`
and `lua/?/init.lua`. For `require("config.lazy")`, go-to-definition should reach
`dot_config/nvim/lua/config/lazy.lua` in the repository.

If it instead opens a deployed file under `~/.config/`, check the language
server's root and reopen the editor after fixing the root marker. The literal
`.luarc.json` is repository tooling and is not deployed by chezmoi.

## Native `gd` does not jump to a function definition

The native profile enabled language servers without defining LazyVim's LSP
navigation mappings, leaving `gd` as Neovim's text-based local-declaration search.
`config/keymaps.lua` now maps `gd`, `gr`, `gI`, and `gy` to the corresponding
Snacks LSP pickers and `gD` to `vim.lsp.buf.declaration`. Their descriptions
populate Which-Key; `gr` uses `nowait` as in LazyVim.

Verified on Arch Linux on 2026-10-17 in the running native Neovim nightly:
all five callbacks and Which-Key descriptions were present after reloading
the keymaps and refreshing Which-Key. A clangd definition request for `Q.size()`
in BFS II resolved to `/usr/include/c++/16/bits/stl_queue.h:251`.

Symbol rename is mapped to `<leader>cr` (`Space c r`) via `vim.lsp.buf.rename`.
Place the cursor on a symbol, invoke the shortcut, and enter its new name.
Verified on 2026-10-17: the running callback and Which-Key entry were present,
and the attached clangd client supported `textDocument/rename`.

## Completion hints and smooth scrolling disappear together

Check `:echo reg_recording()`. Accidental macro recording (for example, `qq`)
disables Blink completion, Snacks scroll animations, and Which-Key triggers.
Run `:normal! q` to stop an existing recording. The native profile now maps
Normal-mode `q` to `<Nop>` to prevent accidental recording.

Verified on Arch Linux with the native Neovim nightly on 2026-10-17: the affected
session was recording register `q`. After stopping recording, Blink's enabled
check and Snacks scroll/animation checks returned true, Which-Key had no
suspended modes, and its `g` trigger was restored.
After disabling the shortcut, the running editor reported `q` mapped to `<Nop>`;
an isolated editor loaded the deployed keymaps and confirmed `qq` did not start
recording. The live keymap file and chezmoi source matched.

## Escape closes the rename prompt instead of entering Normal mode

Without Snacks input enabled, `vim.ui.input` uses a native command-line prompt
rendered by Noice. Escape cancels that prompt. Enable `input = { enabled = true }`
in `plugins/snacks.lua` to use an editable prompt buffer, as in LazyVim.
The first Escape leaves Insert mode; Escape in Normal mode cancels.

Verified on Arch Linux with the native Neovim nightly on 2026-10-17:
the running `vim.ui.input` was switched to `snacks.input.input`. An isolated
prompt used the `snacks_input` buffer and mapped Insert-mode Escape to
`stopinsert` and Normal-mode Escape to `cancel`. Source and live config matched.

## F1 opens `help.txt` accidentally

Neovim's default F1 binding opens help. The native keymaps map F1 to `<Nop>`
in Normal, Insert, Visual, Select, Operator-pending, and Command-line modes.
Verified on 2026-10-17: all six live mappings were `<Nop>`, Lua syntax validation
passed, and the deployed file matched chezmoi source. `:help` remains available.

## `p` pastes deleted text even though the system clipboard is preserved

With yank-only clipboard synchronization, delete/change still update Vim's
unnamed register, which plain `p` normally uses. Native Normal/Visual `p` and `P`
now select the system clipboard register `+` when no register was specified.
Explicit register commands such as `"ap` and `"0p` keep their normal behavior.
Yanks update the clipboard; delete, change, and visual replacement preserve it.

Verified on 2026-10-17 using an isolated in-memory clipboard provider:
delete/change then paste, `P`, visual replacement, counted paste, and named
register paste all passed without changing the clipboard after the yank.
All four live mappings were loaded, Lua syntax passed, and source matched live.
