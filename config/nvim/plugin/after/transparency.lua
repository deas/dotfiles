--- Modifies the background of an existing highlight group to be transparent ('NONE').
--- Preserves its foreground, style, and links.
--- @param group_name string The name of the highlight group (e.g., "Normal")
local function make_hl_transparent(group_name)
  -- Mapping from nvim_get_hl_by_name keys to nvim_set_hl keys
  local key_map = {
    foreground = "fg",
    background = "bg", -- We will explicitly set this to NONE later
    cterm_fg = "ctermfg",
    cterm_bg = "ctermbg", -- We will explicitly set this to NONE later
    bold = "bold",
    italic = "italic",
    underline = "underline",
  }

  -- 1. Retrieve the existing highlight group definition (following links)
  -- local hl_def = vim.api.nvim_get_hl_by_name(group_name, true)
  local hl_def = vim.api.nvim_get_hl(0, { name = group_name })

  -- 2. Create the new options table and copy attributes
  local updated_opts = {}
  for key, value in pairs(hl_def) do
    local new_key = key_map[key]

    if new_key then
      if new_key == "fg" then
        -- Convert decimal color (foreground) back to Hex string
        updated_opts[new_key] = string.format("#%06x", value)
      elseif new_key == "bg" or new_key == "ctermbg" then
        -- SKIP the existing background; we will explicitly set it to none
      else
        -- Copy CTerm and style values directly
        updated_opts[new_key] = value
      end
    end
  end

  -- 3. Overwrite only the background keys to none (transparent)
  updated_opts.bg = "none"
  updated_opts.ctermbg = "none"

  -- 4. Register the new object (the modified table)
  vim.api.nvim_set_hl(0, group_name, updated_opts)
end

local groups_to_update = {
  "Normal",
  "NormalFloat",
  "FloatBorder",
  "Pmenu",
  "Terminal",
  "EndOfBuffer",
  "FoldColumn",
  "Folded",
  "SignColumn",
  "NormalNC",
  "TelescopeBorder",
  "TelescopePromptBorder",

  -- transparent background for neotree
  "NeoTreeNormal",
  "NeoTreeNormalNC",
  "NeoTreeVertSplit",
  "NeoTreeWinSeparator",
  "NeoTreeEndOfBuffer",

  -- transparent background for nvim-tree
  "NvimTreeNormal",
  "NvimTreeVertSplit",
}

-- Make existing groups transparent
for _, group_name in ipairs(groups_to_update) do
  make_hl_transparent(group_name)
end

-- Create additional transparent highlight groups
vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })
vim.api.nvim_set_hl(0, "TelescopePromptTitle", { bg = "none" })

vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = "none" })

-- transparent notify background
vim.api.nvim_set_hl(0, "NotifyINFOBody", { bg = "none" })
vim.api.nvim_set_hl(0, "NotifyERRORBody", { bg = "none" })
vim.api.nvim_set_hl(0, "NotifyWARNBody", { bg = "none" })
vim.api.nvim_set_hl(0, "NotifyTRACEBody", { bg = "none" })
vim.api.nvim_set_hl(0, "NotifyDEBUGBody", { bg = "none" })
vim.api.nvim_set_hl(0, "NotifyINFOTitle", { bg = "none" })
vim.api.nvim_set_hl(0, "NotifyERRORTitle", { bg = "none" })
vim.api.nvim_set_hl(0, "NotifyWARNTitle", { bg = "none" })
vim.api.nvim_set_hl(0, "NotifyTRACETitle", { bg = "none" })
vim.api.nvim_set_hl(0, "NotifyDEBUGTitle", { bg = "none" })
vim.api.nvim_set_hl(0, "NotifyINFOBorder", { bg = "none" })
vim.api.nvim_set_hl(0, "NotifyERRORBorder", { bg = "none" })
vim.api.nvim_set_hl(0, "NotifyWARNBorder", { bg = "none" })
vim.api.nvim_set_hl(0, "NotifyTRACEBorder", { bg = "none" })
vim.api.nvim_set_hl(0, "NotifyDEBUGBorder", { bg = "none" })
