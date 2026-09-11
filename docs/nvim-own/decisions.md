# nvim-own: decisions

[Project guide](README.md) · [Upstream notes](notes.md) ·
[Directions](roadmap.md)

Record only choices whose rationale should guide later work. Current behavior
belongs in the project guide; research belongs in the upstream notes.

## D-001: Incremental-hybrid keymap groups

- **Status:** accepted
- **Decision:** Introduce a which-key domain only with its first real mappings.
  Keep useful standalone mappings such as `<leader>e`, and preserve native
  families such as `gr`, `gs`, `[` and `]`.
- **Why:** This keeps Kickstart's explicitness while gaining scalable grouping,
  without reserving speculative empty categories.
- **Alternatives:** A fixed compact Kickstart vocabulary; the complete LazyVim
  hierarchy declared up front.
- **Revisit when:** Real mappings no longer fit cleanly or discoverability
  becomes worse.

## D-002: Local-first comparison sources

- **Status:** accepted
- **Decision:** Keep the normal LazyVim-based profile, `nvim-own`, and a runnable
  Kickstart snapshot together as separate chezmoi-authored profiles. Compare
  those local sources and the exact LazyVim revision pinned by the normal
  profile's lockfile. Use remotes only to refresh a snapshot deliberately;
  never edit downloaded LazyVim files as source.
- **Why:** Colocated sources are fast to inspect, work offline, match the
  configured profiles, and make comparisons reproducible by full commit.
- **Alternatives:** Repeatedly inspect moving upstream branches; keep Kickstart
  in a separate reference repository.
- **Revisit when:** A profile cannot answer a relevant question or an upstream
  snapshot is intentionally refreshed.

## D-003: Declarative language containers with explicit connectors

- **Status:** accepted
- **Decision:** Keep one module per active language under `lua/languages/`.
  Each container owns that language's server declarations and local overrides.
  An explicit registry validates unique ownership and produces a deterministic
  server list. `plugins.lsp` provisions every declared server through Mason;
  `config.lsp` is the only activation path.
- **Why:** This combines Kickstart's visible server table with LazyVim's
  declarative Mason provisioning, but preserves short, inspectable control
  flow. Adding a language changes its container and one explicit manifest,
  rather than editing installation and activation in several places.
- **Alternatives:** One growing global server table; imperative setup in every
  language file; importing LazyVim's complete LSP framework.
- **Revisit when:** A real non-LSP language tool needs provisioning, or one
  server genuinely needs shared ownership across language containers.

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
