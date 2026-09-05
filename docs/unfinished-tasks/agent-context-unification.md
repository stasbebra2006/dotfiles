# Unify Agent Context and Memory

## Checkpoint

- Written: 2026-09-03 00:09 CEST (`Europe/Prague`)
- Last verified: 2026-09-05 CEST (`Europe/Prague`)
- Status: the loader and symlink research is complete. The user chose independent
  regular global files for dcode and Codex, with relevant personal preferences
  integrated manually. No symlink, adapter, or loader patch will be implemented.
- Current work state: project milestones were removed from `dot_codex/AGENTS.md`
  and unique durable details were retained in the owning Neovim, chezmoi, and
  DCode project docs. The remaining personal preferences were deduplicated and
  organized under communication, systems thinking, teaching, and workflow
  sections; the systems-thinking section formalizes the user's preferred
  map-to-hypothesis-to-measurement reasoning cycle. The independent dcode and
  Codex regular files now contain the same reviewed preferences as the source;
  Codex was applied through chezmoi and dcode was updated manually.
- Ownership correction: the shared preference master is `dot_agents/AGENTS.md`,
  deployed as the regular file `~/.agents/AGENTS.md`. The initial implementation
  mistakenly used `dot_codex/AGENTS.md` as the shared master and populated both
  harness files. Those copies remain separate; future integration is manual.
- Exact resume point: future shared preference changes begin in
  `dot_agents/AGENTS.md`; integrate them into individual harness files only when
  requested. Applying the shared target does not update either harness file.

## Objective

Keep each harness's global `AGENTS.md` limited to durable personal collaboration
preferences. Integrate relevant preferences into dcode, Codex, or another harness
manually instead of wiring the files together. Keep all project paths,
architecture, milestones, experiments, and technical state in project-owned
instructions or documentation. Reusable skills, credentials, logs, caches,
databases, and other runtime state remain with their existing owners.

## Current source and live topology

### Shared personal preferences

```text
Chezmoi source: dot_agents/AGENTS.md
Live target:    ~/.agents/AGENTS.md
```

This is the tool-neutral master for manual integration. No symlink, adapter,
generation step, or loader customization connects it to the harness files.
The older loader observations below are dated evidence, not fresh runtime tests.

### Shared skills

```text
Chezmoi source: dot_agents/skills/
Live target:    ~/.agents/skills/
```

The source currently contains the `config-sync` skill and an untracked
`wrap-session` skill. The live directory also contains `excalidraw-safe-edit` and
`fix-brightness`, which are not currently represented in this chezmoi source.
Do not delete the live-only skills without a separate decision.

### dcode memory

The current dcode process uses `assistant_id=agent`. Its user-level memory path
is:

```text
~/.deepagents/agent/AGENTS.md
```

`deepagents_code.create_cli_agent` constructs a `MemoryMiddleware` with that
path and any discovered project-level `AGENTS.md` files. The middleware reads
those regular Markdown files through a filesystem backend at the beginning of
an agent run, stores their contents in private graph state, and appends the
formatted contents to the system message before model calls.

The model is told in that injected prompt to use the ordinary `edit_file` tool
when durable learning should be saved. There is no special filesystem watcher
that turns feedback into a memory write. The model chooses the tool call; the
filesystem tool writes the file.

A separate `ManagedMemoryGuardMiddleware` protects the machine-managed
onboarding-name block in the dcode user memory file. It intercepts relevant
`write_file`, `edit_file`, and `delete` calls, but does not choose new memories.

### Project context

dcode's project discovery checks only:

```text
<project-root>/.deepagents/AGENTS.md
<project-root>/AGENTS.md
```

It does not automatically search arbitrary directories or follow a prose
reference to `~/.agents/AGENTS.md`. During the current chezmoi work, the dcode
process working directory was `/home/stasbebra2006`, while the chezmoi Git root
was nested below it; the repository `AGENTS.md` was therefore read explicitly
as repository guidance rather than assumed to be automatically injected.

### Codex context and runtime state

```text
Chezmoi source: dot_codex/AGENTS.md
Live target:    ~/.codex/AGENTS.md
```

