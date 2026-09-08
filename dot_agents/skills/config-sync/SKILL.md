---
name: config-sync
description: Safely manage and synchronize chezmoi-backed configuration across live files, the local chezmoi source repository, and its Git remote. Use for planned dotfile changes, importing existing live edits, previewing or applying source changes, pulling changes from another machine, resolving source drift, or committing and publishing configuration.
---

# Config Sync

Keep these states distinct:

1. **Source**: files and templates in `chezmoi source-path`; Git synchronizes this repository.
2. **Target**: the desired state chezmoi renders on demand from the source and this machine's data. It is normally not a persistent directory.
3. **Live destination**: active files under the home directory that applications read.
4. **Remote**: the Git remote for the source repository.

`chezmoi diff` previews target versus live. `chezmoi apply` writes target to live. `chezmoi add` captures a live file into source. Git pull and push affect source, not live files.

## Establish Context

1. Resolve the source repository with `chezmoi source-path`.
2. Read its `AGENTS.md` or `AGENT.md` and relevant documentation when present. Follow them unless they conflict with the user's request or higher-priority instructions.
3. Inspect relevant state before modifying anything:
   - `chezmoi status [target]`
   - `chezmoi diff [target]`
   - `git status --short` in the source repository
   - relevant source and live files
4. Identify whether each source entry is a plain file, template, script, encrypted entry, external, or other special chezmoi entry.
5. Ask which state should win when the request or direction is ambiguous. Do not interpret “sync” as authorization to pull, apply, commit, or push automatically.

Preserve unrelated source changes and live drift. Never hide, discard, reset, or overwrite them to make status clean.

## Choose the Direction

### Planned configuration change

Use source as the editing surface:

1. Ensure wanted live-only edits and uncommitted source work cannot be overwritten.
2. If remote synchronization is requested, fetch and integrate remote source changes before starting the new edit:
   - use fast-forward-only integration when there are no local commits to replay;
   - use rebase when unshared local commits should follow remote commits;
   - stop for conflicts and preserve intended behavior from both sides.
3. Edit the source file or template, preserving machine and OS branches.
4. Run scoped `chezmoi diff` and explain the live effect.
5. Apply only if the user requested the live configuration to be changed. Prefer scoped `chezmoi apply <target>`.
6. Test the affected application and verify the scoped diff/status.

### Existing live edit should be preserved

Reconcile live into source before any apply that could overwrite it:

1. Compare source, rendered target, and live content.
2. For a plain direct-copy file, use `chezmoi add <target>` or make the equivalent reviewed source edit.
3. For a `.tmpl` or other transformed source entry, manually merge the intended live behavior into source. Never replace template logic with one machine's rendered output.
4. Review the source diff and render again with scoped `chezmoi diff`.
5. Do not apply merely to import a live change; apply is target-to-live.

An empty scoped `chezmoi diff` confirms that the current rendered target matches live content. It does not by itself prove that templates, permissions, scripts, secrets, or other machines are correct.

### Remote source changes should reach this machine

1. Inspect live drift, uncommitted source changes, branch, upstream, and local commits.
2. Protect wanted live-only edits by reconciling them into source before integration.
3. Fetch and integrate the intended remote branch without rewriting shared history.
4. Review incoming commits and resulting source changes.
5. Run `chezmoi diff` to preview their machine-specific rendered effect.
6. Apply only after the user authorizes applying that reviewed scope.
7. Verify the application and remaining drift.

Do not use `chezmoi update` during careful reconciliation because it combines source integration and live application.

## Authorization Boundaries

Treat these as independent actions:

- **Inspect/diagnose**: read-only checks only.
- **Edit/capture/reconcile**: modify source as requested; do not infer apply, commit, pull, or push.
- **Pull/synchronize from remote**: integrate remote source; do not infer apply or push.
- **Apply**: write reviewed target state to live destinations; do not infer commit or push.
- **Commit**: stage exact reviewed source files and create a new commit only when explicitly requested.
- **Push/publish**: push only when explicitly requested after checking branch, upstream, and commit contents.

Before adding, committing, or pushing, inspect intended files for credentials, tokens, private keys, machine-specific secrets, and accidental generated or vendored content. Never commit secrets unencrypted.

## Verification

For the affected scope:

1. Review `chezmoi diff` before apply.
2. Review Git diffs of source changes, including template branches.
3. After apply, test the actual consumer and inspect scoped `chezmoi status` and `chezmoi diff`.
4. Before commit, stage exact files and review the staged diff.
5. Before push, verify the branch, upstream, and commits being published.
6. Report separately what was edited, pulled, applied, committed, and pushed, plus conflicts or unresolved drift.
