# Zsh: corrupt history file

Verified on Arch Linux with Zsh 5.9.2 on 2026-10-22.

Symptom: `zsh: corrupt history file ~/.zsh_history` appears repeatedly.
The file contained a single block of 19 NUL bytes. The source of those bytes
was not established. Oh My Zsh enables `SHARE_HISTORY`, so open shells can
repeatedly encounter the same damaged file.

Recovery: save a private backup, remove only the NUL bytes using a binary-safe
operation, and validate the repaired temporary file with `zsh -f` and `fc -R`.
Check stderr as well as the exit status: the corrupt file produced a warning
despite a zero exit status. Ensure the live history has not changed during
repair, then atomically replace it, retaining its permissions. Avoid `strings`,
which can discard valid history content.

The backup from this repair is
`~/.zsh_history.backup-20261022T211846.493214Z` (mode `0600`); keep history and
its backups outside Git because they contain private command text.

Verification: all bytes other than the 19 NUL bytes were preserved; `fc -R`
loaded 3,124 entries without errors. A fresh interactive login shell loaded the
history without the warning. `SHARE_HISTORY` and `HIST_SAVE_BY_COPY` were already
enabled, so no shell configuration changes were needed.
