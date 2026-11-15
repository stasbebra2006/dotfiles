-- Show Git change signs in the gutter and inspect or revert hunks inline.
return {
  "lewis6991/gitsigns.nvim",
  -- Includes Neovim 0.13 diffopt parsing fix (45b3180) and missing-revision fix (5be654f).
  commit = "5be654f2232c10ddcad19c1607a67b6b4b78fc29",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("gitsigns").setup({
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "-" },
        topdelete = { text = "-" },
        changedelete = { text = "~" },
        untracked = { text = "+" },
      },
      signs_staged = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "-" },
        topdelete = { text = "-" },
        changedelete = { text = "~" },
      },
      on_attach = function(bufnr)
        local gs = require("gitsigns")

        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
        end

        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next Hunk")

        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Prev Hunk")

        map("n", "]H", function()
          gs.nav_hunk("last")
        end, "Last Hunk")

        map("n", "[H", function()
          gs.nav_hunk("first")
        end, "First Hunk")

        map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
        map("n", "<leader>ghP", gs.preview_hunk, "Preview Hunk (float)")
        map("n", "<leader>ghd", gs.diffthis, "Diff File (side-by-side)")
        map("n", "<leader>ghD", function()
          gs.diffthis("~")
        end, "Diff File (~1)")
        map("n", "<leader>ghb", function()
          gs.blame_line({ full = true })
        end, "Blame Line")

        map({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
      end,
    })
  end,
}
