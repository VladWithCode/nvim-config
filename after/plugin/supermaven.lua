local sm = require('supermaven-nvim.api')
local cmp_prev = require('supermaven-nvim.completion_preview')

require('supermaven-nvim').setup({
    keymaps = {
        accept_suggestion = "<M-y>",
        clear_suggestion = "<M-]>",
        accept_word = "<M-l>",
    }
})

vim.keymap.set("n", "<leader><M-s>", sm.toggle)
vim.keymap.set("i", "<F18>y", function() cmp_prev.on_accept_suggestion(false) end)
