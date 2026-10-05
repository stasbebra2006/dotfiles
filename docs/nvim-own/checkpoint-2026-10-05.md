# nvim-own notebook experiment — retired (2026-10-05)

## Retirement decision and current state

On 2026-10-05 the user rejected the complexity of the notebook integration and
requested its full rollback, with comprehensive history retained. The experiment
is removed from the active configuration, not waiting for an export fix.
Do not resume it, install a replacement stack, or restore its bindings without a
new request.

### Completed rollback on the Linux machine

- Removed the Molten and Jupytext plugin declarations and registrations.
- Removed the early `python3_host_prog` override, current-cell helper, Python-only
  notebook autocmd/keymaps, and which-key's `Space j` group.
- Removed Snacks' notebook image settings, keeping explorer/picker/dashboard.
- Removed the notebook-only tmux `allow-passthrough on` setting and explicitly
  restored `allow-passthrough off` in the existing server. The F12 keyboard/mouse
  passthrough configuration and OSC 52 clipboard forwarding were preserved.
- Deleted the three notebook-only source modules. Added their deployed paths to
  `.chezmoiremove`, so applying on another machine removes stale live copies
  instead of merely ceasing to track them.
- Updated the active README to describe the experiment as removed; the historical
  implementation and evidence below remain available.
- Preserved all unrelated UI/navigation/session features, Python and C/C++ tooling,
  the normal LazyVim profile, and every coursework notebook, CSV, and image.

Before removal, an actual headless Neovim Python buffer had the kernel/run-cell
bindings and one notebook FileType autocmd. After applying the rollback, a fresh
headless instance confirmed all notebook keys/autocmds and the three live files
absent, and loaded the plugin declarations without Molten/Jupytext. Native theme
and global-statusline options, actual Ctrl-h movement between splits, the manual
formatting mapping, and the Pyright/Ruff/clangd declarations remained intact.
Scoped chezmoi status/diff were empty. These checks do not claim fresh LSP runtime
attachment or complete plugin startup: this Linux host lacks the wrapper's
`~/.local/opt/nvim-unstable` binary, so the smoke used system Neovim with the native
profile modules and plugin declarations.

No notebook runtime data/state/cache directory, notebook host, Jupytext uv tool or
launcher, user `bi-ml1` kernelspec, or generated profile lockfile was found on this
Linux machine. There was therefore no local package/host/kernel data to uninstall.
The Mac installations listed below are a separate historical machine state.
No SSH hosts are configured for reaching that Mac; its external-package cleanup
has not been performed or verified from this session. See the checklist below.
The user subsequently authorized committing and pushing this rollback. The commit
containing this retirement record is the notebook-only removal, not the earlier
implementation checkpoint. Live apply and Mac runtime cleanup remain separate
actions. Check `origin/main` for remote publication; a local copy of this document
alone does not establish that a push succeeded.

### Lessons retained

- Cell execution is not a notebook round trip. A usable result-saving workflow
  needs export and reopen proof, including pre-existing error outputs and plots.
- The editor's Python host, Jupyter kernel, and Pyright interpreter are separate.
  Synchronizing Lua files does not provision any of those external runtimes.
- Hydrogen preserved executable `%magics`; ordinary percent conversion commented
  them and broke correspondence with some saved outputs.
- Start in the notebook asset directory. A selected kernel did not automatically
  adopt the opened notebook's directory.
- Pandas truncation happens before output reaches the editor. Scrolling a window
  cannot recover rows or columns omitted by the producer.
- Three-line previews plus a focusable unwrapped output buffer handled large text
  tables. A permanent code-left/output-right sidebar was never implemented.
- An image placement and terminal placeholders are not visual proof of rendered
  pixels. The failed macOS capture left that graphics check incomplete.
- The suspected upstream export defect remains an inference, not a verified root
  cause or a fixed bug. No fake save, suppressed exception, or discarded error
  outputs were accepted as a workaround.

## Original implementation checkpoint — historical

The following records the Mac experiment before retirement. Its installation
inventory, successful probes, and prior publication authorization describe that
earlier session, not current Linux dependencies or permission to publish rollback.

Checkpoint started at 2026-10-05T11:44:48+02:00 (CEST, Europe/Prague).
The user explicitly requested wrapping, durable progress/removal notes, a commit,
and a push. At that checkpoint the experiment was paused, not completed.

## Objective and conversational position

