# nvim-own checkpoint — 2026-09-11

## Wrap

- **Time:** 2026-09-11 17:43:28 CEST (+0200)
- **Repository:** `/home/stasbebra2006/.local/share/chezmoi`
- **Branch:** `main`, tracking `origin/main`
- **Published baseline:** `e537ae335719056ed5cb56996d1f9af43a94402f`
- **Current work:** uncommitted and unpushed

## Objective

Build `nvim-own` into a capable personal Neovim configuration without hiding
behavior behind a framework. Keep code and explanations concrete: what executes,
what value is created, where it goes, which code consumes it, and when an effect
occurs. Work through one file at a time and move only when the user explicitly
says `next` or equivalent.

## Starting point

The 2026-09-10 checkpoint is at
[`checkpoint-2026-09-10.md`](checkpoint-2026-09-10.md). It records the applied
language-registry architecture, its smoke tests, the managed Kickstart reference
profile, and the earlier learning position at `lua/plugins/which-key.lua`.
Those changes were already uncommitted and must be preserved.

## Work completed during this session

### Documentation organization and review

The nvim-own documentation was moved under `docs/nvim-own/` and renamed to avoid
repeating the directory name in every filename:

```text
docs/nvim-own/
├── README.md
├── decisions.md
├── diagnostics.md
├── notes.md
├── roadmap.md
├── troubleshooting.md
├── checkpoint-2026-09-10.md
└── checkpoint-2026-09-11.md
```

The documents were reviewed for repeated guidance, stale terminology, unclear
profile boundaries, and factual ambiguity. The revised roles are:

- `README.md`: current profile, workflow, and startup behavior;
- `decisions.md`: accepted choices and durable rationale;
- `roadmap.md`: possible future work, not a task queue;
- `notes.md`: revision-scoped Kickstart and LazyVim evidence;
- `diagnostics.md`: historical diagnostic-lifecycle investigation;
- `troubleshooting.md`: verified non-obvious behavior and version-sensitive
  operational guidance.

Internal links and the previous checkpoint's documentation paths were updated.
The historical command
`git show 8653f7d^:docs/nvim-own.md` remains unchanged because that path is
correct inside the referenced commit.

### LuaLS cross-profile definition fix

**Observed:** while normal `nvim` edited
`dot_config/nvim-own/init.lua`, go-to-definition on
`require("config.lazy")` opened
`~/.config/nvim/lua/config/lazy.lua` instead of the sibling nvim-own source file.
The old LuaLS `root_dir` was not captured, so do not claim that the normal live
configuration was definitely the old workspace root; only the incorrect target
was directly observed.

A literal source-tree file was added at:

```text
dot_config/nvim-own/.luarc.json
```

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

This makes LuaLS root at `dot_config/nvim-own/` and maps
`require("config.lazy")` through its local `lua/` tree. The literal hidden source
file is visible to Git but is not a chezmoi-managed target; no apply is needed
for its source-editing purpose.

A real normal-profile Neovim definition request proved:

```text
root=/home/stasbebra2006/.local/share/chezmoi/dot_config/nvim-own
definition=/home/stasbebra2006/.local/share/chezmoi/dot_config/nvim-own/lua/config/lazy.lua
```

### Version-sensitive LSP restart discovery

The earlier advice to use `:LspRestart lua_ls` was wrong for this installation.
The user reported that the command does not exist. Normal `nvim` is 0.12.5 and
uses the built-in command:

```vim
:lsp restart lua_ls
```

Installed nvim-lspconfig returns before registering its legacy commands when the
built-in `:lsp` command exists. Neovim's built-in restart path starts a
replacement client from the existing client configuration, so it is not
reliable root rediscovery after adding `.luarc.json`. Reopening Neovim created a
fresh client, rediscovered the root marker, and fixed the user's session.

This evidence and the rule to check local help and installed source before
recommending remembered commands are recorded in `troubleshooting.md`.

### Learning walkthrough

The following files are now completed or discussed:

