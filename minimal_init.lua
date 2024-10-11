-- minimal_init.lua
vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- Basic setup of lsp-zero
local lsp = require('lsp-zero')

lsp.preset('recommended')

-- Ensure basic LSP servers are installed
lsp.ensure_installed({'lua_ls'})

-- Apply settings and configure servers
lsp.setup()

-- Enable diagnostics
vim.diagnostic.config({
  virtual_text = true,
})
