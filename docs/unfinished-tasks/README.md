# Unfinished Tasks

This directory records configuration work that was investigated but not
completed or kept active. It exists so failed experiments, verified facts, and
next steps are not lost or repeated from scratch.

Each task note should contain:

- the desired behavior and current status;
- the relevant environment and configuration ownership;
- facts verified directly, separated from hypotheses;
- approaches tried and why they were reverted;
- safe next experiments and their expected evidence;
- files that were changed, retained, or removed.

## Active notes

- [Accept Python function completions without parentheses](neovim-python-function-reference-completion.md)

## Configuration provenance

- `dot_config/nvim/lua/config/autocmds.lua` intentionally retains only yank-to-system-clipboard behavior. Theme refreshes, external-file reload, and lockfile-triggered LSP restart were removed; the matching live file is active.
- `dot_config/kitty/kitty.conf` intentionally fixes Ctrl+Tab/Ctrl+Shift+Tab tmux window switching, discards F23/F24 marker events from the mouse thumb-wheel daemon, and disables the audio bell. The matching live file is active.
- This directory is intentionally retained as a record of the reverted completion experiment.
