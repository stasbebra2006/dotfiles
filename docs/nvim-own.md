# nvim-own Learning Configuration

## Checkpoint

Wrapped on 2026-08-27 at 20:59 CEST (`Europe/Prague`). This is the resume document for the unfinished custom Neovim learning project.

## Wrap update — 2026-08-29 02:40 CEST

This section is authoritative and supersedes all older conversational/resume points below it. Preserve the older sections as project history.

### Current objective

Continue building `nvim-own` from explicit, understood pieces while normal LazyVim remains the stable fallback. The immediate technical goal has become concrete: understand and reproduce the native Neovim/Pyright pull-diagnostic lifecycle, then decide whether the learning profile should remain on stable Neovim 0.12.5 or move to a separate 0.13 development executable where the lifecycle is fixed.

The user does not want to make that core-version decision tonight. Resume tomorrow by finishing a concise comparison of the two choices. Do not change wrappers, executable symlinks, or installed core versions until the user understands the tradeoffs and explicitly chooses.

### Work completed after the previous wrap

#### Mason and Pyright

- Added `mason-org/mason.nvim` to the explicit plugin index.
- Added `lua/plugins/mason.lua` with a visible `require("mason").setup()` callback.
- lazy.nvim installed Mason at commit `2a6940af80375532e5e9e7c1f2fc6319a1b7a69d`.
- Mason uses the isolated package root `~/.local/share/nvim-own/mason`.
- Mason installed Pyright 1.1.413 from npm.
- The isolated Mason `bin/` directory exposes `pyright` and `pyright-langserver`.
- The system has no `unzip`, but Mason marks that check as relaxed and Pyright installed successfully without it. Do not install a system package unless a future package requires it and the user approves.

#### Direct native LSP configuration

Added `lua/config/lsp.lua`:

```lua
vim.lsp.config("pyright", {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { ".git" },
})

vim.lsp.enable("pyright")
```

Root `init.lua` now loads `config.lsp` after `config.lazy`, so Mason has already prepended its isolated `bin/` directory to the Neovim process's `PATH` before a Pyright process is started.

Verified behavior:

- a clean startup without a Python buffer starts zero LSP clients;
- opening the AIQ clarifier file starts exactly one `pyright` client;
- the command is `pyright-langserver --stdio`;
- filetype is `python`;
- workspace root is the AIQ Git root;
- no custom interpreter/settings logic has been added yet.

#### Diagnostic presentation

Added `lua/config/diagnostics.lua` and loaded it after core options:

```lua
vim.diagnostic.config({
  underline = true,
  update_in_insert = false,
  virtual_text = false,
  virtual_lines = true,
  severity_sort = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN] = " ",
      [vim.diagnostic.severity.INFO] = " ",
      [vim.diagnostic.severity.HINT] = " ",
    },
  },
  float = true,
})
```

This keeps the LazyVim-like underlines, severity sorting, icons, delayed insert-mode display updates, and floating diagnostics, but uses virtual lines below code instead of same-line virtual text. The user visually compared the result and prefers virtual lines for now.

#### Controlled buffer-deletion probe

A temporary, process-only `Space e` mapping was injected into the running `diagnostics` Neovim process. It was not written to any configuration file. The mapping:

1. prompts to save/discard/cancel when the current buffer is modified;
2. sets that buffer's `bufhidden` option to `delete`;
3. opens netrw with `:Explore`.

This deletes the current file buffer when netrw replaces it, providing the simplest close/reopen lifecycle test without installing Snacks or Bufferline.

### Reproduced bug on Neovim 0.12.5

In the live `diagnostics` process:

```text
register.py before delete/reopen: 13 diagnostics
register.py after delete/reopen:   0 diagnostics
wait after reopen:                 at least 30 seconds
Pyright clients attached:          1
client initialized:                yes
workspace root:                    AIQ Git root
pull diagnostics supported:        yes
buffer modified:                   no
```

The Pyright client remained attached after reopen, but Neovim's diagnostic storage stayed empty. This reproduces the core lifecycle problem in minimal `nvim-own` on current stable Neovim 0.12.5, independently of LazyVim, Snacks, Bufferline, Tree-sitter, Noice, and Blink.

The live process contains useful evidence. Its last confirmed state used RPC socket:

