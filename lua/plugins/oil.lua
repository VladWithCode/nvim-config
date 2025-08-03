return {
    'stevearc/oil.nvim',
    opts = {
        default_file_explorer = true,
        columns = { 'icon' },
        -- use_default_keymaps = false,
        view_options = { show_hidden = true },
    },
    -- dependencies = { { 'echasnovski/mini.icons' } },
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    lazy = false,
}

-- TODO: find how the fuck do i set keybinds for Oil
-- { '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' } },
-- { 
--     '<CR>', 
--     function() require('oil.actions').select() end,
--     { desc = 'Select file (Oil)' }
-- },
-- { 
--     '<C-c>', 
--     function() require('oil.actions').close() end,
--     { desc = 'Close file explorer (Oil)' }
-- },
-- {
--     '<C-l>',
--     function() require('oil.actions').refresh() end,
--     { desc = 'Refresh file explorer (Oil)' }
-- },
-- { 
--     '`', 
--     function() require('oil.actions').cd() end,
--     { desc = 'Change cwd to match file explorer\'s' }
-- },
-- { 
--     '~',
--     function() require('oil.actions').cd({ scope = 'tab' }) end,
--     { desc = 'Change cwd to match file explorer\'s in a new tab' }
-- },
--
