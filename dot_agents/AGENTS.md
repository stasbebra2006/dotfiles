# Agent Guidelines

When launching user terminals or tmux from agent tools, remove agent-injected environment overrides such as `NO_COLOR` from the child environment and verify inheritance; a new tmux server retains them for later sessions.
