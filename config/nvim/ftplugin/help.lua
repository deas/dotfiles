-- Map 'gd' to 'Ctrl-]' only in the current help buffer
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "help",
--   callback = function()
--     vim.keymap.set("n", "gd", "<C-]>", { buffer = true, remap = false })
--   end,
-- })

-- Using the ftplugin ("goto definition" for help files)
vim.keymap.set("n", "gd", "<C-]>", { buffer = true })
