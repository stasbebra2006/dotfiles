# nvim-own: directions

[Project guide](README.md) · [Upstream notes](notes.md) ·
[Decisions](decisions.md)

This map records plausible future work, not a task queue or authorization to
change the configuration. A direction becomes active only when a real need
brings it into the conversation.

## Near-term directions

- keymap discoverability as real mappings accumulate;
- native editing behavior and small autocommands;
- external-file refresh, revisiting `:checktime` only when the workflow needs it;
- source-managing `nvim-own` plugin revisions and deciding Mason tool
  reproducibility separately;
- syntax parsing and highlighting;
- navigation across files, buffers, help, and project text;
- Python environment selection, formatting, linting, and richer LSP behavior;
- Git change visibility and hunk actions.

## Later if needed

Possible later areas include a dedicated explorer, buffer presentation,
statusline, messages and notifications, sessions, debugging, and other UI
layers.

Evaluate cross-cutting concerns such as lazy-loading, project root versus
working directory, lifecycle, portability, and fallback behavior with the
feature that makes them relevant.

## Maintaining this map

- Add only plausible directions; do not preselect a plugin or mapping.
- Remove implemented or rejected directions.
- Put revision-scoped evidence in the notes and durable choices in the decision
  log.
- Split into finer status only when several areas become active at once.
