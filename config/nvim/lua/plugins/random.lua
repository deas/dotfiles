local log = require("plenary.log")
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
--
-- Launch debug server: require('osv').launch({port = 8086})
--
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
    "Olical/nfnl",
    ft = "fennel",
  },
  {
    -- copilot-chat extra spec overrides
    -- https://github.com/CopilotC-Nvim/CopilotChat.nvim/discussions/420
    -- https://github.com/CopilotC-Nvim/CopilotChat.nvim/blob/main/lua/CopilotChat/config.lua
    "CopilotC-Nvim/CopilotChat.nvim",
    opts = function(_, opts)
      -- opts.model = "claude-3.7-sonnet"
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
    "olimorris/codecompanion.nvim",
    opts = {},
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
  {
    "ravitemer/mcphub.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim", -- Required for Job and HTTP requests
    },
    -- comment the following line to ensure hub will be ready at the earliest
    cmd = "MCPHub", -- lazy load by default
    build = "npm install -g mcp-hub@latest", -- Installs required mcp-hub npm module
    -- uncomment this if you don't want mcp-hub to be available globally or can't use -g
    -- build = "bundled_build.lua",  -- Use this and set use_bundled_binary = true in opts  (see Advanced configuration)
    config = function()
      require("mcphub").setup({
        -- foo and bar or baz -> lua if expression
        config = vim.fn.getenv("HOME") and vim.fn.expand("~/.config/mcphub/servers.json"), -- We may want this host specific, overriding the default
        on_ready = function(hub)
          local async = require("plenary.async")
          local call_tool = async.wrap(function(server, tool, input, callback)
            hub:call_tool(server, tool, input, {
              callback = function(response)
                callback(response)
              end,
            })
          end, 4)

          local tools = hub:get_tools()
          local status, copilot_chat = pcall(require, "CopilotChat")

          if not status then
            -- Module couldn't be loaded
            vim.notify("Couldn't load module_name: " .. copilot_chat, vim.log.levels.WARN)
            -- my_module now contains the error message
            return -- or provide fallback functionality
          end
          local chat = copilot_chat.chat
          for _, tool in ipairs(tools) do
            vim.print("Tool name: " .. tool.name)
            -- log.debug("Tool name: " .. tool.name)
            --[[
            chat.config.tools[tool.name] = {
              description = tool.description,
              schema = tool.inputSchema,
              resolve = function(input, source)
                local out = call_tool(tool.server, tool.name, input)
                vim.print(out)
                return {}
              end,
            }
            ]]
            --
          end
        end,
      })
    end,
  },
  {
    -- avante.nvim is a Neovim plugin designed to emulate the behaviour of the Cursor
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    opts = {
      -- add any opts here
      -- for example
      provider = "openai",
      openai = {
        endpoint = "https://api.openai.com/v1",
        model = "gpt-4o", -- your desired model (or use gpt-4o, etc.)
        timeout = 30000, -- Timeout in milliseconds, increase this for reasoning models
        temperature = 0,
        max_completion_tokens = 8192, -- Increase this to include reasoning tokens (for reasoning models)
        --reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "echasnovski/mini.pick", -- for file_selector provider mini.pick
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        ["clojure"] = { "cljfmt" },
      },
    },
  },
  --  TODO: Workaround for https://github.com/LazyVim/LazyVim/issues/5899
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    opts = function()
      require("copilot.api").status = require("copilot.status") -- TODO: Smart override
    end,
    --[[
      event = "VeryLazy",
      opts = function(_, opts)
        table.insert(
          opts.sections.lualine_x,
          2,
          LazyVim.lualine.status(LazyVim.config.icons.kinds.Copilot, function()
            local clients = package.loaded["copilot"] and LazyVim.lsp.get_clients({ name = "copilot", bufnr = 0 }) or {}
            if #clients > 0 then
              local status = require("copilot.status").data.status -- TODO: Actual fix
              return (status == "InProgress" and "pending") or (status == "Warning" and "error") or "ok"
            end
          end)
        )
      end,
      ]]
    --
  },
}
