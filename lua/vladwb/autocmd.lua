-- Format files on save (jsx)
--[[ vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.jsx",
    callback = function()
        vim.fn.system("bun format " .. vim.fn.expand('%'))
        vim.cmd("edit")
    end,
}) ]]
