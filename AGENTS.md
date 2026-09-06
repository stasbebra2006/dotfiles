# Deleting managed files

Removing a source entry does not normally delete its live copy. When retiring files or directories, inspect the live paths and references, and use `.chezmoiremove` for intended deletions across machines. If the scope is unclear, investigate and determine whether explicit removal rules or manual cleanup are appropriate; do not assume unmanaged files are disposable. Preview removals before applying and verify the intended paths are gone afterward; a clean `chezmoi diff` alone does not prove cleanup is complete.
