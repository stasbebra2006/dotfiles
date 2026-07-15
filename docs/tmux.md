# Tmux

## Managed Config

```text
Tmux source:   dot_config/tmux/tmux.conf.tmpl
Tmux target:   ~/.config/tmux/tmux.conf
Konsole source: dot_local/share/kxmlgui5/konsole/konsoleui.rc
Konsole target: ~/.local/share/kxmlgui5/konsole/konsoleui.rc
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
- Prefix-free window navigation: `Ctrl-Tab` for next and `Ctrl-Shift-Tab` for
  previous
- Extended-key reporting enabled so terminals can distinguish those modified
  Tab keys from ordinary Tab and Backtab
- Mouse enabled and window/pane indexes start at 1
- Vim pane navigation: `h`, `j`, `k`, `l`
- Current-directory splits: `|` and `-`
- Status bar at the top with the neutral theme
- Copy mode uses vi keys

## Konsole Integration

Konsole normally reserves `Ctrl-Tab` and `Ctrl-Shift-Tab` for its **Last Used
Tabs** actions, preventing those keys from reaching tmux. On Linux, chezmoi
therefore manages `konsoleui.rc` with these Konsole shortcuts moved to:

- Last Used Tabs: `Ctrl-Up`
- Last Used Tabs (Reverse): `Ctrl-Down`

The tmux reverse binding is written as `C-BTab` because tmux normalizes an
incoming `Ctrl-Shift-Tab` to Control-Backtab. Both the Konsole override and the
tmux bindings are required for prefix-free switching to work.

On iTerm2, also enable **Profiles > Keys > General > Apps can change how keys
are reported**. This lets tmux negotiate extended-key reporting with iTerm2.

The Konsole file is excluded on non-Linux systems by `.chezmoiignore`. After
changing its shortcuts, restart Konsole so new windows load the override.

TPM is declared as `tmux-plugins/tpm` and loaded at runtime from:

```text
~/.tmux/plugins/tpm/tpm
```

There are also plugin copies managed under `~/.config/tmux/plugins`. These are
not the path loaded by the current tmux config. Treat this as a known layout
inconsistency; do not remove or reorganize plugin directories without explicit
approval.
