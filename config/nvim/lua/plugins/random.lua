-- local log = require("plenary.log")

-- local function mcp_servers_config()
--   local root = vim.fn.expand("~/.config/mcphub")
--   return vim.loop.fs_stat(root .. "/servers-local.json") and root .. "/servers-local.json" or root .. "/servers.json"
-- end
--
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
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "nvim-neotest/neotest-python",
    },
    opts = {
      adapters = {
        ["neotest-python"] = {
          -- Here you can specify the settings for the adapter, i.e.
          -- runner = "pytest",
          -- python = ".venv/bin/python",
          -- No idea why this is not default and so hard to figure out
          dap = { justMyCode = false },
        },
      },
    },
  },
  -- TODO: Remove the following once the fix is in Lazyvim https://github.com/LazyVim/LazyVim/pull/5876
  -- { "PaterJason/nvim-treesitter-sexp", enabled = false },
  {
    "Olical/nfnl",
    ft = "fennel",
  },
  {
    "folke/sidekick.nvim",
    opts = {
      -- add any options here
      cli = {
        mux = {
          backend = "zellij",
          enabled = true,
        },
      },
    },
    keys = {
      {
        "<tab>",
        function()
          -- if there is a next edit, jump to it, otherwise apply it if any
          if not require("sidekick").nes_jump_or_apply() then
            return "<Tab>" -- fallback to normal tab
          end
        end,
        expr = true,
        desc = "Goto/Apply Next Edit Suggestion",
      },
      {
        "<c-.>",
        function()
          require("sidekick.cli").focus()
        end,
        mode = { "n", "x", "i", "t" },
        desc = "Sidekick Switch Focus",
      },
      {
        "<leader>aa",
        function()
          require("sidekick.cli").toggle({ focus = true })
        end,
        desc = "Sidekick Toggle CLI",
        mode = { "n", "v" },
      },
      {
        "<leader>ac",
        function()
          require("sidekick.cli").toggle({ name = "claude", focus = true })
        end,
        desc = "Sidekick Claude Toggle",
        mode = { "n", "v" },
      },
      {
        "<leader>ag",
        function()
          require("sidekick.cli").toggle({ name = "grok", focus = true })
        end,
        desc = "Sidekick Grok Toggle",
        mode = { "n", "v" },
      },
      {
        "<leader>ap",
        function()
          require("sidekick.cli").select_prompt()
        end,
        desc = "Sidekick Ask Prompt",
        mode = { "n", "v" },
      },
    },
  },
  {
    "olimorris/codecompanion.nvim",
    opts = {
      opts = {
        log_level = "TRACE", -- TRACE|DEBUG|ERROR|INFO
      },
      adapters = {
        -- opts = {
        --   allow_insecure = true,
        --   proxy = "http://localhost:3128",
        -- },
        -- copilot = function()
        --   return require("codecompanion.adapters").extend("copilot", {
        --     schema = {
        --       model = {
        --         -- "gpt-4o", "o1", "claude-3.5-sonnet", "gemini-2.5-pro", "claude-3.7-sonnet", "o4-mini", "gpt-4.1", "o3-mini", "claude-3.7-sonnet-thought", "gemini-2.0-flash-001",
        --         default = "claude-3.7-sonnet",
        --       },
        --     },
        --   })
        -- end,
      },
      strategies = {
        --[[
        inline = {
          adapter = "gemini",
        },
        cmd = {
          adapter = "gemini",
        },
        ]]
        --
        chat = {
          -- adapter = "gemini",
          tools = {
            opts = {
              default_tools = {
                "full_stack_dev",
              },
            },
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
            -- auto_submit_success = true, -- Send any successful output to the LLM automatically?
            ]]
            --
          },
          --
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
      extensions = {
        mcphub = {
          callback = "mcphub.extensions.codecompanion",
          opts = {
            make_vars = true,
            make_slash_commands = true,
            show_result_in_chat = true,
          },
        },
        --[[
        vectorcode = {
          opts = {
            add_tool = true,
          },
        },
        ]]
        --
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
            picker = "snacks",
            ---Enable detailed logging for history extension
            enable_logging = false,
            ---Directory path to save the chats
            dir_to_save = vim.fn.stdpath("data") .. "/codecompanion-history",
          },
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "ravitemer/mcphub.nvim",
      "ravitemer/codecompanion-history.nvim",
    },
  },
  {
    "Davidyz/VectorCode",
    version = "*", -- optional, depending on whether you're on nightly or release
    build = "uv tool install --upgrade vectorcode --index https://download.pytorch.org/whl/cpu --index-strategy unsafe-best-match", -- pipx upgrade fails when it is not installed already
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
    opts = {
      config = vim.fn.expand("~/.config/mcphub/servers.json"),
    },
    -- },
    --[[
    config = function(opts)
      -- vim.print(vim.inspect(opts))
      -- require("mcphub").setup(vim.tbl_extend("force", opts, mcp_opts))
      -- Detault goes to notifications and is very noisy
      --[[
      opts.log = {
        -- (vim.log.levels.ERROR, WARN, INFO, DEBUG, TRACE)
        level = vim.log.levels.WARN,
        -- to_file = false,
        -- file_path = nil,
        -- prefix = "MCPHub",
      }
      require("mcphub").setup(vim.tbl_extend("force", opts, {
        config = mcp_servers_config(),
      }))
    end,
    ]]
    --
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
      "nvim-mini/mini.pick", -- for file_selector provider mini.pick
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
    "mason-org/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "clojure-lsp", -- TODO: Still not covered by Clojure Extra?
      })
    end,
  },
  {
    "m4xshen/hardtime.nvim",
    lazy = false,
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {},
  },
  { "nvim-mini/mini.test", version = false },
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
  },
  {
    "neoclide/coc.nvim",
    branch = "release",
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
  },
  {
    "sphamba/smear-cursor.nvim",
    opts = {},
  },
  --[[
  {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    event = {
      --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
      "BufReadPre "
        .. vim.fn.expand("~")
        .. "/work/projects/contentreich/contentreich-incubator/docs/*.md",
      "BufNewFile " .. vim.fn.expand("~") .. "/work/projects/contentreich/contentreich-incubator/docs/*.md",
      --   -- refer to `:h file-pattern` for more examples
      --   "BufReadPre path/to/my-vault/*.md",
      --   "BufNewFile path/to/my-vault/*.md",
    },
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
  },
  ]]
  --
}
