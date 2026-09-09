# nvim-own: decisions

[Project guide](nvim-own.md) · [Upstream notes](nvim-own-notes.md) ·
[Directions](nvim-own-roadmap.md)

Record only choices whose rationale should guide later work. Current behavior
belongs in the project guide; research belongs in the upstream notes.

## D-001: Incremental-hybrid keymap groups

- **Status:** accepted
- **Decision:** Borrow scalable domain names only when a feature needs them.
  Introduce a which-key group with its first real mappings, keep useful
  standalone mappings such as `<leader>e`, and preserve native families such as
  `gr`, `gs`, `[` and `]`.
- **Why:** This keeps Kickstart's explicitness without crowding top-level keys,
  and gains LazyVim's scalability without speculative empty categories.
- **Alternatives:** A fixed compact Kickstart vocabulary; the complete LazyVim
  hierarchy declared up front.
- **Revisit when:** Real mappings no longer fit cleanly or discoverability
  becomes worse.

## Entry format

```text
## D-NNN: Title
- Status: accepted | superseded
- Decision:
- Why:
- Alternatives:
- Revisit when:
```

Do not log routine settings or every experiment.