This source entry is tracked separately from the shared master. The rest of `~/.codex/` contains
application-owned state such as authentication, logs, caches, SQLite databases,
sessions, IPC, and browser data. Those are not candidates for synchronization.
Codex CLI 0.153.0 was verified with `codex debug prompt-input`: with default
`CODEX_HOME`, it injects `~/.codex/AGENTS.md`, and an isolated custom
`CODEX_HOME` successfully loaded the same file through a relative symlink.

## Verified dcode execution topology

The relevant LangGraph path is conceptually:

```text
agent run starts
  -> MemoryMiddleware.before_agent reads configured AGENTS.md files
  -> private state receives memory_contents
  -> model request is built
  -> MemoryMiddleware.wrap_model_call appends <agent_memory>...</agent_memory>
  -> model chooses either a final response or a tool call
  -> tools execute through the graph
  -> tool result returns to the model node
  -> model continues or finishes
```

The compiled loop is supplied by LangChain/LangGraph's model/tools graph. The
memory middleware is a lifecycle hook inserted into that graph; the `edit_file`
operation is an ordinary tool transition.

Memory is loaded only when the private state does not already contain
`memory_contents`. A persisted thread can therefore retain an older in-memory
snapshot even after the disk file changes. Restarting the agent process alone
may restore that cached state; a new thread or an explicit state invalidation is
needed to guarantee a disk reread. A run whose restored state lacks
`memory_contents` reads the updated file.

## Verified loader and symlink experiments

The installed versions tested were Codex CLI 0.153.0, Deep Agents Code 0.1.65,
and Deep Agents SDK 0.7.10. Neither application exposes a supported setting for
an independent global-context path. `CODEX_HOME` and `DEEPAGENTS_HOME` select
whole application/profile roots, including configuration and runtime state, so
they are not context-file redirects.

Two isolated probes used disposable directories and harmless unique markers.
They did not call a model, read credentials, or modify the live configuration.

The initially proposed topology failed only at dcode's expected file:

```text
temporary canonical regular file
├── Codex-home/AGENTS.md symlink      -> loaded successfully
└── dcode-home/agent/AGENTS.md symlink -> load and edit rejected
```

Codex's `debug prompt-input` output contained the marker and left its symlink
intact. Dcode's actual `MemoryMiddleware` could not load its symlink because the
SDK `FilesystemBackend.download_files` opens the final path with `O_NOFOLLOW`.
On Linux this produced `ELOOP`, reported by the middleware as `invalid_path`.
The same backend protection made `edit_file` reject the symlink without changing
the target. This is an intentional final-component symlink defense, not a real
symlink cycle.

Dcode's `ManagedMemoryGuardMiddleware` separately resolved the symlink target
correctly: a simulated successful target edit that removed the onboarding block
had that block restored, retained an unrelated edit, and returned the expected
error. The guard is therefore compatible; the loader and filesystem writer
reject the link before normal guarded editing can occur.

A control topology with dcode's expected path as the one regular file passed all
checks:

```text
dcode-home/agent/AGENTS.md regular file
├── shared ~/.agents/AGENTS.md-style symlink
└── Codex-home/AGENTS.md symlink through the shared alias
```

Dcode loaded and edited the regular file, the shared alias immediately exposed
the edit, the real onboarding guard restored its protected block while keeping
an unrelated edit, and Codex loaded the marker through the two-link chain. This
is technically viable but makes dcode's namespace the physical live owner; the
neutral shared path is an alias rather than the regular file.

## Chosen target design

The content should remain compact: general user/agent preferences and
cross-tool workflow rules only. Project architecture, build commands, and
project-specific checkpoints belong in project-owned instructions or durable
project documentation. The global content must not contain credentials, tokens,
private keys, or volatile application state.

A 2026-09-05 user decision selected independent, regular harness-owned files.
Shared personal preferences live in `dot_agents/AGENTS.md` and its regular live
target `~/.agents/AGENTS.md`. They are reviewed and integrated manually into the
harnesses that need them. No dcode adapter, symlink aliases, or loader patch is
planned. Project-specific content stays in project-owned documentation.

## Historical integration options

1. **Neutral canonical file plus regular dcode adapter** — preserves neutral
   ownership but relies on model compliance and leaves two writable files.
