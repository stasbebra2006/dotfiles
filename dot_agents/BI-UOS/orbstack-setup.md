# OrbStack shell-learning setup

Initial setup saved 2026-10-03 10:25 CEST. Separated from learning progress on 2026-10-06. Personal workstation setup, not a Git project.

Learning checkpoints are in `progress.md`. Keep this file for environment setup, terminal access, and tutoring preferences.

## Setup and launch
- OrbStack installed via `brew install --cask orbstack`; application `/Applications/OrbStack.app`, CLI via Homebrew. Installed version observed during setup: 2.2.3.
- `orbctl list` on save confirmed machine `ubuntu`, running, Ubuntu `resolute`, native arm64.
- Open OrbStack if needed, then run `orb -m ubuntu` in the user's usual Mac terminal. `exit` returns to the Mac shell.
- Linux username `stasbebra2006`; Linux home `/home/stasbebra2006`. Run `cd` or `cd ~` after entering: OrbStack can preserve the Mac working directory.
- Mac home `/Users/stasbebra2006` is shared into Linux. Shared files are real Mac files, not copies. This is a Linux learning environment, not a sandbox against access to Mac files.
- Coursework file created and observed: `/home/stasbebra2006/stasbebra2006-info`, 55 bytes, 7 newline-terminated fields. A `~/uos` directory was suggested but not confirmed created.

## Terminal access and teaching preferences
- User explicitly requests checking their terminal before answering shell questions, to explain the exact command/output. Keep explanations short; avoid revealing exercise solutions when they ask for hints.
- Mac tmux session `0`, pane `0:2.1` held the Ubuntu shell. On save pane still exists with current command `scli`; that label is not evidence that Linux is absent. Discover panes with `tmux list-panes -a` if necessary; read with `tmux capture-pane -p -t 0:2.1 -S -15`. Do not type into the user's pane without intent/authorization.
- tmux runs on the Mac, with an OrbStack Linux shell inside its pane. No continuous monitoring implied.

## Shell editing
- Bash supports `set -o vi`, but not Vim text objects (`ciw`, `yiw`). Use `cw`, `ye`, etc.; never promise full Vim motions in Readline.
- Vim and vi were observed installed at `/usr/bin/vim` and `/usr/bin/vi` inside Ubuntu.
- User ran `export VISUAL=vim`, `set -o vi`, later `set -o emacs`; these are session settings. No persistence in `.bashrc` was configured or verified.
- Edit command in actual Vim: Esc then `v` in vi mode; Ctrl+X then Ctrl+E in Emacs mode. Editor selection is VISUAL, EDITOR, then fallback.
- Saving/exiting this editor can execute the command. Use `:cq` to cancel safely. User confused `:!q` (shell command q) with `:q!`; explain distinction if needed.

## Resume access
First inspect the current tmux pane, then read `progress.md` and address the next coursework question based on live text. Discover the pane rather than assuming the saved pane identifier is still current.

## CTU FIT Solaris server (`fray1.fit.cvut.cz`)
- Access: `ssh liashsta@fray1.fit.cvut.cz` (Oracle Solaris 11.4 `SunOS 5.11` SPARC, home `/home/stud/liashsta`; authenticated via `~/.ssh/my_github_key`).
- Startup order: login shell reads `~/.profile` → `/home/.profile.all` (which sets default uncolored `PS1` and sources `~/.bashrc`) → `~/.profile.user`.
- `tmux-256color` terminfo is installed in `~/.terminfo/t/tmux-256color` and enabled by `TERMINFO="$HOME/.terminfo"` in both `~/.profile.user` and `~/.bashrc` (fixes `clear` under tmux).
- **Colorful commands fix (2026-11-04):**
  - *Symptom:* `ls` and `grep` had no color output on `fray1`, and `PS1` was monochrome.
  - *Cause:* Default `/usr/bin/ls` and `/usr/bin/grep` are Solaris native utilities (`/usr/bin/grep` lacks `--color`; Solaris `/usr/bin/ls --color` emits only `sgr0` reset without ANSI color sequences under the custom `tmux-256color` terminfo/default `LS_COLORS`), and `/home/.profile.all` overwrote `PS1` without color.
  - *Solution:* Configured `~/.bashrc` and `~/.profile.user` on `fray1` to alias `ls='/usr/gnu/bin/ls --color=auto'` (GNU coreutils 8.27) and `grep='/usr/gnu/bin/grep --color=auto'` (GNU grep 3.1), and exported a green/blue colored `PS1`.
  - *Verification:* Verified via SSH hex dump (`od -An -tx1`) that `/usr/gnu/bin/ls --color=always` emits `\e[01;34m` / `\e[01;36m` ANSI color sequences on `fray1`. Avoid `tmux send-keys` into an active `fray` pane when the user may be mid-typing; use background `ssh -o BatchMode=yes liashsta@fray1.fit.cvut.cz` instead.
