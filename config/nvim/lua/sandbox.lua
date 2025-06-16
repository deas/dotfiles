local M = {}

-- M.config = { }

function M.vault_get(entry_path)
  return vim.fn.system({ "vlt.clj", "get", entry_path })
  -- return vim.fn.system({ "kwalletcli", "-e", entry, "-f", folder })
end

return M
