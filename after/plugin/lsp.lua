local lsp_zero = require('lsp-zero')

lsp_zero.on_attach(function(client, bufnr)
    local opts = { buffer = bufnr, remap = false }

    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.get_next() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.get_prev() end, opts)
    vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>gr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)

    vim.keymap.set("n", "<S-M-f>", function() vim.lsp.buf.format() end, opts)
end)

require('mason').setup({})
require('mason-lspconfig').setup({
    ensure_installed = { 'ts_ls', 'lua_ls', 'eslint', 'rust_analyzer', 'gopls', 'clangd', 'templ', 'html' },
    handlers = {
        lsp_zero.default_setup,
        lua_ls = function()
            local lua_opts = lsp_zero.nvim_lua_ls()
            require('lspconfig').lua_ls.setup(lua_opts)
        end,
        emmet_language_server = function()
            require('lspconfig').emmet_language_server.setup({
                filetypes = { "templ", "html", "javascriptreact", "typescriptreact" },
                init_options = {
                    includeLanguages = {
                        templ = "html",
                    },
                }
            })
        end
    }
})

local cmp = require('cmp')
local cmp_select = { behavior = cmp.SelectBehavior.Select }

cmp.setup({
    sources = {
        { name = 'path' },
        { name = 'nvim_lsp' },
        { name = 'nvim_lua' },
        { name = 'luasnip',   keyword_length = 2 },
        { name = 'buffer',    keyword_length = 3 },
        { name = 'supermaven' }
    },
    formatting = lsp_zero.cmp_format(),
    mapping = cmp.mapping.preset.insert({
        ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
        ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
        ['<C-Space>'] = cmp.mapping.complete(),
    }),
})
-- Fixes snippets not loading for golang
require('lspconfig').gopls.setup({
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
    settings = {
        gopls = {
            completeUnimported = true,
            -- usePlaceholders = true,
            analyses = {
                unusedparams = true,
            },
            staticcheck = true,
        },
        tailwindcss = {
            includeLanguages = {
                "templ",
            },
            init_options = {
                user_languages = {
                    templ = "html",
                },
            },
        },
    }
})

local utils = require('lspconfig/util')
local configs = require('lspconfig/configs')

if not configs.c3_lsp then
    configs.c3_lsp = {
        default_config = {
            cmd = { '/home/vladwb/Software/c3lsp/server/bin/release/c3lsp' },
            filetypes = { 'c3', 'c3i', 'c3l' },
            root_dir = function(fname)
                return utils.find_git_ancestor(fname) or vim.loop.cwd()
            end,
            settings = {},
            name = 'c3_lsp',
        }
    }
end
require('lspconfig').c3_lsp.setup({
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
})
