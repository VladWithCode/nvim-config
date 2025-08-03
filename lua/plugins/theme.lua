return {
    { 
        'rose-pine/neovim',
        as = 'rose-pine',
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd([[colorscheme rose-pine]])
        end,
    },
    { 'akinsho/horizon.nvim', version = '*' },
    { 'folke/tokyonight.nvim' },
    { 'catppuccin/nvim' },
    { 'vague2k/vague.nvim' },
}