```text
/run/user/1000/nvim-own-diagnostics.sock
```

At wrap time that socket and process still existed, but later RPC inspection timed out. Do not terminate or restart the process merely to clean up; first explain that doing so destroys the live state and let the user decide whether further capture is worthwhile.

### Exact mechanism established

There are two separate in-memory state owners in Neovim 0.12.5:

```text
vim.diagnostic
→ actual diagnostic records, cached by buffer and namespace

vim.lsp.diagnostic
→ pull-diagnostic state and result IDs, cached by buffer/client
```

On buffer detach, the 0.12.5 pull-diagnostic cleanup clears the actual diagnostic namespace but leaves `bufstates[bufnr].client_result_id` in place. On re-enable, it reuses that buffer state and includes the stale value as `previousResultId`.

The installed Pyright 1.1.413 TypeScript source was inspected. Its pull-diagnostic result ID is not a hash. It is the source file's internal diagnostic-version integer converted to a string:

```text
sourceFile.getDiagnosticVersion().toString()
```

Pyright's logic is effectively:

```text
if previousResultId differs from current diagnostic version:
    analyze and return kind="full" with items
else:
    return kind="unchanged" without items
```

For an unchanged file, Pyright can retain diagnostic version `"3"` across `didClose`/`didOpen` because the workspace analyzer still owns the source file. Neovim 0.12.5 incorrectly sends the stale `"3"` after clearing its associated diagnostic payload. Pyright correctly returns `unchanged`; Neovim has no payload left to display.

The user has learned the relevant communication topology:

```text
Neovim buffer
↕
built-in Neovim LSP client
↕ JSON-RPC over dedicated stdin/stdout pipes
Pyright language-server process
```

Important distinctions established:

- LSP is a protocol, not one program.
- Neovim is the LSP client; Pyright is the LSP server.
- JSON is a data encoding; JSON-RPC defines request/response/notification fields.
- `textDocument/didOpen` is a notification carrying URI, language ID, document version, and full current buffer text.
- A URI identifies the project document; the text sent by Neovim supplies unsaved in-memory contents.
- After `didOpen`, Neovim's pull-diagnostic subsystem requests `textDocument/diagnostic`.
- Pyright returns `kind="full"`, a `resultId`, and diagnostic items on the first pull.
- Buffer numbers are local to Neovim and are never sent to Pyright; Pyright identifies documents by URI.

### Neovim 0.13 and Flash status checked on 2026-08-29

Official release state:

```text
current stable: Neovim v0.12.5
0.13:          nightly development prerelease only
```

There is no tagged 0.13 beta, release candidate, or stable release. The official 0.13 release checklist is open and still lists blockers; its milestone due date is 2026-10-01.

Local development executable:

```text
~/.local/bin/nvim-unstable
→ NVIM v0.13.0-dev-1212+g8d2b50c0ce
```

Current exact lifecycle test using today's `nvim-own` config and Pyright 1.1.413:

```text
before bdelete/reopen: 13 diagnostics
after bdelete/reopen:  13 diagnostics
attached clients:      1
```

The pinned 0.13 source handles detach by clearing the diagnostic payload and deleting the corresponding client result-ID state. Reattachment therefore pulls a full report without a stale `previousResultId`.

The former Flash.nvim blocker is now resolved upstream:

- fix commit: `7eff7f8873f87472944d78d0e655920efdc83933` on 2026-08-22;
- fix title: `fix(hacks): support Neovim 0.13 search state (#496)`;
- Flash issues #491 and #495 are closed;
- the fix uses Neovim 0.13's exported `Search` struct while retaining the old globals for older Neovim;
- upstream reported 1,211 tests passing on 0.13 and an older-version smoke test passing.

The user's installed normal-LazyVim Flash checkout is:

```text
5f0f270fdc7c5b0c21d903ee85b9cb06f2ac636a
```

It follows Flash `main`, includes the fix, and is newer than `7eff7f8`. The latest tagged Flash release remains v2.1.0 from 2024 and does not include the 0.13 fix.

A local read-only smoke test ran normal LazyVim under the pinned 0.13 executable and exercised the exact Flash search-state save/restore code that previously failed. It passed.

Therefore the old conclusion “0.13 fixes diagnostics but Flash blocks use” is stale for the user's current Flash checkout. This does not prove every plugin and workflow is compatible with the prerelease core.

