# BI-UOS learning progress

Append dated checkpoints here when the user asks to save progress. Keep environment setup and tutoring preferences in `orbstack-setup.md`. Distinguish observed exercise completion from proposed solutions and unverified submissions.

## 2026-10-03 10:25 CEST — previous checkpoint

Migrated from the original OrbStack setup document; these observations belong to that earlier session.

- Working through CTU FIT BI-UOS introductory shell exercises, including variables, quoting, printf, passwd fields, pipes, tr, redirection, wc, less, and editing shortcuts.
- Most recent explanation: `wc -l "${USER}-info"` prints count plus filename; `wc -l < "${USER}-info"` reads stdin and prints only the count. Semicolon separates commands; trailing bare `wc -l` waits for input (Ctrl+C cancels).
- Last completed observed exercise: `cat stasbebra2006-info | wc -l` returned 7. Empty description field accounts for a blank line (7 lines, 6 words, 55 bytes).
- Explain `>` redirects stdout away from a following pipe; `tee` copies to a file and stdout. Single quotes protect text from Bash, not from interpretation by printf/tr. `${...}` is parameter expansion, `$(...)` command substitution, `$((...))` arithmetic.
- `man` initially missing; user later successfully invoked `man getent` and `man wc`. Exact installed documentation package set not checked.


## 2026-10-06 18:03 CEST — current checkpoint

### Objective and completed work
Continue CTU FIT BI-UOS shell exercises in LearnShell, understanding quoting, variable expansion, and printf formatting. Opened an OrbStack Ubuntu shell in a new tmux window named `OrbStack` in session `0` and changed it to Linux home with `cd ~`.

- The special-character exercise printed `<  \  "` with exactly two spaces between characters. Screenshot confirmed acceptance for 1 point.
- “Tisk proměnné II.” used `printf '%s\n' "$TEXT"`. Screenshot confirmed acceptance for 2 points.
- Explained that the course uses “escaping” broadly to include quoting: double quotes allow variable expansion while preserving whitespace; single quotes prevent variable expansion.
- “Tisk proměnné III.” requires `Pat se zeptal: "PAT?" a Mat odpovedel: "MAT!"`, replacing PAT and MAT with their variable contents.

### Exact conversational position
The user expected printf to insert variable contents through `%s`, which is a valid approach. Two failed attempts were shown:
1. `$"PAT"` / `$"MAT"` printed literal variable names rather than expanding `$PAT` / `$MAT`.
2. `printf '%s\n' "Pat se zeptal: \"%s?\" a Mat odpovedel: \"%s!\"" "$PAT" "$MAT"` treated the sentence as data and printed the variable values on separate lines. printf interprets format directives only in its first argument and repeats the format for remaining arguments.

The last supplied correction was:

```sh
printf 'Pat se zeptal: "%s?" a Mat odpovedel: "%s!"\n' "$PAT" "$MAT"
```

No screenshot or test has confirmed acceptance of this correction. Do not mark “Tisk proměnné III.” completed.

### Live terminal state observed when saving
- tmux session `0`, window `2: OrbStack`, pane `0:2.1`; current command label `scli`.
- Prompt is `stasbebra2006@ubuntu:~$`.
- Live scrollback shows later file/directory practice: `mkdir file`, unsuccessful redirection to a directory and unsuccessful `rm file/`, then `rmdir file/`; `touch test`, `echo privet\ mir > test`, and `cat test` returned `privet mir`.
- `stat test` reported a regular file of 11 bytes; `stat -c %s test` returned `11`.
- `ls` showed directory `02`; its contents were not shown. No task completion on LearnShell is established by these terminal commands.
- The pane was inspected read-only; no user input was changed during checkpointing.

### Resume
First inspect the current user terminal pane and read their next request. If resuming the last conversation topic, explain that the entire sentence is printf's first argument (the format), followed by `"$PAT"` and `"$MAT"`, and verify whether “Tisk proměnné III.” was accepted. Live terminal practice has progressed to files and stat, so do not assume that printf remains the user's current exercise.

### Documentation changes and validation
Created `.agents/BI-UOS/`; moved environment notes to `orbstack-setup.md`, extracted the old learning checkpoint here, and added this checkpoint. Updated `.agents/AGENTS.md` to reference both files. Verified current tmux pane and captured its output. No code work, tests, commit, or publication requested.
