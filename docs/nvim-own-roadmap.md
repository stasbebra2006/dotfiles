# nvim-own: directions

[Project guide](nvim-own.md) · [Upstream notes](nvim-own-notes.md) ·
[Decisions](nvim-own-decisions.md)

This is a map, not a task queue, fixed sequence, or authorization to change the
configuration. A direction becomes work only when a real need brings it into
the conversation.

## Current frontier

The profile has an isolated nightly core, explicit lazy.nvim plugins,
which-key, Mason, native Pyright, deliberate diagnostic rendering, and netrw.
The next useful step may come from everyday use rather than this list.

Areas already close enough to revisit:

- keymap discoverability as real mappings accumulate;
- native editing behavior and small autocommands;
- plugin and external-tool reproducibility;
- syntax parsing and highlighting;
- navigation across files, buffers, help, and project text;
- Python completion, formatting, linting, and richer LSP behavior;
- Git change visibility and hunk actions.

## When a need appears

Possible later areas include a dedicated explorer, buffer presentation,
statusline, messages/notifications, sessions, debugging, and other UI layers.
They remain optional until current behavior exposes a limitation.

Cross-cutting questions—lazy-loading, project root versus cwd, lifecycle,
portability, and fallback behavior—are evaluated with the feature that makes
them relevant rather than planned in isolation.

## Updating this map

- Add a direction only when it is plausible for this profile.
- Do not preselect a plugin or mapping here.
- Remove implemented or rejected directions.
- Put upstream evidence in the notes and durable choices in the decision log.
- Split into finer status only if several areas become active at once.
