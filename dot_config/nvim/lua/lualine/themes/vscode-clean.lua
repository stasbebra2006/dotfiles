local c = require("vscode_clean.palette")

return {
  normal = {
    a = { fg = c.bright, bg = c.focus, gui = "bold" },
    b = { fg = c.fg, bg = c.elevated },
    c = { fg = c.muted, bg = c.sidebar },
  },
  insert = {
    a = { fg = c.bg, bg = c.green, gui = "bold" },
    b = { fg = c.green, bg = c.elevated },
  },
  visual = {
    a = { fg = c.bg, bg = c.gold, gui = "bold" },
    b = { fg = c.gold, bg = c.elevated },
  },
  replace = {
    a = { fg = c.bright, bg = c.red, gui = "bold" },
    b = { fg = c.red, bg = c.elevated },
  },
  command = {
    a = { fg = c.bg, bg = c.cyan, gui = "bold" },
    b = { fg = c.cyan, bg = c.elevated },
  },
  terminal = {
    a = { fg = c.bg, bg = c.orange, gui = "bold" },
    b = { fg = c.orange, bg = c.elevated },
  },
  inactive = {
    a = { fg = c.dim, bg = c.sidebar },
    b = { fg = c.dim, bg = c.sidebar },
    c = { fg = c.dim, bg = c.sidebar },
  },
}
