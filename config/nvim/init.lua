-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
-- https://neovim.io/doc/user/nvim.html#nvim-from-vim

-- Set the runtimepath
-- vim.o.runtimepath = vim.o.runtimepath .. ",~/.vim,~/.vim/after"

-- Set packpath to the same as runtimepath
-- vim.o.packpath = vim.o.runtimepath

-- Source the .vimrc file
-- vim.cmd("source ~/.vimrc")

-- Hide the HUD log popup that is otherwise shown when Conjure connects to the REPL process
vim.g["conjure#log#hud#enabled"] = false