### Update-system distinctions established

Launching `nvim` does not update anything.

```text
Neovim stable core
→ Arch package `neovim 0.12.5-1`
→ updated by the Arch system/package updater

local nvim-unstable
→ manually installed pinned snapshot
→ never updates automatically

lazy.nvim and Neovim plugins
→ missing plugins install automatically
→ updates require an explicit `:Lazy update`

Mason tools such as Pyright
→ managed separately in `:Mason`
→ update through Mason's update action
```

Normal LazyVim has lazy.nvim's background update checker enabled hourly with notifications disabled. It checks availability but does not install updates. `nvim-own` has the checker disabled. Neither profile automatically updates plugins simply because Neovim starts.

### Current authored configuration

```text
~/.config/nvim-own/
├── init.lua
├── lazy-lock.json                    # generated, not yet in chezmoi source
└── lua/
    ├── config/
    │   ├── diagnostics.lua
    │   ├── keymaps.lua
    │   ├── lazy.lua
    │   ├── lsp.lua
    │   └── options.lua
    └── plugins/
        ├── init.lua
        ├── mason.lua
        └── which-key.lua
```

Startup order is now:

```text
mapleader
→ config.options
→ config.diagnostics
→ config.keymaps
→ config.lazy
→ config.lsp
```

Plugin list:

```text
which-key.nvim  3aab2147e74890957785941f0c1ad87d0a44c15a
mason.nvim      2a6940af80375532e5e9e7c1f2fc6319a1b7a69d
lazy.nvim       306a05526ada86a7b30af95c5cc81ffba93fef97
```

which-key remains explicitly configured with the `helix` preset. No Tree-sitter, Snacks, Bufferline, Noice, Blink, real explorer, dashboard, Ruff, custom interpreter selection, or automatic `:checktime` rule has been added to `nvim-own`.

All changed authored live files match their chezmoi source copies. Scoped `chezmoi status` and `chezmoi diff` are empty. The live `lazy-lock.json` remains generated/unmanaged in chezmoi source; decide deliberately whether to manage it before publication.

### Validation at this wrap

A final stable `nvim-own --headless` startup passed assertions that:

- the config path is the isolated `nvim-own` path;
- which-key uses `helix`;
- the `:Mason` command exists;
- `pyright-langserver` resolves to the isolated Mason executable;
- the named Pyright config exists with the expected command and Python filetype;
- virtual lines are enabled, virtual text disabled, and severity sorting enabled;
- no LSP client starts without a matching Python buffer.

The current Flash and 0.13 lifecycle tests described above also passed. No config file was modified by either test.

### Live tmux/process state at wrap

The attached tmux session `nvim-own` has three one-pane windows:

1. `1:config` — active normal-LazyVim host editor, pane `%1`, working directory `~/.config/nvim-own`, RPC socket `/run/user/1000/nvim-own-editor.sock`. Current file is `lua/config/diagnostics.lua` at line 1. No loaded buffer was modified when inspected.
2. `2:nvim` — actual `NVIM_APPNAME=nvim-own` process under a zsh parent, pane `%11`, working directory `~/stasbebra2006/Projects/aiq`. It has no known RPC socket; current buffer and unsaved state are unknown. Treat it as user-owned and preserve it.
3. `3:diagnostics` — actual `NVIM_APPNAME=nvim-own` evidence process, pane `%12`, working directory `~/stasbebra2006/Projects/aiq`, RPC socket `/run/user/1000/nvim-own-diagnostics.sock`. Last confirmed state was reopened `register.py`, one Pyright client, zero diagnostics, and no modification. Its temporary `Space e` mapping is process-only. At wrap, later RPC inspection timed out; preserve the process rather than assuming its current state.

The earlier Mason UI window is gone. Another attached tmux session named `0` has two user-owned windows and must not be changed for this project. All process/window details are ephemeral; reinspect before relying on them tomorrow.

### Exact conversational position and next step

The user understands the broad stale-result mechanism and the exact Pyright diagnostic-version comparison better after several iterations, but the conversation moved to the practical core-version decision. Do not restart tomorrow with another deep protocol explanation unless requested.

The unresolved choice is:

