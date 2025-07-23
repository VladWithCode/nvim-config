local harpoon = require("harpoon")

-- REQUIRED
harpoon:setup()
-- REQUIRED

vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

vim.keymap.set("n", "<M-a>", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<M-w>", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<M-e>", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<M-d>", function() harpoon:list():select(4) end)

vim.keymap.set("n", "<C-M-q>", function() harpoon:list():prev() end)
vim.keymap.set("n", "<C-M-e>", function() harpoon:list():next() end)

