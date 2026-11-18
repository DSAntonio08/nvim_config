-- PlatformIO: :PIO commands + automatic compile_commands.json for clangd completions
return {
  "sbatin/platformio.nvim",
  lazy = false, -- NvChad lazy-loads by default; LazyVim loaded this at startup
  dependencies = { "numToStr/FTerm.nvim" },
  config = function()
    local group = vim.api.nvim_create_augroup("PioCompileDb", { clear = true })
    local running = {}

    -- find the PlatformIO project root (dir containing platformio.ini) for a buffer
    local function pio_root(buf)
      return vim.fs.root(buf, "platformio.ini")
    end

    -- run `pio run -t compiledb` in the background, then restart clangd
    local function compiledb(root, reason)
      if running[root] or vim.fn.executable("pio") == 0 then
        return
      end
      running[root] = true
      vim.notify("PlatformIO: generating compile_commands.json (" .. reason .. ")", vim.log.levels.INFO)
      vim.system({ "pio", "run", "-t", "compiledb" }, { cwd = root, text = true }, function(res)
        running[root] = nil
        vim.schedule(function()
          if res.code ~= 0 then
            vim.notify("PlatformIO compiledb failed:\n" .. (res.stderr or res.stdout or ""), vim.log.levels.ERROR)
            return
          end
          vim.notify("PlatformIO: compile_commands.json ready", vim.log.levels.INFO)
          if #vim.lsp.get_clients({ name = "clangd" }) > 0 then
            vim.cmd("lsp restart clangd")
          end
        end)
      end)
    end

    vim.api.nvim_create_user_command("PioCompileDb", function()
      local root = pio_root(0)
      if not root then
        return vim.notify("No platformio.ini found", vim.log.levels.WARN)
      end
      compiledb(root, "manual")
    end, { desc = "Regenerate compile_commands.json for clangd" })

    -- first time opening a C/C++ file in a PIO project without a compile db -> generate it
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      pattern = { "c", "cpp" },
      callback = function(ev)
        local root = pio_root(ev.buf)
        if root and not vim.uv.fs_stat(root .. "/compile_commands.json") then
          compiledb(root, "missing")
        end
      end,
    })

    -- platformio.ini changed (new lib_deps, board, build_flags ...) -> regenerate
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = group,
      pattern = "platformio.ini",
      callback = function(ev)
        compiledb(vim.fs.dirname(vim.api.nvim_buf_get_name(ev.buf)), "platformio.ini changed")
      end,
    })
  end,
}
