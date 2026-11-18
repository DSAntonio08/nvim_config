return {
  -- formatter: manual only, Alt+Shift+F
  {
    "stevearc/conform.nvim",
    cmd = { "ConformInfo" },
    keys = {
      {
        "<M-F>", -- Alt+Shift+F
        function()
          -- use clang-format etc.; fall back to the LSP (e.g. clangd) if the tool is missing
          require("conform").format { async = true, lsp_format = "fallback" }
        end,
        mode = { "n", "v" },
        desc = "Format",
      },
    },
    opts = require "configs.conform",
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- LuaSnip v2 (NvChad already ships it; pin the version + load your own snippets)
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    config = function(_, opts)
      require("luasnip").config.set_config(opts)
      require "nvchad.configs.luasnip"
      require "snippets.html"
    end,
  },

  -- treesitter parsers for the languages you have LSPs for
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "lua", "luadoc", "printf", "vim", "vimdoc",
        "c", "cpp", "python", "rust", "javascript", "typescript", "tsx",
        "html", "css", "json", "markdown", "markdown_inline", "bash", "ini",
      },
    },
  },
}