Build the user's explicit, understandable `nvim-own` profile without changing
normal LazyVim. Plugin inclusion belongs in `lua/plugins/init.lua`, setup stays
visible in each plugin module, and mappings stay in `config/keymaps.lua`.

The latest feature request was to install and test a practical notebook workflow
using `/Users/stasbebra2006/B261/BI-ML1/01`. Those files contain the user's saved
pandas work, CSV dependencies, unfinished exercises, and Matplotlib/IPython cells.
The user prefers cell-associated/focusable output over one shared REPL history.
A permanent code-left/output-right sidebar was not implemented or promised by
the selected stack; current output inspection is a focused floating window.

We inspected the pyworks/Molten demo at
https://www.youtube.com/watch?v=D_y4YkZqGRY and chose upstream Molten + Jupytext,
reusing already-installed Snacks for images. Pyworks, its forks, Iron, Quarto,
otter.nvim, image.nvim, and Jupynvim were not installed.

The user interrupted the implementation after asking whether Ghostty was asked
to record the screen. An agent-issued macOS `screencapture -x` command attempted
visual verification and failed with `could not create image from display`.
No screenshot was obtained. It can cause a Screen Recording prompt attributed
to Ghostty. Do not retry screen capture or change privacy permissions without a
new explicit request. Tmux text captures did not provide final rendered pixels.

The user then requested the checkpoint and publication instead of finishing
output export. The broken `Space j w` mapping was removed before wrapping; no
replacement no-op, fake successful save, or automatic export was added.

## Completed earlier in this conversation

These previously uncommitted profile changes are included in this checkpoint:

- Startup `mocha-custom` theme and optional Tokyo Night/Catppuccin selection.
- Lualine global statusline and Noice command/message UI; normal Neovim remains
  the editor for the configuration, with `nvim-own` used for feature tests.
- Native Ctrl-h/j/k/l window movement; insert-mode editing remains unchanged.
- Flash pinned to `5f0f270fdc7c5b0c21d903ee85b9cb06f2ac636a`; `s`, `S`, operator
  `r`, and operator/visual `R` map its jump/Tree-sitter/remote/search operations.
- Shared C/C++ `clangd` language declaration, C/C++ Tree-sitter grammars, and
  manual `Space c f` formatting filtered to Ruff or clangd.
- CMake 4.4.4 and clang-format 23.1.2 installed with Homebrew; clangd 23.1.0
  installed in nvim-own's Mason directory, not the normal LazyVim profile.
- Earlier isolated C17/C++20 CMake smoke built and ran both executables, each
  printing result 42. It exercised clangd attachment, standard headers,
  cross-file navigation, completion, diagnostics, formatting, source/header
  switching, C/C++ Tree-sitter, Flash syntax selection, and retained Python
  Ruff formatting. The C/C++ smoke workspace/editor was already removed.

See README for the current UI/C/C++ ownership and keymaps. Do not revert those
features merely to remove the notebook experiment below.

## Historical notebook implementation and installed state (Mac)

Source repository: `/Users/stasbebra2006/.local/share/chezmoi`.
Live profile: `~/.config/nvim-own`; data: `~/.local/share/nvim-own`.
The existing `nvim-own` wrapper sets `NVIM_APPNAME=nvim-own` and selects the
separate `~/.local/opt/nvim-unstable` core. No normal LazyVim files were changed.
At wrap, the actual core reported `v0.13.0-dev-1596+g28ff47b8a4` with LuaJIT,
on this arm64 macOS workstation.

Historical notebook-specific authored files, now removed:

| File | Purpose |
| --- | --- |
| `dot_config/nvim-own/lua/plugins/jupytext.lua` | Explicit Jupytext setup; pin `c8baf3ad344c59b3abd461ecc17fc16ec44d0f7b`; eager BufReadCmd; Python Hydrogen representation. |
| `dot_config/nvim-own/lua/plugins/molten.lua` | Upstream Molten pin `bedea63819c618e007e7c40059fc6e72d598c8df`; Snacks provider, output options, and saved-output import after explicit kernel selection. |
| `dot_config/nvim-own/lua/config/notebooks.lua` | Locate the current `# %%` cell, reject Markdown/raw text cells, and execute its one-based line range with Molten. |

Historical notebook additions to existing files, now reverted:

- `dot_config/nvim-own/init.lua`: `g:python3_host_prog` points to the isolated host
  before lazy.nvim can build remote-plugin registrations.
