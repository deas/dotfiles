-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- vim.opt.relativenumber = false

-- Remote-plugin providers for languages nothing in this config uses. These are
-- the legacy `:perl`/`:ruby`/rpc-host mechanism, NOT the LSP/DAP toolchains —
-- disabling them costs no functionality, skips an interpreter probe at startup,
-- and clears three permanent `:checkhealth` warnings on a machine that has no
-- perl-with-Neovim::Ext, no ruby and no `neovim` npm package.
-- The python3 provider is deliberately left alone.
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
