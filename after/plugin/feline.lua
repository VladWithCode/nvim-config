local feline = require('feline')
local vi_mode = require('feline.providers.vi_mode')
local file = require('feline.providers.file')

local baseSep = function(fg, bg, str)
    fg = fg or 'none'
    bg = bg or 'none'
    str = str or ' '
    return {
        always_visible = true,
        str = ' ',
        hl = { fg = fg, bg = bg },
    }
end

local sep_arrow_right = function(next_bg)
    next_bg = next_bg or 'none'
    return {
        provider = '',
        hl = { fg = 'none', bg = 'none' },
        right_sep = {
            always_visible = true,
            str = 'right_filled',
            hl = { fg = 'bg', bg = next_bg }
        }
    }
end

local sep_slant = function(next_bg, lr, v)
    next_bg = next_bg or 'none'
    lr = lr or 'left'
    v = v or ''
    return {
        provider = '',
        hl = { fg = 'none', bg = 'none' },
        right_sep = {
            always_visible = true,
            str = function ()
                return string.format('slant_%s%s', lr, v)
            end,
            hl = { fg = 'bg', bg = next_bg }
        }
    }
end

local c = {
    -- left
    vim_mode = {
        provider = function()
            return string.format('%s', vi_mode.get_vim_mode())
        end,
        hl = function()
            local fg = vi_mode.get_mode_color()
            if vi_mode.get_vim_mode() == 'INSERT' then
                fg = 'purple'
            end
            return { fg = fg, bg = 'blue' }
        end,
        left_sep = baseSep('none', 'blue'),
        right_sep = {
            always_visible = true,
            str = 'right_filled',
            hl = { bg = 'bg', fg = 'blue' }
        },
    },

    file_name = {
        provider = {
            name = 'file_info',
            opts = {
                colored_icon = false,
                type = 'relative',
            },
        },
        hl = { fg = 'blue', bg = 'cyan' },
        left_sep = {
            str = 'right_filled',
            always_visible = true,
            hl = { fg = 'cyan', bg = 'cyan' }
        },
        right_sep = {
            str = 'right_filled',
            always_visible = true,
            hl = { fg = 'cyan', bg = 'bg' }
        },
    },

    git_branch = {
        provider = function()
            local git = require('feline.providers.git')
            local branch, icon = git.git_branch()
            local s
            if #branch > 0 then
                s = string.format('%s%s', icon, branch)
            else
                s = 'Untracked'
            end
            return s
        end,
        hl = { fg = 'white', bg = 'red' },
        left_sep = {
            always_visible = true,
            str = 'left_rounded',
            hl = { fg = 'red', bg = 'bg' }
        },
        right_sep = {
            always_visible = true,
            str = 'right_filled',
            hl = { fg = 'red', bg = 'bg' }
        }
    },

    -- right
    macro = {
        provider = function ()
            local s
            local recording_register = vim.fn.reg_recording()
            if #recording_register == 0 then
                s = ''
            else
                s = string.format('Recording @%s', recording_register)
            end
            return s
        end,
        hl = { fg = 'purple' },
    },

    search_count = {
        provider = 'search_count',
        hl = { fg = 'white' },
    },

    cursor_position = {
        provider = {
            name = 'position',
            opts = { padding = true },
        },
        hl = { fg = 'yellow', bg = 'blue' },
        left_sep = {
            always_visible = true,
            str = 'slant_left',
            hl = { fg = "blue" }
        },
        right_sep = {
            always_visible = true,
            str = 'slant_right_2',
            hl = { fg = "blue" }
        },
    },

    scroll_bar = {
        provider = {
            name = 'scroll_bar',
            opts = { reverse = true },
        },
        hl = { fg = 'green', bg = 'bg' },
    },

    -- Utility
    transparent = {
        provider = '',
        hl = { fg = 'none', bg = 'none' }
    },
}

local active = {
    { -- left
        c.vim_mode,
        sep_arrow_right('cyan'),
        c.file_name,
        { provider = ' ', hl = { fg = 'none' } },
        c.git_branch,
    },
    { -- right
        c.macro,
        c.search_count,
        c.cursor_position,
        c.scroll_bar,
    }
}

local inactive = {
    {},
    {
        provider = function ()
            if vim.api.nvim_buf_get_name(0) == '' then
                return file.file_info({}, { colored_icon = false })
            else
                return file.file_type(
                    {},
                    { colored_icon = false, case = 'lowercase' }
                )
            end
        end,
    }
}

local theme = {
    black = '#001626',
    blue = '#003052',
    red = '#FF4E52',
    green = '#9ECC6E',
    yellow = '#E4D093',
    lightblue = '#80ACF8',
    purple = '#C993E4',
    cyan = '#78DBCB',
    white = '#EBF7FF',
    bg = '#001626',
    fg = '#EBF7FF',
}

local sep = {
    right_chev = '❰',
    left_chev = '❱',
}

local opts = {
    components = {
        active = active,
        inactive = inactive,
    },
    separators = sep,
}

feline.setup(opts)
feline.use_theme(theme)
