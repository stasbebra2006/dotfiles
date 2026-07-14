# Tmux

## Managed Config

```text
Source: dot_config/tmux/tmux.conf.tmpl
Target: ~/.config/tmux/tmux.conf
```

The target path is shared by Linux and macOS. The template changes only the
copy-mode clipboard command:

- Linux/Wayland: `wl-copy`
- macOS: `pbcopy`

When importing live changes, edit the template and retain both conditional
branches. Do not replace the template with the rendered Linux file.

## Current Shared Behavior

- Prefix: `Ctrl-s`
- Reload: prefix followed by `r`
- Mouse enabled and window/pane indexes start at 1
- Vim pane navigation: `h`, `j`, `k`, `l`
- Current-directory splits: `|` and `-`
- Status bar at the top with the neutral theme
- Copy mode uses vi keys

TPM is declared as `tmux-plugins/tpm` and loaded at runtime from:

```text
~/.tmux/plugins/tpm/tpm
```

There are also plugin copies managed under `~/.config/tmux/plugins`. These are
not the path loaded by the current tmux config. Treat this as a known layout
inconsistency; do not remove or reorganize plugin directories without explicit
approval.
