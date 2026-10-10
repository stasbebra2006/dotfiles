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

## VS Code editing plugins are missing

Start native `nvim` and run `:Lazy install`. VS Code reuses the native data
folder but does not run the plugin manager. Check that `mini.ai`,
`mini.surround`, and `nvim-treesitter-textobjects` are installed there.

The `ds` alias must remap to `gsd`. Calling `MiniSurround.delete()` directly
bypasses the mapping's input-cache reset and repeat setup.

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

## Lua definitions resolve into the wrong profile

The source-only [`.luarc.json`](../../dot_config/nvim/.luarc.json) makes
`dot_config/nvim/` a LuaLS workspace and resolves modules through `lua/?.lua`
and `lua/?/init.lua`. For `require("config.lazy")`, go-to-definition should reach
`dot_config/nvim/lua/config/lazy.lua` in the repository.

If it instead opens a deployed file under `~/.config/`, check the language
server's root and reopen the editor after fixing the root marker. The literal
`.luarc.json` is repository tooling and is not deployed by chezmoi.
