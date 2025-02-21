-- copilot-chat extra spec overrides
-- https://github.com/CopilotC-Nvim/CopilotChat.nvim/discussions/420
return {
  "CopilotC-Nvim/CopilotChat.nvim",
  opts = function(_, opts)
    opts.model = "claude-3.5-sonnet"
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
}
