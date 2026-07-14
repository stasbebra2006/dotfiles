# Zsh

## Managed Config

```text
Source: dot_zshrc.tmpl
Target: ~/.zshrc
```

The template is shared between Linux and macOS. Preserve both OS branches when
syncing changes from a rendered local file.

Shared behavior:

- Oh My Zsh with the `robbyrussell` theme
- `git` plugin
- `~/.local/bin` added to `PATH`
- Optional sourcing of `~/.local/bin/env`
- `EDITOR` and `SUDO_EDITOR` set to `nvim`

Linux-only behavior:

- Arch/Hyprland aliases
- Pacman/paru update alias
- Suspend aliases using `systemctl`

macOS-only behavior initializes Homebrew through `/opt/homebrew/bin/brew` and
provides an `update` alias for Homebrew maintenance.

Chezmoi Zsh completion is installed separately under
`~/.local/share/zsh/site-functions/_chezmoi`; it is not currently represented
in this source repository.
