-- drop NvChad's LSP keymaps (gD, <leader>wa/wr/wl, <leader>D, <leader>ra); LazyVim ones are in lua/mappings.lua
require("nvchad.configs.lspconfig").on_attach = function() end
require("nvchad.configs.lspconfig").defaults()

-- clangd: allow it to query cross-compilers (PlatformIO toolchains like avr-g++,
-- xtensa-esp32-elf-g++, arm-none-eabi-g++ ...) for their system headers and target.
-- Without this, clangd uses the host (arm64 macOS) target and can't find avr/*.h etc.
vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--background-index",
    "--header-insertion=never",
    "--query-driver=" .. vim.env.HOME .. "/.platformio/packages/toolchain-*/bin/*",
  },
})

local servers = {
  "clangd",
  "lua_ls",
  "pyright",
  "rust_analyzer",
  "ts_ls",
}
vim.lsp.enable(servers)
-- LSP keymaps live in lua/mappings.lua (so they win over NvChad's defaults)
