# Dotfiles

My cross-platform terminal and editor configuration, managed with
[chezmoi](https://www.chezmoi.io/). The same source supports macOS and Linux,
with small OS-specific branches for shell setup, clipboard integration, and
Konsole shortcuts.

This is a personal setup rather than a general-purpose distribution. Feel free
to borrow from it, but review the templates before applying them to your home
directory.

## What's included

| Area | Highlights |
| --- | --- |
| Zsh | Oh My Zsh, the `robbyrussell` theme, Git integration, and OS-specific update aliases |
| Neovim | LazyVim-based configuration, custom navigation and UI behavior, plus a lightweight VS Code Neovim startup path |
| tmux | `Ctrl-s` prefix, Vim-style pane navigation, prefix-free window switching, current-directory splits, and vi copy mode |
| Terminal integration | Wayland/macOS clipboard support and Linux Konsole shortcut overrides |

The principal source-to-destination mappings are:

```text
dot_zshrc.tmpl                        -> ~/.zshrc
dot_config/nvim/                      -> ~/.config/nvim/
dot_config/tmux/tmux.conf.tmpl        -> ~/.config/tmux/tmux.conf
dot_local/share/kxmlgui5/konsole/     -> ~/.local/share/kxmlgui5/konsole/
```

Files ending in `.tmpl` are Go templates rendered by chezmoi. The Konsole
configuration is installed only on Linux.

## Requirements

At minimum, install [Git](https://git-scm.com/) and
[chezmoi](https://www.chezmoi.io/install/). Depending on which configuration
you use, you will also want:

- Zsh and [Oh My Zsh](https://ohmyz.sh/)
- [Neovim](https://neovim.io/) and a Nerd Font
- [tmux](https://github.com/tmux/tmux)
- `wl-copy` on Wayland; macOS uses the built-in `pbcopy`
- Homebrew on macOS, installed at `/opt/homebrew`

Linux-specific shell aliases currently assume an Arch Linux setup and may
reference `pacman`, `paru`, Hyprland, and `systemctl`.

## Installation

Initialize the repository without applying it immediately:

```sh
chezmoi init https://github.com/stasbebra2006/dotfiles.git
```

Review what would change:

```sh
chezmoi diff
```

Then apply the configuration when you are satisfied:

```sh
chezmoi apply
```

The tmux configuration loads TPM from `~/.tmux/plugins/tpm/tpm`. Install TPM at
that location if it is not already present:

```sh
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Inside tmux, press prefix + <kbd>I</kbd> to install declared plugins.

## Updating

Preview remote changes before applying them:

```sh
chezmoi git -- pull --rebase
chezmoi diff
chezmoi apply
```

When editing a managed file locally, use `chezmoi edit` or reconcile the change
back into the source directory before pulling. In particular, preserve the OS
branches in `.tmpl` files rather than replacing a template with its rendered
output.

## Repository layout

```text
.
├── dot_config/       # ~/.config
├── dot_local/        # ~/.local
├── dot_zshrc.tmpl    # ~/.zshrc template
├── docs/             # setup and maintenance notes
└── AGENTS.md         # repository automation guidance
```

More implementation details are documented in [`docs/`](docs/), including the
chezmoi workflow and notes for Zsh, tmux, Neovim, and VS Code Neovim.

## License

My original configuration is available under the [MIT License](LICENSE).
Vendored components remain subject to their own license files.
