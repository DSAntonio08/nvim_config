-- LazyVim keybindings on top of NvChad.
-- Adds the plugins LazyVim used for its keys (snacks, flash, trouble, todo-comments,
-- grug-far, persistence) and rebinds NvChad's own plugins (cmp, gitsigns, which-key).
-- Core (non-plugin) keymaps and LSP keymaps live in lua/mappings.lua.

-- LazyVim-style root dir: LSP workspace root -> .git/lua marker -> cwd
local function root()
  local buf = vim.api.nvim_get_current_buf()
  for _, client in ipairs(vim.lsp.get_clients { bufnr = buf }) do
    local ws = client.config.workspace_folders
    if ws and ws[1] then
      return vim.uri_to_fname(ws[1].uri)
    end
    if client.config.root_dir then
      return client.config.root_dir
    end
  end
  return vim.fs.root(buf, { ".git", "lua" }) or vim.uv.cwd()
end

local function git_root()
  return vim.fs.root(0, ".git") or vim.uv.cwd()
end

-- terminal window navigation (same as LazyVim)
local function term_nav(dir)
  return function(self)
    return self:is_floating() and "<c-" .. dir .. ">" or vim.schedule(function()
      vim.cmd.wincmd(dir)
    end)
  end
end

-- pad every line of an ASCII-art block to the same width, so the dashboard
-- centers it as one block (editors like to strip trailing spaces)
local function block(text)
  local lines = vim.split(text, "\n")
  local width = 0
  for _, l in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(l))
  end
  for i, l in ipairs(lines) do
    lines[i] = l .. string.rep(" ", width - vim.fn.strdisplaywidth(l))
  end
  return table.concat(lines, "\n")
end