1. Keep `nvim-own` on stable 0.12.5 temporarily, preserving the reproducible bug for learning/instrumentation, while accepting incorrect diagnostics after buffer deletion/reload.
2. Make only the isolated learning setup use the pinned 0.13 development build, gaining correct diagnostic lifecycle and currently working Flash, while accepting prerelease-core risk.
3. Potentially maintain parallel stable and 0.13 learning commands for direct comparison instead of replacing either immediately.

Tomorrow, begin with a brief overview of those choices and their concrete consequences. Include these facts:

- normal `nvim` should remain stable unless separately requested;
- `nvim-own` currently calls `nvim` through its wrapper and therefore uses stable 0.12.5;
- the pinned 0.13 build is not the newest nightly and does not auto-update;
- Flash's known blocker is fixed in the installed main-branch checkout;
- one successful Flash smoke test is not full ecosystem certification;
- switching the wrapper or creating a parallel wrapper is a configuration decision requiring exact code explanation and explicit approval.

After the user chooses the core strategy, continue the incremental editor stack. Do not install unrelated UI/buffer plugins before that decision.

### Git and publication state

The chezmoi source repository remains on `main`, tracking `origin/main`:

```text
 M AGENTS.md
?? docs/nvim-own.md
?? dot_agents/skills/wrap-session/
?? dot_codex/
?? dot_config/nvim-own/
?? dot_local/bin/
```

`AGENTS.md` has the tracked pointer to this checkpoint. `docs/nvim-own.md`, `dot_config/nvim-own/`, and the wrapper under `dot_local/bin/` remain untracked. `dot_agents/skills/wrap-session/` and `dot_codex/` are unrelated pre-existing untracked paths; do not include them accidentally.

No `chezmoi apply`, commit, or push was performed. Normal `~/.config/nvim` was inspected but not authored by this project. The investigation directory was read as evidence and is not a Git worktree.

## Latest continuation update — 2026-08-28 16:20 CEST

The session continued after the wrap:

- `mason-org/mason.nvim` is now indexed in `lua/plugins/init.lua` and explicitly configured in `lua/plugins/mason.lua` with `require("mason").setup()`; authored live and chezmoi source files match.
- lazy.nvim installed Mason at commit `2a6940af80375532e5e9e7c1f2fc6319a1b7a69d`.
- Mason's isolated package root is `~/.local/share/nvim-own/mason`.
- Mason installed Pyright 1.1.413 from npm and exposed `pyright` and `pyright-langserver` under that root's `bin/` directory.
- Verification in an actual `NVIM_APPNAME=nvim-own` process showed Mason considered Pyright installed, resolved the isolated `pyright-langserver`, and had zero active LSP clients. Installing an executable did not configure or start it.
- The system has no `unzip`, but Mason classifies that check as relaxed and Pyright installed without it. Do not install a system package unless a later selected package requires it and the user approves.
- A separate tmux window named `mason` was created in session `nvim-own`, running the actual isolated profile with the Mason UI. Reinspect the session before relying on this ephemeral state.
- The direct native LSP configuration has now been explained, approved, and added in `lua/config/lsp.lua`; root `init.lua` loads it after `config.lazy`.
- The named `pyright` recipe uses `cmd = { "pyright-langserver", "--stdio" }`, `filetypes = { "python" }`, and `root_markers = { ".git" }`, then calls `vim.lsp.enable("pyright")`.
- A real headless AIQ file test started exactly one Pyright client with filetype `python` and root directory equal to the AIQ Git root. A clean startup without a Python buffer kept zero clients. Authored live/source files match and scoped chezmoi status/diff remain empty.

The exact next learning step supersedes the older resume point below: inspect the newly working client/diagnostic path without running `:edit` yet, then establish a controlled diagnostic baseline. No custom interpreter settings, reload test, `:bdelete` comparison, or Snacks path has been added or run in `nvim-own` yet.

## Objective

Build a personal Neovim configuration from first principles so Stasbebra2006 understands and controls each behavior. LazyVim and other distributions are references for useful behavior and appearance, but `nvim-own` must not import their configuration frameworks. Keep normal LazyVim fully usable as a fallback while the isolated profile grows only through explicitly understood and approved choices.

