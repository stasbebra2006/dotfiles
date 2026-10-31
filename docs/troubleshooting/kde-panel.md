# KDE panel

## Pin Firefox (2026-10-26)

Firefox was installed but absent from the pinned launchers. On Plasma 6.8.1
(Firefox 158.0.1), appended `applications:firefox.desktop` through Plasma's
`evaluateScript` D-Bus API to panel 3, Icons-only Task Manager widget 6.
Verified the live launcher list and persisted configuration; the file diff
contained only the added launcher. Existing pins were preserved.

The panel configuration is not managed by chezmoi. A backup is stored in
`~/.local/state/plasma-panel-backups/desktop-appletsrc-20261026-135416`.