- `lua/plugins/init.lua`: explicit `plugins.jupytext` and `plugins.molten` entries.
- `lua/config/keymaps.lua`: Python-only `nvim-own-notebook-keymaps` FileType group.
- `lua/plugins/which-key.lua`: `Space j` notebook group.
- `lua/plugins/snacks.lua`: `image` enabled; document auto-scanning disabled;
  maximum image width/height 100 columns/24 rows.
- `dot_config/tmux/general.conf`: `allow-passthrough on` for Kitty graphics.
  The existing keyboard/F12 passthrough configuration was not changed.
- `docs/nvim-own/README.md`: experimental workflow and explicit export warning.

Installed outside Git on the Mac during the experiment:

- `~/.local/share/nvim-own/notebook-venv`: uv-created Python 3.12.13 host with
  pynvim 0.6.0, jupyter-client 8.10.0, nbformat 5.11.1, Pillow 12.3.0, and their
  dependencies. This is not the coursework kernel and does not contain its
  scientific packages.
- Jupytext 1.19.6 via `uv tool install --python 3.12 jupytext`, exposing
  `~/.local/bin/jupytext` and `jupytext-config`.
- Homebrew ImageMagick 7.1.2-32; new dependencies freetype, aom, libde265, libheif,
  m4, and libtool. Do not broadly autoremove dependencies shared with other tools.
- Downloaded Molten and Jupytext plugins under `~/.local/share/nvim-own/lazy/`.
- Generated `~/.local/share/nvim-own/rplugin.vim` registers Molten. The generated
  live `lazy-lock.json` remains unmanaged in chezmoi source.
- New user kernelspec `~/Library/Jupyter/kernels/bi-ml1`, registered by
  `/opt/miniconda3/envs/bi-ml1/bin/python -m ipykernel install --user --name bi-ml1
  --display-name 'Python (BI-ML1)'`.
- The existing Conda environment itself was not created or upgraded. Observed:
  Python 3.12.11, pandas 2.3.2, NumPy 2.3.3, Matplotlib 3.10.6, ipykernel 6.30.1.

Current notebook controls: `]j`/`[j` cell boundaries; `Space j i` kernel chooser;
`j r` current cell/visual selection; `j l` line; `j o` focused output; `j h` hide;
`j p` import; `j x` interrupt; `j k` restart keeping output; `j I` information.
All are Python-buffer-local. There is no `j w` binding in the wrapped version.
Three-line inline previews use bottom truncation; wrapping is off. Plots appear
in the manually opened output window, not in the inline preview.

Kernel and LSP environments are independent. The successful DataFrame-completion
smoke inherited `PATH=/opt/miniconda3/envs/bi-ml1/bin:$PATH` and
`CONDA_PREFIX=/opt/miniconda3/envs/bi-ml1` before Neovim started. Activating Conda
in the user's initialized shell is the intended equivalent. Choosing `bi-ml1`
in Molten alone does not switch Pyright's interpreter. Launch from the notebook
asset directory: Molten's Python host starts the kernel with its own startup cwd.

## Observed notebook verification

Only copies under `/tmp/nvim-own-notebook.euKjZV` were executed or saved.
The agent-owned editor was tmux window `@25`, pane `%25`; earlier registration
attempts used `@23/%23` and `@24/%24`. Those experimental editors were closed.
Persistence saving was disabled for the experiments; user editors were preserved.
Agent-injected NO_COLOR/FORCE_COLOR/CLICOLOR overrides were removed when launching
children; Neovim reported NO_COLOR and FORCE_COLOR absent.

- Original template: 74 cells, 18 cells with saved output, no saved PNG plots.
  Ordinary `:w` preserved every saved output payload and execution count.
- Original full notebook: 75 cells, 40 cells with saved output, four PNG plots.
  Its copied notebook's output payloads remained unchanged after saving inputs,
  including an added test cell; the attempted export failed before replacing
  them. The new table cell had no persisted output afterward.
- Real kernel selection was exercised with `Space j i`, the Snacks chooser,
  and Enter selecting `bi-ml1`. Saved results imported without executing cells.
- The original percent representation commented `%matplotlib inline`. Molten
  imported only 37 cells from the full notebook and had no histogram cell output.
  Switching to Hydrogen preserved the raw magic; Molten reported 50 imported
  code/output cells, including the saved histogram and other PNG outputs.
- Actual mapped cell execution succeeded for imports (`Out[1]`), relative
  `data1.csv` loading (`Out[2]`), Matplotlib plus `%matplotlib inline` (`Out[3]`),
  and `df.Age.plot(kind='hist', title="Passenger age distribution")` (`Out[4]`).