The primary technical motivation is understanding Tree-sitter, native Neovim LSP, Python language servers, diagnostics, and buffer lifecycle well enough to reproduce and reason about inconsistent Python diagnostics without first reverse-engineering all of LazyVim's architecture.

## Driving investigation context

Use this existing investigation directory as evidence and historical context before planning Tree-sitter, Python LSP, diagnostic-lifecycle, or buffer-lifecycle work:

```text
~/stasbebra2006/Projects/neovim-python-lsp-investigation/
```

Read its files in this order when relevant:

1. `README.md`
2. `conclusion.md`
3. `evidence.md`
4. `recommended-changes.md`
5. archived configuration only when a specific historical implementation must be inspected

Do not copy the archived LazyVim configuration into `nvim-own`. Reconstruct the necessary editor, parser, LSP-client, language-server, diagnostic, and buffer-lifecycle pieces incrementally.

The evidence directory documents two independent historical problems:

1. Pyright could begin meaningful analysis with the wrong effective interpreter/settings when Neovim was launched outside the project root. Replacing `config.settings` in `before_init` could make inspection look correct while the retained effective settings remained stale.
2. On Neovim 0.12.4, plain `:edit` caused valid Pyright pull diagnostics to disappear (`20 -> 0`), while a controlled 0.13 development build preserved them (`20 -> 20`). The evidence attributed this to Neovim diagnostic result-ID/state ownership across `didClose`/`didOpen`, not to Tree-sitter.

Preserve a distinction between that controlled result and the user's recollection that old errors could remain after editing and closing/reopening through Snacks or Bufferline until LazyVim restarted. They may be related lifecycle manifestations or separate observations. Do not merge them into one diagnosis without a fresh reproduction on the currently installed Neovim 0.12.5.

Current Snacks code remains relevant but is only a clue: LazyVim's `<leader>bd` and Bufferline close actions call `Snacks.bufdelete`; its implementation swaps the visible buffer, temporarily ignores `DiagnosticChanged`, and then runs `bdelete!`. Compare this path only after establishing the native baseline.

## Configuration ownership and isolation

- `/usr/bin/nvim` is the actual Neovim 0.12.5 executable.
- `~/.local/bin/nvim` is a symbolic link to `/usr/bin/nvim`; it is not a shell alias.
- `~/.local/bin/nvim-own` is an executable shell wrapper:

  ```sh
  #!/bin/sh

  # Use ~/.config/nvim-own and matching isolated data, state, and cache directories.
  export NVIM_APPNAME=nvim-own
  # Replace this wrapper with the normal nvim command and forward every argument.
  exec nvim "$@"
  ```

- Normal `nvim` uses `~/.config/nvim` and starts the existing LazyVim setup.
- `nvim-own` uses `~/.config/nvim-own`.
- `NVIM_APPNAME=nvim-own` also isolates generated state under `~/.local/share/nvim-own`, `~/.local/state/nvim-own`, and `~/.cache/nvim-own`.
- The live learning configuration is `~/.config/nvim-own`.
- Chezmoi source entries are `dot_config/nvim-own/` and `dot_local/bin/executable_nvim-own`.
- Existing VS Code Neovim continues through normal `~/.config/nvim`; read `docs/neovim-vscode.md` before touching that path.

## Learning and implementation workflow

- Treat Stasbebra2006 as the active architect and explain every operation.
- Before changing learner-facing code, explain the immediate problem, the concrete objects and their types, and the exact proposed code; then obtain explicit approval.
- Introduce one small unfamiliar mechanism at a time unless the user explicitly asks to review a whole file together.
- Prefer direct Lua and visible execution paths over hidden scanning, framework imports, or unnecessary abstraction.
- Once startup, module loading, and one keymap are understood, move to the real plugin stack instead of polishing temporary built-in substitutes.
- Use normal LazyVim as the host editor for `nvim-own` files. Launch `nvim-own` separately only for testing the replacement profile.
- Preserve current tmux windows. Opening another directory or project means creating a separate tmux window in the existing `nvim-own` session by default, not replacing the current editor buffer.
- If an external file tool changes the file visible in the host editor, immediately invoke `:checktime` over its known RPC socket and verify the buffer reloaded.
- Preserve each intended live edit in chezmoi source and verify a scoped empty `chezmoi diff`.
- Never run `chezmoi apply`, commit, or push unless separately requested.
- Keep LazyVim's `FocusGained`/`TermClose`/`TermLeave` `:checktime` disk-refresh autocmd out of `nvim-own` during the current buffer-lifecycle investigation. This behavior is deferred, not rejected: revisit it after the investigation and add it as a separate learner-approved step.

