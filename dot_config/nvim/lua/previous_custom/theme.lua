local M = {}

local colors = {
  rosewater = "#f5e0dc",
  flamingo = "#f2cdcd",
  pink = "#f5c2e7",
  mauve = "#cba6f7",
  red = "#f38ba8",
  maroon = "#eba0ac",
  peach = "#fab387",
  yellow = "#f9e2af",
  green = "#a6e3a1",
  teal = "#94e2d5",
  sky = "#89dceb",
  sapphire = "#74c7ec",
  blue = "#89b4fa",
  lavender = "#b4befe",
  text = "#cdd6f4",
  subtext1 = "#bac2de",
  subtext0 = "#a6adc8",
  overlay2 = "#9399b2",
  overlay1 = "#7f849c",
  overlay0 = "#6c7086",
  surface2 = "#585b70",
  surface1 = "#45475a",
  surface0 = "#313244",
}

local groups = {
  -- Snacks picker contrast fixes and the former Flash label.
  SnacksPickerDir = { link = "Directory" },
  SnacksPickerListCursorLine = { link = "CursorLine" },
  FlashLabel = { fg = "#ffffff", bg = "#b94a48", bold = true },

  -- Standard Vim syntax groups.
  Comment = { fg = colors.surface2, italic = true },
  Constant = { fg = colors.peach },
  String = { fg = colors.green },
  Character = { fg = colors.green },
  Number = { fg = colors.peach },
  Boolean = { fg = colors.peach },
  Float = { fg = colors.peach },
  Identifier = { fg = colors.text },
  Function = { fg = colors.blue },
  Statement = { fg = colors.mauve },
  Conditional = { fg = colors.mauve },
  Repeat = { fg = colors.mauve },
  Label = { fg = colors.mauve },
  Operator = { fg = colors.sky },
  Keyword = { fg = colors.mauve },
  Exception = { fg = colors.mauve },
  PreProc = { fg = colors.yellow },
  Include = { fg = colors.mauve },
  Define = { fg = colors.mauve },
  Macro = { fg = colors.yellow },
  PreCondit = { fg = colors.yellow },
  Type = { fg = colors.yellow },
  StorageClass = { fg = colors.yellow },
  Structure = { fg = colors.yellow },
  Typedef = { fg = colors.yellow },
  Special = { fg = colors.pink },
  SpecialChar = { fg = colors.pink },
  Tag = { fg = colors.yellow },
  Delimiter = { fg = colors.teal },
  SpecialComment = { fg = colors.surface2 },
  Debug = { fg = colors.yellow },
  Error = { fg = colors.red },
  Todo = { fg = colors.yellow },

  -- Modern Tree-sitter captures.
  ["@comment"] = { fg = colors.surface2, italic = true },
  ["@operator"] = { fg = colors.sky },
  ["@punctuation.delimiter"] = { fg = colors.teal },
  ["@punctuation.bracket"] = { fg = colors.overlay2 },
  ["@punctuation.special"] = { fg = colors.pink },
  ["@string"] = { fg = colors.green },
  ["@string.regex"] = { fg = colors.pink },
  ["@string.escape"] = { fg = colors.pink },
  ["@character"] = { fg = colors.green },
  ["@character.special"] = { fg = colors.pink },
  ["@boolean"] = { fg = colors.peach },
  ["@number"] = { fg = colors.peach },
  ["@float"] = { fg = colors.peach },
  ["@function"] = { fg = colors.blue },
  ["@function.builtin"] = { fg = colors.blue },
  ["@function.call"] = { fg = colors.blue },
  ["@method"] = { fg = colors.blue },
  ["@method.call"] = { fg = colors.blue },
  ["@constructor"] = { fg = colors.yellow },
  ["@parameter"] = { fg = colors.maroon, italic = true },
  ["@keyword"] = { fg = colors.mauve },
  ["@keyword.function"] = { fg = colors.mauve },
  ["@keyword.return"] = { fg = colors.mauve },
  ["@conditional"] = { fg = colors.mauve },
  ["@repeat"] = { fg = colors.mauve },
  ["@label"] = { fg = colors.mauve },
  ["@type"] = { fg = colors.yellow },
  ["@type.builtin"] = { fg = colors.yellow },
  ["@class"] = { fg = colors.yellow },
  ["@attribute"] = { fg = colors.blue },
  ["@variable"] = { fg = colors.text },
  ["@variable.builtin"] = { fg = colors.mauve },
  ["@variable.member"] = { fg = colors.text },
}

function M.apply()
  for group, spec in pairs(groups) do
    vim.api.nvim_set_hl(0, group, spec)
  end
end

function M.load()
  -- This was the original combination: Neovim's default interface with the
  -- custom Catppuccin syntax block applied on top.
  for index = 0, 15 do
    vim.g["terminal_color_" .. index] = nil
  end

  vim.cmd("highlight clear")
  if vim.fn.exists("syntax_on") == 1 then
    vim.cmd("syntax reset")
  end

  vim.g.colors_name = "previous-custom"
  M.apply()
end

return M
