-- C and C++ share one clangd server; compile_commands.json supplies per-file flags.
return {
  name = "c_cpp",

  servers = {
    clangd = {
      cmd = { "clangd", "--background-index", "--clang-tidy" },
      filetypes = { "c", "cpp" },
      -- Recognize CMake projects before a compilation database has been generated.
      root_markers = {
        ".clangd",
        ".clang-tidy",
        ".clang-format",
        "compile_commands.json",
        "compile_flags.txt",
        "CMakeLists.txt",
        "configure.ac",
        ".git",
      },
    },
  },
}
