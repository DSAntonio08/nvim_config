-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
--
-- PLAYGROUND (2026-11-18): trying the stock NvChad README look.
-- Old setup (tokyonight + transparent + bordered) is backed up in
-- ~/Documents/nvChad_attempt1/lua/chadrc.lua

---@type ChadrcConfig
local M = {}

M.base46 = {
  -- try: onedark, radium, catppuccin, rxyhn, chadracula, gruvchad, everforest,
  -- rosepine, tokyonight, nord, kanagawa ...  (live preview: <leader>uC)
  theme = "nord",
  transparency = false, -- README screenshots are all opaque
  theme_toggle = { "nord", "one_light" },
  -- theme colors for the LazyVim-style plugins (see lua/plugins/lazyvim.lua)
  integrations = { "snacks", "flash", "trouble", "todo", "grug_far" },
}

M.ui = {
  -- borderless = solid filled picker panels (the README look)
  -- bordered   = thin borders, see-through (what you had before)
  telescope = { style = "borderless" },

  statusline = {
    theme = "default", -- default / vscode / vscode_colored / minimal
    separator_style = "default", -- default / round / block / arrow
  },

  cmp = {
    style = "default", -- default / flat_light / flat_dark / atom / atom_colored
  },
}

return M
