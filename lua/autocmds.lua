require "nvchad.autocmds"

-- match the terminal background to the theme's background, so Ghostty's
-- (transparent-style) titlebar and window padding blend into nvim instead of
-- showing as a lighter strip. OSC 11 sets the terminal bg, OSC 111 resets it.
local function term_send(seq)
  if vim.api.nvim_ui_send then
    vim.api.nvim_ui_send(seq)
  else
    io.stdout:write(seq)
  end
end

-- global Normal bg. Don't use `link = false` here: that resolves through the
-- hl namespace of the last drawn window, and while the theme picker is open
-- that's the picker's Normal (volt's black2, still from the previous theme
-- when NvThemeReload fires). That made the terminal bg lag one theme behind.
local function normal_bg()
  local hl = vim.api.nvim_get_hl(0, { name = "Normal" })
  for _ = 1, 10 do
    if not hl.link then break end
    hl = vim.api.nvim_get_hl(0, { name = hl.link })
  end
  return hl.bg
end

local function sync_term_bg()
  local bg = normal_bg()
  if bg then
    term_send(string.format("\027]11;#%06x\027\\", bg))
  end
end

local group = vim.api.nvim_create_augroup("SyncTermBg", { clear = true })
vim.api.nvim_create_autocmd({ "UIEnter", "ColorScheme" }, { group = group, callback = sync_term_bg })
-- base46 (NvChad themes / <leader>uC picker) fires this instead of ColorScheme
vim.api.nvim_create_autocmd("User", { group = group, pattern = "NvThemeReload", callback = sync_term_bg })
vim.api.nvim_create_autocmd({ "UILeave", "VimSuspend" }, {
  group = group,
  callback = function() term_send "\027]111\027\\" end,
})
vim.api.nvim_create_autocmd("VimResume", { group = group, callback = sync_term_bg })
