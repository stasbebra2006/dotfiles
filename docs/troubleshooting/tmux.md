# tmux startup, popup styling, and switcher preview

Checked on macOS (`tmux next-3.9`, `HEAD-a73616d`) and verified against `tmux 3.8`.

## Symptoms

1. On startup, tmux flashed `Tmux resurrect file not found!` for 5 seconds.
2. Sourcing `~/.config/tmux/appearance.conf` on `tmux next-3.9` failed with:
   - `invalid option: popup-style`
   - `invalid option: popup-border-style`
   - `invalid option: popup-border-lines`
3. Opening the session switcher (`prefix + s`) showed an empty preview below the separator and logged `can't find pane: =0` and `invalid option: @note` in `tmux show-messages`.
4. In `tmux next-3.9`, the `Sessions` / `Windows` switcher preview captured the floating popup itself (producing a recursive hall-of-mirrors preview on reload, e.g. pressing `c`) and listed the temporary popup pane in the session pane list.

## Causes

- `@continuum-restore 'on'` in `dot_config/tmux/plugins.conf` ran `tmux-resurrect/scripts/restore.sh` on startup even before any snapshot existed at `~/.local/share/tmux/resurrect/last` (or `~/.tmux/resurrect/last`).
- `tmux next-3.9` replaced legacy popup options with floating panes and removed `popup-style`, `popup-border-style`, and `popup-border-lines`, which previously ran under `%if "#{>=:#{version},3.3}"`.
- `tmux-switcher` called `tmux capture-pane -ep -t "=$target"` for session previews (`=0` instead of `=0:`) and queried `@note` / `@wlabel` / `@label` with `show-options` without `-q`.
- Because `tmux next-3.9` implements `display-popup` as a floating pane (`#{pane_floating_flag} == 1`) that becomes the active pane of the current window, `capture-pane -t "=0:"` targeted the popup pane itself instead of the underlying pane (`#{pane_last}` / first non-floating pane).

## Solution

- Guarded `@continuum-restore` in `dot_config/tmux/plugins.conf` so it enables auto-restore only when a resurrect `last` file exists, and sets `'off'` otherwise.
- Narrowed the global `popup-*` block in `dot_config/tmux/appearance.conf` to `3.3 <= version < 3.9`, and added `-b rounded -s 'bg=colour234,fg=colour250' -S 'bg=colour234,fg=colour240'` to `display-popup` bindings in `dot_config/tmux/keybindings.conf`.
- Updated `dot_local/bin/executable_tmux-switcher` to pass `-q` to `tmux show-options` lookups, resolve a non-floating target pane via `resolve_capture_pane` (`pane_floating_flag != 1`, preferring active, then last, then first non-floating pane) for both previews and `prompt-plabel`, and hide floating panes from the preview pane list.
- Added an interactive `help` command list (`tmux-switcher help`, bound to `Ctrl-s ?` in `dot_config/tmux/keybindings.conf` and `?` inside the switcher) and switched the switcher headers to two compact lines so key hints are not truncated.
- Restored `status-justify centre` and removed the trailing `│ ` divider from `status-left` in `dot_config/tmux/appearance.conf` so the window list stays centered in the top status bar (after `37d8b1f5` switched it to `left`).

## Verification

- Validated `general.conf`, `keybindings.conf`, `passthrough.conf`, and `appearance.conf` with `tmux source-file` on `tmux next-3.9` and verified `display-popup` flags and `-q` options on both `tmux 3.8` and `tmux next-3.9`.
- Created an initial resurrect snapshot via `tmux-resurrect/scripts/save.sh quiet`, reloaded `~/.config/tmux/tmux.conf`, confirmed `status-justify centre`, and verified `tmux-switcher preview-session 0` captures pane output cleanly without new errors in `tmux show-messages`.
