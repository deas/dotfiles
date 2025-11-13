-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- https://github.com/folke/snacks.nvim/blob/main/docs/debug.md

-- Hide the HUD log popup that is otherwise shown when Conjure connects to the REPL process
vim.g["conjure#log#hud#enabled"] = false

_G.dd = function(...)
  Snacks.debug.inspect(...)
end
_G.bt = function()
  Snacks.debug.backtrace()
end
-- if vim.fn.has("nvim-0.11") == 1 then
--   vim._print = function(_, ...)
--     dd(...)
--   end
-- else
--   vim.print = dd
-- end

local status, osv = pcall(require, "osv")
if not status then
  vim.notify("Warning: Failed to load osv module", vim.log.levels.WARN)
else
  _G.osv_launch = function()
    osv.launch({ port = 8086 })
  end
end
