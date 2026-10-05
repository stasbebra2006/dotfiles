# nvim-own checkpoint — 2026-10-04

Historical checkpoint; names, commands, inventory, and resume instructions below
describe the session at that date and are not current operational guidance.
The former `nvim-own` base is now `nvim` (`dot_config/nvim/`); ordinary LazyVim
is now `lazy-nvim` (`dot_config/lazy-nvim/`). Documentation moved to `docs/nvim/`.
Use [the current guide](README.md) for launch commands and source ownership.

Wrapped at 2026-10-04T19:25:47+02:00 (CEST).

## Objective and starting context

Build the user's independent `nvim-own` profile with practical editing features,
while keeping normal LazyVim separate. Authored configuration belongs in chezmoi
source; normal Neovim is the editor and `nvim-own` is the feature runtime.

The previous checkpoint, `checkpoint-2026-09-17.md`, ended after the language
registry walkthrough and proposed `lua/config/lsp.lua` as the next lesson.
This session instead added completion, navigation, buffer tabs, sessions, and
Python highlighting/linting/formatting. Do not treat the old walkthrough position
as the latest task or imply that the connector walkthrough was completed here.

## Conversational position and exact resume action

The last feature request was “ok set it all up”: Python Tree-sitter highlighting,
Ruff linting and formatting, with Pyright retained for types and completion.
Those features are installed and applied. Formatting is manual with `Space c f`;
no automatic rewrites on save were requested or added.

The latest request is “ok wrap session, and sync with the remote”. No next feature
or lesson has been selected. The user prefers practical progress and explicitly
said “don't do the checks” earlier. Do not launch a health-check campaign,
add optional dashboard features, or implement the roadmap without a new request.

First action on resumption: inspect this checkpoint's enclosing commit and remote
state to establish the final publication outcome. Then resume from this completed
feature baseline, not an unfinished implementation.
Restart `nvim-own` in a real project to load the new configuration if the user's
instance predates these changes. If the user returns to the earlier walkthrough,
the pending connector file is `dot_config/nvim-own/lua/config/lsp.lua`; its
registry now contains both `pyright` and `ruff`.

## Completed features and current configuration

- Blink `v1.10.2` with the prebuilt Rust matcher; LSP/path/buffer completion.
  Nothing is preselected and navigation does not insert previews. `Ctrl-Space`
  opens completion/documentation, `Ctrl-n`/`Ctrl-p` select, `Ctrl-e` hides, and
  Enter accepts only a selected item. Tab and command-line completion remain native.
  The LSP specification depends on Blink so completion capabilities register first.
- Snacks `v2.31.0`: only explorer, picker, and dashboard enabled. Persistent left
  explorer replaces netrw. `Space e`, `Space f f`, and `Space f g` use the current
  working directory. Dashboard keys: `f`, `g`, `r`, `n`, `s`, `q`.
- Bufferline `v4.9.1`, sharing devicons `v0.100`. `Shift-h`/`Shift-l` cycle buffers;
  `Space b d` and tab close actions use Snacks buffer deletion to preserve splits
  and prompt for unsaved work. Sidebar offset uses `snacks_layout_box`.
- Persistence `v3.1.0`: automatic saving after opening a real file; manual restore.
  `Space q s` restores the current project, `q S` selects, `q l` restores the last,
  and `q d` disables saving for that process. Dashboard `s` restores the project.
  Sessions use the profile's state directory and directory/Git-branch identity.
  Session options include buffers, curdir, tabpages, winsize, help, globals,
  skiprtp, and folds; not configuration options or terminal buffers.
- nvim-treesitter maintained `main`, pinned to
  `e289100ff98969e118c702199d88b764ce9e7fdf`, eager-loaded. The build installs or
  refreshes Python's matching parser and queries; Python FileType starts native
  highlighting. No Tree-sitter indentation or folding configuration was added.
- Native Ruff LSP, Mason-installed Ruff `0.16.10`, handles lint diagnostics and
  manual formatting. `Space c f` selects only Ruff and leaves changes unsaved;
  formatting does not run lint fixes. Normal project/global Ruff config applies.
- Pyright still handles type analysis, completion, hover, and navigation.
  Its organize-imports action is disabled in favor of Ruff; Ruff hover is disabled
  in favor of Pyright. Pyright analysis was not disabled or broadly ignored.
- Which-key groups: find (`f`), buffers (`b`), sessions (`q`), code (`c`).

No Conform or nvim-lint was added: Ruff's native LSP supplies the requested paths.
Projects/Config/Lazy dashboard extras were discussed but not authorized or added.

## Files changed in this session

All configuration paths below are relative to `dot_config/nvim-own/`:

- New `lua/plugins/blink.lua`, `snacks.lua`, `bufferline.lua`, `persistence.lua`,
  and `treesitter.lua`: the five feature specifications and their version pins.
- `lua/plugins/init.lua`: explicit registration of those specifications.
- `lua/plugins/lsp.lua`: Blink dependency before server activation.
- `lua/plugins/which-key.lua`: groups for the implemented mappings.
- `lua/config/keymaps.lua`: file/search/buffer/session/manual-format actions.
- `lua/config/options.lua`: workspace session-content policy.
- `lua/languages/python.lua`: Pyright role override and Ruff declaration/callback.
- `lua/languages/init.lua`: update stale Pyright-only examples; registry logic unchanged.

Repository-only documentation: `docs/nvim-own/README.md` documents the features,
keys, prerequisites, and ownership; `roadmap.md` removes completed directions;
this checkpoint preserves the latest resume position.

## Runtime, application, and observed verification

- Source: `/home/stasbebra2006/.local/share/chezmoi`.
  Live profile: `~/.config/nvim-own/`. Downloads: `~/.local/share/nvim-own/`.
- Existing wrapper selects `NVIM_APPNAME=nvim-own` and the separate nightly
  `0.13.0-dev-1558+g8d5ebdf986` through `~/.local/opt/nvim-unstable`.
  Normal Neovim remains stable `0.12.5`. The core was not changed this session.
- Scoped chezmoi previews and applies were used. At wrap inspection, both
  `chezmoi status ~/.config/nvim-own` and the built-in diff were empty.
  The live generated `lazy-lock.json` remains unmanaged in source.
- Earlier feature steps used isolated actual-editor scenarios for completion,
  navigation/buffer UI, and sessions; their temporary fixtures were removed.
- Python parser installation through `Lazy! install nvim-treesitter` downloaded,
  compiled, and installed Python successfully. C compiler, curl, tar, and
  tree-sitter CLI `0.26.9` are available; the pinned plugin requires CLI >=0.26.1.
- An isolated actual `nvim-own` TUI attached both Pyright and Ruff. Native
  Tree-sitter returned capture `keyword.import` on `import`; the screen displayed
  Ruff `F401` for unused `os` and Pyright `reportAssignmentType` for assigning a
  string to an annotated int. Ruff also reported `C408` under discovered config.
- Pressing actual `Space c f` changed `result=dict( a=1,b=2 )` to
  `result = dict(a=1, b=2)`. The unused import remained, the buffer became modified,
  and the disk file stayed unchanged. This proves formatting without lint fixes
  or automatic file writes.
- No permanent tests or throwaway scripts were added. The isolated Python tmux
  server and fixture directory were removed after verification. Its state path
  was isolated with `XDG_STATE_HOME`; injected `NO_COLOR` was absent in the editor.

## Operational corrections, unresolved items, and safety

- mason-lspconfig deliberately skips `ensure_installed` in headless mode. An
  initial headless wait therefore timed out without installing Ruff. Explicit
  `MasonInstall ruff` completed successfully; normal TUI provisioning remains
  configured through the language registry. Do not repeat the ineffective wait.
- Parsing an empty headless buffer returned no syntax tree; this was not evidence
  of a failed parser installation. Real Python-buffer highlighting worked.
- Observed a timeout with a remote-expression wait nested inside synchronous
  LSP formatting. [INFERENCE] Harness reentrancy caused that timeout. Waiting for
  a subsequent editor-side tmux signal succeeded; no production change was needed.
- Source LuaLS was unavailable to the agent's LSP tool; scoped inspection was used.
- User editor instances and unsaved work were not closed. No agent-owned editor,
  background installer, or experiment remains running.
- Preserve the source-only `.luarc.json`; do not deploy it to silence warnings.
  Preserve machine branches and use built-in chezmoi diff for reliable previews.
- Other languages, Python environment selection, Git hunks, statusline,
  notifications, and debugging are not implemented by this session.

## Git and publication state at checkpoint creation

Branch `main` tracks `origin/main`; both were `2190a45` after `git fetch origin`.
`git rev-list --left-right --count HEAD...origin/main` returned `0 0`:
no incoming commits and no existing local commits to publish.
Remote: `git@github.com:stasbebra2006/dotfiles.git`.

The session's configuration/docs changes and this checkpoint were uncommitted
at creation. After clarification, the user explicitly selected “Commit and push
session”, authorizing publication of the reviewed nvim-own configuration and
documentation only. The next operations are a new commit and a normal push,
without force; no incoming integration is needed.

This text records the pre-publication state, not a success claim. Inspect the
commit containing this checkpoint and its remote ref for the final outcome.

Unrelated user changes exist in `AGENTS.md` and `symlink_chezmoi.tmpl`. They were
left untouched and must not be staged with this session's commit.
