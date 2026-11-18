-- formatter (manual only: Alt+Shift+F, never on save)
local options = {
  formatters_by_ft = {
    c = { "clang_format" },
    cpp = { "clang_format" },
    lua = { "stylua" },
    python = { "black" },
    javascript = { "prettier" },
    rust = { "rustfmt" },
  },
  -- no format_on_save / format_after_save: formatting only happens on Alt+Shift+F
}

return options