return {
  -- snacks: picker, explorer, terminal, lazygit, notifier, scratch, toggles, words ...
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      -- start screen (LazyVim's dashboard layout)
      dashboard = {
        enabled = true,
        width = 66, -- a bit wider than the default 60
        -- more breathing room between header, menu and footer
        sections = {
          { section = "header", padding = 3 },
          { section = "keys", gap = 2, padding = 3 }, -- gap = blank lines between menu items
          { section = "startup" },
        },
        preset = {
          -- always use the snacks picker (not Telescope), from the project root
          pick = function(cmd, opts)
            return Snacks.picker.pick(cmd, vim.tbl_extend("force", { cwd = root() }, opts or {}))
          end,
          -- old "NVCHAD" text header (swap it with the logo below to go back)
          -- header = block [[
          -- ███╗   ██╗██╗   ██╗ ██████╗██╗  ██╗ █████╗ ██████╗
          -- ████╗  ██║██║   ██║██╔════╝██║  ██║██╔══██╗██╔══██╗
          -- ██╔██╗ ██║██║   ██║██║     ███████║███████║██║  ██║
          -- ██║╚██╗██║╚██╗ ██╔╝██║     ██╔══██║██╔══██║██║  ██║
          -- ██║ ╚████║ ╚████╔╝ ╚██████╗██║  ██║██║  ██║██████╔╝
          -- ╚═╝  ╚═══╝  ╚═══╝   ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝]],
          -- NvChad logo (same as nvdash's default header)
          header = block [[
  ▄▄         ▄ ▄▄▄▄▄▄▄
▄▀███▄     ▄██ █████▀
██▄▀███▄   ███
███  ▀███▄ ███
███    ▀██ ███
███      ▀ ███
▀██ █████▄▀█▀▄██████▄
  ▀ ▀▀▀▀▀▀▀ ▀▀▀▀▀▀▀▀▀▀]],
          -- stylua: ignore
          keys = {
            { icon = "\u{f002} ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = "\u{f0fe} ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = "\u{f0f6} ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('grep')" },
            { icon = "\u{f1da} ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('recent')" },
            { icon = "\u{f013} ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', { cwd = vim.fn.stdpath('config') })" },
            { icon = "\u{f53f} ", key = "t", desc = "Themes", action = ":lua require('nvchad.themes').open()" },
            { icon = "\u{f021} ", key = "s", desc = "Restore Session", section = "session" },
            { icon = "\u{f08b} ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
      },
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      notifier = { enabled = true },
      words = { enabled = true },
      explorer = { enabled = true, replace_netrw = true },
      picker = {
        enabled = true,
        -- no dimmed backdrop behind the picker: it made everything darker than
        -- Ghostty's titlebar (which follows the theme bg, see lua/autocmds.lua)
        layout = { layout = { backdrop = false } },
        -- your old snacks.lua: show hidden + gitignored files
        sources = {
          explorer = { hidden = true, ignored = true },
          files = { hidden = true, ignored = true },
        },
      },
      terminal = {
        win = {
          keys = {
            nav_h = { "<C-h>", term_nav "h", desc = "Go to Left Window", expr = true, mode = "t" },
            nav_j = { "<C-j>", term_nav "j", desc = "Go to Lower Window", expr = true, mode = "t" },
            nav_k = { "<C-k>", term_nav "k", desc = "Go to Upper Window", expr = true, mode = "t" },
            nav_l = { "<C-l>", term_nav "l", desc = "Go to Right Window", expr = true, mode = "t" },
            hide_slash = { "<C-/>", "hide", desc = "Hide Terminal", mode = "t" },
            hide_underscore = { "<c-_>", "hide", desc = "which_key_ignore", mode = "t" },
          },
        },
      },
    },
    -- stylua: ignore
    keys = {
      -- top level
      { "<leader><space>", function() Snacks.picker.files({ cwd = root() }) end, desc = "Find Files (Root Dir)" },
      { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>/", function() Snacks.picker.grep({ cwd = root() }) end, desc = "Grep (Root Dir)" },
      { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
      { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
      { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
      { "<leader>.", function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
      { "<leader>S", function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
      { "<leader>dps", function() Snacks.profiler.scratch() end, desc = "Profiler Scratch Buffer" },
      -- explorer
      { "<leader>fe", function() Snacks.explorer({ cwd = root() }) end, desc = "Explorer Snacks (root dir)" },
      { "<leader>fE", function() Snacks.explorer() end, desc = "Explorer Snacks (cwd)" },
      { "<leader>e", "<leader>fe", desc = "Explorer Snacks (root dir)", remap = true },
      { "<leader>E", "<leader>fE", desc = "Explorer Snacks (cwd)", remap = true },
      -- find
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>fB", function() Snacks.picker.buffers({ hidden = true, nofile = true }) end, desc = "Buffers (all)" },
      { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
      { "<leader>ff", function() Snacks.picker.files({ cwd = root() }) end, desc = "Find Files (Root Dir)" },
      { "<leader>fF", function() Snacks.picker.files() end, desc = "Find Files (cwd)" },
      { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Files (git-files)" },
      { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent" },
      { "<leader>fR", function() Snacks.picker.recent({ filter = { cwd = true } }) end, desc = "Recent (cwd)" },
      { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },
      { "<leader>ft", function() Snacks.terminal(nil, { cwd = root() }) end, desc = "Terminal (Root Dir)" },
      { "<leader>fT", function() Snacks.terminal() end, desc = "Terminal (cwd)" },
      { "<c-/>", function() Snacks.terminal.focus(nil, { cwd = root() }) end, desc = "Terminal (Root Dir)", mode = { "n", "t" } },
      { "<c-_>", function() Snacks.terminal.focus(nil, { cwd = root() }) end, desc = "which_key_ignore", mode = { "n", "t" } },
      -- git
      { "<leader>gg", function() Snacks.lazygit({ cwd = git_root() }) end, desc = "Lazygit (Root Dir)" },
      { "<leader>gG", function() Snacks.lazygit() end, desc = "Lazygit (cwd)" },
      { "<leader>gL", function() Snacks.picker.git_log() end, desc = "Git Log (cwd)" },
      { "<leader>gl", function() Snacks.picker.git_log({ cwd = git_root() }) end, desc = "Git Log" },
      { "<leader>gb", function() Snacks.picker.git_log_line() end, desc = "Git Blame Line" },
      { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Current File History" },
      { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse (open)", mode = { "n", "x" } },
      { "<leader>gY", function() Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false }) end, desc = "Git Browse (copy)", mode = { "n", "x" } },
      { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (hunks)" },
      { "<leader>gD", function() Snacks.picker.git_diff({ base = "origin", group = true }) end, desc = "Git Diff (origin)" },
      { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
      { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
      { "<leader>gi", function() Snacks.picker.gh_issue() end, desc = "GitHub Issues (open)" },
      { "<leader>gI", function() Snacks.picker.gh_issue({ state = "all" }) end, desc = "GitHub Issues (all)" },
      { "<leader>gp", function() Snacks.picker.gh_pr() end, desc = "GitHub Pull Requests (open)" },
      { "<leader>gP", function() Snacks.picker.gh_pr({ state = "all" }) end, desc = "GitHub Pull Requests (all)" },
      -- search
      { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
      { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
      { "<leader>sg", function() Snacks.picker.grep({ cwd = root() }) end, desc = "Grep (Root Dir)" },
      { "<leader>sG", function() Snacks.picker.grep() end, desc = "Grep (cwd)" },
      { "<leader>sp", function() Snacks.picker.lazy() end, desc = "Search for Plugin Spec" },
      { "<leader>sw", function() Snacks.picker.grep_word({ cwd = root() }) end, desc = "Visual selection or word (Root Dir)", mode = { "n", "x" } },
      { "<leader>sW", function() Snacks.picker.grep_word() end, desc = "Visual selection or word (cwd)", mode = { "n", "x" } },
      { '<leader>s"', function() Snacks.picker.registers() end, desc = "Registers" },
      { "<leader>s/", function() Snacks.picker.search_history() end, desc = "Search History" },
      { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
      { "<leader>sc", function() Snacks.picker.command_history() end, desc = "Command History" },
      { "<leader>sC", function() Snacks.picker.commands() end, desc = "Commands" },
      { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
      { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
      { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
      { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights" },
      { "<leader>si", function() Snacks.picker.icons() end, desc = "Icons" },
      { "<leader>sj", function() Snacks.picker.jumps() end, desc = "Jumps" },
      { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
      { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location List" },
      { "<leader>sM", function() Snacks.picker.man() end, desc = "Man Pages" },
      { "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },
      { "<leader>sR", function() Snacks.picker.resume() end, desc = "Resume" },
      { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
      { "<leader>su", function() Snacks.picker.undo() end, desc = "Undotree" },
      -- NvChad themes instead of colorschemes (base46 themes are what NvChad uses)
      { "<leader>uC", function() require("nvchad.themes").open() end, desc = "Colorschemes (NvChad themes)" },
      { "<leader>th", function() require("nvchad.themes").open() end, desc = "Themes (NvChad default key)" },
    },
  },

  -- flash: s / S / r / R / <c-space>
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
      { "<c-space>", mode = { "n", "o", "x" }, function()
          require("flash").treesitter({ actions = { ["<c-space>"] = "next", ["<BS>"] = "prev" } })
        end, desc = "Treesitter Incremental Selection" },
    },
  },

  -- trouble: <leader>x...
  {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    opts = { modes = { lsp = { win = { position = "right" } } } },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>cs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
      { "<leader>cS", "<cmd>Trouble lsp toggle<cr>", desc = "LSP references/definitions/... (Trouble)" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
      {
        "[q",
        function()
          if require("trouble").is_open() then
            require("trouble").prev { skip_groups = true, jump = true }
          else
            local ok, err = pcall(vim.cmd.cprev)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end,
        desc = "Previous Trouble/Quickfix Item",
      },
      {
        "]q",
        function()
          if require("trouble").is_open() then
            require("trouble").next { skip_groups = true, jump = true }
          else
            local ok, err = pcall(vim.cmd.cnext)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end,
        desc = "Next Trouble/Quickfix Item",
      },
    },
  },

  -- todo-comments: ]t [t <leader>xt <leader>st
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble" },
    event = "User FilePost",
    opts = {},
    -- stylua: ignore
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next Todo Comment" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous Todo Comment" },
      { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todo (Trouble)" },
      { "<leader>xT", "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
      { "<leader>st", function() Snacks.picker.todo_comments() end, desc = "Todo" },
      { "<leader>sT", function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "Todo/Fix/Fixme" },
    },
  },

  -- grug-far: <leader>sr search & replace
  {
    "MagicDuck/grug-far.nvim",
    cmd = { "GrugFar", "GrugFarWithin" },
    opts = { headerMaxWidth = 80 },
    keys = {
      {
        "<leader>sr",
        function()
          local ext = vim.bo.buftype == "" and vim.fn.expand "%:e"
          require("grug-far").open {
            transient = true,
            prefills = { filesFilter = ext and ext ~= "" and "*." .. ext or nil },
          }
        end,
        mode = { "n", "x" },
        desc = "Search and Replace",
      },
    },
  },

  -- persistence: <leader>q sessions (picks up your old LazyVim sessions too)
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    -- stylua: ignore
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
      { "<leader>qS", function() require("persistence").select() end, desc = "Select Session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
    },
  },

  -- which-key: LazyVim layout + groups
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      opts = opts or {}
      opts.preset = "helix"
      opts.spec = {
        {
          mode = { "n", "x" },
          { "<leader><tab>", group = "tabs" },
          { "<leader>c", group = "code" },
          { "<leader>d", group = "debug" },
          { "<leader>dp", group = "profiler" },
          { "<leader>f", group = "file/find" },
          { "<leader>g", group = "git" },
          { "<leader>gh", group = "hunks" },
          { "<leader>q", group = "quit/session" },
          { "<leader>s", group = "search" },
          { "<leader>u", group = "ui" },
          { "<leader>x", group = "diagnostics/quickfix" },
          { "[", group = "prev" },
          { "]", group = "next" },
          { "g", group = "goto" },
          { "z", group = "fold" },
          {
            "<leader>b",
            group = "buffer",
            expand = function()
              return require("which-key.extras").expand.buf()
            end,
          },
          {
            "<leader>w",
            group = "windows",
            proxy = "<c-w>",
            expand = function()
              return require("which-key.extras").expand.win()
            end,
          },
          { "gx", desc = "Open with system app" },
        },
      }
      return opts
    end,
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show { global = false }
        end,
        desc = "Buffer Keymaps (which-key)",
      },
      {
        "<c-w><space>",
        function()
          require("which-key").show { keys = "<c-w>", loop = true }
        end,
        desc = "Window Hydra Mode (which-key)",
      },
    },
  },

  -- gitsigns: LazyVim hunk keys
  {
    "lewis6991/gitsigns.nvim",
    opts = function(_, opts)
      opts = opts or {}
      opts.on_attach = function(buffer)
        local gs = package.loaded.gitsigns
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc, silent = true })
        end
        -- stylua: ignore start
        map("n", "]h", function()
          if vim.wo.diff then vim.cmd.normal({ "]c", bang = true }) else gs.nav_hunk("next") end
        end, "Next Hunk")
        map("n", "[h", function()
          if vim.wo.diff then vim.cmd.normal({ "[c", bang = true }) else gs.nav_hunk("prev") end
        end, "Prev Hunk")
        map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
        map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
        map({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
        map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>ghB", function() gs.blame() end, "Blame Buffer")
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
        -- stylua: ignore end
      end
      return opts
    end,
  },

  -- completion: LazyVim (blink "enter" preset) keys instead of NvChad's
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require "cmp"
      local select = { behavior = cmp.SelectBehavior.Select }
      opts.mapping = {
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm { select = true },
        ["<C-n>"] = cmp.mapping.select_next_item(select),
        ["<C-p>"] = cmp.mapping.select_prev_item(select),
        ["<Down>"] = cmp.mapping.select_next_item(select),
        ["<Up>"] = cmp.mapping.select_prev_item(select),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        -- Tab / S-Tab: jump through snippet placeholders (not cycle the menu)
        ["<Tab>"] = cmp.mapping(function(fallback)
          local ls = require "luasnip"
          if ls.locally_jumpable(1) then
            ls.jump(1)
          else
            fallback()
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
          local ls = require "luasnip"
          if ls.locally_jumpable(-1) then
            ls.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }
      return opts
    end,
  },
}
