-- LazyVim keymaps (NvChad's default mappings are intentionally NOT loaded).
-- Plugin keymaps (pickers, explorer, terminal, git, flash, trouble ...) are in lua/plugins/lazyvim.lua.
-- Your own extras: Alt+Shift+F = format (lua/plugins/init.lua), <leader>rn = LSP rename.

local map = vim.keymap.set
local tabufline = function()
  return require "nvchad.tabufline"
end

-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Move to window using the <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Move Lines
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- buffers (follow the order of NvChad's tab bar)
map("n", "<S-h>", function() tabufline().prev() end, { desc = "Prev Buffer" })
map("n", "<S-l>", function() tabufline().next() end, { desc = "Next Buffer" })
map("n", "[b", function() tabufline().prev() end, { desc = "Prev Buffer" })
map("n", "]b", function() tabufline().next() end, { desc = "Next Buffer" })
map("n", "[B", function() tabufline().move_buf(-1) end, { desc = "Move buffer prev" })
map("n", "]B", function() tabufline().move_buf(1) end, { desc = "Move buffer next" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>bd", function() Snacks.bufdelete() end, { desc = "Delete Buffer" })
map("n", "<leader>bo", function() Snacks.bufdelete.other() end, { desc = "Delete Other Buffers" })
map("n", "<leader>bi", function() Snacks.bufdelete.invisible() end, { desc = "Delete Invisible Buffers" })
map("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })
map("n", "<leader>br", function() tabufline().closeBufs_at_direction "right" end, { desc = "Delete Buffers to the Right" })
map("n", "<leader>bl", function() tabufline().closeBufs_at_direction "left" end, { desc = "Delete Buffers to the Left" })

-- Clear search and stop snippet on escape
map({ "i", "n", "s" }, "<esc>", function()
  vim.cmd "noh"
  local ls = package.loaded.luasnip
  if ls and ls.get_active_snip and ls.get_active_snip() then
    vim.schedule(ls.unlink_current)
  end
  return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

-- Clear search, diff update and redraw
map("n", "<leader>ur", "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>", { desc = "Redraw / Clear hlsearch / Diff Update" })

-- saner n / N
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- save file
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

-- keywordprg
map("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })

-- better indenting
map("x", "<", "<gv")
map("x", ">", ">gv")

-- commenting
map("n", "gco", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
map("n", "gcO", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })

-- lazy
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- new file
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })

-- location / quickfix list
map("n", "<leader>xl", function()
  local ok, err = pcall(vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 and vim.cmd.lclose or vim.cmd.lopen)
  if not ok and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Location List" })
map("n", "<leader>xq", function()
  local ok, err = pcall(vim.fn.getqflist({ winid = 0 }).winid ~= 0 and vim.cmd.cclose or vim.cmd.copen)
  if not ok and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end, { desc = "Quickfix List" })
-- ([q / ]q are in lua/plugins/lazyvim.lua, they also step through Trouble)

-- diagnostics
local function diagnostic_goto(next, severity)
  return function()
    vim.diagnostic.jump {
      count = (next and 1 or -1) * vim.v.count1,
      severity = severity and vim.diagnostic.severity[severity] or nil,
      float = true,
    }
  end
end
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
map("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

-- stylua: ignore start

-- toggle options (<leader>u...)
Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
Snacks.toggle.diagnostics():map("<leader>ud")
Snacks.toggle.line_number():map("<leader>ul")
Snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "Conceal Level" }):map("<leader>uc")
Snacks.toggle.option("showtabline", { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = "Tabline" }):map("<leader>uA")
Snacks.toggle.treesitter():map("<leader>uT")
Snacks.toggle.dim():map("<leader>uD")
Snacks.toggle.profiler():map("<leader>dpp")
Snacks.toggle.profiler_highlights():map("<leader>dph")
Snacks.toggle.inlay_hints():map("<leader>uh")
-- dark/light: NvChad themes ignore 'background', so toggle tokyonight <-> one_light instead
map("n", "<leader>ub", function() require("base46").toggle_theme() end, { desc = "Toggle Dark/Light Theme" })
-- indent guides: NvChad uses indent-blankline instead of snacks.indent
Snacks.toggle({
  name = "Indent Guides",
  get = function() return require("ibl.config").get_config(-1).enabled end,
  set = function(state) vim.cmd(state and "IBLEnable" or "IBLDisable") end,
}):map("<leader>ug")
Snacks.toggle({
  name = "Git Signs",
  get = function() return require("gitsigns.config").config.signcolumn end,
  set = function(state) require("gitsigns").toggle_signs(state) end,
}):map("<leader>uG")

-- quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

-- highlights under cursor
map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
map("n", "<leader>uI", function() vim.treesitter.inspect_tree() vim.api.nvim_input("I") end, { desc = "Inspect Tree" })

-- windows
map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete Window", remap = true })
Snacks.toggle.zoom():map("<leader>wm"):map("<leader>uZ")
Snacks.toggle.zen():map("<leader>uz")

-- tabs
map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
map("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- lua: run current file / selection
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function(ev)
    map({ "n", "x" }, "<localleader>r", function() Snacks.debug.run() end, { buffer = ev.buf, desc = "Run Lua" })
  end,
})

-- LSP keymaps (buffer-local, set when a server attaches) -- same as LazyVim w/ snacks picker
local function lsp_keys(buf, client)
  local function m(mode, lhs, rhs, desc, opts)
    vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { buffer = buf, desc = desc, silent = true }, opts or {}))
  end
  local function has(method) return client:supports_method(method) end

  m("n", "<leader>cl", function() Snacks.picker.lsp_config() end, "Lsp Info")
  m("n", "gd", function() Snacks.picker.lsp_definitions() end, "Goto Definition")
  m("n", "gr", function() Snacks.picker.lsp_references() end, "References", { nowait = true })
  m("n", "gI", function() Snacks.picker.lsp_implementations() end, "Goto Implementation")
  m("n", "gy", function() Snacks.picker.lsp_type_definitions() end, "Goto T[y]pe Definition")
  m("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
  m("n", "K", function() return vim.lsp.buf.hover() end, "Hover")
  m("n", "gK", function() return vim.lsp.buf.signature_help() end, "Signature Help")
  m("i", "<c-k>", function() return vim.lsp.buf.signature_help() end, "Signature Help")
  m({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
  m("n", "<leader>cA", function()
    vim.lsp.buf.code_action { apply = true, context = { only = { "source" }, diagnostics = {} } }
  end, "Source Action")
  m("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
  m("n", "<leader>rn", vim.lsp.buf.rename, "Rename") -- yours
  m("n", "<leader>cR", function() Snacks.rename.rename_file() end, "Rename File")
  if has "textDocument/codeLens" then
    m({ "n", "x" }, "<leader>cc", vim.lsp.codelens.run, "Run Codelens")
    m("n", "<leader>cC", vim.lsp.codelens.refresh, "Refresh & Display Codelens")
  end
  m("n", "<leader>ss", function() Snacks.picker.lsp_symbols() end, "LSP Symbols")
  m("n", "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, "LSP Workspace Symbols")
  if has "callHierarchy/incomingCalls" then
    m("n", "gai", function() Snacks.picker.lsp_incoming_calls() end, "C[a]lls Incoming")
    m("n", "gao", function() Snacks.picker.lsp_outgoing_calls() end, "C[a]lls Outgoing")
  end
  if has "textDocument/documentHighlight" then
    m("n", "]]", function() Snacks.words.jump(vim.v.count1) end, "Next Reference")
    m("n", "[[", function() Snacks.words.jump(-vim.v.count1) end, "Prev Reference")
    m("n", "<a-n>", function() Snacks.words.jump(vim.v.count1, true) end, "Next Reference")
    m("n", "<a-p>", function() Snacks.words.jump(-vim.v.count1, true) end, "Prev Reference")
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("LazyVimLspKeys", { clear = true }),
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client then lsp_keys(ev.buf, client) end
  end,
})
-- mappings.lua runs deferred, so also cover servers that attached before it loaded
for _, client in ipairs(vim.lsp.get_clients()) do
  for buf in pairs(client.attached_buffers) do
    lsp_keys(buf, client)
  end
end
-- stylua: ignore end