- Pyright attached with the scientific environment and returned DataFrame
  completions `shape`, `columns`, and `head`; unresolved pandas/NumPy imports
  disappeared. Ruff formatting requests returned an edit without an RPC error.
  Those formatting requests were inspected, not applied to the coursework copy.
- A new copied-notebook cell ran
  `print(df.head(80).to_string(index=False))` (`Out[5]`). The focusable output
  buffer contained the PassengerId header, all 80 rows, and the final passenger
  row. It was 83 buffer lines, 120 window columns, with `wrap=false`.
- In the actual output window, `G` reached the final rows; on the final populated
  row, `zL` moved `leftcol` to 106 and `zH` back to 46. Text capture showed the
  scrolled rows and previously hidden columns. Horizontal movement on the final
  empty padding line did not scroll; that was a smoke-driver mistake, not a
  production change.
- `Space j o` focused the histogram output. Snacks created the image placement
  and Kitty Unicode placeholders were visible in the tmux capture. Final rendered
  Ghostty pixels were not inspected because macOS screen capture failed.
- Pyright still reports notebook-only `%matplotlib` syntax and `display` builtins
  as static issues; unfinished Ellipsis exercises also legitimately produce
  diagnostics. No global suppression or coursework solution edits were added.
- No permanent tests were added. This was an actual-editor smoke, not a mocked
  plugin-wiring test or a blanket health-check campaign.
- Final wrap startup smoke opened the copied notebook as Python, retained the
  run-cell binding, and confirmed the failing save-with-outputs binding absent.
  Scoped chezmoi status/diff matched live; the original notebook hashes below
  were rechecked unchanged.

The first lazy.nvim installation generated an empty remote-plugin manifest:
its new plugin's init callback had not supplied the provider early enough,
leading to `v:null is not executable`. Moving the host selection to `init.lua`
and running `nvim-own --headless +UpdateRemotePlugins +qa` successfully registered
`['molten']`. Do not install pynvim into Homebrew's system Python to work around
this. An eval-side pip attempt hit PEP 668; no system packages were changed.
The smoke was driven through the real Neovim socket and `--remote-expr` instead.

## Unresolved output-export failure and historical reproducer

The removed `Space j w` callback ran `:write` followed by `:MoltenExportOutput!`.
Writing inputs succeeded; exporting fresh results raised:

```text
rplugin/python3/molten/ipynb.py, line 176, in export_outputs
    nbformat.v4.new_output(...)
TypeError: new_output() got multiple values for argument 'output_type'
```

The copied full notebook includes an imported `ValueError` output in zero-based
cell 48, from the illustrative `dfn.set_index("PassengerId", ..., verify_integrity=True)`
cell. No runtime error was produced by the five newly executed smoke cells.

[INFERENCE] Likely cause: `handle_output_types`' error branch assigns the entire
saved output dictionary to `ErrorOutputChunk.extras`, including `output_type`.
The exporter passes `chunk.output_type` positionally and `**chunk.extras`, supplying
that parameter twice. This has not been fixed or confirmed with a passing export.

Reproducer retained for history, not an active task: on a fresh copy of the full
notebook containing that imported error output, initialize `bi-ml1`, execute one
simple cell, and call non-bang `MoltenExportOutput` so a successful probe would
write `copy-of-...ipynb` rather than replace the input notebook. Any future
investigation requires a new user request and should inspect the error branch and
exporter in the pinned revision. Do not patch only a downloaded clone, discard
imported errors, or suppress the exception as a supposed fix.

After a real fix: verify text/error/image payloads, execution counts, metadata,
and cell identity through export and reopen; include duplicate code cells because
Molten matches by code/order. Only then restore a save-with-outputs binding.
Saving fresh results and reopening them is NOT verified by this checkpoint.
Do not infer authorization to switch to Jupynvim or install the larger Quarto stack.

## Original coursework safety

Neither original notebook nor its CSV/assets was edited. Original SHA-256 values:

```text
a7237dee61ad6796852c722279d7e15e44cc366d45213cbeafe4a95ac466e2a8  01_introduction_cs_template.ipynb
5f53e1eb755a5fbdd658811ac9f8e194c6c8aaf85b320ac6c8712c1992012eb6  01_introduction_cs_full.ipynb
```

The coursework progress document says the user is at joining datasets (template
cell 41). Do not solve the remaining exercises or execute all unfinished cells
when resuming configuration work. No commit was made in the coursework repository.

