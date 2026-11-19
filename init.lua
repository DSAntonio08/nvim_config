vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "
vim.g.maplocalleader = "\\" -- must be set before lazy loads (LazyVim's default)

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
-- Special/Function/Title/... : the start screen links to these. NvChad only
-- loads them with treesitter (first real buffer), so without this the
-- dashboard shows nvim's default turquoise until the theme picker runs.
dofile(vim.g.base46_cache .. "syntax")
dofile(vim.g.base46_cache .. "statusline")
for _, name in ipairs(require("chadrc").base46.integrations or {}) do
  pcall(dofile, vim.g.base46_cache .. name)
end

require "options"
require "autocmds"

vim.schedule(function()
  require "mappings"
end)
