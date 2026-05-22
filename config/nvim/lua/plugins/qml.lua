-- QML / Quickshell editing support.
-- Extends LazyVim's treesitter + lspconfig specs declaratively.
return {
  -- Treesitter: extend ensure_installed (LazyVim merges this list).
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "qmljs" } },
  },

  -- LSP: qmlls ships with Qt at /usr/lib/qt6/bin/qmlls and is not on $PATH,
  -- so override cmd with the full path. -E lets it also honor QML_IMPORT_PATH
  -- as a fallback to the per-module .qmlls.ini Quickshell manages.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        qmlls = {
          mason = false, -- qmlls comes from Qt, not Mason
          cmd = { "/usr/lib/qt6/bin/qmlls", "-E" },
        },
      },
    },
  },
}
