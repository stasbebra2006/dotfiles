# Accept Python Function Completions Without Parentheses

Status: unfinished; experimental configuration reverted on 2026-07-28.

## Goal

Keep normal completion acceptance for Python calls:

```python
transform()
```

Provide a second acceptance key for passing the function itself:

```python
map(transform, values)
```

The original requested interaction was:

- `Enter`: accept a callable completion and keep `()`;
- `Ctrl+Enter`: accept the same completion without `()`.

## Environment observed

The investigation was performed with:

- Konsole 26.04.3;
- tmux 3.7b;
- Neovim 0.12.4;
- LazyVim commit `c10948c5`;
- `blink.cmp` commit `78336bc`.

The active input path was:

```text
Konsole -> tmux -> Neovim -> blink.cmp
```

Neovim is a direct-copy chezmoi target under `dot_config/nvim/`.

## Verified facts

### Completion behavior

LazyVim uses `blink.cmp` in this setup. Its default configuration enables:

```lua
completion.accept.auto_brackets.enabled = true
```

Blink adds `()` when it recognizes a completion item as a function or method.
The installed Blink API exposes completion callbacks, but its accepted-item
options do not expose a one-shot `auto_brackets = false` flag.

### Experimental Neovim mapping

An experimental `lua/plugins/completion.lua` plugin override mapped
`<C-CR>` and later `<A-CR>`. It accepted the selected item and then removed an
empty `()` surrounding the cursor, only when `filetype == "python"`.

Headless checks verified that:

- Blink registered the custom mappings after `InsertEnter`;
- the ordinary `<CR>` mapping remained Blink's normal `accept`;
- the callback changed `map(transform())` to `map(transform)`;
- a non-empty call such as `transform(value)` was preserved;
- non-Python completions were preserved.

The mapping was also confirmed as loaded in the user's active Python buffer.
Despite that, the requested behavior did not work end to end in the interactive
terminal session.

### Terminal input

Process ancestry confirmed that the active terminal was Konsole, not Kitty.

The current Konsole default keyboard table has generic Return rules that emit
carriage return and no dedicated `Return+Control` rule. This is strong evidence
that `Ctrl+Enter` reached the application as ordinary Enter before Neovim could
distinguish it.

The active tmux server was already configured correctly for extended keys:

```text
extended-keys: on
extended-keys-format: xterm
client feature: extkeys
```

Tmux cannot recover a modifier that the terminal did not encode distinctly.

Attempts to capture the exact interactive key with Neovim's `getcharstr()` were
inconclusive because focus and queued mouse/keyboard events were captured
instead.

## Approaches tried

### Post-accept removal callback

The callback approach was intentionally conservative: it removed only an empty
pair immediately around the completion cursor. Its isolated tests passed, but
the full terminal-to-completion path did not.

Possible unresolved causes:

- the modified Enter key never reached the custom mapping;
- Blink's real acceptance timing or cursor placement differed from the
  simulated callback test;
- another layer normalized the modified key before Blink handled it.

### `Alt+Enter` fallback

`<A-CR>` was added as a second mapping because Konsole can encode Alt as an
escape-prefixed key. The Neovim-side checks passed, but the user reported that
the end-to-end behavior still did not work. This was not investigated further
before the experiment was reverted.

## Revert completed

The experiment introduced only these files:

```text
~/.config/nvim/lua/plugins/completion.lua
dot_config/nvim/lua/plugins/completion.lua
```

Both were removed on 2026-07-28. No active completion override remains. No
Konsole profile, Konsole key table, tmux configuration, existing Neovim file,
commit, or remote branch was changed by this experiment.

## Possible next experiments

### 1. Use a non-Enter key

This is the smallest and least fragile option. Map a key Konsole already sends
distinctly, such as `Ctrl+Y`, to the same accept-without-empty-parentheses
callback.

Expected evidence:

1. `getcharstr()` reports the intended key.
2. Blink's mapping is present in the active Python buffer.
3. A real Pyright completion produces the function name without `()`.

### 2. Disable automatic brackets for Python

Set Blink's automatic brackets as blocked for Python. All Python callable
completions would then insert only the name; calls would require typing `(`
manually.

This is simpler technically but changes the common call-writing path, so it
needs an explicit usability decision.

### 3. Add a custom Konsole keyboard table

Konsole supports user `*.keytab` files. A custom table could clone the default
table and add a distinct `Return+Control` escape sequence, then the Konsole
profile could select that table.

This affects terminal input beyond Neovim and must be tested through both
Konsole and tmux before being kept. The safe order is:

1. clone the current Konsole default key table;
2. add one `Return+Control` rule using an extended-key sequence;
3. select the custom table in a test Konsole profile;
4. verify the raw key in Neovim with `getcharstr()`;
5. only then restore the Blink mapping;
6. confirm normal Enter, Ctrl+Enter, tmux, and shell input independently.

Konsole's keyboard-table format is documented in the
[Konsole handbook](https://docs.kde.org/trunk_kf6/en/konsole/konsole/key-bindings.html).

### 4. Avoid post-editing the accepted text

Investigate whether a newer Blink version gains a per-accept auto-bracket
override. That would be preferable to inserting `()` and deleting it in a
callback.

Revalidate against the installed Blink source before implementing because the
API is version-sensitive.
