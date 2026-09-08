---
name: wrap-session
description: Create a durable, resume-grade project checkpoint when the user asks to wrap, pause, hand off, save, or preserve the current session. Capture both technical state and the exact conversational/learning position so a later agent can continue without rediscovery. Commit or push only when the user explicitly requests those Git actions.
---

# Wrap Session

Create a project-local checkpoint that lets a later agent resume the same work and dialogue accurately.

## Choose the checkpoint file

1. Use a path explicitly requested by the user when provided.
2. Otherwise follow an existing checkpoint or progress-document convention in the project.
3. If no convention exists, use `progress-YYYY-MM-DD.md` in the project root, based on the user's local timezone.
4. Append a timestamped section when wrapping more than once into the same file on one day.

## Gather authoritative state

1. Re-read the original objective and the latest user messages.
2. Inspect relevant project documentation, changed files, Git status, and diffs.
3. Record tests and commands that actually ran, including their results.
4. Record live processes, open experiments, editor state, or safety constraints when they affect resumption.
5. Separate proven facts, current hypotheses, unresolved questions, and work that was only planned.
6. Capture the conversational position: what was being explained or reviewed, the last completed item, the user's latest understanding or concern, and the exact next item.
7. Include exact identifiers and relative file paths needed to resume, but never include credentials, tokens, private keys, or other secrets.

## Write the checkpoint

Include concise sections covering:

- wrap timestamp and timezone;
- objective and why the work matters;
- starting context and evidence that already existed;
- work completed during this session;
- current technical state;
- current conversational or learning state;
- exact resume point, including the first next action or explanation;
- changed files and their purpose;
- tests, validation, and observed results;
- unresolved questions, hypotheses, blockers, and safety notes;
- Git branch and publication state when relevant.

Preserve distinctions such as “observed,” “inferred,” “not yet tested,” and “not yet implemented.” Do not turn a partial investigation into a completion claim.

## Verify resumability

1. Re-read the checkpoint against the latest conversation and current filesystem state.
2. Confirm that a new agent can identify the first next step without guessing.
3. Confirm that planned work is not described as completed.
4. Confirm that no secret or accidental generated artifact is included.

## Commit and publish only when requested

When the user explicitly requests a commit or push:

1. Inspect the repository, branch, upstream, and all intended changes.
2. Preserve unrelated work and stage specific reviewed files rather than using blanket staging.
3. Run the relevant final checks and inspect the staged diff.
4. Create a new commit; never amend unless explicitly requested.
5. Push normally without force and verify the resulting branch state.
6. If the wrap affects multiple repositories, use separate reviewed commits and report each repository independently.
