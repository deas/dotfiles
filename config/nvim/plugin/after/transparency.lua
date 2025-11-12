--- Modifies the background of an existing highlight group to be transparent ('none').
--- Preserves its foreground, style, and links.
--- @param group_name string The name of the highlight group (e.g., "Normal")
local function create_hl_transparent(group_name)
  local hl_def = vim.api.nvim_get_hl(0, { name = group_name })
  local updated_opts = {
    bg = "none",
    ctermbg = "none",
  }

  for key, value in pairs(hl_def) do
    if key == "fg" then
      -- Convert decimal color (foreground) back to Hex string
      updated_opts[key] = string.format("#%06x", value)
    elseif key == "bg" or key == "ctermbg" then
      -- SKIP the existing background; we will explicitly set it to none
    else
      -- Copy CTerm and style values directly
      updated_opts[key] = value
    end
  end

  return updated_opts
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
  vim.api.nvim_set_hl(0, group_name, create_hl_transparent(group_name))
end

-- Create additional transparent highlights
vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "none" })
vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })
vim.api.nvim_set_hl(0, "TelescopePromptTitle", { bg = "none" })

vim.api.nvim_set_hl(0, "NvimTreeEndOfBuffer", { bg = "none" })

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
