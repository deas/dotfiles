-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins
--
-- See example.lua for more examples
--
-- Hide the HUD log popup that is otherwise shown when Conjure connects to the REPL process
vim.g["conjure#log#hud#enabled"] = false

--[[ 
function _G.inspect_to_buffer(obj)
  local lines = vim.split(vim.inspect(obj), "\n")
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_command("vsplit")
  vim.api.nvim_win_set_buf(vim.api.nvim_get_current_win(), buf)
end
--]]

return {
  {
    -- copilot-chat extra spec overrides
    -- https://github.com/CopilotC-Nvim/CopilotChat.nvim/discussions/420
    -- https://github.com/CopilotC-Nvim/CopilotChat.nvim/blob/main/lua/CopilotChat/config.lua
    "CopilotC-Nvim/CopilotChat.nvim",
    opts = function(_, opts)
      opts.model = "claude-3.5-sonnet"
      -- level "info" does not appear to create CopilogChat.log
      -- opts.log_level = "trace"
      -- opts.debug = false -- Enable debug logging (same as 'log_level = 'debug')
      -- opts.log_level = "info" -- Log level to use, 'trace', 'debug', 'info', 'warn', 'error', 'fatal'
      -- Modify existing opts
      --opts.window = {
      -- your custom window settings
      -- }

      -- Or add new options
      -- opts.custom_option = "value"

      return opts
    end,
    -- Add or override keymaps
    -- keys = {
    -- your custom keymaps
    -- },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        ["clojure"] = { "cljfmt" },
      },
    },
  },
}