## Implemented file structure

Live profile:

```text
~/.config/nvim-own/
├── init.lua
├── lazy-lock.json
└── lua/
    ├── config/
    │   ├── keymaps.lua
    │   ├── lazy.lua
    │   └── options.lua
    └── plugins/
        ├── init.lua
        └── which-key.lua
```

Chezmoi source contains the same authored Lua files under `dot_config/nvim-own/`. The generated live `lazy-lock.json` is not currently present in chezmoi source and therefore is not yet versioned with the configuration. Decide deliberately whether to manage it before publication; lazy.nvim recommends version-controlling lockfiles, but that decision has not been taught or approved yet.

## Exact startup and module flow

```text
nvim-own executable wrapper
→ sets NVIM_APPNAME=nvim-own
→ executes the normal nvim executable
→ Neovim automatically executes ~/.config/nvim-own/init.lua
→ sets Space as mapleader
→ require("config.options")
   → lua/config/options.lua
→ require("config.keymaps")
   → lua/config/keymaps.lua
→ require("config.lazy")
   → lua/config/lazy.lua
   → locate/bootstrap lazy.nvim
   → prepend lazy.nvim directory to runtimepath
   → require("plugins")
      → lua/plugins/init.lua
      → require("plugins.which-key")
         → lua/plugins/which-key.lua
         → return one which-key plugin-spec table
      → return the outer plugin-list table
   → require("lazy").setup(plugins)
```

`lua/config/lazy.lua` now ends with:

```lua
local plugins = require("plugins")

require("lazy").setup(plugins)
```

`lua/plugins/init.lua` is an explicit plugin index:

```lua
return {
  require("plugins.which-key"),
}
```

No automatic directory scanning or LazyVim-style imports are used. `config/` owns plugin-independent Neovim behavior and lazy.nvim bootstrap. Each file under `plugins/` owns one feature's repository declaration, setup, dependencies, and plugin-specific mappings.

## Current behavior

- `lua/config/options.lua` sets `vim.opt.number = true`.
- `lua/config/keymaps.lua` maps normal-mode `<leader>e` (`Space e`) to `<cmd>Explore<cr>` with description `Open file explorer`.
- `:Explore` is stock netrw. It is only a native probe and is not the settled explorer design.
- lazy.nvim bootstraps itself from `https://github.com/folke/lazy.nvim.git` at its `stable` branch when absent.
- The only requested user plugin is `folke/which-key.nvim`.
- which-key is loaded at startup because no lazy-loading rule has been added.
- which-key is explicitly configured with its built-in `helix` preset:

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

- The explicit `config` callback is intentional. The user learned that lazy.nvim's `config` field accepts a function (or `true`) and chose to keep the visible `require("which-key").setup(...)` call instead of switching to lazy.nvim's shorter `opts` convention.
- Temporary `modern` and `helix` comparison processes were created in separate tmux windows, visually compared, and later closed. The user selected `helix`.
- No Tree-sitter configuration, Mason, language server, LSP configuration, Noice, Blink, Snacks, Bufferline, or dashboard has been added to `nvim-own`.

## Runtime-generated plugin state

Generated plugin clones are not chezmoi-managed:

```text
~/.local/share/nvim-own/lazy/lazy.nvim
~/.local/share/nvim-own/lazy/which-key.nvim
```

At wrap time both Git worktrees were clean at:

```text
lazy.nvim      306a05526ada86a7b30af95c5cc81ffba93fef97
which-key.nvim 3aab2147e74890957785941f0c1ad87d0a44c15a
```

Live `lazy-lock.json` records those same revisions.

## Concepts established during this session

