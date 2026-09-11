# nvim-own checkpoint

## Wrap

- **Time:** 2026-09-10 22:51:17 CEST (+0200)
- **Repository:** `/home/stasbebra2006/.local/share/chezmoi`
- **Branch:** `main`, tracking `origin/main`
- **Published baseline:** `e537ae3 docs(nvim): add incremental development references`
- **Current work:** uncommitted and unpushed

## Objective

Build `nvim-own` into a capable personal configuration without hiding behavior
behind a framework. Keep the structure scalable through small, clearly named
containers and explicit connectors. Add mechanisms only when a real need appears,
but use the strongest relevant ideas from the local Kickstart and LazyVim
references.

The learning objective is equally important: understand what each line actually
does, where data goes, which code reads it, and when the observable effect occurs.
Architectural labels are useful only after this execution path is concrete.

## Work completed

The former hard-coded Pyright setup was replaced by a declarative language
registry:

- `dot_config/nvim-own/lua/languages/python.lua` owns Python's current
  `pyright = {}` server declaration. The empty override selects the maintained
  `nvim-lspconfig` recipe.
- `dot_config/nvim-own/lua/languages/init.lua` is the explicit active-language
  manifest. It validates language names, server config tables, and unique server
  ownership, then returns a sorted server registry.
- `dot_config/nvim-own/lua/plugins/lsp.lua` eagerly loads `nvim-lspconfig`, Mason,
  and `mason-lspconfig`; passes the registry's server names to
  `ensure_installed`; disables Mason's automatic enablement; then invokes the
  runtime connector.
- `dot_config/nvim-own/lua/config/lsp.lua` is the sole activation path. Its
  `setup()` function calls `vim.lsp.config()` and `vim.lsp.enable()` for each
  validated server.
- `dot_config/nvim-own/lua/plugins/mason.lua` was retired. `.chezmoiremove`
  removes the obsolete live file.
- `dot_config/nvim-own/init.lua` now enters language tooling through the plugin
  graph rather than calling `config.lsp` too early.

The source was applied to `~/.config/nvim-own/`.

Documentation updates:

- `docs/nvim-own/README.md` now states the container/connector design goal, current
  language architecture, asynchronous first-install caveat, and preferred
  mechanism-first teaching method.
- `docs/nvim-own/decisions.md` records D-003, declarative language containers
  with explicit connectors.
- `docs/nvim-own/roadmap.md` reflects the implemented registry and remaining
  Python/tool-version directions.

Earlier uncommitted work also added the managed Kickstart comparison profile at
`dot_config/nvim-kickstart/`, its launcher at
`dot_local/bin/executable_nvim-kickstart`, and related documentation. Preserve
that work; do not treat it as generated or discard it.

## Proven technical state

Applied-profile smoke test:

```text
registry=pyright
client=pyright
root=/tmp/nvim-own-lsp-smoke
executable=~/.local/share/nvim-own/mason/bin/pyright-langserver
```

Fresh isolated-profile smoke test:

1. Started real interactive `nvim-own` with isolated data/state/cache paths and
   no installed Pyright.
2. lazy.nvim installed the plugin graph.
3. Mason installed `pyright-langserver` from the registry declaration.
4. A subsequent headless Python launch attached client `pyright` and selected
   the directory containing `pyproject.toml` as its root.
5. The isolated smoke profile and test files were removed.

Two earlier headless-only provisioning probes timed out intentionally from the
plugin's perspective: current `mason-lspconfig` skips its `ensure_installed`
feature when `platform.is_headless` is true. This was a probe-design issue, not a
configuration failure; the real interactive path succeeded.

Final checks before wrapping:

- recursive `chezmoi status ~/.config/nvim-own`: empty;
- recursive `chezmoi diff ~/.config/nvim-own`: empty;
- `git diff --check`: clean;
- live plugin files contain `plugins/lsp.lua` and no obsolete
  `plugins/mason.lua`;
- no related `nvim-own` process remains running.

The live `lazy-lock.json` remains unmanaged, as documented. Plugin/tool version
pinning remains an open decision.

## Explanation method requested by the user

Work through exactly one file at a time. Do not give unsolicited file summaries.
After the user asks a question, answer only that question. Move only when the
user says `next` or equivalent.

Explain from the concrete mechanism first:

1. What expression executes?
2. Is a value an ordinary Lua value/table or a Neovim-backed table-like
   interface?
3. Where is data stored or passed?
4. Which code reads or reacts to it?
5. Does the effect happen immediately or later?
6. Only then introduce a general name or abstraction.

Example of the desired perspective: `vim.g.foo = x` and
`vim.opt.number = true` both look like assignments through table-like Lua
interfaces. The first writes a Vim global variable that matters when named code
reads it. The second calls Neovim's predefined option machinery, which validates
and applies `number` behavior. Avoid replacing this execution path with labels
such as “semantic ownership.”

## Current learning position

Completed or already discussed:

```text
init.lua
lua/config/options.lua
lua/config/diagnostics.lua
lua/config/keymaps.lua
lua/config/lazy.lua
lua/plugins/init.lua
```

Current file:

```text
lua/plugins/which-key.lua
```

The last question was how the returned structure works and why our local
`plugins/which-key.lua` is not confused with the installed plugin module
`which-key`.

## Exact resume action

On resume, do not move to another file. First repeat the following explanation
of `lua/plugins/which-key.lua`, then wait for questions:

```lua
return {
  "folke/which-key.nvim",

  config = function()
    require("which-key").setup({
      preset = "helix",
    })
  end,
}
```

This returns one ordinary Lua table. The unkeyed repository string is stored at
numeric key `1`; lazy.nvim interprets it as the plugin identity. The named
`config` field stores a function value. Creating and returning the table does
not run that function. lazy.nvim installs and loads the plugin, then calls the
stored function.

`require("plugins.which-key")` and `require("which-key")` are different module
names and therefore different searches:

```text
require("plugins.which-key")
    -> ~/.config/nvim-own/lua/plugins/which-key.lua
    -> our file that returns the lazy.nvim plugin specification

require("which-key")
    -> ~/.local/share/nvim-own/lazy/which-key.nvim/lua/which-key/init.lua
    -> the installed plugin's actual API module
```

They are also cached separately as `package.loaded["plugins.which-key"]` and
`package.loaded["which-key"]`. Inside the stored callback,
`require("which-key")` returns the installed plugin's API table, `.setup`
selects its setup function, and the `{ preset = "helix" }` table is passed to
that function.

After the user is satisfied and explicitly asks for the next file, continue to:

```text
lua/plugins/lsp.lua
```

## Repository state and safety

Current source changes include both the managed Kickstart profile and the new
`nvim-own` language architecture. `git status` was not clean at wrap time by
design. No commit or push was requested, so none was performed. Do not reset,
discard, or overwrite these changes. Apply, commit, and push remain separate
authorization boundaries.
