# Zsh

## Managed Config

```text
Source: dot_zshrc.tmpl
Target: ~/.zshrc
```

The template is shared between Arch Linux, Ubuntu Server, and macOS. Preserve
all three branches when syncing changes from a rendered local file. Linux
variants are selected with `.chezmoi.osRelease.id`.

Shared behavior:

- Oh My Zsh with the `robbyrussell` theme
- `git` plugin
- `~/.npm-global/bin`, `/usr/bin`, and `~/.local/bin` added to `PATH`
- Optional sourcing of `~/.local/bin/env`
- `EDITOR` and `SUDO_EDITOR` set to `nvim`

Arch Linux behavior:

- Arch/Hyprland aliases
- Pacman/paru update alias
- Suspend aliases using `systemctl`

Ubuntu Server behavior:

- `apt` update/upgrade alias
- No Hyprland or pacman aliases
- No short suspend aliases, avoiding accidental loss of remote access

macOS behavior initializes Homebrew through `/opt/homebrew/bin/brew` and
provides an `update` alias for Homebrew maintenance.

Chezmoi Zsh completion is installed separately under
`~/.local/share/zsh/site-functions/_chezmoi`; it is not currently represented
in this source repository.
