local log = require("plenary.log")

local function mcp_servers_config()
  local root = vim.fn.expand("~/.config/mcphub")
  return vim.loop.fs_stat(root .. "/servers-local.json") and root .. "/servers-local.json" or root .. "/servers.json"
end

--[[
local function update_chat(hub, chat)
  -- local mcp = require("mcphub")
  local async = require("plenary.async")
  local call_tool = async.wrap(function(server, tool, input, callback)
    hub:call_tool(server, tool, input, {
      callback = function(res, err)
        callback(res, err)
      end,
    })
  end, 4)

  local access_resource = async.wrap(function(server, uri, callback)
    hub:access_resource(server, uri, {
      callback = function(res, err)
        callback(res, err)
      end,
    })
  end, 3)

  local resources = hub:get_resources()
  for _, resource in ipairs(resources) do
    local name = resource.name:lower():gsub(" ", "_"):gsub(":", "")
    chat.config.functions[name] = {
      uri = resource.uri,
      description = type(resource.description) == "string" and resource.description or "",
      resolve = function()
        local res, err = access_resource(resource.server_name, resource.uri)
        if err then
          error(err)
        end

        res = res or {}
        local result = res.result or {}
        local content = result.contents or {}
        local out = {}

        for _, message in ipairs(content) do
          if message.text then
            table.insert(out, {
              uri = message.uri,
              data = message.text,
              mimetype = message.mimeType,
            })
          end
        end

        return out
      end,
    }
  end

  local tools = hub:get_tools()
  for _, tool in ipairs(tools) do
    -- vim.print("Tool name: " .. tool.name)
    chat.config.functions[tool.name] = {
      group = tool.server_name,
      description = tool.description,
      schema = tool.inputSchema,
      resolve = function(input)
        local res, err = call_tool(tool.server_name, tool.name, input)
        if err then
          error(err)
        end

        res = res or {}
        local result = res.result or {}
        local content = result.content or {}
        local out = {}

        for _, message in ipairs(content) do
          if message.type == "text" then
            table.insert(out, {
              data = message.text,
            })
          elseif message.type == "resource" and message.resource and message.resource.text then
            table.insert(out, {
              uri = message.resource.uri,
              data = message.resource.text,
              mimetype = message.resource.mimeType,
            })
          end
        end

        return out
      end,
    }
  end
end

local mcp_opts = {
  -- foo and bar or baz -> lua if expression
  config = mcp_servers_config(), -- This is the default location for the config file - which appears to be ignored
  -- config = vim.fn.getenv("HOME") and vim.fn.expand("~/.config/mcphub/servers-local.json"), -- We may want this host specific, overriding the default
  -- TODO:
  on_ready = function(hub)
    local status, chat = pcall(require, "CopilotChat")

    if not status then
      vim.notify("Couldn't load module_name: " .. chat, vim.log.levels.WARN)
      -- my_module now contains the error message
      return -- or provide fallback functionality
    end
    update_chat(hub, chat)
  end,
}

local function update_mcp(mcp, chat)
  return function()
    local hub = mcp.get_hub_instance()
    if not hub then
      return
    end
    update_chat(hub, chat)
  end
end
]]
--

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
  -- TODO: Remove the following once the fix is in Lazyvim https://github.com/LazyVim/LazyVim/pull/5876
  { "PaterJason/nvim-treesitter-sexp", enabled = false },
  {
    "Olical/nfnl",
    ft = "fennel",
  },
  --[[
  {
    -- copilot-chat extra spec overrides
    -- https://github.com/CopilotC-Nvim/CopilotChat.nvim/discussions/420
    -- https://github.com/CopilotC-Nvim/CopilotChat.nvim/blob/main/lua/CopilotChat/config.lua
    "CopilotC-Nvim/CopilotChat.nvim",
    config = function(opts)
      local chat = require("CopilotChat")
      chat.setup(opts)

      local status, mcp = pcall(require, "mcphub")

      if not status then
        vim.notify("Couldn't load module_name: " .. mcp, vim.log.levels.WARN)
        -- my_module now contains the error message
        return -- or provide fallback functionality
      end
      -- mcp.setup(mcp_opts) -- TODO beware - setup returns immediately - mcp_opts effectively ignored
      -- TODO: Sould fire mcp on_ready as well. Otherwise we won't see things when MCPHub comes up first
      -- https://github.com/CopilotC-Nvim/CopilotChat.nvim/pull/1029#issuecomment-2782794141
      mcp.on({ "servers_updated", "tool_list_changed", "resource_list_changed" }, update_mcp(mcp, chat))
    end,
    opts = function(_, opts)
      -- opts.model = "claude-3.7-sonnet"
      --opts.prompts = {
      --  CustomPrompt = {
      --    prompt = "Explain how it works.",
      --    system_prompt = "You are very good at explaining stuff",
      --    -- mapping = "<leader>ccmc",
      --    description = "My custom prompt description",
      --  },
      --}
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
      -- TODO: Should probably add functions like this: https://github.com/ravitemer/mcphub.nvim/wiki/CodeCompanion
      opts.functions = {
        birthday = {
          description = "Retrieves birthday information for a person",
          schema = {
            type = "object",
            required = { "name" },
            properties = {
              name = {
                type = "string",
                enum = { "Alice", "Bob", "Charlie" },
                description = "Person's name",
              },
            },
          },
          resolve = function(input)
            return {
              {
                type = "text",
                data = input.name .. " birthday info",
              },
            }
          end,
        },
      }
      return opts
    end,
    -- Add or override keymaps
    -- keys = {
    -- your custom keymaps
    -- },
  },
  ]]
  --
  {
    "olimorris/codecompanion.nvim",
    opts = {
      --[[
      adapters = {
        copilot = function()
          return require("codecompanion.adapters").extend("copilot", {
            schema = {
              model = {
                -- "gpt-4o", "o1", "claude-3.5-sonnet", "gemini-2.5-pro", "claude-3.7-sonnet", "o4-mini", "gpt-4.1", "o3-mini", "claude-3.7-sonnet-thought", "gemini-2.0-flash-001",
                default = "claude-3.7-sonnet",
              },
            },
          })
        end,
      },
      -- ]]
      strategies = {
        chat = {
          tools = {
            -- Breaking Changes since codecompanion v15
            -- Remove old mcp tool which will be auto added as a tool group with two individual tools.
            --[[
            ["mcp"] = {
              -- Prevent mcphub from loading before needed
              callback = function()
                return require("mcphub.extensions.codecompanion")
              end,
              description = "Call tools and resources from the MCP Servers",
            },
            ]]
            --
            -- auto_submit_success = true, -- Send any successful output to the LLM automatically?
          },
        },
      },
      --[[
      display = {
        chat = {
          show_settings = true,
        },
        diff = {
          provider = "mini_diff", -- TODO: Workaround for https://github.com/olimorris/codecompanion.nvim/pull/1368
        },
      },
      --]]
      --
      --[[
      strategies = {
        -- Change the default chat adapter
        chat = {
          adapter = "anthropic",
        },
      },
      ]]
      --
      extensions = {
        mcphub = {
          callback = "mcphub.extensions.codecompanion",
          opts = {
            make_vars = true,
            make_slash_commands = true,
            show_result_in_chat = true,
          },
          history = {
            enabled = true,
            opts = {
              -- Keymap to open history from chat buffer (default: gh)
              keymap = "gh",
              -- Automatically generate titles for new chats
              auto_generate_title = true,
              ---On exiting and entering neovim, loads the last chat on opening chat
              continue_last_chat = false,
              ---When chat is cleared with `gx` delete the chat from history
              delete_on_clearing_chat = false,
              -- Picker interface ("telescope", "snacks" or "default")
              picker = "telescope",
              ---Enable detailed logging for history extension
              enable_logging = false,
              ---Directory path to save the chats
              dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
            },
          },
        },
        --[[vectorcode = {
          opts = {
            add_tool = true,
          },
        },]]
        --
      },
      opts = {
        log_level = "TRACE", -- TRACE|DEBUG|ERROR|INFO
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "ravitemer/codecompanion-history.nvim",
    },
  },
  {
    "Davidyz/VectorCode",
    version = "*", -- optional, depending on whether you're on nightly or release
    build = "uv tool install --upgrade vectorcode --index https://download.pytorch.org/whl/cpu", -- pipx upgrade fails when it is not installed already
    -- uv tool install vectorcode --index https://download.pytorch.org/whl/cpu
    -- build = "uv tool upgrade vectorcode", -- This helps keeping the CLI up-to-date
    -- PIP_INDEX_URL="https://download.pytorch.org/whl/cpu" PIP_EXTRA_INDEX_URL="https://pypi.org/simple" pipx install vectorcode
    -- build = "pipx upgrade vectorcode", -- optional but recommended. This keeps your CLI up-to-date.
    dependencies = { "nvim-lua/plenary.nvim" },
    enabled = false,
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
    -- opts = mcp_opts, -- Not what it appears to be - opts wont be mcp_opts in function config
    -- https://github.com/ravitemer/mcphub.nvim/discussions/110
    -- mcphub.config.extensions.codecompanion is deprecated as the options are now declared at codecompanion extension itself.
    --[[
    opts = {
      extensions = {
        codecompanion = {
          -- Show the mcp tool result in the chat buffer
          show_result_in_chat = true,
          -- Make chat #variables from MCP server resources
          make_vars = true,
          -- Create slash commands for prompts
          make_slash_commands = true,
        },
      },
    },
    ]]
    --
    config = function(opts)
      -- vim.print(vim.inspect(opts))
      -- require("mcphub").setup(vim.tbl_extend("force", opts, mcp_opts))
      require("mcphub").setup(vim.tbl_extend("force", opts, {
        config = mcp_servers_config(),
      }))
    end,
  },
  {
    "joshuavial/aider.nvim",
    opts = {
      -- your configuration comes here
      -- if you don't want to use the default settings
      auto_manage_context = true, -- automatically manage buffer context
      default_bindings = true, -- use default <leader>A keybindings
      debug = false, -- enable debug logging
    },
  },
  {
    -- avante.nvim is a Neovim plugin designed to emulate the behaviour of the Cursor
    "yetone/avante.nvim",
    enabled = false,
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
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions -- TODO : Should be blink
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
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "clojure-lsp", -- Not covered by Clojure Extra
      })
    end,
  },
  --[[
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clojure_lsp = {},
      },
    },
  },
  ]]
  --
  {
    "m4xshen/hardtime.nvim",
    lazy = false,
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {},
  },
  { "echasnovski/mini.test", version = false },
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
  {
    "neoclide/coc.nvim",
    breanch = "release",
  },
  "epwalsh/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = "markdown",
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
  --   -- refer to `:h file-pattern` for more examples
  --   "BufReadPre path/to/my-vault/*.md",
  --   "BufNewFile path/to/my-vault/*.md",
  -- },
  dependencies = {
    -- Required.
    "nvim-lua/plenary.nvim",

    -- see below for full list of optional dependencies 👇
  },
  opts = {
    workspaces = {
      {
        name = "personal",
        path = "~/vaults/personal",
      },
      {
        name = "work",
        path = "~/vaults/work",
      },
    },

    -- see below for full list of options 👇
  },
}