2. **Regular dcode-owned file plus shared and Codex symlink aliases** — one live
   content object and verified direct loading/writing, but the physical owner is
   tool-specific.
3. **Narrow dcode loader patch or maintained fork** — could preserve a neutral
   regular canonical file with direct loading, but adds local maintenance until
   equivalent behavior is supported upstream.
4. **Generated copies with common and harness-specific source fragments** — use
   only when real harness-specific differences justify synchronization and
   generation complexity.
5. **Independent copied files** — selected with intentional manual review. This
   accepts possible drift in exchange for simple tool-owned regular files and no
   loader customization.

Do not replace dcode's installed backend or weaken `O_NOFOLLOW` merely to enable
the aesthetically preferred topology. Its symlink restriction is a security
boundary.

## Investigated narrow dcode patch

A manual code change is technically possible without weakening every filesystem
operation. In `create_cli_agent`, dcode currently passes the literal expected
path from `get_user_agent_md_path(assistant_id)` to `MemoryMiddleware`. A narrow
change could resolve only that configured user-memory path, verify that its
target is the intended regular `~/.agents/AGENTS.md`, and pass the resolved
regular path to `MemoryMiddleware`.

This would produce two useful consequences:

- the loader would open a regular target rather than a final-component symlink;
- the injected memory source name would be the canonical path, directing later
  `edit_file` calls to the regular target instead of the rejected symlink.

The onboarding guard already resolves its configured path and protected the
canonical target in the isolated probe, so it may not need modification. That
does not prove the complete lifecycle: onboarding updates, agent reset, context
diagnostics, fresh-thread loading, and all memory-writing paths must still be
tested against the patched build.

The patch must remain narrow. Removing `O_NOFOLLOW` from the shared
`FilesystemBackend` would allow all agent file operations to follow final-path
symlinks and would discard a deliberate defense against redirected reads and
writes. Do not make that global change merely for memory sharing.

Editing the installed site-package file directly would be overwritten by a
dcode update and could silently disappear. A supported upstream memory-source
setting is preferable; a maintained fork is safer than an undocumented vendor
edit if the behavior must be retained before upstream support exists.

This patch is not planned under the chosen independent-file design. If that
decision is explicitly revisited, the safe experiment is to copy or install the exact dcode version into a
disposable environment, apply only the path-resolution change there, recreate
the neutral-canonical symlink topology, and repeat the loader, writer, guard,
onboarding, reset, and fresh-thread checks. Do not patch the live installation
until that evidence is reviewed and the update/rollback strategy is explicit.

## Safe next steps

1. Edit and review shared personal preferences in `dot_agents/AGENTS.md`.
2. Apply only `~/.agents/AGENTS.md` when deploying the shared master. Integrate
   preferences into Codex or dcode separately when requested, preserving any
   harness-specific content and dcode's managed onboarding block.
3. Verify a fresh Codex session and a new dcode thread because existing sessions
   can retain old context snapshots.

## Rollback

The compact personal-preference master is in `dot_agents/AGENTS.md`,
while removed project details are retained in their owning project docs. Both
live harness paths remain regular files rather than symlinks. Recovery must keep:

- `~/.deepagents/agent/AGENTS.md` as the dcode memory file;
- `~/.agents/AGENTS.md` as the independent shared preferences file;
- `~/.codex/AGENTS.md` as the Codex context file;
- the existing `~/.agents/skills/` contents;
- all tool-owned files under `~/.codex/` untouched.

Restore only reviewed personal preferences rather than the removed project
checkpoints. Use a fresh thread or explicitly invalidate dcode's
`memory_contents` so it reloads the restored file; restarting the process alone
may retain persisted thread state. Do not use broad recursive cleanup.

## Current adjacent work

- Tmux simplification is complete and its stale handoffs were removed.
- Zsh source cleanup and the authored-config comment/readability pass are
  prepared but not applied, committed, or pushed.
- The live `~/.profile` was simplified separately and remains unmanaged.
- The current source repository contains substantial unrelated uncommitted
  Neovim, tmux, agent, and local-bin work. Preserve it and stage narrowly later.
- The shared preferences file maps from `dot_agents/AGENTS.md` to
  `~/.agents/AGENTS.md`; inspect scoped chezmoi status for deployment state.
