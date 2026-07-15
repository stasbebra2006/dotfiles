# Chezmoi Workflow

## Current Setup

- Source repository: `~/.local/share/chezmoi`
- Remote: `git@github.com:stasbebra2006/dotfiles.git`
- Destination: the user's home directory
- New-machine bootstrap: `chezmoi init --apply git@github.com:stasbebra2006/dotfiles.git`

Important mappings:

```text
dot_zshrc.tmpl                       -> ~/.zshrc
dot_config/nvim/                     -> ~/.config/nvim/
dot_config/tmux/tmux.conf.tmpl       -> ~/.config/tmux/tmux.conf
dot_local/share/kxmlgui5/konsole/    -> ~/.local/share/kxmlgui5/konsole/
```

Chezmoi converts `dot_` to `.`. A `.tmpl` suffix means the source is rendered
as a Go template before being written to its destination.

## Direction of Changes

```text
Git remote <-> ~/.local/share/chezmoi -> live files in $HOME
                  git                  chezmoi apply
```

`chezmoi apply` writes the rendered source into the home directory and can
overwrite live edits. It is not a command for importing local changes.

When the live file should win:

1. Inspect `chezmoi status` and `chezmoi diff`.
2. For a direct-copy file, import the live version with `chezmoi add` or update
   its source file directly.
3. For a template, manually merge the live changes into the `.tmpl` source and
   preserve all template branches.
4. Re-run `chezmoi diff`; the affected file should produce no output.
5. Review `git diff`, then commit and push only when requested.

In `chezmoi status`, the first column compares the last applied state with the
live file. The second compares the live file with the current rendered target.
`MM` means the live file changed and an apply would also modify it.

## Concurrent Changes on Multiple Machines

Chezmoi does not merge rendered files between machines. Git merges the shared
source files and templates.

On a machine with wanted local changes:

1. Import or manually reconcile the live changes into the chezmoi source.
2. Commit them locally.
3. Run `git pull --rebase`.
4. If Git reports a conflict, edit the source/template to combine the intended
   local and remote behavior, then continue the rebase.
5. Review the resulting `chezmoi diff`; apply only after confirming that it
   will not discard wanted machine-local changes.
6. Push the combined history when requested.

`git pull` fetches remote changes and integrates them, commonly by creating a
merge commit when histories diverge. `git pull --rebase` instead replays local
commits after the fetched remote commits, keeping a linear history. It still
requires manual conflict resolution when both machines changed the same lines.

Avoid `chezmoi update` during reconciliation because it pulls and applies in a
single operation.

## Repository-Only Files

`AGENTS.md` and `docs/` are listed in `.chezmoiignore`. They remain in Git but
are not written to `~/AGENTS.md` or `~/docs` by chezmoi.

`.ideavimrc` is intentionally unmanaged until that setup is finished.

## Machine Variants

Templates support three machine types:

- Arch Linux desktop: detected by `.chezmoi.osRelease.id == "arch"`
- Ubuntu Server: detected by `.chezmoi.osRelease.id == "ubuntu"`
- macOS: detected by `.chezmoi.os == "darwin"`

Use OS-release conditions for Linux-specific behavior. The Ubuntu Server is
accessed over SSH, so it uses OSC 52 clipboard forwarding and does not deploy
the Arch desktop's Konsole override.
