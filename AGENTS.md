# Agent Entry Point

This repository is the chezmoi source for shared dotfiles. Read
`docs/chezmoi.md` before changing managed configuration, then read the note for
the tool being changed.

## Safety Rules

- Treat the current machine's live config as authoritative unless the user says
  otherwise.
- Never run `chezmoi apply` unless the user explicitly requests it.
- Start with `chezmoi status`, `chezmoi diff`, and `git status` in this source
  repository.
- For direct-copy files, sync intended live changes into the source.
- For `.tmpl` files, reconcile changes manually and preserve OS conditionals;
  chezmoi cannot reconstruct template logic from a rendered file.
- After syncing, verify that `chezmoi diff` is empty for the affected files.
- Do not commit or push unless the user requests it.
- `.ideavimrc` is intentionally not managed while its setup is unfinished.

## Cross-Machine Sync

Before pulling on a machine that has local config changes:

1. Inspect `chezmoi status`, `chezmoi diff`, and the source repository's
   `git status`.
2. Reconcile wanted live changes into the source/template and commit them
   locally so they cannot be overwritten.
3. Run `git pull --rebase` to replay those local commits after remote commits.
4. Resolve conflicts in the source, preserving intended changes from both
   machines and all OS-specific template branches.
5. Review `git diff` and `chezmoi diff`. Apply only with explicit user approval.
6. Push only when requested.

Do not use `chezmoi update` for this workflow because it combines pulling and
applying. After cross-machine work, report the local changes captured, remote
changes received, conflicts and resolutions, verification performed, and
whether anything was applied, committed, or pushed.

## Tool Notes

- `docs/chezmoi.md`: repository layout and safe synchronization workflow
- `docs/neovim-vscode.md`: LazyVim and VSCode Neovim startup/config ownership
- `docs/tmux.md`: tmux template, clipboard conditions, and plugin paths
- `docs/zsh.md`: zsh template and OS-specific behavior

`AGENTS.md` and `docs/` are source-repository documentation. They are excluded
by `.chezmoiignore` and must not be deployed into the home directory.