- `nvim-own` is an executable shell script discovered through `$PATH`, not an alias.
- A path suffix such as `.nvim` does not determine filesystem object type. `lazy.nvim` is the name of a downloaded directory; a trailing `/` is optional when referring to it.
- `require` is a Lua function. A module name is transformed into candidate paths under `lua/` in each runtime directory: dots become directory separators, and both `name.lua` and `name/init.lua` forms are tried.
- `require` calls are expressions that produce values; source text is not substituted. `return { require("plugins.which-key") }` stores the table returned by the inner module as the first element of an outer table.
- The two `[1]` positions in the conceptual nested table belong to two distinct table objects: the outer plugin list and the inner plugin specification.
- `require("plugins.which-key")` resolves to authored config at `lua/plugins/which-key.lua`; `require("which-key")` resolves to the plugin's public module at its own `lua/which-key/init.lua` because the exact module names map to different paths.
- lazy.nvim is a Neovim plugin manager. LazyVim is a configuration framework/distribution loaded through lazy.nvim. Normal LazyVim behavior comes from both the user's `~/.config/nvim` layer and the downloaded LazyVim framework layer.
- A lazy.nvim plugin specification is an API-defined table schema. Lua itself does not assign special meaning to `config`, `opts`, `event`, or similar keys; lazy.nvim interprets them according to its documentation.
- which-key's `classic`, `modern`, and `helix` choices are built-in layout presets. The `helix` name references the separate Helix modal editor; it changes presentation, not keybinding semantics.
- Tree-sitter is parsing technology loaded inside Neovim that builds incremental syntax trees. It can support highlighting, folds, indentation, navigation, and syntax-aware text objects. Native `ciw` does not require Tree-sitter. Tree-sitter is not an LSP server and does not normally resolve imports or types.
- `nvim-treesitter` is a Neovim plugin used to install/configure language parsers and Tree-sitter-based features; Tree-sitter itself is the parsing technology.
- Mason is a Neovim plugin that installs external developer tools such as language servers, linters, formatters, and debug adapters. Mason does not analyze code itself and does not configure Neovim's clients.

## Existing LazyVim feature ownership learned for reference

These are observations about normal LazyVim, not features added to `nvim-own`:

- which-key displays available key sequences and descriptions.
- Noice renders the `:` command line and messages in custom views.
- Blink provides command-line and insert-mode completion candidates.
- Actual commands remain owned by Neovim or the plugin that registered each command.
- Snacks is a broad plugin containing dashboard, picker, explorer, terminal, notifier, and buffer-delete features.
- The LazyVim greeting screen is the Snacks dashboard feature, not a separate active dashboard plugin.
- Bufferline (`akinsho/bufferline.nvim`) draws listed buffers as browser-like tabs in Neovim's tabline area.
- Native Neovim buffers, windows, and tabpages are different object types: buffers hold text, windows display buffers, and tabpages hold window layouts.
- Normal LazyVim's disk-refresh behavior comes from a LazyVim autocmd that calls `:checktime` on `FocusGained`, `TermClose`, and `TermLeave`. The user's own normal config does not define that rule.

## Disk-refresh state in nvim-own

Observed in a fresh `nvim-own` process:

```text
autoread=true
FocusGained checktime rule=false
```

`autoread=true` is currently inherited behavior and does not continuously watch the disk. The LazyVim-style `:checktime` autocmd has not been copied yet because it could affect the current buffer-lifecycle investigation; it is planned for a later step after that investigation. One-time RPC `:checktime` calls used to refresh the separate host editor were operational actions, not persisted profile configuration.

## Validation performed

which-key was installed with:

```text
nvim-own --headless '+Lazy! install' +qa
```

A final fresh `nvim-own --headless` run on 2026-08-27 passed assertions that:

- `stdpath("config")` is `~/.config/nvim-own`;
- line numbers are enabled;
- mapleader is Space;
- the `Space e` normal-mode mapping exists;
- the `:Lazy` command exists;
- the which-key specification and installed directory exist;
- the explicit which-key setup callback ran;
- the active which-key preset is `helix`;
- no `FocusGained` autocmd containing `checktime` exists.

Scoped `chezmoi status` and `chezmoi diff` for `~/.config/nvim-own` and `~/.local/bin/nvim-own` were empty at wrap time. Authored live/source which-key files matched. No `chezmoi apply` was run.

## Current conversational and learning position

The complete configuration/module/plugin flow has been reviewed. The last implementation step was persisting and verifying the which-key `helix` preset. The user explicitly requested explanations for every future operation and chose to keep the visible lazy.nvim `config` callback rather than convert it to `opts`.

