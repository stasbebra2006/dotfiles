# Neovim and VS Code

## Config Ownership

Neovim is managed as a direct-copy directory at `~/.config/nvim`. The important
startup files are:

```text
~/.config/nvim/init.lua
~/.config/nvim/lua/config/lazy.lua
~/.config/nvim/lua/config/vscode.lua
```

VS Code's `settings.json`, `keybindings.json`, and extensions are handled by VS
Code Settings Sync, not chezmoi.

## Startup Flow

The installed extension is `asvetliakov.vscode-neovim`. On Linux it launches
`/usr/bin/nvim`, so Neovim starts with the same `~/.config/nvim/init.lua` used by
terminal Neovim.

```lua
if vim.g.vscode then
  require("config.vscode")
  return
end

require("config.lazy")
```

- Inside VS Code, `vim.g.vscode` is set and only the lightweight
  `config.vscode` setup is loaded.
- In normal Neovim, startup continues through `config.lazy` and loads LazyVim.

Do not remove the VS Code guard or forget to sync `config/vscode.lua`; both are
required for the integration to work on another machine.

## Terminal Neovim Theme

Standalone Neovim uses the dependency-free `previous-custom` colorscheme by
default. It combines Neovim's built-in `default` interface with the former
Catppuccin syntax highlights and Snacks/Flash overrides:

```text
~/.config/nvim/colors/previous-custom.lua
~/.config/nvim/lua/previous_custom/theme.lua
```

The newer `vscode-clean` theme remains available separately:

```text
~/.config/nvim/colors/vscode-clean.lua
~/.config/nvim/lua/vscode_clean/palette.lua
~/.config/nvim/lua/vscode_clean/theme.lua
~/.config/nvim/lua/lualine/themes/vscode-clean.lua
```

Use `<leader>uC` to switch themes interactively, or run
`:colorscheme vscode-clean`. `lua/config/autocmds.lua` reapplies
plugin-specific highlights after LazyVim loads and when either local scheme is
selected again.

## Responsibility Split

Neovim owns editing behavior inside the active editor. The VS Code-specific Lua
config reuses Flash, mini.surround, mini.ai, and Tree-sitter resources from the
local LazyVim installation.

VS Code owns workbench UI, notebooks, file navigation, language actions, and
the Which Key menu. Native Neovim UI plugins such as Telescope, Neo-tree,
BufferLine, and `which-key.nvim` are not loaded for the VS Code path.

Notebook-specific keybindings use the `neovim.transientActive` context to route
Escape to Neovim while Flash, operator-pending commands, character motions, or
mini.surround are waiting for input. Normal notebook Escape behavior is
preserved at other times.

After changing the Lua config or VS Code bindings, use **Developer: Reload
Window** in VS Code.
