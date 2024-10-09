-- Format files on save (jsx)
vim.api.nvim_create_autocmd(
    "BufWritePost",
    {
        pattern = "*.jsx",
        callback = function()
            vim.fn.system("pnpm format " .. vim.fn.expand('%'))
            vim.cmd("edit")
        end,
    }
)
