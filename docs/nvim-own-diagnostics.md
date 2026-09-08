# nvim-own: diagnostic lifecycle investigation

[Back to the project guide](nvim-own.md)

Historical findings from 2026-08-27–29, with a fresh comparison on 2026-09-08.
Version numbers below identify tested builds, not current release recommendations.

## Observed results

| Test | Core | Diagnostics before → after |
| --- | --- | --- |
| Earlier investigation: plain `:edit` | 0.12.4 | 20 → 0 |
| Earlier investigation: same reload | Controlled 0.13 development build | 20 → 20 |
| Minimal `nvim-own`: delete/reopen `register.py` | 0.12.5, Pyright 1.1.413 | 13 → 0 |
| Same minimal lifecycle comparison | `0.13.0-dev-1212+g8d2b50c0ce`, Pyright 1.1.413 | 13 → 13 |
| 2026-09-08: delete/reopen AIQ `clarifier/register.py` | 0.12.5, Pyright 1.1.413 | 13 → 0 |
| Same file and current `nvim-own` config | `0.13.0-dev-1558+g8d5ebdf986`, Pyright 1.1.413 | 13 → 13 |

The fresh comparison left one Pyright client attached on both cores. A tiny
standalone file did not reproduce the failure: both cores preserved its two
diagnostics after reload and delete/reopen. Workspace context matters. The new
nightly also cleared those diagnostics after correcting the unsaved buffer text.
Flash's targeted search-state save/restore smoke test passed with the installed
checkout; this is not a full plugin compatibility test.

On the 0.12.5 failure, one initialized Pyright client remained attached, pull
support was enabled, the buffer was unmodified, and diagnostics stayed empty for
at least 30 seconds. The reproduction did not require LazyVim, Snacks, Bufferline,
Tree-sitter, Noice, or Blink.

The stable-build probe used a temporary mapping that set `bufhidden=delete` and
opened netrw, deleting the file buffer when it was replaced. That mapping was
process-only; the persisted `Space e` mapping simply runs `:Explore`.

## Mechanism established in the inspected source

Neovim's built-in LSP client exchanges JSON-RPC messages with a separate Pyright
process over stdin/stdout. `textDocument/didOpen` supplies a document URI and buffer
text, including unsaved contents. A pull request uses `textDocument/diagnostic`.
Neovim buffer numbers stay local; Pyright identifies documents by URI.

Two Neovim subsystems retained different parts of the response:

- `vim.diagnostic`: diagnostic items, indexed by buffer and namespace.
- `vim.lsp.diagnostic`: pull state, including the client result ID.

In the inspected 0.12.5 path:

1. A full report populated diagnostic items and saved its `resultId`.
2. Detach cleared the items but retained `bufstates[bufnr].client_result_id`.
3. Reattachment sent the stale ID as `previousResultId`.
4. Pyright returned `kind="unchanged"`, with no replacement items.
5. Neovim had already discarded the items that response assumed it still held.

Pyright 1.1.413 used `sourceFile.getDiagnosticVersion().toString()` for its result
ID, not a content hash. An unchanged source file could retain version `"3"` across
close/open because the workspace analyzer still owned it.

The tested 0.13 source cleared both the diagnostic payload and the corresponding
client result-ID state on detach, allowing reattachment to request a full report.

## Scope and unresolved questions

- A separate earlier problem concerned effective Python interpreter/settings when
  launching outside the project root. Do not conflate it with lost pull results.
- The user's recollection of stale errors after edits and Snacks/Bufferline closes
  was not established as the same bug. Compare that path only after a native baseline.
- A historical Flash search-state smoke test passed with checkout `5f0f270fdc7c5b0c21d903ee85b9cb06f2ac636a`,
  which included fix `7eff7f8873f87472944d78d0e655920efdc83933`. This did not validate
  the whole plugin setup against a development Neovim core.

For future core upgrades, repeat the project-file comparison and check client
attachment; a standalone sample alone did not expose this regression.

## Original evidence

The earlier investigation was recorded under
`~/stasbebra2006/Projects/neovim-python-lsp-investigation/`: start with `README.md`,
then `conclusion.md`, `evidence.md`, and `recommended-changes.md`. Archived config
is evidence to inspect, not a template to copy into this profile.

The full pre-cleanup journal remains recoverable from chezmoi Git history:

```sh
git show 8653f7d^:docs/nvim-own.md
```