The investigation directory was then inspected and referenced from this checkpoint. It changed the planned diagnostic investigation: plain `:edit` already reproduced the historical core lifecycle issue, so Snacks and Bufferline are not required for the first controlled experiment.

The assistant introduced only the top-level shape of the next topic:

```text
Neovim buffer → built-in LSP client → separate Pyright process
                                      ↓
Neovim diagnostics ← LSP messages ← analysis
```

Do not assume the user already understands that diagram. The next session must begin by explaining one concrete LSP object at a time.

## Exact resume point

Start with the first LSP topology concept before installing anything:

1. Explain that a Neovim buffer is an in-memory object inside the Neovim process containing the current text.
2. Then, in later messages, distinguish the built-in Neovim LSP client code from the separate Pyright executable/process and explain the direction of messages.
3. Explain where diagnostics are stored and why buffer close/reload events matter.
4. Only after the user understands and approves that topology, present the exact Mason plugin specification before editing files.
5. Install only the minimum needed for one Python path: Mason, Pyright, and direct native Neovim LSP configuration. Avoid LazyVim framework imports.
6. Reproduce plain `:edit` on current Neovim 0.12.5 with a controlled Python file and counted diagnostics.
7. Compare built-in `:bdelete`/reopen behavior.
8. Add or invoke `Snacks.bufdelete` only after the native baseline is understood; add Bufferline later only if its UI layer is relevant.

Planned later features, not yet implemented, include Tree-sitter, Blink, Noice, a real explorer, Bufferline, and possibly a Snacks dashboard. Add one layer at a time and inspect what changes.

## Live process state at wrap

The tmux session `nvim-own` exists, is attached, and has three one-pane windows:

1. `1:config` — active. Normal LazyVim host editor (`NVIM_APPNAME` unset), pane `%1`, working directory `~/.config/nvim-own`, RPC socket `$XDG_RUNTIME_DIR/nvim-own-editor.sock`. Current file is `lua/plugins/which-key.lua` at line 8. No loaded buffer is modified.
2. `2:lazyvim-config` — normal LazyVim editor (`NVIM_APPNAME` unset), pane `%3`, working directory `~/.config/nvim`, RPC socket `$XDG_RUNTIME_DIR/lazyvim-config-editor.sock`. A Snacks picker is currently open. No loaded buffer is modified.
3. `3:zsh` — user-owned shell, pane `%4`, working directory `~/stasbebra2006/Projects/aiq`. Preserve it; do not replace or terminate it without explicit instruction.

The temporary `wk-modern` and `wk-helix` windows and their RPC sockets are gone. Another attached tmux session named `0` exists with four user-owned windows; do not alter it for this project.

These process details are ephemeral. Reinspect them before relying on window numbers, buffers, or sockets in a later session.

## Changed files and generated state

Authored live changes:

```text
~/.config/nvim-own/lua/config/lazy.lua
~/.config/nvim-own/lua/plugins/init.lua
~/.config/nvim-own/lua/plugins/which-key.lua
```

Matching chezmoi source changes:

```text
dot_config/nvim-own/lua/config/lazy.lua
dot_config/nvim-own/lua/plugins/init.lua
dot_config/nvim-own/lua/plugins/which-key.lua
```

Generated live state:

```text
~/.config/nvim-own/lazy-lock.json
~/.local/share/nvim-own/lazy/which-key.nvim/
```

Documentation/memory changes:

```text
docs/nvim-own.md
~/.deepagents/agent/AGENTS.md
```

Normal `~/.config/nvim` was inspected but not edited.

## Git and publication state

The chezmoi source repository is on `main`, tracking `origin/main`. At wrap time:

```text
 M AGENTS.md
?? docs/nvim-own.md
?? dot_agents/skills/wrap-session/
?? dot_codex/
?? dot_config/nvim-own/
?? dot_local/bin/
```

`AGENTS.md` has one tracked addition pointing to this checkpoint. `docs/nvim-own.md`, `dot_config/nvim-own/`, and the `nvim-own` wrapper under `dot_local/bin/` remain untracked. `dot_agents/skills/wrap-session/` and `dot_codex/` are unrelated pre-existing untracked paths and must not be included accidentally.

No configuration was applied through chezmoi. Nothing was committed or pushed. The investigation directory is not a Git worktree and was only read.
