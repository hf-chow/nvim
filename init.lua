require("hfchow")
require("config.lazy")
require'nvim-treesitter.configs'.setup {
  ensure_installed = {"rust", "python", "javascript", "typescript", "c", "lua", "vim", "query", "go", "zig", "sql"},
  sync_install = false,
  auto_install = true,
  ignore_install = { "javascript" },
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}
print("Initialized")
