-- every spec file under the "plugins" directory will be loaded automatically by lazy.nvim
--
-- In your plugin files, you can:
-- * add extra plugins
-- * disable/enabled LazyVim plugins
-- * override the configuration of LazyVim plugins
--
-- See example.lua for more examples

-- Alternative lua debug adapter
-- https://tamerlan.dev/a-guide-to-debugging-applications-in-neovim/
--[[ 
local dap = require("dap")
-- Adapters
dap.adapters["local-lua"] = {
  type = "executable",
  command = "node",
  args = {
    "/home/deas/work/projects/3rd-party/local-lua-debugger-vscode/extension/debugAdapter.js",
  },
  enrich_config = function(config, on_config)
    if not config["extensionPath"] then
      local c = vim.deepcopy(config)
      -- 💀 If this is missing or wrong you'll see
      -- "module 'lldebugger' not found" errors in the dap-repl when trying to launch a debug session
      c.extensionPath = "/home/deas/work/projects/3rd-party/local-lua-debugger-vscode"
      on_config(c)
    else
      on_config(config)
    end
  end,
}

-- Configurations
dap.configurations = {
  lua = {
    {
      name = "Current file (local-lua-dbg, lua)",
      type = "local-lua",
      repl_lang = "lua",
      request = "launch",
      cwd = "${workspaceFolder}",
      program = {
        lua = "luajit",
        file = "${file}",
      },
      args = {},
    },
    {
      name = "Current file (local-lua-dbg, neovim lua interpreter with nlua)",
      type = "local-lua",
      repl_lang = "lua",
      request = "launch",
      cwd = "${workspaceFolder}",
      program = {
        lua = "nlua",
        file = "${file}",
      },
      args = {},
    },
  },
}
--]]
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
      opts.model = "claude-3.7-sonnet"
      --[[
      opts.prompts = {
        CustomPrompt = {
          prompt = "Explain how it works.",
          system_prompt = "You are very good at explaining stuff",
          -- mapping = "<leader>ccmc",
          description = "My custom prompt description",
        },
      }--]]
      opts.debug = true
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
