# Tmux

## Managed Config

```text
Tmux source:   dot_config/tmux/tmux.conf.tmpl
Tmux target:   ~/.config/tmux/tmux.conf
Konsole source: dot_local/share/kxmlgui5/konsole/konsoleui.rc
Konsole target: ~/.local/share/kxmlgui5/konsole/konsoleui.rc
```

The target path is shared by Arch Linux, Ubuntu Server, and macOS. The template
changes only clipboard integration:

- Arch Linux/Wayland: `wl-copy`
- Ubuntu Server/SSH: tmux OSC 52 clipboard forwarding
- macOS: `pbcopy`

When importing live changes, edit the template and retain all three conditional
branches. Do not replace the template with a rendered machine-specific file.

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
Tabs** actions, preventing those keys from reaching tmux. On the Arch Linux
desktop, chezmoi therefore manages `konsoleui.rc` with these Konsole shortcuts
moved to:

- Last Used Tabs: `Ctrl-Up`
- Last Used Tabs (Reverse): `Ctrl-Down`

The tmux reverse binding is written as `C-BTab` because tmux normalizes an
incoming `Ctrl-Shift-Tab` to Control-Backtab. Both the Konsole override and the
tmux bindings are required for prefix-free switching to work.

On iTerm2, also enable **Profiles > Keys > General > Apps can change how keys
are reported**. This lets tmux negotiate extended-key reporting with iTerm2.

The Konsole file is excluded on Ubuntu Server and non-Linux systems by
`.chezmoiignore`. The SSH client machine owns its terminal configuration. After
changing shortcuts on the Arch desktop, restart Konsole so new windows load
the override.

On Ubuntu Server, tmux copy mode stores the selection in tmux and emits OSC 52.
The escape sequence crosses SSH so a compatible client terminal can place it
in the client machine's clipboard. The client terminal must permit OSC 52.

TPM is declared as `tmux-plugins/tpm` and loaded at runtime from:

```text
~/.config/tmux/plugins/tpm/tpm
```

This path is managed by chezmoi, so the tmux configuration is self-contained on
a fresh Arch Linux, Ubuntu Server, or macOS installation.