## Cross-machine cleanup checklist

The source edits and scoped apply are already complete on Linux. This checklist
is for the Mac's previously installed, outside-Git artifacts; **those uninstall
steps have not been executed here**. Inspect its current state first because other
consumers may have started using packages since the original checkpoint.

1. Pull and integrate the notebook-retirement commit once published on `main`.
   Pulling only the original implementation checkpoint does not remove anything.
   Avoid reverting that implementation commit wholesale: it also contains
   unrelated UI/Flash/C/C++ work.
2. On the Mac, preserve live/source drift, preview
   `chezmoi diff --recursive ~/.config/nvim-own ~/.config/tmux/general.conf`, then
   apply that reviewed scope. `.chezmoiremove` retires these exact live files:

   ```text
   .config/nvim-own/lua/config/notebooks.lua
   .config/nvim-own/lua/plugins/jupytext.lua
   .config/nvim-own/lua/plugins/molten.lua
   ```

   Explicitly check the files are absent; an empty rendered diff alone is not proof
   that retired, no-longer-managed files were deleted.
3. Save and close/restart affected `nvim-own` instances without discarding user
   buffers. Already-loaded plugins/autocmds will not disappear simply because
   their files were removed. In an existing tmux server, explicitly run
   `tmux set-option -g allow-passthrough off`; removing the config line alone
   does not unset an inherited runtime value. Preserve the F12 passthrough setup.
4. Before deleting the Python host, inspect its `jupyter kernelspec list --json`.
   Remove only the experiment-created `bi-ml1` user kernelspec if unused elsewhere;
   the original location was `~/Library/Jupyter/kernels/bi-ml1`. Its removal does
   not require deleting or modifying `/opt/miniconda3/envs/bi-ml1`.
5. If no other workflow uses the CLI, run `uv tool uninstall jupytext`. This removes
   its dedicated tool environment and exposed launchers, not scientific packages
   in the coursework environment. Do not uninstall uv or its unrelated tools.
6. Remove only the unused plugin directories
   `~/.local/share/nvim-own/lazy/molten-nvim` and
   `~/.local/share/nvim-own/lazy/jupytext.nvim`. Remove their entries from the
   unmanaged live `~/.config/nvim-own/lazy-lock.json`, preserving all other entries.
   Do not delete the complete plugin/data directory or lockfile.
7. Inspect `~/.local/share/nvim-own/rplugin.vim`. At the original checkpoint it
   registered only Molten, so removing that sole-plugin manifest was appropriate.
   If another remote plugin has since been registered, rebuild its manifest with
   its own valid host instead of deleting shared registrations.
8. Remove `~/.local/share/nvim-own/notebook-venv` only after checking that no other
   Python-host feature uses it. Remove the notebook image cache at
   `~/.cache/nvim-own/snacks/image` if still unused. Keep all unrelated caches,
   editor state, sessions, parsers, Mason tools, and lazy.nvim itself.
9. ImageMagick was newly installed for plot rendering. If unused by other tools,
   uninstall it with `brew uninstall imagemagick`. Its recorded new dependencies
   were freetype, aom, libde265, libheif, m4, and libtool; do not broadly run
   `brew autoremove` or remove libraries now shared with other packages.
10. Preserve the existing Conda `bi-ml1` environment, all coursework notebooks and
    assets, Snacks navigation, themes, completion, Pyright/Ruff/clangd, C/C++/Python
    parsers, CMake, and clang-format. This retires the Neovim notebook experiment,
    not the user's scientific-computing environment.
11. Verify the three retired live modules, notebook bindings, host override, and
    plugin registrations are gone. Record the package/kernel/manifest cleanup
    actually performed; do not infer it from a clean chezmoi diff.

The original temporary notebook workspace and downloaded demo workspace were
removed during the historical wrap. No coursework originals were edited. Preserve
the user's existing editor/tmux panes; retirement is not permission to close them.

## Publication state at checkpoint creation

Branch `main` tracks `origin/main`; both were `cef006f` after fetching origin.
The ahead/behind count was `0 0`. Remote is
`git@github.com:stasbebra2006/dotfiles.git`.

The user explicitly authorized a new commit and normal push of the reviewed
session changes: nvim-own authored configuration/docs and the one tmux graphics
setting. No force push, amend, coursework commit, or unrelated staging is intended.
This file is written before publication; its enclosing commit is the checkpoint.
Inspect that commit and the remote ref for the final outcome rather than treating
this pre-publication paragraph as a successful-push claim.
