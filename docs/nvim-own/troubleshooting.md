# nvim-own: troubleshooting

[Project guide](README.md) · [Decisions](decisions.md) ·
[Directions](roadmap.md)

This file records verified, non-obvious behavior that would otherwise be easy to
rediscover or answer incorrectly from outdated documentation. Keep entries
version-scoped and separate observed facts from explanations.

## Before trusting a remembered command

Neovim and plugin commands change. Check the executable used by the active
profile, then consult that version's help and command registry:

```sh
nvim --version
nvim-own --version
```

```vim
:help :lsp-restart
:echo exists(':lsp')
:echo exists(':LspRestart')
```

Use installed plugin source when local help and external examples disagree.
Record the tested version, exact command, observed result, and whether the
explanation was verified or inferred.

## LSP restart command on Neovim 0.12

Verified on 2026-09-11 with normal `nvim` 0.12.5:

```vim
:lsp restart lua_ls
```

`:LspRestart` is the older nvim-lspconfig command and does not exist in this
profile. The installed nvim-lspconfig compatibility code returns without
registering its legacy commands when Neovim's built-in `:lsp` command exists.
Do not recommend `:LspRestart` from memory.

### Restarting is not root rediscovery

Neovim's built-in restart path starts a replacement client with the existing
client configuration. It is suitable for restarting a stuck server process, but
it does not reliably recalculate the project root after adding a root marker such
as `.luarc.json`.

After adding or changing a root marker, close and reopen Neovim so the new LSP
client performs root discovery from scratch.

## LuaLS resolving modules into the wrong Neovim profile

### Observed symptom

While normal `nvim` edited
`dot_config/nvim-own/init.lua`, go-to-definition on:

```lua
require("config.lazy")
```

opened:

```text
~/.config/nvim/lua/config/lazy.lua
```

instead of:

```text
~/.local/share/chezmoi/dot_config/nvim-own/lua/config/lazy.lua
```

The old LuaLS `root_dir` was not captured, so do not claim that the normal live
configuration was definitely the workspace root. The verified failure was the
incorrect definition target.

### Why the target was plausible to LuaLS

Normal `nvim` puts `~/.config/nvim/` on its runtime path, and LazyVim's
`lazydev.nvim` exposes Neovim runtime and plugin libraries to LuaLS. Before the
local root marker existed, LuaLS knew about the live module
`~/.config/nvim/lua/config/lazy.lua` but had no project-local rule mapping
`config.lazy` through `dot_config/nvim-own/lua/`.

Chezmoi's `dot_config/nvim-own` name has no special meaning to LuaLS.

### Fix

The source-only [`.luarc.json`](../../dot_config/nvim-own/.luarc.json) makes
`dot_config/nvim-own/` a LuaLS root and defines Neovim-style module paths:

```json
{
  "runtime.version": "LuaJIT",
  "runtime.path": [
    "lua/?.lua",
    "lua/?/init.lua"
  ],
  "workspace.checkThirdParty": false
}
```

For `require("config.lazy")`, `lua/?.lua` maps `config.lazy` to
`lua/config/lazy.lua` under that root.

The literal hidden file is repository tooling: Git can retain it, but chezmoi
does not manage or deploy it to `~/.config/nvim-own/`.

### Verification

After reopening normal Neovim, an actual definition request returned:

```text
root=/home/stasbebra2006/.local/share/chezmoi/dot_config/nvim-own
definition=/home/stasbebra2006/.local/share/chezmoi/dot_config/nvim-own/lua/config/lazy.lua
```
