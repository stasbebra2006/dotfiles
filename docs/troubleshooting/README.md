# Troubleshooting

Use the dated verification and limitations in each note before repeating a fix.
An unresolved investigation is not a verified remedy.

| Topic | Notes |
| --- | --- |
| [Linux audio](linux-audio.md) | HyperX popping, completed experiments, rollback state, and proposed tests; unresolved. |
| [Gaming on Arch Linux](linux-gaming.md) | Steam/Mesa setup and Valheim FPS drops with Night Light. |
| [USB wake and suspend](linux-sleep.md) | USB wake policy, saved udev rule, verification, and undo; successful suspend remains unconfirmed. |
| [KDE panel](kde-panel.md) | Restoring a missing pinned Firefox launcher. |
| [Zsh history](zsh.md) | Repairing NUL-byte corruption while preserving valid history. |
| [Neovim and VS Code](../nvim/troubleshooting.md) | Editor profiles, highlighting, language servers, notebook synchronization, and key behavior. |

Detailed [research records](research/README.md) retain evidence and experimental
history. Supporting files stay beside their topic; the USB wake rule is in
[`linux-sleep/`](linux-sleep/99-disable-usb-wakeup.rules) and is not installed by
chezmoi.

[All configuration notes](../README.md)
