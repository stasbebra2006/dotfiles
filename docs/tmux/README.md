# tmux Command Reference

Prefix key: **`Ctrl-s`** (press `Ctrl-s` twice to send `Ctrl-s` to the pane).
Press **`Ctrl-s ?`** anywhere in tmux (or **`?`** inside the Sessions/Windows switcher) to open this command list as a floating popup.

## Sessions & Windows

| Key | Action |
| --- | --- |
| `Ctrl-s s` | Open Sessions switcher popup |
| `Ctrl-s w` | Open Windows switcher popup |
| `Ctrl-s S` | New session prompt |
| `Ctrl-s $` | Rename current session |
| `Ctrl-s N` | Edit session note |
| `Ctrl-s c` | New window |
| `Ctrl-s ,` | Rename current window (`Ctrl-u` + Enter resets to automatic rename) |
| `Ctrl-s W` | Edit window label |
| `Ctrl-s &` | Kill current window |
| `Ctrl-Tab` | Next window (no prefix) |
| `Ctrl-Shift-Tab` | Previous window (no prefix) |

## Panes & Splits

| Key | Action |
| --- | --- |
| `Ctrl-s \|` | Split horizontally (side-by-side) in current directory |
| `Ctrl-s -` | Split vertically (top/bottom) in current directory |
| `Ctrl-s h` / `j` / `k` / `l` | Move left / down / up / right between panes |
| `Ctrl-s T` | Edit pane label / title |
| `Ctrl-s z` | Zoom / unzoom current pane |
| `Ctrl-s x` | Kill current pane |

## Persistence, Reload & Nested tmux

| Key | Action |
| --- | --- |
| `Ctrl-s Alt-s` | Save sessions (`tmux-resurrect`) |
| `Ctrl-s Ctrl-r` | Restore sessions (`tmux-resurrect`) |
| `Ctrl-s r` | Reload `~/.config/tmux/tmux.conf` |
| `Ctrl-s d` | Detach client |
| `F12` | Toggle passthrough mode for nested tmux (no prefix) |
| `Ctrl-s ?` | Open the command list popup |

## Inside Sessions / Windows Switcher (`tmux-switcher`)

| Key | Action |
| --- | --- |
| `j` / `k` / `g` / `G` | Move down / up / first / last |
| `J` / `K` | Scroll preview down / up |
| `Ctrl-d` / `Ctrl-u` | Half-page scroll preview |
| `/` / `i` / `a` | Enter search mode (`Esc` returns to normal mode) |
| `c` | Clear search filter and reload list |
| `Enter` | Switch to selected session or window |
| `n` (`Ctrl-n`) | New session (Sessions view) |
| `e` (`Ctrl-e`) | Edit session note (Sessions) or window label (Windows) |
| `r` (`Ctrl-r`) | Rename session or window |
| `x` / `d` (`Ctrl-x`) | Kill session (Sessions view) |
| `w` / `s` | Switch between Windows and Sessions views |
| `?` | Show command list |
| `q` / `Esc` | Close switcher |