```text
init.lua
lua/config/options.lua
lua/config/diagnostics.lua
lua/config/keymaps.lua
lua/config/lazy.lua
lua/plugins/init.lua
lua/plugins/which-key.lua
lua/plugins/lsp.lua
lua/languages/python.lua
```

Important points covered during this session:

- a lazy.nvim `config` callback delays `setup()` until after plugin loading;
- `require("which-key").setup()` performs side effects and returns `nil` in the
  installed which-key implementation;
- `neovim/nvim-lspconfig` is a real plugin, while `vim.lsp` is Neovim's built-in
  client and `lua/config/lsp.lua` is our connector;
- nvim-lspconfig supplies server recipes, Mason installs external executables,
  and mason-lspconfig maps server names to Mason packages;
- `languages.python` returns only declarative data: `name = "python"` and
  `servers = { pyright = {} }`;
- the empty Pyright override preserves nvim-lspconfig's maintained recipe at
  `~/.local/share/nvim-own/lazy/nvim-lspconfig/lsp/pyright.lua`;
- `string:format(value)` is method-call syntax for formatting a new string;
  `%q` produces a quoted representation useful in assertion messages.

### Language-registry comments

The user correctly objected that `lua/languages/init.lua` forced the reader to
deduce its purpose. Source comments were added to explain:

- the file's declaration → validation → provisioning/activation data flow;
- why adding a language file does not activate it;
- why `registry.servers` is keyed while `registry.server_names` is an array;
- why `language_names` and `server_owners` are builder-only state;
- the single-owner invariant;
- why names are sorted;
- which modules consume the returned fields.

The executable Lua expressions were not changed. These comments have not been
applied to the live profile.

## Current learning position

Current file:

```text
lua/languages/init.lua
```

Already explained in this file:

1. `require("languages")` resolves to `lua/languages/init.lua` through the
   `?/init.lua` module-search pattern.
2. `containers` receives the table returned by `languages.python` at numeric key
   `1`.
3. `registry.servers` stores keyed server configurations for `config.lsp`.
4. `registry.server_names` stores an array for Mason's `ensure_installed`.
5. `language_names` and `server_owners` are temporary validation lookups.
6. The outer `ipairs(containers)` loop and container assertions were covered
   through `language_names[container.name] = true` at source line 38.
7. The most recent question concerned
   `("..."):format(container.name)`, colon-call syntax, and `%q`.

The new explanatory comments are present in source and were summarized to the
user, but the walkthrough has not yet continued through the inner server loop.

## Exact resume action

Do not move to another file. Continue in `lua/languages/init.lua` at:

```lua
for server_name, server_config in pairs(container.servers) do
```

Explain concretely that, for the current Python container, `pairs()` supplies:

```text
server_name   = "pyright"
server_config = the same empty table declared in languages/python.lua
```

Then continue through, in order:

1. server-name validation;
2. server-configuration table validation;
3. the single-owner assertion and its formatted message;
4. writes to `server_owners`, `registry.servers`, and
   `registry.server_names`—including that the configuration table is not copied;
5. `table.sort(registry.server_names)` and why `pairs()` order is unstable;
6. `return registry` and the exact readers in `plugins.lsp` and `config.lsp`.

Answer only questions about the current point. Move to `lua/config/lsp.lua` only
when the user explicitly says `next` after finishing this file.

## Current technical state

### Chezmoi target state

`chezmoi status ~/.config/nvim-own` currently reports only:

```text
 M .config/nvim-own/lua/languages/init.lua
```

The scoped diff is comment-only. The source and live profile otherwise retain
the previously proven language-registry architecture. Do not apply unless the
user requests it.

`dot_config/nvim-own/.luarc.json` is intentionally source-only. Verified, not
inferred: `chezmoi status ~/.config/nvim-own/.luarc.json` exited with
`not managed`. Keep the literal filename so LuaLS recognizes it in the source
tree; `dot_luarc.json` would be a separate deployed-target concern.

### Git state

Branch `main` still tracks `origin/main` with no recorded ahead/behind state.
Current status at wrap:

