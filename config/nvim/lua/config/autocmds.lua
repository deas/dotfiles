-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--
-- https://github.com/LazyVim/LazyVim/discussions/4748
vim.api.nvim_create_autocmd({ "TermOpen" }, {
  group = nativeTermGroup,
  pattern = "term://*",
  callback = function(event)
    local buf = event.buf
    vim.keymap.set("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to Left Window", buffer = buf, nowait = true })
    vim.keymap.set("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to Above Window", buffer = buf, nowait = true })
    -- "c-\\" does not play with german keyboard
    vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode", buffer = buf, nowait = true })
  end,
})