```text
 M .chezmoiremove
 D docs/nvim-own-decisions.md
 D docs/nvim-own-diagnostics.md
 D docs/nvim-own-notes.md
 D docs/nvim-own-roadmap.md
 D docs/nvim-own.md
 M dot_agents/AGENTS.md.tmpl
 M dot_config/nvim-own/init.lua
 M dot_config/nvim-own/lua/config/lsp.lua
 M dot_config/nvim-own/lua/plugins/init.lua
 D dot_config/nvim-own/lua/plugins/mason.lua
?? docs/nvim-own/
?? dot_config/nvim-kickstart/
?? dot_config/nvim-own/.luarc.json
?? dot_config/nvim-own/lua/languages/
?? dot_config/nvim-own/lua/plugins/lsp.lua
?? dot_local/bin/executable_nvim-kickstart
```

Git shows the old documentation paths as deleted and the new directory as
untracked; rename detection can occur when eventually staged. No staging was
performed.

`dot_agents/AGENTS.md.tmpl` appeared as unrelated modified work during the
session and was not edited here. Preserve it and all other unrelated changes.

### Open editor

A separate Kitty was launched through `systemd-run --user`. It contains an
isolated tmux server/socket `nvim-own-editor-2`, session `nvim-own`, with:

```text
path=/home/stasbebra2006/.local/share/chezmoi/dot_config/nvim-own
command=nvim
```

`NO_COLOR` is absent from that tmux server environment. The editor uses normal
LazyVim, not the `nvim-own` profile. Do not refresh or overwrite buffers without
checking for unsaved work.

## Verification performed

- Normal `nvim`: `NVIM v0.12.5`.
- `nvim-own`: `NVIM v0.13.0-dev-1558+g8d5ebdf986`.
- Actual LuaLS definition smoke test returned the intended nvim-own root and
  `lua/config/lazy.lua` path shown above.
- Direct source-registry load returned:

  ```text
  server_names = { "pyright" }
  servers = { pyright = {} }
  ```

- The source-only `.luarc.json` passed `jq empty`.
- All relative Markdown links in `docs/nvim-own/` resolved.
- Markdown headings were separated and no trailing whitespace was found.
- `git diff --check` was clean at wrap time.
- The temporary definition smoke script was removed.

No project-wide test suite was run; the relevant runtime paths were exercised
directly.

## Unresolved directions and safety

- The newly added comments in `lua/languages/init.lua` remain unapplied.
- The live `nvim-own` `lazy-lock.json` remains unmanaged.
- Plugin revision and Mason-tool reproducibility remain separate open directions.
- No commit or push was requested; none was performed.
- Do not reset, discard, stage wholesale, or overwrite existing changes.
- Apply, commit, and push remain separate authorization boundaries.

## Post-wrap publication — 2026-09-11 17:53:31 CEST

After the initial wrap, the user explicitly requested apply, commit, and push.
The earlier statements that the registry comments were unapplied and that no
commit or push was requested describe the initial wrap state and are superseded
by this section.

- Applied the reviewed source to `~/.config/nvim-own/`,
  `~/.config/nvim-kickstart/`, and `~/.local/bin/nvim-kickstart`.
- Scoped chezmoi status and diff were empty after apply.
- `nvim-own` loaded `server_names = { "pyright" }` from the live registry.
- `nvim-kickstart` completed a headless startup smoke test.
- The obsolete live `lua/plugins/mason.lua` was absent.
- Scanned the intended files for credential and private-key patterns; none were
  found.
- Staged 34 exact nvim-related paths while leaving
  `dot_agents/AGENTS.md.tmpl` unstaged as unrelated work.
- Created and pushed commit
  `6ea51259faa905350579c251be6d3c0453bea1c5`
  (`feat(nvim): expand standalone profile and references`) to `origin/main`.
- Local `HEAD` and `origin/main` matched that commit after the push.

This timestamped section is the follow-up publication record. The live
`lazy-lock.json` remains unmanaged, and the unrelated
`dot_agents/AGENTS.md.tmpl` modification still requires preservation.
